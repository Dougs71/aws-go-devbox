resource "aws_key_pair" "mykey" {
  key_name = "mykey"
  public_key = "${file("${var.PATH_TO_PUBLIC_KEY}")}"
}

resource "aws_instance" "example" {
  ami = "${lookup(var.AMIS, var.AWS_REGION)}"
  instance_type = "${var.INSTANCE_TYPE}"
  key_name = "${aws_key_pair.mykey.key_name}"

  tags {
    Name = "example"
  }

  root_block_device {
    delete_on_termination = true
  }
  
  provisioner "file" {
    source = "provision.sh"
    destination = "/tmp/provision.sh"
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/provision.sh",
      "sudo /tmp/provision.sh"
    ]
  }

  provisioner "local-exec" {
    command = "ansible-playbook -i \"${aws_instance.example.public_ip},\" -u ${var.INSTANCE_USERNAME} --private-key=${var.PATH_TO_PRIVATE_KEY} site.yml"
  }

  connection {
    user = "${var.INSTANCE_USERNAME}"
    private_key = "${file("${var.PATH_TO_PRIVATE_KEY}")}"
  }
}

output "id" {
  value = "${aws_instance.example.id}"
}
output "ip" {
  value = "${aws_instance.example.public_ip}"
}
