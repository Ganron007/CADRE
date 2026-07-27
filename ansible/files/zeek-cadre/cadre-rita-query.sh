#!/bin/bash
# cadre-rita-query.sh — Query RITA ClickHouse data from provisioning VM
# Usage: ./cadre-rita-query.sh [database_name]
# Default: cadre_test

DB="${1:-cadre_test}"

echo "=== Top Connections by Count (beacon candidates) ==="
echo "SELECT src, dst, countMerge(count) AS conn_cnt, sumMerge(total_duration) AS total_secs, sumMerge(total_ip_bytes) AS total_bytes FROM ${DB}.uconn GROUP BY src, dst ORDER BY conn_cnt DESC LIMIT 15" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== Top Connections by Duration (long-connection candidates) ==="
echo "SELECT src, dst, sumMerge(total_duration) AS total_secs, countMerge(count) AS conn_cnt FROM ${DB}.uconn GROUP BY src, dst ORDER BY total_secs DESC LIMIT 15" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== Top Connections by Total Bytes (data exfil candidates) ==="
echo "SELECT src, dst, sumMerge(total_ip_bytes) AS total_bytes, countMerge(count) AS conn_cnt FROM ${DB}.uconn GROUP BY src, dst ORDER BY total_bytes DESC LIMIT 15" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== DNS Query Volume (potential C2/DGA) ==="
echo "SELECT src, dst, count(*) AS dns_count FROM ${DB}.dns GROUP BY src, dst ORDER BY dns_count DESC LIMIT 10" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== HTTP POST Events ==="
echo "SELECT src, dst, method, uri, count(*) AS cnt FROM ${DB}.http WHERE method='POST' GROUP BY src, dst, method, uri ORDER BY cnt DESC LIMIT 10" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== SSL/TLS Anomalies (unusual ciphers, self-signed) ==="
echo "SELECT src, dst, server_name, ssl_version, count(*) AS cnt FROM ${DB}.ssl GROUP BY src, dst, server_name, ssl_version ORDER BY cnt DESC LIMIT 10" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== RITA Analysis Complete ==="
