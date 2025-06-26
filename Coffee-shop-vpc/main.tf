provider "aws" {
  region = vars.aws_region
}

### The VPC
resource "aws_vpc" "coffee_shop_vpc" {
  cidr_block = vars.vpc_cidr
  tags = {
    Name = "CoffeeShopVPC"
  }
}


### Subnets
### This subnet is for the coffee shop's public-facing resources
### It is public and will have internet access
resource "aws_subnet" "coffee_public_shop_subnet" {
    vpc_id            = aws_vpc.coffee_shop_vpc.id
    cidr_block        = "10.0.1.0/24"
    availability_zone = "${var.aws_region}a"
    tags = {
        Name = "CoffeeShop-Public-Subnet"
    }
}

### This subnet is for the coffee shop's private resources
### It is private and will not have direct internet access
resource "aws_subnet" "coffee_private_shop_subnet" {
    vpc_id            = aws_vpc.coffee_shop_vpc.id
    cidr_block        = "10.0.2.0/24"
    availability_zone = "${var.aws_region}a"
    tags = {
        Name = "CoffeeShop-Private-Subnet"
    }
}

### This subnet is for the database
### It is private and will not have direct internet access
resource "aws_subnet" "coffee_db_subnet" {
    vpc_id            = aws_vpc.coffee_shop_vpc.id
    cidr_block        = "10.0.3.0/24"
    availability_zone = "${var.aws_region}b"
    tags = {
        Name = "CoffeeShop-DB-Subnet"
    }
}


### Internet Gateway
### This allows the VPC to connect to the internet
resource "aws_internet_gateway" "coffee_shop_igw" {
  vpc_id = aws_vpc.coffee_shop_vpc.id
  tags = {
    Name = "CoffeeShop-IGW"
  }
}


### Route Table for Public Subnet
### This route table allows the public subnet to access the internet
resource "aws_route_table" "coffee_public_route_table" {
  vpc_id = aws_vpc.coffee_shop_vpc.id
  tags = {
    Name = "CoffeeShop-Public-Route-Table"
  }
}


### Route to Internet
### This route allows traffic from the public subnet to go to the internet
### It uses the internet gateway created above
resource "aws_route" "default_internet_route" {
  route_table_id         = aws_route_table.coffee_public_route_table.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.coffee_shop_igw.id
}


### Associate Route Table with Public Subnet
### This associates the public route table with the public subnet
resource "aws_route_table_association" "coffee_public_subnet_association" {
  subnet_id      = aws_subnet.coffee_public_shop_subnet.id
  route_table_id = aws_route_table.coffee_public_route_table.id
}


### Security Group
### This security group allows inbound traffic on port 80 (HTTP) and 443 (HTTPS)
resource "aws_security_group" "coffee_shop_sg" {
    name = "CoffeeShop-SG"
    description = "Security group for Coffee Shop VPC"
    vpc_id = aws_vpc.coffee_shop_vpc.id
    ingress {
        from_port   = 80
        to_port     = 80
        protocol    = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    ingress {   
        from_port   = 22
        to_port     = 22
        protocol    = "tcp"
        cidr_blocks = [var.my_ip]
    }
    egress {
        from_port   = 0
        to_port     = 0
        protocol    = "-1"
        cidr_blocks = ["0.0.0.0/0"]
    }
    
    tags = {
        Name = "CoffeeShop-SG"
    }

}

### Ec2 Instance
### This is a placeholder for the EC2 instance that will be launched in the public subnet
resource "aws_instance" "coffee_shop_instance" {
    ami           = "ami-0c55b159cbfafe1f0"
    instance_type = "t2.micro"
    subnet_id     = aws_subnet.coffee_public_shop_subnet.id
    security_groups = [aws_security_group.coffee_shop_sg.name]
    associate_public_ip_address = true
    vpc_security_group_ids = [aws_security_group.coffee_shop_sg.id]
    user_data = <<-EOF
                #!/bin/bash
                echo "Hello, Coffee Shop!" > /var/www/html/index.html
                systemctl start httpd
                systemctl enable httpd
                EOF
    tags = {
        Name = "CoffeeShop-Instance"
    }
}