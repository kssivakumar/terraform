output "ec2_public_ip" {
  value = module.myinfra-server.instance.public_ip
}