#!/bin/bash
yum update -y
amazon-linux-extras install nginx1 -y

# Create a simple index.html file with hello-world content
echo "hello-world" > /usr/share/nginx/html/index.html

systemctl start nginx
systemctl enable nginx
