output "record_fqdn" {
  description = "Fully qualified DNS name that points at the ALB"
  value       = length(aws_route53_record.alb) > 0 ? aws_route53_record.alb[0].fqdn : ""
}
