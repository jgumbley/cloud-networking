/*
  Inside Servers
*/
resource "aws_security_group" "inside" {
    name = "vpc_db"
    description = "Allow SSH connections."

    ingress { # SSH
        from_port = 22
        to_port = 22
        protocol = "tcp"
        security_groups = ["${aws_security_group.boundary.id}"]
    }

    ingress {
        from_port = 22
        to_port = 22
        protocol = "tcp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }
    ingress {
        from_port = -1
        to_port = -1
        protocol = "icmp"
        cidr_blocks = ["${var.vpc_cidr}"]
    }

    egress {
        from_port = 80
        to_port = 80
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }
    egress {
        from_port = 443
        to_port = 443
        protocol = "tcp"
        cidr_blocks = ["0.0.0.0/0"]
    }

    vpc_id = "${aws_vpc.default.id}"

    tags {
        Name = "Inside"
    }
}

resource "aws_instance" "inside-1" {
  ami = "${lookup(var.amis, var.aws_region)}"
  availability_zone = "eu-west-1a"
  instance_type = "t2.micro"
  key_name = "deployer-key"
  vpc_security_group_ids = ["${aws_security_group.inside.id}"]
  subnet_id = "${aws_subnet.eu-west-1a-private.id}"
  source_dest_check = false
  private_ip = "10.0.1.56"

    tags {
        Name = "Inside Server"
    }
}
