resource "aws_subnet" "main-public" {
  count  = var.subnet_count
  vpc_id = aws_vpc.main.id

  cidr_block = var.public_subnet_cidr_list != null ? var.public_subnet_cidr_list[count.index] : cidrsubnet(var.vpc_cidr_block, var.newbits, var.netnum_public + count.index)

  map_public_ip_on_launch = true

  tags = {
    Name = "${var.name}-public_${substr(data.aws_availability_zones.available.names[count.index], -1, -1)}",
    Tier = "public",
  }

  availability_zone = data.aws_availability_zones.available.names[count.index]
}

resource "aws_route_table" "main-public" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name = "${var.name}-public",
    Tier = "public",
  }

}

resource "aws_route" "internet_gateway" {
  route_table_id         = aws_route_table.main-public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.main-gw.id
}

resource "aws_route_table_association" "public" {
  count          = var.subnet_count
  subnet_id      = element(aws_subnet.main-public.*.id, count.index)
  route_table_id = aws_route_table.main-public.id
}
