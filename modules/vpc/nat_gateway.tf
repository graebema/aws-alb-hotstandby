resource "aws_eip" "nat_gateway" {
  count = var.subnet_count
  tags = {
    Name = "nat_gateway_${substr(data.aws_availability_zones.available.names[count.index], -1, -1)}",
  }
}

resource "aws_nat_gateway" "nat-gw" {
  count         = var.subnet_count
  allocation_id = element(aws_eip.nat_gateway.*.id, count.index)
  subnet_id     = element(aws_subnet.main-public.*.id, count.index)
  depends_on    = [aws_internet_gateway.main-gw]

  tags = {
    Name = "nat-gw_${substr(data.aws_availability_zones.available.names[count.index], -1, -1)}",
  }

  #lifecycle {
  #  prevent_destroy = false
  #}
}
