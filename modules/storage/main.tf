resource "aws_ebs_volume" "this" {
  count = var.create_data_volumes ? length(var.instance_ids) : 0

  availability_zone = var.availability_zones[count.index]
  size              = var.volume_size
  type              = var.volume_type

  tags = merge(
    var.tags,
    {
      Name = "${var.volume_name_prefix}-${count.index + 1}"
    }
  )
}

resource "aws_volume_attachment" "this" {
  count = var.create_data_volumes ? length(var.instance_ids) : 0

  device_name = var.device_name
  volume_id   = aws_ebs_volume.this[count.index].id
  instance_id = var.instance_ids[count.index]
}
