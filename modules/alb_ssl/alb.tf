resource "aws_lb" "frontend" {
  depends_on                 = [aws_s3_bucket.log-bucket]
  enable_deletion_protection = false
  enable_http2               = true
  idle_timeout               = 60
  internal                   = var.internal
  ip_address_type            = "ipv4"
  load_balancer_type         = "application"
  name                       = var.alb_name
  security_groups            = var.alb_securitygroup_ids
  subnets                    = var.alb_subnet_ids

  access_logs {
    bucket  = aws_s3_bucket.log-bucket.id
    enabled = true
  }
  tags = var.tags
}

#### listener
resource "aws_lb_listener" "front80" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 80
  protocol          = "HTTP"

  default_action {
    type = "redirect"

    redirect {
      host        = "#{host}"
      path        = "/#{path}"
      port        = "443"
      protocol    = "HTTPS"
      query       = "#{query}"
      status_code = "HTTP_301"
    }
  }

  timeouts {}
}

resource "aws_lb_listener" "front443" {
  load_balancer_arn = aws_lb.frontend.arn
  port              = 443
  protocol          = "HTTPS"
  ssl_policy        = "ELBSecurityPolicy-2016-08"
  certificate_arn   = var.alb_cert_arn
  default_action {
    order            = 1
    target_group_arn = var.alb_targetgroup_arn
    type             = "forward"
  }

}

//resource "aws_lb_listener_rule" "redirect_http_to_https" {
//  listener_arn = aws_lb_listener.front80.arn
//  priority     = 1
//
//  action {
//    order = 1
//    type  = "redirect"
//
//    redirect {
//      host        = "#{host}"
//      path        = "/#{path}"
//      port        = "443"
//      protocol    = "HTTPS"
//      query       = "#{query}"
//      status_code = "HTTP_301"
//    }
//  }
//  condition {
//    path_pattern {
//      values = ["/*"]
//    }
//  }
//}

//resource "aws_lb_listener_rule" "redirect_to_backend" {
//  listener_arn = aws_lb_listener.front443.arn
//  priority     = 1
//
//  //  action {
//  //    order = 1
//  //    type  = "authenticate-cognito"
//  //
//  //    authenticate_cognito {
//  //      authentication_request_extra_params = {}
//  //      on_unauthenticated_request          = "authenticate"
//  //      scope                               = "openid"
//  //      session_cookie_name                 = "AWSELBAuthSessionCookie"
//  //      session_timeout                     = 604800
//  //      user_pool_arn                       = aws_cognito_user_pool.adfs-pool.arn
//  //      user_pool_client_id                 = aws_cognito_user_pool_client.app-client.id
//  //      user_pool_domain                    = aws_cognito_user_pool_domain.user-pool-domain.domain
//  //
//  //    }
//  //  }
//
//  action {
//    order            = 1
//    target_group_arn = var.alb_targetgroup_arn
//    type             = "forward"
//  }
//
//  condition {
//    path_pattern {
//      values = ["/"]
//    }
//  }
//
//}

## certificate for alb
resource "aws_lb_listener_certificate" "alb-cert" {
  listener_arn    = aws_lb_listener.front443.arn
  certificate_arn = var.alb_cert_arn
}


## caller
data "aws_caller_identity" "current" {}
## region
data "aws_region" "current" {}


## log bucket policy allow access from aws lb account, which is different per region
## alb_name needs to be converted to lowercase!
resource "aws_s3_bucket" "log-bucket" {
  bucket = "alb-log-${data.aws_caller_identity.current.account_id}-${lower(var.alb_name)}"
  versioning {
    enabled = true
  }
  server_side_encryption_configuration {
    rule {
      apply_server_side_encryption_by_default {
        sse_algorithm = "AES256"
      }
    }
  }
}

resource "aws_s3_bucket_policy" "log-bucket" {
  bucket = aws_s3_bucket.log-bucket.id

  policy = <<POLICY
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {
        "AWS": "arn:aws:iam::${var.aws_alb_accounts[data.aws_region.current.name]}:root"
      },
      "Action": "s3:PutObject",
      "Resource": "arn:aws:s3:::${aws_s3_bucket.log-bucket.id}/*"
    },
    {
      "Sid": "AllowSSLRequestsOnly",
      "Action": "s3:*",
      "Effect": "Deny",
      "Resource": [
        "arn:aws:s3:::${aws_s3_bucket.log-bucket.id}",
        "arn:aws:s3:::${aws_s3_bucket.log-bucket.id}/*"
      ],
      "Condition": {
        "Bool": {
          "aws:SecureTransport": "false"
        }
      },
      "Principal": "*"
    }
  ]
}
POLICY
}
