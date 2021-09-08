# Create private subnets for not publicly accessible resources such as instances and database
resource "aws_subnet" "main-private" {
  count  = var.subnet_count
  vpc_id = aws_vpc.main.id

  cidr_block = var.private_subnet_cidr_list != null ? var.private_subnet_cidr_list[count.index] : cidrsubnet(var.vpc_cidr_block, var.newbits, var.netnum_private + count.index)

  availability_zone = data.aws_availability_zones.available.names[count.index]

  map_public_ip_on_launch = false

  tags = {
    Name = "${var.name}-private_${substr(data.aws_availability_zones.available.names[count.index], -1, -1)}",
    Tier = "private",
  }

}

resource "aws_route_table" "main-private" {
  vpc_id = aws_vpc.main.id
  count  = var.subnet_count

  tags = {
    Name = "${var.name}-private_${substr(data.aws_availability_zones.available.names[count.index], -1, -1)}",
    Tier = "private",
  }
}

resource "aws_route" "nat_gateway" {
  count                  = var.subnet_count
  route_table_id         = element(aws_route_table.main-private.*.id, count.index)
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = element(aws_nat_gateway.nat-gw.*.id, count.index)
}

resource "aws_route_table_association" "private" {
  count          = var.subnet_count
  subnet_id      = element(aws_subnet.main-private.*.id, count.index)
  route_table_id = element(aws_route_table.main-private.*.id, count.index)
}
