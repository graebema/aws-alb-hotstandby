#!/bin/bash

INSTANCE_ID="`wget -qO- http://instance-data/latest/meta-data/instance-id`"
cd /

cat << EOF > /index.html
httpd on ec2 with id:  $INSTANCE_ID
EOF

busybox httpd
