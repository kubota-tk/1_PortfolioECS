##他モジュールに出力

output "vpc_id" {
  value = aws_vpc.vpc.id
}

output "pub_sub_1_id" {
  value = aws_subnet.public_subnet_1.id
}

output "pub_sub_2_id" {
  value = aws_subnet.public_subnet_2.id
}

output "pri_sub_1_id" {
  value = aws_subnet.private_subnet_1.id
}

output "pri_sub_2_id" {
  value = aws_subnet.private_subnet_2.id
}

output "pri_sub_3_id" {
  value = aws_subnet.private_subnet_3.id
}

output "pri_sub_4_id" {
  value = aws_subnet.private_subnet_4.id
}

output "pri_route_table_1_id" {
  value = aws_route_table.private_route_table_1.id
}

output "pri_route_table_2_id" {
  value = aws_route_table.private_route_table_2.id
}
