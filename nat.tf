resource "aws_eip" "nat" {
    
    tags = {
      Name = "nat"
    }
}

resource "aws_nat_gateway" "nat" {
    allocation_id = aws_eip.nat.id
    subnet_id = aws_subnet.private-us-east-1b

    tags = {
      Name = "nat"
    }

    depends_on = [ aws_internet_gateway.igw ]
  
}