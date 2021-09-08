#!/bin/bash
function wait_for_dpkg_lock {
  # check for a lock on dpkg (another installation is running)
  lsof /var/lib/dpkg/lock > /dev/null
  dpkg_is_locked="$?"
  if [ "$dpkg_is_locked" == "0" ]; then
    echo "Waiting for another installation to finish"
    sleep 5
    wait_for_dpkg_lock
  fi
}

function wait_for_dpkg_lock_frontend {
  # check for a lock on dpkg (another installation is running)
  lsof /var/lib/dpkg/lock-frontend > /dev/null
  dpkg_is_locked="$?"
  if [ "$dpkg_is_locked" == "0" ]; then
    echo "Waiting for another installation to finish"
    sleep 5
    wait_for_dpkg_lock
  fi
}

set -x 

vgchange -ay

DEVICE_FS=`blkid -o value -s TYPE ${DEVICE} || echo ""`
if [ "`echo -n $DEVICE_FS`" == "" ] ; then 
  # wait for the device to be attached
  DEVICENAME=`echo "${DEVICE}" | awk -F '/' '{print $3}'`
  DEVICEEXISTS=''
  while [[ -z $DEVICEEXISTS ]]; do
    echo "checking $DEVICENAME"
    DEVICEEXISTS=`lsblk |grep "$DEVICENAME" |wc -l`
    if [[ $DEVICEEXISTS != "1" ]]; then
      sleep 15
    fi
  done
  pvcreate ${DEVICE}
  vgcreate data ${DEVICE}
  lvcreate --name volume1 -l 100%FREE data
  mkfs.ext4 /dev/data/volume1
fi
mkdir -p ${MOUNT}
echo '/dev/data/volume1 ${MOUNT} ext4 defaults 0 0' >> /etc/fstab
mount ${MOUNT}


# install cloudwatch agent
wget https://s3.amazonaws.com/amazoncloudwatch-agent/ubuntu/amd64/latest/amazon-cloudwatch-agent.deb


wait_for_dpkg_lock
wait_for_dpkg_lock_frontend

echo "dpkg lock released, installing cloudwatch agent"
dpkg -i -E ./amazon-cloudwatch-agent.deb
# cloudwatch config file
cat << EOF > /opt/aws/amazon-cloudwatch-agent/bin/config.json
${CLOUDWATCH_CONFIG}
EOF
# start cloudwatch agent
/opt/aws/amazon-cloudwatch-agent/bin/amazon-cloudwatch-agent-ctl -a fetch-config -m ec2 -c file:/opt/aws/amazon-cloudwatch-agent/bin/config.json -s
