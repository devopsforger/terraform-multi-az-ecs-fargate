variable "cloudfront_origin_access_controls" {
  description = "CloudFront Origin Access Controls"
  type = map(object({
    name                              = string
    description                       = string
    origin_access_control_origin_type = string
    signing_behavior                  = string
    signing_protocol                  = string
  }))
}

variable "cloudfront_distributions" {
  type = map(object({
    comment             = string
    enabled             = bool
    default_root_object = string
    price_class         = string
    default_origin_key  = string

    # Origins — fully configurable via type + key
    origins = map(object({
      origin_id                 = string
      origin_type               = string # e.g. "s3", "alb", "custom"
      key                       = string # e.g. bucket key, alb key, or literal domain
      origin_path               = optional(string, null)
      origin_access_control_key = optional(string, null) # for S3 OAC
    }))

    allowed_methods        = list(string)
    cached_methods         = list(string)
    viewer_protocol_policy = string
    compress               = bool
    min_ttl                = number
    default_ttl            = number
    max_ttl                = number

    cache_policy_id            = optional(string) # AWS managed ID or custom
    origin_request_policy_id   = optional(string)
    response_headers_policy_id = optional(string)

    # Viewer certificate (optional)
    viewer_certificate = optional(object({
      cloudfront_default_certificate = optional(bool, true)
      acm_certificate_key            = optional(string)
      minimum_protocol_version       = optional(string, "TLSv1.2_2021")
      ssl_support_method             = optional(string, "sni-only")
    }), {})

    tags = map(string)
  }))
  default = {}
}

module "cloudfront_origin_access_control" {
  for_each = var.cloudfront_origin_access_controls

  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/cloudfront_origin_access_control"

  name                              = each.value.name
  description                       = each.value.description
  origin_access_control_origin_type = each.value.origin_access_control_origin_type
  signing_behavior                  = each.value.signing_behavior
  signing_protocol                  = each.value.signing_protocol
}

locals {
  # Build the origin map dynamically based on type + key from tfvars
  resolved_origins = {
    for dist_key, dist in var.cloudfront_distributions : dist_key => {
      for origin_key, origin in dist.origins : origin_key => {
        domain_name = origin.origin_type == "s3" ? module.s3_bucket[origin.key].bucket_regional_domain_name : origin.origin_type == "alb" ? module.alb[origin.key].dns_name : origin.origin_type == "custom" ? origin.key : null # literal domain name : null   # error case — can add validation later

        origin_id                = origin.origin_id
        origin_path              = origin.origin_path
        origin_access_control_id = origin.origin_type == "s3" && lookup(origin, "oac_key", null) != null ? module.cloudfront_origin_access_control[origin.oac_key].id : null
      }
    }
  }
}


module "cloudfront_distribution" {
  for_each = var.cloudfront_distributions

  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/cloudfront_distribution"

  enabled             = each.value.enabled
  comment             = each.value.comment
  default_root_object = each.value.default_root_object
  price_class         = each.value.price_class
  is_ipv6_enabled     = true

  origin = local.resolved_origins[each.key]

  viewer_certificate = each.value.viewer_certificate != {} ? {
    cloudfront_default_certificate = each.value.viewer_certificate.cloudfront_default_certificate
    acm_certificate_arn            = each.value.viewer_certificate.acm_certificate_key != null ? module.acm_certificate[each.value.viewer_certificate.acm_certificate_key].arn : null
    minimum_protocol_version       = each.value.viewer_certificate.minimum_protocol_version
    ssl_support_method             = each.value.viewer_certificate.ssl_support_method
  } : null

  default_cache_behavior = {
    allowed_methods        = each.value.allowed_methods
    cached_methods         = each.value.cached_methods
    target_origin_id       = each.value.default_origin_key
    viewer_protocol_policy = each.value.viewer_protocol_policy
    compress               = each.value.compress
    min_ttl                = each.value.min_ttl
    default_ttl            = each.value.default_ttl
    max_ttl                = each.value.max_ttl
    cache_policy_id        = lookup(each.value, "cache_policy_id", null)
  }

  restrictions = {
    geo_restriction = {
      restriction_type = "none"
      locations        = []
    }
  }

  depends_on = [module.s3_bucket, module.cloudfront_origin_access_control]
  tags       = merge(each.value.tags, local.tags)
}