nat_gateways = {
  backend_private_1 = {
    vpc        = "main"
    elastic_ip = "backend_private_1"
    subnet     = "nat_public_1"
    tags = {
      Name        = "BackendNAT1"
      Description = "Natgateway 1"
    }
  },
  backend_private_2 = {
    vpc        = "main"
    elastic_ip = "backend_private_2"
    subnet     = "nat_public_2"
    tags = {
      Name        = "BackendNAT2"
      Description = "Natgateway 2"
    }
  }
}