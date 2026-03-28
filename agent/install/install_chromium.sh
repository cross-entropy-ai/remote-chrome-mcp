#!/usr/bin/env bash
set -ex

apt-get update

# Ubuntu Noble: install from Debian bookworm repos
apt-get install -y software-properties-common
apt-get remove -y chromium-browser-l10n chromium-codecs-ffmpeg chromium-browser 2>/dev/null || true

mkdir -p /etc/apt/keyrings
curl -fsSL https://ftp-master.debian.org/keys/archive-key-12.asc | tee /etc/apt/keyrings/debian-archive-key-12.asc
echo "deb [signed-by=/etc/apt/keyrings/debian-archive-key-12.asc] http://deb.debian.org/debian bookworm main" | tee /etc/apt/sources.list.d/debian-bookworm.list
echo -e "Package: *\nPin: release a=bookworm\nPin-Priority: 100" | tee /etc/apt/preferences.d/debian-bookworm
apt-get update
apt-get install -y chromium --no-install-recommends

# Cleanup bookworm repos
rm /etc/apt/sources.list.d/debian-bookworm.list
rm /etc/apt/preferences.d/debian-bookworm
rm /etc/apt/keyrings/debian-archive-key-12.asc
apt-get update

REAL_BIN=chromium

mv /usr/bin/${REAL_BIN} /usr/bin/${REAL_BIN}-orig
cat >/usr/bin/${REAL_BIN} <<'EOL'
#!/usr/bin/env bash
if ! pgrep chromium > /dev/null; then
  rm -f /home/rcm/chrome/Singleton*
fi
sed -i 's/"exited_cleanly":false/"exited_cleanly":true/' /home/rcm/chrome/Default/Preferences 2>/dev/null || true
sed -i 's/"exit_type":"Crashed"/"exit_type":"None"/' /home/rcm/chrome/Default/Preferences 2>/dev/null || true
/usr/bin/chromium-orig --password-store=basic --no-sandbox --ignore-gpu-blocklist --disable-dev-shm-usage --user-data-dir=/home/rcm/chrome --no-first-run "$@"
EOL
chmod +x /usr/bin/${REAL_BIN}

mkdir -p /etc/chromium/policies/managed/
cat >/etc/chromium/policies/managed/default_managed_policy.json <<'EOL'
{"CommandLineFlagSecurityWarningsEnabled": false, "DefaultBrowserSettingEnabled": false}
EOL
