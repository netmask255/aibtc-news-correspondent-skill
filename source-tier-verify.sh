#!/bin/bash
# Source Tier Verification Tool
# 自动分类 sources 为 T1/T2/T3/T4

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# T1 PRIMARY_DOMAINS (Quantum Beat)
T1_DOMAINS=(
  "eprint.iacr.org"
  "arxiv.org"
  "nist.gov"
  "github.com"
  "bitcoinops.org"
  "bitcoin.org"
  "btcstudy.org"
  "nakamotoinstitute.org"
)

# T2 SECONDARY_DOMAINS
T2_DOMAINS=(
  "bitcoinmagazine.com"
  "coindesk.com"
  "theblock.co"
  "decrypt.co"
  "cointelegraph.com"
  "blockworks.co"
  "dlnews.com"
)

# T3 TERTIARY_DOMAINS
T3_DOMAINS=(
  "twitter.com"
  "x.com"
  "medium.com"
  "substack.com"
  "reddit.com"
)

classify_source() {
  local url=$1
  
  # 提取域名
  domain=$(echo "$url" | sed -E 's|https?://([^/]+).*|\1|' | sed 's/^www\.//')
  
  # 检查 T1
  for t1 in "${T1_DOMAINS[@]}"; do
    if [[ "$domain" == *"$t1"* ]]; then
      echo "T1"
      return
    fi
  done
  
  # 检查 T2
  for t2 in "${T2_DOMAINS[@]}"; do
    if [[ "$domain" == *"$t2"* ]]; then
      echo "T2"
      return
    fi
  done
  
  # 检查 T3
  for t3 in "${T3_DOMAINS[@]}"; do
    if [[ "$domain" == *"$t3"* ]]; then
      echo "T3"
      return
    fi
  done
  
  # 默认 T4
  echo "T4"
}

# 主函数
if [ $# -eq 0 ]; then
  echo "Usage: $0 <url1> [url2] [url3] ..."
  echo ""
  echo "Example:"
  echo "  $0 https://eprint.iacr.org/2017/598 https://twitter.com/aibtcdev"
  exit 1
fi

echo "=== Source Tier Verification ==="
echo ""

total=0
t1_count=0
t2_count=0
t3_count=0
t4_count=0

for url in "$@"; do
  tier=$(classify_source "$url")
  total=$((total + 1))
  
  case $tier in
    T1)
      echo -e "${GREEN}✅ T1 (PRIMARY):${NC} $url"
      t1_count=$((t1_count + 1))
      ;;
    T2)
      echo -e "${BLUE}ℹ️  T2 (SECONDARY):${NC} $url"
      t2_count=$((t2_count + 1))
      ;;
    T3)
      echo -e "${YELLOW}⚠️  T3 (TERTIARY):${NC} $url"
      t3_count=$((t3_count + 1))
      ;;
    T4)
      echo -e "${RED}❌ T4 (UNKNOWN):${NC} $url"
      t4_count=$((t4_count + 1))
      ;;
  esac
done

echo ""
echo "=== Summary ==="
echo "Total sources: $total"
echo -e "${GREEN}T1 (PRIMARY): $t1_count${NC}"
echo -e "${BLUE}T2 (SECONDARY): $t2_count${NC}"
echo -e "${YELLOW}T3 (TERTIARY): $t3_count${NC}"
echo -e "${RED}T4 (UNKNOWN): $t4_count${NC}"

echo ""

# 建议
if [ $t1_count -ge 2 ]; then
  echo -e "${GREEN}✅ 优秀！至少 2 个 T1 sources${NC}"
elif [ $t1_count -ge 1 ]; then
  echo -e "${BLUE}ℹ️  良好，有 1 个 T1 source，建议再添加 1 个${NC}"
else
  echo -e "${RED}❌ 警告：没有 T1 sources，建议至少添加 1-2 个${NC}"
fi

if [ $t3_count -ge 2 ]; then
  echo -e "${YELLOW}⚠️  注意：T3 sources 过多（$t3_count 个），可能被视为低质量${NC}"
fi

if [ $t4_count -ge 1 ]; then
  echo -e "${RED}❌ 警告：有 $t4_count 个 T4 (UNKNOWN) sources，建议替换为 T1/T2${NC}"
fi
