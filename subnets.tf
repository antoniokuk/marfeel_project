resource "aws_subnet" "private-us-east-1b" {
    vpc_id      = aws_vpc.main.id
    cidr_block  = "10.0.0.0/24"
    availability_zone = "us-east-1b"
    map_public_ip_on_launch = true

    tags = {

      "Name"                                = "private-us-east-1b"
      "kubernetes.io/role/internal-elb"     = "1"
      "kubernetes.io/cluster/marfeel"       = "owned"
    }
}

resource "aws_subnet" "private-us-east-1f" {
    vpc_id      = aws_vpc.main.id
    cidr_block  = "10.0.1.0/24"
    availability_zone = "us-east-1f"
    map_public_ip_on_launch = true

    tags = {

      "Name"                                = "private-us-east-1f"
      "kubernetes.io/role/internal-elb"     = "1"
      "kubernetes.io/cluster/marfeel"       = "owned"
    }
}