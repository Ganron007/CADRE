#!/bin/bash
# cadre-rita-analyze.sh — Run RITA analysis session (unmask → import → analyze → re-mask)
# Usage: sudo ./cadre-rita-analyze.sh [database_name] [logs_path]
# Example: sudo ./cadre-rita-analyze.sh cadre_session /opt/zeek/logs/current/
# Default: cadre_session, /opt/zeek/logs/current/
# NOTE: RITA v5.1.2 requires underscores in database names (no hyphens).

DB="${1:-cadre_session}"
LOGS="${2:-/opt/zeek/logs/current}"
# Replace any hyphens with underscores (RITA v5 rejects hyphens in DB names)
DB="${DB//-/_}"

echo "=== RITA Analysis Session ==="
echo "Database: $DB"
echo "Logs: $LOGS"
echo ""

# Step 1: Unmask and start Docker (also unmask containerd — needed by Docker)
echo "[1/6] Starting Docker..."
sudo systemctl unmask containerd 2>/dev/null
sudo systemctl start containerd
sleep 2
sudo systemctl unmask docker 2>/dev/null
sudo systemctl start docker
sleep 5

# Step 2: Import Zeek logs
echo "[2/6] Importing Zeek logs into RITA..."
sudo rita import --database="$DB" --logs="$LOGS"
echo ""

# Step 3: Query RITA via ClickHouse SQL for C2/beacon-like analysis
echo "[3/6] Beacon candidates (high connection count between same src/dst):"
echo "SELECT src, dst, countMerge(count) AS conn_cnt, sumMerge(total_duration) AS total_secs, sumMerge(total_ip_bytes) AS total_bytes FROM $DB.uconn GROUP BY src, dst ORDER BY conn_cnt DESC LIMIT 15" | \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null
echo ""

echo "--- Long Connections (by total duration) ---"
echo "SELECT src, dst, sumMerge(total_duration) AS total_secs, countMerge(count) AS conn_cnt FROM $DB.uconn GROUP BY src, dst ORDER BY total_secs DESC LIMIT 15" | \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null
echo ""

echo "--- Data Exfil Candidates (by total bytes) ---"
echo "SELECT src, dst, sumMerge(total_ip_bytes) AS total_bytes, countMerge(count) AS conn_cnt FROM $DB.uconn GROUP BY src, dst ORDER BY total_bytes DESC LIMIT 15" | \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null
echo ""

echo "--- DNS Query Volume ---"
echo "SELECT src, dst, count(*) AS dns_count FROM $DB.dns GROUP BY src, dst ORDER BY dns_count DESC LIMIT 10" | \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null
echo ""

echo "--- HTTP POST Events ---"
echo "SELECT src, dst, method, uri, count(*) AS cnt FROM $DB.http WHERE method='POST' GROUP BY src, dst, method, uri ORDER BY cnt DESC LIMIT 10" | \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null
echo ""

echo "--- SSL/TLS Summary ---"
echo "SELECT src, dst, server_name, ssl_version, count(*) AS cnt FROM $DB.ssl GROUP BY src, dst, server_name, ssl_version ORDER BY cnt DESC LIMIT 10" | \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null
echo ""

# Step 4: Delete database (cleanup — RITA only supports one-shot analysis)
echo "[4/6] Cleaning up database..."
echo "DROP TABLE IF EXISTS $DB.conn" | sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null
echo y | sudo rita delete "$DB" 2>/dev/null || true
echo ""

# Step 5: Stop Docker and re-mask
echo "[5/6] Stopping Docker..."
sudo rita down 2>/dev/null
sudo systemctl stop docker
sudo systemctl mask docker
sudo systemctl stop containerd
sudo systemctl mask containerd
echo "Docker masked."
echo ""

# Step 6: Clear known_hosts (monitor has dynamic SSH keys for lab VMs)
ssh-keygen -f /home/vagrant/.ssh/known_hosts -R 192.168.77.55 2>/dev/null || true


