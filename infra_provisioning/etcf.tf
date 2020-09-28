#########################
# etcd cluster instances
#########################
resource "aws_key_pair" "etcd_keypair" {
  key_name = "etcd_key"
  public_key = "${var.default_keypair_public_key}"
}


resource "aws_instance" "etcd" {
    count = 1
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "${var.etcd_instance_type}"

    subnet_id = "${aws_subnet.kubernetes.id}"
    private_ip = "${cidrhost(var.vpc_cidr, 10 + count.index)}"
    associate_public_ip_address = true # Instances have public, dynamic IP

    availability_zone = "${var.zone}"
    vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
    key_name = aws_key_pair.etcd_keypair.key_name

    tags = {
      Owner = "${var.owner}"
      Name = "etcd-${count.index}"
      ansibleFilter = "${var.ansibleFilter}"
      ansibleNodeType = "etcd"
      ansibleNodeName = "etcd${count.index}"
    }
}
