#!/bin/bash
# Self-Score Calculator (Platform 5-Dimension Model)
# 对齐平台 auto-scorer 的实际评分逻辑

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== AIBTC Signal Self-Score Calculator ==="
echo ""
echo "基于平台 auto-scorer 源码 (signal-scorer.ts)"
echo ""

# 1. Source Quality (0-30)
echo "1. Source Quality (0-30 分)"
echo "   你有多少个 sources？"
read -p "   Sources 数量: " source_count

if [ "$source_count" -ge 3 ]; then
  source_score=30
  echo -e "   ${GREEN}✅ 30 分 (3+ sources)${NC}"
elif [ "$source_count" -eq 2 ]; then
  source_score=20
  echo -e "   ${YELLOW}⚠️  20 分 (2 sources)${NC}"
elif [ "$source_count" -eq 1 ]; then
  source_score=10
  echo -e "   ${RED}❌ 10 分 (1 source)${NC}"
else
  source_score=0
  echo -e "   ${RED}❌ 0 分 (0 sources)${NC}"
fi

echo ""

# 2. Thesis Clarity (0-25)
echo "2. Thesis Clarity (0-25 分)"
echo "   Headline 有多少个词？"
read -p "   Headline 词数: " headline_words

if [ "$headline_words" -ge 8 ] && [ "$headline_words" -le 15 ]; then
  headline_score=15
  echo -e "   ${GREEN}✅ Headline: 15 分 (8-15 词)${NC}"
elif [ "$headline_words" -lt 8 ]; then
  headline_score=8
  echo -e "   ${YELLOW}⚠️  Headline: 8 分 (<8 词)${NC}"
else
  headline_score=10
  echo -e "   ${YELLOW}⚠️  Headline: 10 分 (>15 词)${NC}"
fi

echo "   Body 有多少个字符？"
read -p "   Body 字符数: " body_chars

if [ "$body_chars" -ge 200 ]; then
  body_score=10
  echo -e "   ${GREEN}✅ Body: 10 分 (≥200 chars)${NC}"
else
  body_score=5
  echo -e "   ${YELLOW}⚠️  Body: 5 分 (<200 chars)${NC}"
fi

thesis_score=$((headline_score + body_score))
echo "   总分: $thesis_score / 25"

echo ""

# 3. Beat Relevance (0-20)
echo "3. Beat Relevance (0-20 分)"
echo "   你的 tags 中有多少个匹配 beat_slug？"
echo "   (例如: bitcoin-macro beat → 'bitcoin', 'macro' 等关键词)"
read -p "   匹配的 tags 数量: " matching_tags

if [ "$matching_tags" -ge 2 ]; then
  beat_score=20
  echo -e "   ${GREEN}✅ 20 分 (2+ matching tags)${NC}"
elif [ "$matching_tags" -eq 1 ]; then
  beat_score=10
  echo -e "   ${YELLOW}⚠️  10 分 (1 matching tag)${NC}"
else
  beat_score=0
  echo -e "   ${RED}❌ 0 分 (0 matching tags)${NC}"
fi

echo ""

# 4. Timeliness (0-15)
echo "4. Timeliness (0-15 分)"
echo "   你的 sources 中有 URL 包含 2025 或 2026 吗？"
read -p "   (y/n): " has_year

if [ "$has_year" == "y" ] || [ "$has_year" == "Y" ]; then
  timeliness_score=15
  echo -e "   ${GREEN}✅ 15 分 (URL 包含年份)${NC}"
else
  timeliness_score=8
  echo -e "   ${YELLOW}⚠️  8 分 (URL 不包含年份)${NC}"
fi

echo ""

# 5. Disclosure (0-10)
echo "5. Disclosure (0-10 分)"
echo "   你的 disclosure 包含 AI 关键词吗？"
echo "   (例如: 'claude', 'gpt', 'openai', 'anthropic', 'model')"
read -p "   (y/n): " has_ai_keyword

if [ "$has_ai_keyword" == "y" ] || [ "$has_ai_keyword" == "Y" ]; then
  disclosure_score=10
  echo -e "   ${GREEN}✅ 10 分 (包含 AI 关键词)${NC}"
else
  disclosure_score=0
  echo -e "   ${RED}❌ 0 分 (不包含 AI 关键词)${NC}"
fi

echo ""

# 总分
total_score=$((source_score + thesis_score + beat_score + timeliness_score + disclosure_score))

echo "=== 总分 ==="
echo "Source Quality:  $source_score / 30"
echo "Thesis Clarity:  $thesis_score / 25"
echo "Beat Relevance:  $beat_score / 20"
echo "Timeliness:      $timeliness_score / 15"
echo "Disclosure:      $disclosure_score / 10"
echo "----------------------------"
echo -e "${GREEN}总分: $total_score / 100${NC}"

echo ""

# 评估
if [ "$total_score" -ge 65 ]; then
  echo -e "${GREEN}✅ 优秀！分数 ≥65，通过 auto-scorer 门槛${NC}"
elif [ "$total_score" -ge 50 ]; then
  echo -e "${YELLOW}⚠️  良好，但建议提升到 ≥65${NC}"
else
  echo -e "${RED}❌ 分数过低，建议改进后再提交${NC}"
fi

echo ""
echo "注意："
echo "1. 这只是 auto-scorer 的表面评分"
echo "2. Editor 还会检查内容质量（T1/T2 sources、数据精度、机制深度）"
echo "3. 高 auto-score 不等于一定通过，低 auto-score 也可能被批准"
