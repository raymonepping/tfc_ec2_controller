output "ami_id" {
  description = "The AMI ID selected for the given OS and architecture"
  value = var.ami_id_override != "" ? var.ami_id_override : (length(data.aws_ami.latest) > 0 ? data.aws_ami.latest[0].id : null)
}
