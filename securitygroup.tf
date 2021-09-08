resource "aws_security_group" "allow-ping" {
  vpc_id      = module.vpc.vpc_id
  name        = "allow-icmp"
  description = "security group that allows icmp and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = -1
    to_port     = -1
    protocol    = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_security_group" "allow-https" {
  vpc_id      = module.vpc.vpc_id
  name        = "allow-https"
  description = "security group that allows https and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = [local.workstation-external-cidr]
  }
}
resource "aws_security_group" "allow-http" {
  vpc_id      = module.vpc.vpc_id
  name        = "allow-http"
  description = "security group that allows http and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = [local.workstation-external-cidr]
  }
}

resource "aws_security_group" "allow-http-alb" {
  vpc_id      = module.vpc.vpc_id
  name        = "allow-http-alb"
  description = "security group that allows http(s) from alb and all egress traffic"
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    security_groups = [aws_security_group.allow-https.id]
  }

  ingress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    security_groups = [aws_security_group.allow-https.id]
  }

}
