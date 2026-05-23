resource "aws_security_group" "api_sg"{
name = "api-sg"
vpc_id = module.vpc.vpc_id

ingress{
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress{
from_port = 3111
to_port = 3111
protocol = "tcp"
cidr_blocks = ["0.0.0.0/0"]
}

ingress{
from_port = 49134
to_port = 49134
protocol = "tcp"
cidr_blocks = ["10.0.0.0/16"]
}

egress{
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

}

resource "aws_security_group" "worker_sg"{
name = "worker-sg"
vpc_id = module.vpc.vpc_id

ingress{
from_port = 22
to_port = 22
protocol = "tcp"
cidr_blocks = ["10.0.0.0/16"]
}

ingress{
from_port = 49134
to_port = 49134
protocol = "tcp"
security_groups = [aws_security_group.api_sg.id]
}

egress{
from_port = 0
to_port = 0
protocol = "-1"
cidr_blocks = ["0.0.0.0/0"]
}

}
