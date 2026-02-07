cloudfront_origin_access_controls = {
  s3_frontend = {
    name                              = "frontend-oac"
    description                       = "OAC for S3 frontend"
    origin_access_control_origin_type = "s3"
    signing_behavior                  = "always"
    signing_protocol                  = "sigv4"
  }
}

cloudfront_distributions = {
  frontend = {
    comment             = "CloudFront for Forger stage frontend"
    enabled             = true
    default_root_object = "index.html"
    price_class         = "PriceClass_100"
    default_origin_key  = "s3-frontend"

    origins = {
      "s3-frontend" = {
        origin_id                 = "s3-frontend-origin"
        origin_type               = "s3"
        key                       = "frontend" # ← s3 bucket key
        origin_access_control_key = "s3_frontend"
      }
      # Example: future ALB origin
      # "api" = {
      #   origin_id   = "alb-backend"
      #   origin_type = "alb"
      #   key         = "backend"               # ← alb module key
      # }
    }

    allowed_methods        = ["GET", "HEAD", "OPTIONS"]
    cached_methods         = ["GET", "HEAD"]
    viewer_protocol_policy = "redirect-to-https"
    compress               = true
    min_ttl                = 0
    default_ttl            = 86400
    max_ttl                = 31536000
    cache_policy_id        = "658327ea-f89d-4fab-a63d-7e66439e5e4f"

    viewer_certificate = {
      cloudfront_default_certificate = true
    }

    tags = {
      Name = "forger-stage-frontend-cdn"
    }
  }
}