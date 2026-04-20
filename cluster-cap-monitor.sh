#!/bin/bash
# Cluster Cap Real-Time Monitor
# 实时监控 Quantum Beat 各个 cluster 的 cap 状态

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo "=== Quantum Beat Cluster Cap Monitor ==="
echo ""

TODAY=$(date -u +%Y-%m-%d)

# 获取今日所有 quantum beat approved 信号
QUANTUM_SIGNALS=$(curl -s "https://aibtc.news/api/signals?beat=quantum&status=approved&since=${TODAY}T00:00:00Z&limit=100" | \
  jq '[.signals[] | select(.utcDate == "'"$TODAY"'")]')

TOTAL=$(echo "$QUANTUM_SIGNALS" | jq 'length')

echo "今日 Quantum Beat approved 信号: $TOTAL / 10"
echo ""

if [ "$TOTAL" -eq 0 ]; then
  echo -e "${GREEN}✅ 今日无 approved 信号，所有 cluster 都有空间！${NC}"
  exit 0
fi

# 定义 clusters
declare -A CLUSTERS
CLUSTERS["sBTC/Peg"]="sbtc|peg|bridge|wrap"
CLUSTERS["Heavy-Hex"]="heavy.hex|ibm|quantum.volume"
CLUSTERS["NIST/PQC"]="nist|pqc|post.quantum|sphincs|dilithium|kyber"
CLUSTERS["Shor/Grover"]="shor|grover|algorithm|factoring"
CLUSTERS["Qubit/Gate"]="qubit|gate|error.rate|fidelity"
CLUSTERS["Threat-Model"]="threat|attack|vulnerability|exploit"
CLUSTERS["Timeline"]="timeline|roadmap|prediction|forecast"
CLUSTERS["Mitigation"]="mitigation|upgrade|bip|soft.fork"

# 统计每个 cluster
echo "=== Cluster 统计 ==="
echo ""

for cluster in "${!CLUSTERS[@]}"; do
  pattern="${CLUSTERS[$cluster]}"
  
  # 统计匹配的信号数量
  count=$(echo "$QUANTUM_SIGNALS" | jq --arg pattern "$pattern" '
    [.[] | select(
      (.headline | ascii_downcase | test($pattern)) or
      (.body | ascii_downcase | test($pattern))
    )] | length
  ')
  
  # 显示状态
  if [ "$count" -ge 4 ]; then
    echo -e "${RED}❌ $cluster: $count/4 (已满)${NC}"
  elif [ "$count" -ge 3 ]; then
    echo -e "${YELLOW}⚠️  $cluster: $count/4 (接近满)${NC}"
  elif [ "$count" -ge 1 ]; then
    echo -e "${BLUE}ℹ️  $cluster: $count/4 (有空间)${NC}"
  else
    echo -e "${GREEN}✅ $cluster: $count/4 (空闲)${NC}"
  fi
done

echo ""

# 显示今日所有信号的标题
echo "=== 今日 Quantum Beat 信号 ==="
echo ""
echo "$QUANTUM_SIGNALS" | jq -r '.[] | "  - \(.headline)"'

echo ""

# 建议
echo "=== 建议 ==="
echo ""

FULL_CLUSTERS=$(for cluster in "${!CLUSTERS[@]}"; do
  pattern="${CLUSTERS[$cluster]}"
  count=$(echo "$QUANTUM_SIGNALS" | jq --arg pattern "$pattern" '
    [.[] | select(
      (.headline | ascii_downcase | test($pattern)) or
      (.body | ascii_downcase | test($pattern))
    )] | length
  ')
  if [ "$count" -ge 4 ]; then
    echo "$cluster"
  fi
done)

if [ -n "$FULL_CLUSTERS" ]; then
  echo -e "${RED}❌ 以下 cluster 已满 (4/4)，避免提交:${NC}"
  echo "$FULL_CLUSTERS" | while read cluster; do
    echo "  - $cluster"
  done
else
  echo -e "${GREEN}✅ 所有 cluster 都有空间！${NC}"
fi

echo ""

EMPTY_CLUSTERS=$(for cluster in "${!CLUSTERS[@]}"; do
  pattern="${CLUSTERS[$cluster]}"
  count=$(echo "$QUANTUM_SIGNALS" | jq --arg pattern "$pattern" '
    [.[] | select(
      (.headline | ascii_downcase | test($pattern)) or
      (.body | ascii_downcase | test($pattern))
    )] | length
  ')
  if [ "$count" -eq 0 ]; then
    echo "$cluster"
  fi
done)

if [ -n "$EMPTY_CLUSTERS" ]; then
  echo -e "${GREEN}✅ 以下 cluster 完全空闲 (0/4)，优先考虑:${NC}"
  echo "$EMPTY_CLUSTERS" | while read cluster; do
    echo "  - $cluster"
  done
fi
