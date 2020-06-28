resource "aws_vpc" "demo-vpc" {
    cidr_block  = "10.0.0.0/16"

    tags = {
        "Name" = "demo-vpc"
    }
}

resource "aws_subnet" "demo-public-subnets" {
    count = 2

    availability_zone       = data.aws_availability_zones.available.names[count.index]
    cidr_block              = "10.0.${count.index * 64}.0/18"
    vpc_id                  = aws_vpc.demo-vpc.id

    tags = map(
        "Name", "demo-public-subnet-${count.index}",
        "kubernetes.io/cluster/${var.cluster-name}", "shared",
        "kubernetes.io/role/elb", 1,
    )
}

resource "aws_subnet" "demo-private-subnets" {
    count = 2

    availability_zone       = data.aws_availability_zones.available.names[count.index]
    cidr_block              = "10.0.${(count.index + 2) * 64}.0/18"
    map_public_ip_on_launch = false
    vpc_id                  = aws_vpc.demo-vpc.id

    tags = map(
        "Name", "demo-private-subnet-${count.index}",
        "kubernetes.io/cluster/${var.cluster-name}", "shared",
        "kubernetes.io/role/internal-elb", 1,
    )
}

resource "aws_internet_gateway" "demo-internet-gateway" {
    vpc_id = aws_vpc.demo-vpc.id

    tags = {
        Name = "demo-internet-gateway"
    }
}

resource "aws_route_table" "demo-public-route-table" {
    vpc_id = aws_vpc.demo-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_internet_gateway.demo-internet-gateway.id
    }

    tags = {
        Name = "demo-public-route-table"
    }
}

resource "aws_route_table" "demo-private-route-tables" {
    count = 2

    vpc_id = aws_vpc.demo-vpc.id

    route {
        cidr_block = "0.0.0.0/0"
        gateway_id = aws_nat_gateway.demo-nat-gws.*.id[count.index]
    }

    tags = {
        Name = "demo-private-route-table-${count.index}"
    }

    depends_on = [aws_nat_gateway.demo-nat-gws]
}

resource "aws_eip" "demo-nat-gw-eips" {
    count = 2

    tags = {
        Name = "demo-nat-gw-eip-${count.index}"
    }
}

resource "aws_nat_gateway" "demo-nat-gws" {
    count = 2

    allocation_id   = aws_eip.demo-nat-gw-eips.*.id[count.index]
    subnet_id       = aws_subnet.demo-public-subnets.*.id[count.index]

    tags = {
        Name = "demo-nat-gw-${count.index}"
    }

    depends_on = [
        aws_eip.demo-nat-gw-eips,
        aws_subnet.demo-public-subnets
    ]
}

resource "aws_route_table_association" "demo-public-subnet-rt-association" {
    count = 2

    subnet_id       = aws_subnet.demo-public-subnets.*.id[count.index]
    route_table_id  = aws_route_table.demo-public-route-table.id
}

resource "aws_route_table_association" "demo-private-subnet-rt-association" {
    count = 2

    subnet_id       = aws_subnet.demo-private-subnets.*.id[count.index]
    route_table_id  = aws_route_table.demo-private-route-tables.*.id[count.index]
}