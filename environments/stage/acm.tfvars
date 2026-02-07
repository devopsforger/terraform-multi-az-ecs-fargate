acm_certificates = {
  frontend_cert = {
    domain_name               = "example.com"
    subject_alternative_names = ["www.example.com"]
    validation_method         = "DNS"
    tags = {
    }
  }
}

acm_certificate_validations = {
  frontend_cert_validation = {
    certificate_key = "frontend_cert"
  }
}