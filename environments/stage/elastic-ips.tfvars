elastic_ips = {
  backend_private_1 = {
    domain = "vpc",
    tags = {
      Name        = "NAT gateway 1",
      Description = "Elastic IP for natgateway 1"
    }
  },

  backend_private_2 = {
    domain = "vpc",
    tags = {
      Name        = "NAT gateway 2",
      Description = "Elastic IP for natgateway 2"
    }
  }
}