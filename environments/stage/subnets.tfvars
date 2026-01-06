subnets = {
  # Minimal public subnets - ONLY for NAT Gateway
  "nat_public_1" = {
    cidr_block        = "10.0.1.0/24"
    availability_zone = "us-east-1a"
    public            = true
    vpc_name          = "main"
    tags = {
      Name = "NATPublicSubnet1"
      Type = "nat"
    }
  },
  "nat_public_2" = {
    cidr_block        = "10.0.2.0/24"
    availability_zone = "us-east-1b"
    public            = true
    vpc_name          = "main"
    tags = {
      Name = "NATPublicSubnet2"
      Type = "nat"
    }
  },

  # actual application subnets (private)
  "backend_private_1" = {
    cidr_block        = "10.0.10.0/24"
    availability_zone = "us-east-1a"
    public            = false
    vpc_name          = "main"
    tags = {
      Name = "BackendPrivateSubnet1"
    }
  },
  "backend_private_2" = {
    cidr_block        = "10.0.11.0/24"
    availability_zone = "us-east-1b"
    public            = false
    vpc_name          = "main"
    tags = {
      Name = "BackendPrivateSubnet2"
    }
  },
  "database_private_1" = {
    cidr_block        = "10.0.20.0/24"
    availability_zone = "us-east-1a"
    public            = false
    vpc_name          = "main"
    tags = {
      Name = "DatabasePrivateSubnet1"
    }
  },
  "database_private_2" = {
    cidr_block        = "10.0.21.0/24"
    availability_zone = "us-east-1b"
    public            = false
    vpc_name          = "main"
    tags = {
      Name = "DatabasePrivateSubnet2"
    }
  }
}