
############################################
# K8s Worker (aka Nodes, Minions) Instances
############################################

resource "aws_key_pair" "k8worker_keypair" {
  key_name = "k8worker_key"
  public_key = "${var.default_keypair_public_key}"
}


resource "aws_instance" "worker" {
    count = 3
    ami = "${lookup(var.amis, var.region)}"
    instance_type = "${var.worker_instance_type}"

    subnet_id = "${aws_subnet.kubernetes.id}"
    private_ip = "${cidrhost(var.vpc_cidr, 30 + count.index)}"
    associate_public_ip_address = true # Instances have public, dynamic IP
    source_dest_check = false # TODO Required??

    availability_zone = "${var.zone}"
    vpc_security_group_ids = ["${aws_security_group.kubernetes.id}"]
    key_name = aws_key_pair.k8worker_keypair.key_name

    tags = {
      Owner = "${var.owner}"
      Name = "worker-${count.index}"
      ansibleFilter = "${var.ansibleFilter}"
      ansibleNodeType = "worker"
      ansibleNodeName = "worker${count.index}"
    }
}

output "kubernetes_workers_public_ip" {
  value = "${join(",", aws_instance.worker.*.public_ip)}"
}
