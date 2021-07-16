#!/bin/sh
sudo su
yum -y install httpd
echo "<p> Hello, Built In! </p>" >> /var/www/html/index.html
sudo systemctl enable httpd
sudo systemctl start httpd