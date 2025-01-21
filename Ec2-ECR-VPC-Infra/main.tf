module "vpc" {
  source = "./module/vpc"

  # Pass variables to VPC module
  vpc_id                  = "10.0.0.0/16"
  instance_tenancy        = "default"
  enable_dns_support      = "true" # If set to true, DNS queries can be resolved within the VPC (e.g., for instances to communicate using private DNS names).
  enable_dns_hostnames    = "true" # If set to true, instances with public IPs will also receive public DNS hostnames
  public_subnet_01        = "10.0.1.0/24"
  availability_zone       = "ap-south-1a"
  map_public_ip_on_launch = "true" # Enable auto-assign public IP
  public_subnet_02        = "10.0.2.0/24"
  availability_zone1      = "ap-south-1b"
}



module "ec2" {
  source = "./module/ec2_instance"

  # Pass variables to EC2 module
  ami_value                   = "ami-053b12d3152c0cc71" # data.aws_ami.ubuntu_24_arm.id                            
  instance_type_value         = "t2.large"
  key_name                    = "varma.pem"
  instance_count              = "1"
  public_subnet_01            = module.vpc.public_subnet_id
  associate_public_ip_address = "true" # Enable a public IP
  availability_zone           = "ap-south-1a"
  vpc_id                      = module.vpc.vpc_id
  # instance_tenancy       = "dedicated"
  volume_size         = "30"
  volume_type         = "gp3"
  security_group_name = "Frissly-Security-Group"

}


module "ecr" {
  source = "./module/ecr"

  repository_name   = "frissly-docker-repo"
  vpc_id            = module.vpc.vpc_id
  public_subnet_01  = module.vpc.public_subnet_id
  public_subnet_02  = module.vpc.public_subnet1_id
  security_group_id = module.ec2.security_group_id
}

resource "null_resource" "name" {
  connection {
    type        = "ssh"
    user        = "ubuntu"
    private_key = file(var.private_key_path)
    host        = module.ec2.public_ip[0]
  }

  provisioner "file" {
    source      = "./module/ec2_instance/jenkins.sh"
    destination = "/home/ubuntu/jenkins.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "export $(grep -v '^#' /home/ubuntu/.env | xargs)",
      "mkdir -p /home/ubuntu/.aws",
      "echo '[default]' > /home/ubuntu/.aws/config",
      "echo 'region = ${var.region}' >> /home/ubuntu/.aws/config",
      "echo '[default]' > /home/ubuntu/.aws/credentials",
      "echo 'aws_access_key_id = ${var.access_key}' >> /home/ubuntu/.aws/credentials",
      "echo 'aws_secret_access_key = ${var.secret_key}' >> /home/ubuntu/.aws/credentials",

      # Optional: Clean up the .env file if not needed
      "rm /home/ubuntu/.env",
      "sudo chmod +x /home/ubuntu/jenkins.sh",
      "sh /home/ubuntu/jenkins.sh"
    ]
  }

  depends_on = [module.ec2]
}