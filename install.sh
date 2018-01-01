#!/usr/bin/env bash

# This script installs and configurs nginx
# it will listen on port 80, and will populate a simple html page with the node metadata

# install nginx
sudo apt-get update > /dev/null
sudo apt-get -y install nginx

# configure site
sudo bash -c "cat > /etc/nginx/sites-available/default << EOF
server {
  listen 8080 default_server;
  listen [::]:8080 default_server;

  root /var/www/html;

  index index.html index.htm index.nginx-debian.html;

  server_name localhost;

  location / {
    try_files \\\$uri \\\$uri/ /index.html;
  }
}
EOF"

# configure index.html
sudo bash -c "cat > /var/www/html/index.html << EOF

<!DOCTYPE html>
<html>
<body>
<h3>instance index=$1</h3>
<p>
  instance id=$(ec2metadata --instance-id) <br>
  instance type=$(ec2metadata --instance-type) <br>
  instance ip=$(ec2metadata --public-ipv4) <br>
  instance region=$(ec2metadata --availability-zone | sed 's/.$//') <br>
</p>
</body>
</html>

EOF"

# restart nginx to apply changes
sudo /etc/init.d/nginx restart



