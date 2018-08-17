provider "aws" {
    region = "${var.region}"
    secret_key = "${var.secret_key}"
    access_key = "${var.access_key}"
    version = "~> 1.32"
}
resource "aws_key_pair" "bitrix_key_pair" {
    key_name = "bitrix"
    public_key = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDAnD9158wWWuvonO7Lj32WRFi8Fev7wNQuODwjUEXzVAdu8UJ3UP2ZqDiTpJzvpdkGGpBVjR5G+7xp2MwKTaB7FkmY0kfOhH28uS33HtD17lBddBjxEevsC1ZBL+llJfXomqeUZTl3GH/HF8f7U6CY2VMfHTUi+a4A75HAB791Nwo6sKFLnSAFI1AGnYeOshyUGJlDfOTnUvknid2BVI7cXOCyYjRI/xRHiOQ8b9VubsAMM8dWFtZQJRawQSTkB7F3ySfzLRhrsgH6Hz3wknM4pvH/GQxOcuAzgQVWu4fzBMb+qg3dtWWffqcV7sBa+TgGGxUeMnFxBvWy3H0tHr13"
}

resource "aws_default_vpc" "main_vpc" {
}

resource "aws_security_group" "bitrix_access" {
    name = "bitrix_web_access"
    vpc_id = "${aws_default_vpc.main_vpc.id}"
}
resource "aws_security_group_rule" "http_inbound_rule" {
    description = "Allow incoming traffic to 80 port"
    type = "ingress"
    from_port = 80
    to_port = 80
    protocol = 6   # https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.bitrix_access.id}"
}

resource "aws_security_group_rule" "https_inbound_rule" {
    description = "Allow incoming traffic to 443 port"
    type = "ingress"
    from_port = 443
    to_port = 443
    protocol = 6   # https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtml
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.bitrix_access.id}"
}

resource "aws_security_group_rule" "ssh_access_rule" {
    description = "Allow incoming ssh traffic"
    type = "ingress"
    from_port = 22
    to_port = 22
    protocol = 6   # https://www.iana.org/assignments/protocol-numbers/protocol-numbers.xhtmls
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.bitrix_access.id}"
}

resource "aws_security_group_rule" "outbound_rule" {
    description = "Allow all outgoint traffic"
    type = "egress"
    from_port = 0
    to_port = 0
    protocol = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    security_group_id = "${aws_security_group.bitrix_access.id}"
}

resource "aws_instance" "bitrix_instance" {
    ami = "${var.ami_id}"
    instance_type = "${var.instance_type}"
    vpc_security_group_ids = ["${aws_security_group.bitrix_access.id}"]
    key_name = "${aws_key_pair.bitrix_key_pair.key_name}"

    provisioner "remote-exec" {
        inline = [
            "apt-get update -y",
            "apt-get upgrade -y",
            "apt-get install python -y"
        ]

        connection {
            user = "ubuntu"
            private_key = "${"file(/home/bitrix/.ssh/id_rsa)"}"
        }
    }
}