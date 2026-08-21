#!/bin/bash
# Live apply for vr when Ansible (provisioning) is down. Keep in sync with 14-velociraptor.yml.
set -euo pipefail
mkdir -p /opt/cadre-vr-mcp
install -m 0755 /tmp/mcp_server.py /opt/cadre-vr-mcp/mcp_server.py
install -m 0755 /tmp/patch_catalog.py /opt/cadre-vr-mcp/patch_catalog.py
cp -a /etc/velociraptor/server.config.yaml "/etc/velociraptor/server.config.yaml.bak-$(date -u +%Y%m%d)"
python3 /opt/cadre-vr-mcp/patch_catalog.py /etc/velociraptor/server.config.yaml
chmod 600 /etc/velociraptor/server.config.yaml
if [ ! -f /etc/velociraptor/api_client.yaml ]; then
  /usr/local/bin/velociraptor --config /etc/velociraptor/server.config.yaml \
    config api_client --name cadre-mcp --role administrator \
    /etc/velociraptor/api_client.yaml
  chmod 600 /etc/velociraptor/api_client.yaml
fi
/usr/local/bin/velociraptor --config /etc/velociraptor/server.config.yaml \
  user add --role administrator cadre-mcp 'CadreVrMcp!Lab2026' || true
/usr/local/bin/velociraptor --config /etc/velociraptor/server.config.yaml \
  acl grant cadre-mcp --role administrator || true
systemctl restart velociraptor
for _ in $(seq 1 30); do
  ss -lntp | grep -q ":8889" && break
  sleep 2
done
echo "---LISTEN---"
ss -lntp | grep -E "8000|8001|8002|8889" || true
echo "---CATALOG---"
/usr/local/bin/velociraptor --config /etc/velociraptor/server.config.yaml artifacts list 2>/dev/null | grep CADRE || echo CATALOG_MISS
cat >/etc/velociraptor/mcp.env <<'EOF'
VR_MCP_BIND=0.0.0.0
VR_MCP_PORT=8002
VR_MCP_API_KEY=CadreVrMcp!Lab2026
VR_API_CONFIG=/etc/velociraptor/api_client.yaml
VR_BIN=/usr/local/bin/velociraptor
EOF
chmod 600 /etc/velociraptor/mcp.env
cat >/etc/systemd/system/velociraptor-mcp.service <<'EOF'
[Unit]
Description=Velociraptor MCP HTTP front (Nexus RemoteVRMCPClient)
After=network.target velociraptor.service
Wants=velociraptor.service
[Service]
Type=simple
User=root
EnvironmentFile=/etc/velociraptor/mcp.env
ExecStart=/usr/bin/python3 /opt/cadre-vr-mcp/mcp_server.py
Restart=always
RestartSec=3
[Install]
WantedBy=multi-user.target
EOF
systemctl daemon-reload
systemctl enable --now velociraptor-mcp
sleep 2
systemctl is-active velociraptor velociraptor-mcp
echo "---HEALTH---"
curl -fsS http://127.0.0.1:8002/health; echo
echo "---VQL---"
curl -fsS -H "Authorization: Bearer CadreVrMcp!Lab2026" -H "Content-Type: application/json" \
  -d '{"vql":"SELECT 1 AS ok","timeout_seconds":15}' \
  http://127.0.0.1:8002/vql; echo
touch /var/lib/velociraptor/.artifacts_imported /var/lib/velociraptor/.hunts_imported
echo LIVE_VR_APPLY_DONE
