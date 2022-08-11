# terraform-module-blacksmith-lb
Terraform module to create the ALB for Blacksmith

Inputs - Required:

 - `resource_tags` - AWS tags to apply to resources
 - `vpc_id` - AWS VPC Id
 - `subnet_ids` - The AWS Subnet Id to place the lb into     
 - `blacksmith_domain` - url used for blacksmith domain
 - `route53_zone_id` - Route53 zone id
 - `security_groups` - Array of security groups to use on the lb
 - `system_acm_arn` - ACM arn for the system urls

Inputs - Optional: 

 - `enable_route_53` - Disable if using CloudFlare or other DNS (default = 1, to disable, set = 0)
 - `internal_lb` - Determine whether the load balancer is internal-only facing (default = true)
 
Outputs:

 - `dns_name` - The A Record for the created load balancer
 - `lb_name` - Name of the load balancer.  Map this value in your cloud config
 - `lb_target_group_name` - Name of the target group. Map this in your cloud config.
