provider "aws" {
  access_key = "KEY"
  secret_key = "SECRET"
  region     = "us-west-2"
}

resource "aws_instance" "drupal-zone-a" {
  ami               = "ami-e274d182"
  count             = "1"
  instance_type     = "t2.micro"
  key_name          = "PRIVATEKEY"
  availability_zone = "us-west-2a"
  tags {
    Name = "Drupal Zone A"
  }
}

resource "aws_instance" "drupal-zone-b" {
  ami               = "ami-e274d182"
  count             = "1"
  instance_type     = "t2.micro"
  key_name          = "PRIVATEKEY"
  availability_zone = "us-west-2b"
  tags {
    Name = "Drupal Zone B"
  }
}

resource "aws_elb" "bar" {
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
    target = "HTTP:80/"
    interval = 30
  }

  instances = ["${aws_instance.drupal-zone-a.*.id}","${aws_instance.drupal-zone-b.*.id}"]
  cross_zone_load_balancing = true
  idle_timeout = 400
  connection_draining = true
  connection_draining_timeout = 400

  tags {
    Name = "drupal-elb"
  }
}
