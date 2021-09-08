output "vpc_id" { value = aws_vpc.main.id }
output "vpc_cidr_block" { value = aws_vpc.main.cidr_block }

output "public_subnet_ids" { value = aws_subnet.main-public.*.id }
output "private_subnet_ids" { value = aws_subnet.main-private.*.id }
output "public_route_table_ids" { value = aws_route_table.main-public.id }
output "private_route_table_ids" { value = aws_route_table.main-private.*.id }

output "nat_gateway_ids" { value = aws_nat_gateway.nat-gw.*.id }
output "nat_gateway_ips" { value = aws_nat_gateway.nat-gw.*.public_ip }

output "public_cidr_blocks" { value = aws_subnet.main-public.*.cidr_block }
output "private_cidr_blocks" { value = aws_subnet.main-private.*.cidr_block }
