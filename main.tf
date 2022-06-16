variable subnet_ids            {}  # The AWS Subnet Id to place the lb into
variable resource_tags         {}  # AWS tags to apply to resources
variable vpc_id                {}  # The VPC Id
variable blacksmith_domain     {}  # url used for blacksmith domain
variable route53_zone_id       {}  # Route53 zone id
variable security_groups       {}  # Array of security groups to use
variable system_acm_arn        {}  # ACM arn for the system certificates

variable enable_route_53       { default = 1 }  # Disable if using CloudFlare or other DNS

################################################################################
# Blacksmith ALB
################################################################################
resource "aws_lb" "blacksmith_alb" {
  name               = "blacksmith-alb"
  internal           = true
  load_balancer_type = "application"
  subnets            = var.subnet_ids
  security_groups    = var.security_groups
  tags = merge(
    {Name = "blacksmith-alb"},
    {Environment = "blacksmith-alb" }, 
    var.resource_tags
    )
}

################################################################################
# Blacksmith ALB Target Group
################################################################################
resource "aws_lb_target_group" "blacksmith_alb_tg" {
  name     = "blacksmith-alb-tg"
  port     = 443
  protocol = "HTTPS"
  vpc_id   = var.vpc_id
  tags     = merge({Name = "blacksmith-alb-tg"}, var.resource_tags)
  health_check {
    path = "/"
    matcher = "401"
    protocol = "HTTPS"
  }
}

################################################################################
# Blacksmith ALB Target Group Attachment - Do this with vm_extension instead
################################################################################
# Define bs instances using instance group, can use instance_tags or filter
#data "aws_instances" "blacksmith_instances" {
#  instance_tags = {
#    instance_group = "blacksmith"
#  }
#}
#resource "aws_lb_target_group_attachment" "blacksmith_alb_tga" {
#  count            = length(data.aws_instances.blacksmith_instances.ids)
#  target_id        = data.aws_instances.blacksmith_instances.ids[count.index]
#  target_group_arn = aws_lb_target_group.blacksmith_alb_tg.arn
#  port             = 443
#}

################################################################################
# Blacksmith ALB Listeners - Blacksmith API - HTTPS
################################################################################
resource "aws_alb_listener" "blacksmith_alb_listener_443" {
  load_balancer_arn = aws_lb.blacksmith_alb.arn
  port = "443"
  protocol = "HTTPS"
  ssl_policy = "ELBSecurityPolicy-TLS-1-2-2017-01"
  certificate_arn = var.system_acm_arn
  default_action {
    type = "forward"
    target_group_arn = aws_lb_target_group.blacksmith_alb_tg.arn
  }
  tags = merge({Name = "blacksmith-alb-listener-443"}, var.resource_tags)
}
################################################################################
# Route53 Blacksmith CNAME Record
################################################################################
resource "aws_route53_record" "useast1_sz_np_bs_record" {

  count   = var.enable_route_53
  zone_id = var.route53_zone_id
  name = var.blacksmith_domain
  type = "CNAME"
  ttl = "60"
  records = ["${aws_lb.blacksmith_alb.dns_name}"]
}

output "dns_name" {value = aws_lb.blacksmith_alb.dns_name}