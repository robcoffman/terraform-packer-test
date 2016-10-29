provider "aws" {
  access_key = "KEY"
  secret_key = "KEY"
  region     = "us-west-2"
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
      from_port = 81
      to_port = 81
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

resource "aws_launch_configuration" "drupal_conf" {
    name_prefix = "drupal-app-"
    image_id = "ami-2cc86c4c"
    instance_type = "t2.micro"
    key_name          = "CopperLeafRobCoffman1"
    security_groups   = ["${aws_security_group.drupal_app.name}"]
    lifecycle {
      create_before_destroy = true
    }
}

resource "aws_autoscaling_policy" "drupal_policy" {
  name = "drupal-autoscale-policy"
  scaling_adjustment = 4
  adjustment_type = "ChangeInCapacity"
  cooldown = 300
  autoscaling_group_name = "${aws_autoscaling_group.drupal_group.name}"
}

resource "aws_autoscaling_group" "drupal_group" {
  availability_zones = ["us-west-2a", "us-west-2b"]
  name = "drupal-autoscal-group"
  max_size = 5
  min_size = 2
  health_check_grace_period = 300
  health_check_type = "ELB"
  force_delete = true
  launch_configuration = "${aws_launch_configuration.drupal_conf.name}"
  load_balancers = ["${aws_elb.drupal_elb.id}"]
  tag {
    key = "Name"
    value = "Drupal App"
    propagate_at_launch = true
  }
}
