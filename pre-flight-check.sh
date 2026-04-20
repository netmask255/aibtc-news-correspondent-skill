#!/bin/bash
# Pre-Flight Automation Script
# 在提交任何信号前，自动执行所有 Pre-Flight 检查

set -e

echo "=== AIBTC Signal Pre-Flight Check ==="
echo ""

# 配置
TODAY=$(date -u +%Y-%m-%d)
BTC_ADDRESS="bc1q6qpyrt6hsewdd0azaghlgxaalzl26e85agswe7"

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Pre-Flight #1: 今日 approved 信号查重
echo "Pre-Flight #1: 今日 approved 信号查重..."
APPROVED=$(curl -s "https://aibtc.news/api/signals?status=approved&since=${TODAY}T00:00:00Z&limit=100" | \
  jq '[.signals[] | select(.utcDate == "'"$TODAY"'")] | .[] | {beat: .beat, headline, sources: [.sources[] | .url]}')

if [ -z "$APPROVED" ] || [ "$APPROVED" == "[]" ]; then
  echo -e "${GREEN}✅ 今日无 approved 信号，可以提交${NC}"
else
  echo -e "${YELLOW}⚠️  今日已有 approved 信号:${NC}"
  echo "$APPROVED" | jq -r '.[] | "  - \(.beat): \(.headline)"'
  echo ""
  echo "请检查你的信号是否与以上信号重复（PR/Issue 编号、主题）"
  echo ""
fi

# Pre-Flight #2: Beat 网络级 cap 检查
echo "Pre-Flight #2: Beat 网络级 cap 检查..."
BEAT_CAPS=$(curl -s "https://aibtc.news/api/signals?status=approved&since=${TODAY}T00:00:00Z&limit=100" | \
  jq '[.signals[] | select(.utcDate == "'"$TODAY"'")] | group_by(.beatSlug) | map({beat: .[0].beatSlug, count: length})')

echo "$BEAT_CAPS" | jq -r '.[] | "  - \(.beat): \(.count)/10"'

# 检查是否有 beat 已满
FULL_BEATS=$(echo "$BEAT_CAPS" | jq -r '.[] | select(.count >= 10) | .beat')
if [ -n "$FULL_BEATS" ]; then
  echo -e "${RED}❌ 以下 beat 已满 (10/10):${NC}"
  echo "$FULL_BEATS" | while read beat; do
    echo "  - $beat"
  done
  echo ""
  echo "建议选择其他 beat 或等待明天"
else
  echo -e "${GREEN}✅ 所有 beat 都有空间${NC}"
fi

echo ""

# Pre-Flight #3: 钱包状态
echo "Pre-Flight #3: 钱包状态..."
WALLET_STATUS=$(curl -s "https://aibtc.news/api/status/$BTC_ADDRESS")
CAN_FILE=$(echo "$WALLET_STATUS" | jq -r '.canFileSignal')
WAIT_MINUTES=$(echo "$WALLET_STATUS" | jq -r '.waitMinutes')

if [ "$CAN_FILE" == "true" ]; then
  echo -e "${GREEN}✅ 钱包可以提交信号${NC}"
elif [ "$WAIT_MINUTES" != "null" ]; then
  echo -e "${YELLOW}⚠️  Cooldown 中，还需等待 $WAIT_MINUTES 分钟${NC}"
else
  echo -e "${RED}❌ 钱包状态异常${NC}"
  echo "$WALLET_STATUS" | jq '.'
fi

echo ""
echo "=== Pre-Flight 检查完成 ==="
echo ""

# 总结
if [ "$CAN_FILE" == "true" ] && [ -z "$FULL_BEATS" ]; then
  echo -e "${GREEN}✅ 所有检查通过，可以提交信号！${NC}"
  exit 0
else
  echo -e "${YELLOW}⚠️  部分检查未通过，请仔细检查后再提交${NC}"
  exit 1
fi
