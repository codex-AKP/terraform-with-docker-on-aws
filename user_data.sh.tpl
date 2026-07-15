#!/bin/bash
set -euo pipefail

dnf update -y
dnf install -y docker git

systemctl enable docker
systemctl start docker

usermod -aG docker ec2-user

cd /home/ec2-user

git clone --filter=blob:none --sparse https://github.com/codex-AKP/terraform-with-docker-on-aws.git
cd terraform-with-docker-on-aws
git sparse-checkout set site
rm -rf main.tf outputs.tf terraform.tf user_data.sh.tpl variables.tf


cat > Dockerfile <<'EOF'
FROM nginx:alpine
RUN rm -rf /usr/share/nginx/html/*
COPY site/index.html /usr/share/nginx/html/index.html
EXPOSE 80
CMD ["nginx", "-g", "daemon off;"]
EOF

docker build -t ${container_image_tag} .

docker run -d \
  --name ${container_name} \
  --restart unless-stopped \
  -p ${app_port}:80 \
  ${container_image_tag}