resource "aws_route_table" "table01" {
  vpc_id = var.vpc_id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = var.igw_id
  }

  tags = {
    Name = var.route_table_name
  }
}
resource "aws_route_table_association" "association01" {
  subnet_id      = var.subnet_id
  route_table_id = aws_route_table.table01.id
}