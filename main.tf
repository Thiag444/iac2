terraform {
  required_providers {
      aws = {}
  }
}

provider "aws" {
  region = "us-east-1"
}

#criando um grupo de segurança p/liberar a porta 80

resource "aws_security_group" "http" {
  name = "liberando_http"
  description = "liberando a porta 80"

  ingress {
      from_port = 80
      to_port = 80
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

#criando um grupo de segurança p/liberar a porta 22

resource "aws_security_group" "ssh" {
  name = "liberando_ssh"
  description = "liberando a porta 22"

  ingress {
      from_port = 22
      to_port = 22
      protocol = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
  }
  egress {
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
  }
}

#criando a instancia ec2

resource "aws_instance" "web_server" {
  ami = "ami-0d5eff06f840b45e9"
  instance_type = "t2.micro"
  security_groups = [aws_security_group.ssh.name, aws_security_group.http.name]
  key_name = "minhachave"

  provisioner "file" {
    source = "files/index.html"
    destination = "/tmp/index.html"
  }
  connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }
  provisioner "remote-exec" {
    inline = [
        "sudo yum install httpd -y",
        "sudo systemctl enable httpd.service",
        "sudo systemctl start httpd.service",
        "sudo mv /tmp/index.html /var/www/html/index.html"
    ]
connection {
    type = "ssh"
    user = "ec2-user"
    private_key = file("~/.ssh/id_rsa")
    host = self.public_ip
  }
  }
  tags = {
    "Name" = "pagina"
  }


}

output "ip_publico" {
  value = aws_instance.web_server.public_ip
}


