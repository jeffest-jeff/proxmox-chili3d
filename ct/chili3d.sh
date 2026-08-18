#!/usr/bin/env bash
# Engine comes from community-scripts/core; this repo only ships the scripts.
# Local checkout wins (COMMUNITY_SCRIPTS_CORE_DIR, else a sibling ../core), so a
# fork/branch of core can be tested without touching this file.
_cs_boot="${COMMUNITY_SCRIPTS_CORE_DIR:-$(dirname "${BASH_SOURCE[0]}")/../../core}/core/build.func"
source "$_cs_boot" 2>/dev/null || source <(curl -fsSL "${COMMUNITY_SCRIPTS_CORE_URL:-https://raw.githubusercontent.com/community-scripts/core/main}/core/build.func")

# Copyright (c) 2021-2026 community-scripts ORG
# Author: Jeff (jkleinhenz)
# License: MIT | https://github.com/community-scripts/ProxmoxVED/raw/main/LICENSE
# Source: https://github.com/xiangechen/chili3d

APP="Chili3D"
var_tags="${var_tags:-cad;3d-printing}"
var_cpu="${var_cpu:-4}"
var_ram="${var_ram:-4096}"
var_disk="${var_disk:-10}"
var_os="${var_os:-debian}"
var_version="${var_version:-13}"
#var_arm64="${var_arm64:-no}" # unset = ask the user; set yes/no only when verified
var_unprivileged="${var_unprivileged:-1}"

header_info "$APP"
variables
color
catch_errors

function update_script() {
  header_info
  check_container_storage
  check_container_resources

  if [[ ! -d /opt/chili3d ]]; then
    msg_error "No ${APP} Installation Found!"
    exit
  fi

  if check_for_gh_release "chili3d" "xiangechen/chili3d"; then
    CLEAN_INSTALL=1 fetch_and_deploy_gh_release "chili3d" "xiangechen/chili3d" "tarball"

    msg_info "Building Chili3D"
    cd /opt/chili3d
    export NODE_OPTIONS="--max-old-space-size=3072"
    $STD npm ci
    $STD npm run build
    msg_ok "Built Chili3D"

    msg_info "Deploying Chili3D"
    rm -rf /var/www/html/*
    cp -r /opt/chili3d/dist/. /var/www/html/
    systemctl reload nginx
    msg_ok "Deployed Chili3D"
    msg_ok "Updated successfully!"
  fi
  exit
}

start
build_container
description

msg_ok "Completed Successfully!\n"
echo -e "${CREATING}${GN}${APP} setup has been successfully initialized!${CL}"
echo -e "${INFO}${YW}Access it using the following URL:${CL}"
echo -e "${GATEWAY}${BGN}http://${IP}${CL}"
