locals {
  create_count = var.create_data_volumes ? length(var.instance_ids) : 0
}

resource "aws_ebs_volume" "data" {
  count = local.create_count

  availability_zone = var.availability_zones[count.index]
  size              = var.volume_size
  type              = var.volume_type
  encrypted         = true

  tags = merge(
    var.tags,
    {
      Name = "${var.volume_name_prefix}-${count.index + 1}"
    }
  )
}

resource "aws_volume_attachment" "this" {
  count = local.create_count

  device_name  = var.device_name
  volume_id    = aws_ebs_volume.data[count.index].id
  instance_id  = var.instance_ids[count.index]
  force_detach = false
  skip_destroy = false
}
