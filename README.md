# WellTechnically FRP Client add-on

A minimal, self-owned Home Assistant add-on that runs the **frp** client (`frpc`) to open a
secure outbound tunnel to the WellTechnically AWS reverse proxy. Built to replace the
third-party frpc add-on so the client-side code is fully under your control.

## Why this instead of a community add-on

- **Least privilege** — only `host_network` (needed to reach HA at `127.0.0.1:8123`). No
  `NET_ADMIN`, no `/dev/net/tun`, no `/share` access.
- **Verified supply chain** — the official frp binary is downloaded at build time and its
  **sha256 is checked against a pinned value** (`build.yaml`). No runtime downloads.
- **No secret leakage** — the token is written only to container-local `/tmp/frpc.toml`
  (never `/share`) and is never printed to the log.
- **You own updates** — it lives in your GitHub repo; nothing changes on client boxes unless
  you push a change.

## Publish it (once)

1. Create a **public** GitHub repo, e.g. `keteracel/ha_frp`.
2. Copy the contents of this `addon-frpc/` directory to that repo's root so it looks like:
   ```
   repository.yaml
   frpc/
     config.yaml
     build.yaml
     Dockerfile
     run.sh
   ```
3. Edit `repository.yaml` (and `config.yaml`'s `url`) to your repo URL. Commit + push.

## Install on a client's Raspberry Pi HAOS

1. **Settings → Add-ons → Add-on Store → (⋮) Repositories**, add your repo URL.
2. Refresh, open **WellTechnically FRP Client → Install**.
3. **Configuration** tab:
   - `server_addr` — the proxy Elastic IP
   - `server_port` — `7000`
   - `token` — your shared FRP token (masked field)
   - `custom_domain` — `<client>.welltechnically.co.uk`
   - `proxy_name` — `ha-<client>` (must be unique across all clients)
   - `local_port` — `8123`
4. **Start** (enable *Start on boot* + *Watchdog*).
5. Trust the proxy in Home Assistant. Recent HA manages HTTP in the UI (a `http:` block in
   `configuration.yaml` is ignored):
   - **Settings → System → Network → "HTTP server"**: enable **Trust X-Forwarded-For** and
     add `127.0.0.1` (and `::1`) to **Trusted proxies**. Set the external URL there too.
   - Older HA: use a `configuration.yaml` `http:` block with `use_x_forwarded_for: true` and
     `trusted_proxies: [127.0.0.1, ::1]`, plus `homeassistant: external_url: …`.

## Notes

- **Architecture:** aarch64 only (Raspberry Pi HAOS). To add amd64/armv7, add the arch to
  `config.yaml`, and its `build_from` base + the matching frp `FRP_ARCH`/`FRP_SHA256` (from
  the official `frp_sha256_checksums.txt`) — one arch builds one binary, so checksums are
  per-arch.
- **frp version** is pinned in `build.yaml`; bump `FRP_VERSION` + `FRP_SHA256` together to
  update.
