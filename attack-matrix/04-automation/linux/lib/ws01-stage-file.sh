#!/bin/bash
# CONFIG lane: stage files on ws01 via vagrant WinRM (local admin).
# Attacks use ws01-exec.sh (analyst_t1 / earned AD creds) — not this script for execution.
# Usage: ws01-stage-file.sh <local-path> [remote-basename]
set -euo pipefail

SRC="${1:?local file required}"
BASENAME="${2:-$(basename "$SRC")}"
REMOTE="C:/Tools/cadre-attack/${BASENAME}"
WS01_IP="${WS01_IP:-192.168.77.62}"
OPENSSL_LEGACY="${OPENSSL_LEGACY:-/tmp/openssl_legacy.cnf}"

[[ -f "$SRC" ]] || { echo "missing: $SRC" >&2; exit 1; }

if [[ ! -f "$OPENSSL_LEGACY" ]]; then
  cat > "$OPENSSL_LEGACY" <<'EOF'
openssl_conf = openssl_init
[openssl_init]
providers = provider_sect
[provider_sect]
default = default_sect
legacy = legacy_sect
[default_sect]
activate = 1
[legacy_sect]
activate = 1
EOF
fi
export OPENSSL_CONF="$OPENSSL_LEGACY"

B64=$(base64 -w0 "$SRC" 2>/dev/null || base64 "$SRC" | tr -d '\n')
REMOTE_WIN=$(echo "$REMOTE" | tr '/' '\\')

CONN=(
  -i "${WS01_IP},"
  -e ansible_user=vagrant
  -e ansible_password=vagrant
  -e ansible_connection=winrm
  -e ansible_winrm_transport=basic
  -e ansible_winrm_scheme=http
  -e ansible_port=5985
  -e ansible_winrm_server_cert_validation=ignore
)

ansible "${CONN[@]}" all -m win_shell -a "
\$dir = 'C:\\Tools\\cadre-attack'
New-Item -ItemType Directory -Force -Path \$dir | Out-Null
try { Add-MpPreference -ExclusionPath \$dir -Force } catch {}
\$b64 = @'
${B64}
'@
\$bytes = [Convert]::FromBase64String(\$b64)
[IO.File]::WriteAllBytes('${REMOTE_WIN}', \$bytes)
Get-Item '${REMOTE_WIN}' | Select-Object FullName,Length
"

echo "Staged: ${REMOTE}"
