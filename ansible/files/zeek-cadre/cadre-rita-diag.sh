#!/bin/bash
# RITA ClickHouse diagnostic — run on provisioning VM
DB="${1:-cadre_test}"

echo "=== Tables with data ==="
echo "SELECT table, sum(rows) AS row_count FROM system.parts WHERE database='${DB}' AND active=1 GROUP BY table ORDER BY row_count DESC" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== conn rows ==="
echo "SELECT count(*) FROM ${DB}.conn" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== uconn rows ==="
echo "SELECT count(*) FROM ${DB}.uconn" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== dns rows ==="
echo "SELECT count(*) FROM ${DB}.dns" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== http rows ==="
echo "SELECT count(*) FROM ${DB}.http" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== ssl rows ==="
echo "SELECT count(*) FROM ${DB}.ssl" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== uconn top connections ==="
echo "SELECT src, dst, countMerge(count) AS conn_cnt, sumMerge(total_duration) AS total_secs, sumMerge(total_ip_bytes) AS total_bytes FROM ${DB}.uconn GROUP BY src, dst ORDER BY conn_cnt DESC LIMIT 10" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== uconn duration ==="
echo "SELECT src, dst, sumMerge(total_duration) AS total_secs, countMerge(count) AS conn_cnt FROM ${DB}.uconn GROUP BY src, dst ORDER BY total_secs DESC LIMIT 10" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== DNS query volume ==="
echo "SELECT src, dst, count(*) AS cnt FROM ${DB}.dns GROUP BY src, dst ORDER BY cnt DESC LIMIT 10" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== HTTP POST ==="
echo "SELECT src, dst, method, uri, count(*) AS cnt FROM ${DB}.http WHERE method='POST' GROUP BY src, dst, method, uri ORDER BY cnt DESC LIMIT 10" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null

echo ""
echo "=== SSL summary ==="
echo "SELECT src, dst, server_name, ssl_version, count(*) AS cnt FROM ${DB}.ssl GROUP BY src, dst, server_name, ssl_version ORDER BY cnt DESC LIMIT 10" | \
  ssh -o StrictHostKeyChecking=accept-new vagrant@192.168.77.55 \
  sudo docker exec -i rita-clickhouse clickhouse-client 2>/dev/null
