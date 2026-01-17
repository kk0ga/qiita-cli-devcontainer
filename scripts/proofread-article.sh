#!/bin/bash
# Copilot CLI を使った記事校正スクリプト

set -e

ARTICLE_PATH="${1:-.}"
PROMPT_FILE=".vscode/prompts/proofread.prompt.md"
COPILOT_MODEL="${COPILOT_MODEL:-gpt-5.2}"
COPILOT_CONFIG_DIR="${COPILOT_CONFIG_DIR:-/workspace/.copilot-cli}"

echo "📝 記事校正を開始します..."
echo "  記事ファイル: $ARTICLE_PATH"
echo "  プロンプト: $PROMPT_FILE"
echo ""

# Copilot CLIでレビューを実行
# プロンプトファイルの @ARTICLE_PATH をファイルパスに置換
copilot -p "$(sed "s|@ARTICLE_PATH|@${ARTICLE_PATH}|g" "${PROMPT_FILE}")" \
  --config-dir "${COPILOT_CONFIG_DIR}" \
  --model "${COPILOT_MODEL}" \
  --allow-tool 'write'

echo ""
echo "✅ 校正完了！"
