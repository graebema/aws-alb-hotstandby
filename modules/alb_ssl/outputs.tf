output "alb_arn" { value = aws_lb.frontend.arn }
output "alb_dns_name" { value = aws_lb.frontend.dns_name }
output "alb_zone_id" { value = aws_lb.frontend.zone_id }
output "listener_443_arn" { value = aws_lb_listener.front443.arn }
