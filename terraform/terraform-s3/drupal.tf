provider "aws" {
  access_key = "KEY"
  secret_key = "KEY"
  region     = "us-west-2"
}

data "terraform_remote_state" "drupal" {
    backend = "s3"
    config {
        bucket = "copperleaf-terraform"
        key = "drupal_terraform.tfstate"
        region = "us-west-2"
        shared_credentials_file = "~/.aws/config"
        profile= "copper"
    }
}

resource "aws_security_group" "drupal_app" {
  name = "drupal_app"
  description = "Allow traffic to drupal nodes"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["172.0.0.0/8"]
  }

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["72.201.88.232/32"]
  }

  tags {
    Name = "drupal_app"
  }
}

resource "aws_security_group" "drupal_elb" {
  name = "drupal_elb"
  description = "Allow traffic to ELB"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }

  tags {
    Name = "drupal_app"
  }
}

resource "aws_instance" "drupal-zone-a" {
  ami               = "ami-1c7dd97c"
  count             = "1"
  instance_type     = "t2.micro"
  key_name          = "CopperLeafRobCoffman1"
  availability_zone = "us-west-2a"
  security_groups   = ["${aws_security_group.drupal_app.name}"]
  tags {
    Name = "Drupal Zone A"
  }
}

resource "aws_instance" "drupal-zone-b" {
  ami               = "ami-1c7dd97c"
  count             = "1"
  instance_type     = "t2.micro"
  key_name          = "CopperLeafRobCoffman1"
  availability_zone = "us-west-2b"
  security_groups   = ["${aws_security_group.drupal_app.name}"]
  tags {
    Name = "Drupal Zone B"
  }
}

resource "aws_elb" "drupal_elb" {
  name = "drupal-terraform-elb"
  availability_zones = ["us-west-2a", "us-west-2b"]

  listener {
    instance_port = 80
    instance_protocol = "http"
    lb_port = 80
    lb_protocol = "http"
  }

  health_check {
    healthy_threshold = 2
    unhealthy_threshold = 2
    timeout = 3
    target = "TCP:80"
    interval = 30
  }

  instances = ["${aws_instance.drupal-zone-a.*.id}","${aws_instance.drupal-zone-b.*.id}"]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400
  security_groups   = ["${aws_security_group.drupal_elb.id}","${aws_security_group.drupal_app.id}"]

  tags {
    Name = "drupal-elb"
  }
}


resource "aws_lb_cookie_stickiness_policy" "drupal_elb_policy" {
      name = "drupal-sticky-policy"
      load_balancer = "${aws_elb.drupal_elb.id}"
      lb_port = 80
      cookie_expiration_period = 600
}
