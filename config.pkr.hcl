packer {
    required_plugins {
     ibmcloud = {
       version = ">=v3.0.0"
       source = "github.com/IBM/ibmcloud"
     }
   }
 }

variable "IBM_API_KEY" {
  type = string
}

variable "SUBNET_ID" {
  type = string
}

variable "REGION" {
  type = string
}

variable "RESOURCE_GROUP_ID" {
  type = string
}

//variable "SECURITY_GROUP_ID" {
//  type = string
//}

// variable "VPC_URL" {
//   type = string
// }
// variable "IAM_URL" {
//   type = string
// }


locals {
  timestamp = regex_replace(timestamp(), "[- TZ:]", "")
}

source "ibmcloud-vpc" "ubuntucompose" {
  api_key           = var.IBM_API_KEY
  region            = var.REGION
  subnet_id         = var.SUBNET_ID
  resource_group_id = var.RESOURCE_GROUP_ID
  // security_group_id = var.SECURITY_GROUP_ID

  // vsi_base_image_id = "r010-f0bbe222-8d6a-4935-a14e-a1680287f079"

  vsi_base_image_id = "r010-a6cb691f-5533-4f82-9329-b4569353052b"

  vsi_profile        = "bx2-2x8"
  vsi_interface      = "public"
  vsi_user_data_file = ""

  image_name = "packer-${local.timestamp}"

  communicator = "ssh"
  ssh_username = "root"
  ssh_port     = 22
  ssh_timeout  = "15m"

  timeout = "30m"
}

build {
  sources = [
    "source.ibmcloud-vpc.ubuntucompose"
  ]

 // provisioner "shell" {
 //   execute_command = "{{.Vars}} bash '{{.Path}}'"
 //   inline = [
 //     "echo 'Hello from IBM Cloud Packer Plugin - VPC Infrastructure'",
 //     "echo 'Hello from IBM Cloud Packer Plugin - VPC Infrastructure' >> /hello.txt"
 //   ]
 // }






provisioner "file" {
  source = "bootstrap_docker_ce.sh"
  destination = "/tmp/bootstrap_docker_ce.sh"
}
  provisioner "file" {
  source = "cleanup.sh"
  destination = "/tmp/cleanup.sh"
}

provisioner "shell" {
  execute_command =  "echo 'packer' | sudo -S sh -c '{{ .Vars }} {{ .Path }}'"
  inline = [        
    "whoami",
    "cd /tmp",
    "chmod +x bootstrap_docker_ce.sh",
    "chmod +x cleanup.sh",
    "ls -alh /tmp",
    "./bootstrap_docker_ce.sh",
    "sleep 10",
    "ls -alh /tmp",
    "pwd",
    "./cleanup.sh"
    ]
}










}