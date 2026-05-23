resource "aws_instance" "api_vm"{
ami = var.ami_id
instance_type = "t2.micro"

subnet_id = module.vpc.public_subnets[0]

vpc_security_group_ids = [aws_security_group.api_sg.id]

associate_public_ip_address = true

key_name = var.key_name

tags = {
Name = "api_ec2"
}
}


resource "aws_instance" "caller_worker"{
ami = var.ami_id
instance_type = "t2.micro"

subnet_id = module.vpc.public_subnets[0]
vpc_security_group_ids = [aws_security_group.worker_sg.id]
associate_public_ip_address = true
key_name = var.key_name

tags = {
Name = "caller-worker"
}
}

resource "aws_instance" "inference_worker"{
ami = var.ami_id
instance_type = "t2.micro"

subnet_id = module.vpc.public_subnets[0]
vpc_security_group_ids = [aws_security_group.worker_sg.id]
associate_public_ip_address = true
key_name = var.key_name

tags = {
Name = "inference-worker"
}
}
