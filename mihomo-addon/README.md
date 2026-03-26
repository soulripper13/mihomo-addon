# Mihomo Global VPN for Home Assistant

This add-on runs **Mihomo (Clash Meta)** in TUN mode, providing a global VPN for your Home Assistant host and your entire home network.

## Features
- **TUN Mode:** Captures all traffic on the host machine.
- **Whole Network Proxy:** Acts as a network gateway for other devices.
- **Rule-based Routing:** Use Clash-style rules for selective proxying.
- **DNS Hijacking:** Automatically hijacks DNS requests to ensure no leaks.

## Installation
1. Copy this folder (`mihomo-vpn-addon`) to your Home Assistant `/addons/` directory.
2. Restart Home Assistant or go to **Settings > Add-ons > Add-on Store** and select **Check for updates**.
3. Find and install **Mihomo Global VPN**.

## Configuration
Before starting the add-on, you must create a configuration file at `/config/mihomo/config.yaml`.

A sample configuration is provided in the `mihomo` folder of this add-on. You will need to add your own proxy providers or individual proxies to that file.

> **Note:** If Mihomo fails with a GeoIP download error on first start, it means it can't reach GitHub before the proxy is up. Remove or comment out any `GEOIP` rules temporarily until the addon is stable, or bake the `geoip.metadb` file into the image at build time.

## Connecting Individual Devices

### iPhone / iPad
1. Go to **Settings → Wi-Fi** → tap your network → **Configure Proxy**
2. Set to **Manual**
3. **Server:** your HA machine's IP (e.g. `192.168.1.100`)
4. **Port:** `7890`
5. Save and verify at [ipinfo.io](https://ipinfo.io) in Safari.

### Mac
1. Go to **System Settings → Network** → your connection → **Details → Proxies**
2. Enable **Web Proxy (HTTP)** and **Secure Web Proxy (HTTPS)**
3. Set both to your HA machine's IP and port `7890`

## Whole Network VPN (Router-level)

To route all devices on your network through Mihomo, configure your router to hand out the HA machine's IP as the default gateway and DNS server.

### Generic Router
1. Find your HA machine's local IP (e.g. `192.168.1.100`).
2. In your router's DHCP settings, set:
   - **Default Gateway:** HA machine's IP
   - **DNS Server:** HA machine's IP
3. Reconnect your devices (or wait for DHCP lease renewal).

### MikroTik Router
Via WinBox/WebFig: **IP → DHCP Server → Networks** → edit your LAN network and set Gateway and DNS Servers to the HA machine's IP.

Via SSH terminal:
```routeros
/ip dhcp-server network set [find] gateway=192.168.1.100 dns-server=192.168.1.100
/ip dns set servers=192.168.1.100,1.1.1.1
```

> The second DNS (`1.1.1.1`) acts as a fallback in case Mihomo goes down, so your network doesn't lose internet entirely.

## Production Setup (Recommended)

For a reliable always-on setup:

1. **Use dedicated hardware** — run Home Assistant on a Raspberry Pi, mini PC, or similar. Do not run it in a VM on a laptop that sleeps.
2. **Assign a static IP** — set a static IP in HA under **Settings → System → Network**, or assign a static DHCP lease by MAC address on your router. Never use a dynamic IP for a device acting as your network gateway.
3. **Set up auto-restart** — create a Home Assistant automation to restart the Mihomo addon automatically if it goes down.

## Security Warning
This add-on runs with **Privileged** access and **Host Network** mode. It has full control over your machine's network stack. Use only with a configuration you trust.
