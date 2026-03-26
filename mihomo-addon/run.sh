#!/usr/bin/with-contenv bashio

bashio::log.info "Starting Mihomo VPN Add-on..."

# Wait for network to be ready
bashio::net.wait_for_interface || sleep 5

# Enable IP Forwarding
bashio::log.info "Enabling IP Forwarding..."
if [ "$(cat /proc/sys/net/ipv4/ip_forward)" = "1" ]; then
    bashio::log.info "IP Forwarding is already enabled."
else
    sysctl -w net.ipv4.ip_forward=1 || echo 1 > /proc/sys/net/ipv4/ip_forward || bashio::log.warning "Failed to set net.ipv4.ip_forward=1. Whole network gateway might not work."
fi

# Set up MASQUERADE
bashio::log.info "Setting up IPTables Masquerade..."
iptables -t nat -A POSTROUTING -j MASQUERADE || bashio::log.warning "Failed to set iptables MASQUERADE"

# Get Config path from options
CONFIG_PATH=$(bashio::config 'config_path')

# In some versions of HA, /config is mounted as /homeassistant
# Let's check both if necessary
if [ ! -f "${CONFIG_PATH}" ] && [ -f "/homeassistant/mihomo/config.yaml" ]; then
    CONFIG_PATH="/homeassistant/mihomo/config.yaml"
fi

bashio::log.info "Using config: ${CONFIG_PATH}"

# Check if config directory exists, if not create it
CONFIG_DIR=$(dirname "${CONFIG_PATH}")
if [ ! -d "${CONFIG_DIR}" ]; then
    bashio::log.info "Creating config directory: ${CONFIG_DIR}"
    mkdir -p "${CONFIG_DIR}"
fi

# If the user pasted config content in the add-on UI, write it to the file
CONFIG_CONTENT=$(jq -r '.config_content // empty' /data/options.json)
if [ -n "${CONFIG_CONTENT}" ]; then
    bashio::log.info "Writing config from add-on configuration tab..."
    printf '%s\n' "${CONFIG_CONTENT}" > "${CONFIG_PATH}"
# Otherwise fall back to auto-creating from the default template
elif [ ! -f "${CONFIG_PATH}" ]; then
    bashio::log.warning "No config found at ${CONFIG_PATH}. Creating a default config."
    bashio::log.warning "Paste your config in the Configuration tab or edit ${CONFIG_PATH} directly, then restart."
    cp /defaults/config.yaml "${CONFIG_PATH}"
fi

# Set capabilities (redundant but safe)
setcap cap_net_admin,cap_net_raw+ep /usr/bin/mihomo

# Start Mihomo
bashio::log.info "Executing Mihomo binary..."
exec /usr/bin/mihomo -d "${CONFIG_DIR}" -f "${CONFIG_PATH}"
