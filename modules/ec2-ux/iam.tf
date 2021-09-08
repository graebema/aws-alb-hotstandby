resource "aws_iam_role" "ec2-role" {
  name               = "ec2-role-${var.name}"
  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "ec2.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF

}

# instance profile which allows ssm, kms and cloudwatch log creation

resource "aws_iam_instance_profile" "ec2-role-instanceprofile" {
  name = "ec2-role-instanceprofile-${var.name}"
  role = aws_iam_role.ec2-role.name
}

resource "aws_iam_role_policy" "ec2-role-policy" {
  name   = "ec2-role-policy-${var.name}"
  role   = aws_iam_role.ec2-role.id
  policy = <<EOF
{
    "Version": "2012-10-17",
    "Statement": [
        {
            "Effect": "Allow",
            "Action": [
              "kms:Encrypt",
              "kms:Decrypt",
              "kms:ReEncrypt*",
              "kms:GenerateDataKey*",
              "kms:DescribeKey"
            ],
            "Resource": [
              "${var.ebs_kms_key_arn}"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
              "ec2:DescribeTags"
            ],
            "Resource": [
              "*"
            ]
        },
        {
            "Effect": "Allow",
            "Action": [
              "logs:CreateLogStream",
              "logs:DescribeLogStreams",
              "logs:CreateLogGroup",
              "logs:PutLogEvents"
            ],
            "Resource": [
              "*"
            ]
        }
    ]
}
EOF

}

resource "aws_iam_role_policy_attachment" "ec2-role-ssm-attach" {
  role       = aws_iam_role.ec2-role.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonSSMManagedInstanceCore"
}

## optional: additional policy attachment
resource "aws_iam_role_policy_attachment" "ec2-role-additional-policy_at" {
  count      = var.additional_policy_arn != null ? 1 : 0
  policy_arn = var.additional_policy_arn
  role       = aws_iam_role.ec2-role.name
}
