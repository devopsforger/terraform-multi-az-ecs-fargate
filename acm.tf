variable "acm_certificates" {
  description = "ACM certificates"
  type = map(object({
    domain_name               = string
    subject_alternative_names = list(string)
    validation_method         = string
    tags                      = map(string)
  }))
}

variable "acm_certificate_validations" {
  description = "ACM certificate validations"
  type = map(object({
    certificate_key = string
  }))
}

module "acm_certificate" {
  for_each = var.acm_certificates

  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/acm_certificate"

  domain_name               = each.value.domain_name
  subject_alternative_names = each.value.subject_alternative_names
  validation_method         = each.value.validation_method
  tags                      = each.value.tags
}

module "acm_certificate_validation" {
  for_each = var.acm_certificate_validations

  source = "/media/davidshare/Tersu/TersuCorp/devopsforge/projects/terraform-aws-modules/acm_certificate_validation"

  certificate_arn = module.acm_certificate[each.value.certificate_key].arn
}
