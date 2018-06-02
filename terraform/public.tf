/*
  Boundary
*/
resource "aws_security_group" "boundary" {
    name = "vpc_boundary"
    description = "Allow incoming HTTP connections."

   ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
     cidr_blocks = ["0.0.0.0/0"]
    }

   ingress {
      from_port = 443
      to_port = 443
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }

  ingress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
    }

  egress {
    from_port       = 80
    to_port         = 80
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port       = 443
    to_port         = 443
    protocol        = "tcp"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  egress {
    from_port = -1
    to_port = -1
    protocol = "icmp"
    cidr_blocks = ["0.0.0.0/0"]
  }

    egress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }
  egress {
        from_port = 3306
        to_port = 3306
        protocol = "tcp"
        cidr_blocks = ["${var.private_subnet_cidr}"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "Boundary"
    }
}

resource "aws_instance" "jump-1" {
    ami = "${lookup(var.amis, var.aws_region)}"
    availability_zone = "eu-west-1a"
    instance_type = "t2.micro"
    key_name = "deployer-key"
    vpc_security_group_ids = ["${aws_security_group.boundary.id}"]
    subnet_id = "${aws_subnet.eu-west-1a-public.id}"
    associate_public_ip_address = true
    source_dest_check = false

    tags {
        Name = "Jump"
    }
}

resource "aws_key_pair" "deployer" {
  key_name = "deployer-key"
  public_key = "${file("../deploy_key.pub")}"
}


resource "aws_eip" "jump-1" {
    instance = "${aws_instance.jump-1.id}"
    vpc = true
}

output "bastion_ip" {
  value = "${aws_instance.jump-1.public_ip}"
}
