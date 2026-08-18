# proxmox-chili3d

A [Proxmox VE](https://www.proxmox.com/) community-script-style LXC installer for
[Chili3D](https://github.com/xiangechen/chili3d) — an open-source, browser-based 3D CAD
application built with TypeScript, Three.js, and OpenCascade (OCCT) compiled to WebAssembly.

The container builds Chili3D's static production bundle from source and serves it with
nginx. There is no backend and no database — Chili3D runs entirely client-side, with
documents persisted in the browser's IndexedDB.

This repo follows the script structure and helper-function conventions of
[community-scripts/ProxmoxVED](https://github.com/community-scripts/ProxmoxVED)
(see [AGENTS.md](AGENTS.md)) and reuses its build engine
([community-scripts/core](https://github.com/community-scripts/core)) at runtime.

## Install

Run this in the Proxmox VE host shell:

```bash
bash -c "$(curl -fsSL https://raw.githubusercontent.com/jeffest-jeff/proxmox-chili3d/main/ct/chili3d.sh)"
```

This creates a new unprivileged Debian 13 LXC container, installs Node.js and nginx,
builds Chili3D from the latest GitHub release, and serves it on port 80.

Default resources (adjustable during the interactive setup, or via `var_*` environment
variables for an unattended install):

| Resource | Default |
| -------- | ------- |
| CPU      | 4 cores |
| RAM      | 4096 MB |
| Disk     | 10 GB   |
| OS       | Debian 13 |

Once complete, open `http://<container-ip>/` in a browser.

## Updating

Re-run the same script inside the container (or via the Proxmox VE web UI's update
button) to pull the latest Chili3D release, rebuild, and redeploy it.

## Notes

- **Data storage**: Chili3D documents live in the browser's IndexedDB, not on the
  container. Use the app's export/save-as (STEP, IGES, BREP, STL) to keep permanent
  copies.
- **Analytics**: the upstream app loads Microsoft Clarity by default. To opt out, remove
  the Clarity `<script>` block from `/opt/chili3d/public/index.html` before rebuilding
  (or from `/var/www/html/index.html` after install) and reload nginx.
- **License**: Chili3D is AGPL-3.0 (its WASM module under `cpp/` is LGPL-3.0). Review the
  license before redistributing or offering this as a hosted service.

## Repository layout

```
ct/chili3d.sh              Container script (creates/updates the LXC)
install/chili3d-install.sh Install script (runs inside the container)
json/chili3d.json          App metadata (resources, categories, notes)
AGENTS.md                  Script conventions this repo follows
```

## Credits

- [Chili3D](https://github.com/xiangechen/chili3d) by [xiangechen](https://github.com/xiangechen)
- Script engine and conventions from [community-scripts/ProxmoxVED](https://github.com/community-scripts/ProxmoxVED)
