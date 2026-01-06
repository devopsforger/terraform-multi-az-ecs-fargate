route_tables = {
  "public" = {
    vpc = "main"
    tags = {
      Name        = "Public-Route-Table"
      Description = "Route table for public subnets with internet access"
    }
  },

  "backend_private_az_a" = {
    vpc = "main",
    tags = {
      Name = "Backend-Private-AZ-A"
    }
  },

  "backend_private_az_b" = {
    vpc = "main",
    tags = {
      Name = "Backend-Private-AZ-B"
    }
  },

  "database_private" = {
    vpc = "main"
    tags = {
      Name        = "Database-Private-Route-Table"
      Description = "Route table for database subnets with no internet access"
    }
  }
}

subnets_route_table_association = {
  # Public subnets → Public route table
  "nat_public_1" = {
    route_table = "public"
    subnet      = "nat_public_1"
  },
  "nat_public_2" = {
    route_table = "public"
    subnet      = "nat_public_2"
  },

  # Backend subnets → Backend private route table (BOTH AZs use same route table)
  "backend_private_1" = {
    route_table = "backend_private_az_a"
    subnet      = "backend_private_1"
  },
  "backend_private_2" = {
    route_table = "backend_private_az_b"
    subnet      = "backend_private_2"
  },

  # Database subnets → Database private route table (BOTH AZs use same route table)
  "database_private_1" = {
    route_table = "database_private"
    subnet      = "database_private_1"
  },
  "database_private_2" = {
    route_table = "database_private"
    subnet      = "database_private_2"
  }
}


internet_gateway_routes = {
  "public-internet" = {
    route_table = "public"
    cidr        = "0.0.0.0/0"
    gateway     = "main" # This references your internet_gateway module key
  }
}

nat_gateway_routes = {
  # Route for AZ A backend subnets
  "backend-az-a-to-nat" = {
    route_table = "backend_private_az_a",
    cidr        = "0.0.0.0/0",
    gateway     = "backend_private_1" # NAT in us-east-1a
  },
  # Route for AZ B backend subnets  
  "backend-az-b-to-nat" = {
    route_table = "backend_private_az_b",
    cidr        = "0.0.0.0/0",
    gateway     = "backend_private_2" # NAT in us-east-1b
  }
}