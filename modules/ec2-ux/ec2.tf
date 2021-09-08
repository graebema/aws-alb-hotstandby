data "aws_ami" "ubuntu" {
  most_recent = true

  filter {
    name   = "name"
    values = [var.ubuntu_version]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }

  owners = ["099720109477"] # Canonical
}

resource "aws_key_pair" "ec2keypair" {
  count      = var.path_to_ssh_public_key != null ? 1 : 0
  key_name   = "ec2keypair-${var.name}"
  public_key = file(var.path_to_ssh_public_key)
}

resource "aws_instance" "ec2" {
  ami                    = var.ami != null ? var.ami : data.aws_ami.ubuntu.id
  instance_type          = var.instance_type
  subnet_id              = var.subnet_id
  private_ip             = var.private_ip
  iam_instance_profile   = aws_iam_instance_profile.ec2-role-instanceprofile.name
  vpc_security_group_ids = var.securitygroups
  root_block_device {
    encrypted             = true
    delete_on_termination = var.delete_on_termination
    kms_key_id            = var.ebs_kms_key_arn
    volume_size           = var.root_volume_size
    tags = {
      Name   = "${var.name}-root-volume",
      Backup = "true"
    }
  }
  tags = merge(
    tomap({
      Name = var.name
    }),
    var.tags,
  )
  metadata_options {
    http_endpoint = var.metadata_enabled
  }
  # optional: the public SSH key
  key_name = var.path_to_ssh_public_key != null ? aws_key_pair.ec2keypair[0].key_name : null

  user_data = data.template_cloudinit_config.cloudinit-ec2.rendered
}

resource "aws_ebs_volume" "ebs-volume-1" {
  availability_zone = var.availability_zone
  size              = var.ebs_size
  type              = "gp2"
  encrypted         = true
  kms_key_id        = var.ebs_kms_key_arn
  tags = merge(
    tomap({
      Name   = "${var.name}-volume"
      Backup = "true"
    }),
    var.tags,
  )
}

resource "aws_volume_attachment" "ebs-volume-1-attachment" {
  device_name = var.instance_device_name
  volume_id   = aws_ebs_volume.ebs-volume-1.id
  instance_id = aws_instance.ec2.id
}


##### cloudinit #########
data "template_file" "init-script" {
  template = file("${path.module}/scripts/init.cfg")
  vars = {
    REGION = var.aws_region
  }
}

data "template_file" "shell-script" {
  template = file("${path.module}/scripts/volumes.sh")
  vars = {
    DEVICE            = var.ebs_device_name
    MOUNT             = var.ebs_mountpoint
    CLOUDWATCH_CONFIG = file(var.cloudwatch_config_file)
  }
}

## optional init script
data "template_file" "additional-shell-script" {
  count    = var.init_script != null ? 1 : 0
  template = file(var.init_script)
  vars     = var.init_script_vars
}

data "template_cloudinit_config" "cloudinit-ec2" {
  gzip          = false
  base64_encode = false

  part {
    filename     = "init.cfg"
    content_type = "text/cloud-config"
    content      = data.template_file.init-script.rendered
  }

  part {
    content_type = "text/x-shellscript"
    content      = data.template_file.shell-script.rendered
  }

  dynamic "part" {
    for_each = (var.init_script != null) ? [true] : []
    content {
      content_type = "text/x-shellscript"
      content      = data.template_file.additional-shell-script[0].rendered
    }
  }
}
