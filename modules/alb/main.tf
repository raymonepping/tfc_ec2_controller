##############################################################################
# Security group for ALB
##############################################################################

resource "aws_security_group" "alb" {
  name        = "${var.alb_name}-sg"
  description = "Security group for the Application Load Balancer"
  vpc_id      = var.vpc_id

  # ALB HTTP from anywhere. In a stricter setup you would limit this or use HTTPS.
  ingress {
    description = "HTTP from anywhere"
    from_port   = var.listener_port
    to_port     = var.listener_port
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    description = "All outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.alb_name}-sg"
    }
  )
}

##############################################################################
# Application Load Balancer
##############################################################################

resource "aws_lb" "this" {
  name               = var.alb_name
  internal           = false
  load_balancer_type = "application"

  security_groups = [aws_security_group.alb.id]
  subnets        = var.subnet_ids

  idle_timeout = 60

  tags = merge(
    var.tags,
    {
      Name = var.alb_name
    }
  )
}

##############################################################################
# Target group
##############################################################################

resource "aws_lb_target_group" "this" {
  name        = "${var.alb_name}-tg"
  port        = var.target_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id

  health_check {
    enabled             = true
    path                = var.health_check_path
    matcher             = "200"
    interval            = 30
    timeout             = 5
    healthy_threshold   = 3
    unhealthy_threshold = 3
  }

  tags = merge(
    var.tags,
    {
      Name = "${var.alb_name}-tg"
    }
  )
}

##############################################################################
# Listener
##############################################################################

resource "aws_lb_listener" "http" {
  load_balancer_arn = aws_lb.this.arn
  port              = var.listener_port
  protocol          = "HTTP"

  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.this.arn
  }
}

##############################################################################
# Attach instances to target group
##############################################################################

resource "aws_lb_target_group_attachment" "instances" {
  count            = length(var.instance_ids)
  target_group_arn = aws_lb_target_group.this.arn
  target_id        = var.instance_ids[count.index]
  port             = var.target_port
}
