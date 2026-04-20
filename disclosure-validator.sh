#!/bin/bash
# Disclosure Format Validator
# 验证 disclosure 是否符合平台即将强制的格式要求

set -e

# 颜色
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m'

echo "=== Disclosure Format Validator ==="
echo ""

if [ $# -eq 0 ]; then
  echo "Usage: $0 \"<disclosure_text>\""
  echo ""
  echo "Example:"
  echo "  $0 \"claude-opus-4-6, https://github.com/netmask255/aibtc-news-correspondent-skill\""
  exit 1
fi

DISCLOSURE="$1"

echo "检查 disclosure: $DISCLOSURE"
echo ""

# 检查项
has_model=false
has_tool=false
has_comma=false

# 1. 检查是否包含 AI 模型名称
AI_MODELS=(
  "claude"
  "gpt"
  "openai"
  "anthropic"
  "gemini"
  "llama"
  "mistral"
  "qwen"
  "deepseek"
  "opus"
  "sonnet"
  "haiku"
)

for model in "${AI_MODELS[@]}"; do
  if [[ "$DISCLOSURE" == *"$model"* ]]; then
    has_model=true
    echo -e "${GREEN}✅ 包含 AI 模型名称: $model${NC}"
    break
  fi
done

if [ "$has_model" = false ]; then
  echo -e "${RED}❌ 未包含 AI 模型名称${NC}"
  echo "   建议: 添加模型名称（如 'claude-opus-4-6', 'gpt-4', 'gemini-pro'）"
fi

echo ""

# 2. 检查是否包含工具/技能 URL 或 API endpoint
if [[ "$DISCLOSURE" == *"http"* ]] || [[ "$DISCLOSURE" == *"github"* ]] || [[ "$DISCLOSURE" == *"skill"* ]] || [[ "$DISCLOSURE" == *"api"* ]]; then
  has_tool=true
  echo -e "${GREEN}✅ 包含工具/技能引用${NC}"
else
  echo -e "${YELLOW}⚠️  未包含工具/技能引用${NC}"
  echo "   建议: 添加 SKILL URL 或 API endpoint"
fi

echo ""

# 3. 检查格式（逗号分隔）
if [[ "$DISCLOSURE" == *","* ]]; then
  has_comma=true
  echo -e "${GREEN}✅ 使用逗号分隔${NC}"
else
  echo -e "${YELLOW}⚠️  未使用逗号分隔${NC}"
  echo "   建议格式: {model}, {tool/skill URL}"
fi

echo ""

# 总结
echo "=== 验证结果 ==="

if [ "$has_model" = true ] && [ "$has_tool" = true ] && [ "$has_comma" = true ]; then
  echo -e "${GREEN}✅ 完美！disclosure 格式完全符合要求${NC}"
  echo ""
  echo "示例格式:"
  echo "  claude-opus-4-6, https://github.com/netmask255/aibtc-news-correspondent-skill"
  exit 0
elif [ "$has_model" = true ]; then
  echo -e "${YELLOW}⚠️  良好，但建议添加工具/技能引用${NC}"
  echo ""
  echo "当前: $DISCLOSURE"
  echo "建议: $DISCLOSURE, https://github.com/netmask255/aibtc-news-correspondent-skill"
  exit 1
else
  echo -e "${RED}❌ 格式不符合要求${NC}"
  echo ""
  echo "当前: $DISCLOSURE"
  echo "建议: claude-opus-4-6, https://github.com/netmask255/aibtc-news-correspondent-skill"
  exit 1
fi
