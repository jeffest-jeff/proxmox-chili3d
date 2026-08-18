#!/usr/bin/env bash

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Jeff (jkleinhenz)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/xiangechen/chili3d

source /dev/stdin <<<"$FUNCTIONS_FILE_PATH"
color
verb_ip6
catch_errors
setting_up_container
network_check
update_os

msg_info "Installing Dependencies"
$STD apt install -y nginx
msg_ok "Installed Dependencies"

NODE_VERSION="24" setup_nodejs

fetch_and_deploy_gh_release "chili3d" "xiangechen/chili3d" "tarball"

msg_info "Building Chili3D"
cd /opt/chili3d
export NODE_OPTIONS="--max-old-space-size=3072"
$STD npm ci
$STD npm run build
msg_ok "Built Chili3D"

msg_info "Deploying Chili3D"
rm -rf /var/www/html/*
cp -r /opt/chili3d/dist/. /var/www/html/
msg_ok "Deployed Chili3D"

msg_info "Configuring Nginx"
cat <<'EOF' >/etc/nginx/sites-available/chili3d.conf
server {
    listen 80 default_server;
    server_name _;
    root /var/www/html;
    index index.html;

    location / {
        try_files $uri $uri/ /index.html;
    }
}
EOF
ln -sf /etc/nginx/sites-available/chili3d.conf /etc/nginx/sites-enabled/chili3d.conf
rm -f /etc/nginx/sites-enabled/default
systemctl reload nginx
msg_ok "Configured Nginx"

motd_ssh
customize
cleanup_lxc
