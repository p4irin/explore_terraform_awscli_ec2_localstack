resource "aws_key_pair" "mykey" {
  key_name   = "mykey"
  public_key = file("~/.ssh/id_rsa.pub")
}

resource "aws_instance" "ubuntu2204" {
  ami           = "ami-df5de72bdb3b"
  instance_type = "t3.nano"
  key_name      = aws_key_pair.mykey.key_name
}
