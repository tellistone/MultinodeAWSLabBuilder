#! /bin/bash
sudo apt-get update
sudo apt-get install -y apache2
sudo systemctl start apache2
sudo systemctl enable apache2

sudo ufw allow in "Apache Full"

echo "<h1>Hello Graylog</h1>" | sudo tee /var/www/html/index.html

sudo apt install mysql-server
sudo apt install php libapache2-mod-php php-mysql