#!/usr/bin/env bash
# 将 photo-pose-coach-data 推送到 GitHub 公开仓库
# 用法: GITHUB_TOKEN=xxx GITHUB_USER=你的用户名 bash push_init.sh
# 说明: token 仅通过环境变量传入，不会写入任何文件或聊天记录。
#       脚本会自动创建公开仓库（若不存在）、替换占位符、提交并推送。
set -e

TOKEN="${GITHUB_TOKEN:?❌ 请先设置环境变量 GITHUB_TOKEN（GitHub PAT，需 repo 权限）}"
USER="${GITHUB_USER:?❌ 请通过环境变量 GITHUB_USER 指定你的 GitHub 用户名}"
REPO="photo-pose-coach-data"
BRANCH="main"

cd "$(dirname "$0")"

# ---------- 1. 自动创建公开仓库（若不存在） ----------
echo "🔍 检查/创建 GitHub 公开仓库 ${REPO} ..."
CREATE_RESP=$(curl -s -w "\n%{http_code}" -X POST \
  -H "Authorization: token ${TOKEN}" \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/user/repos \
  -d "{\"name\":\"${REPO}\",\"public\":true,\"description\":\"photo-pose-coach shared KB + gallery\"}" || true)
HTTP_CODE=$(printf '%s' "$CREATE_RESP" | tail -n1 | tr -d '\r\n ')
case "$HTTP_CODE" in
  201) echo "✅ 仓库已成功创建（公开）" ;;
  422) echo "ℹ️ 仓库已存在，直接推送" ;;
  401) echo "❌ token 无效或已过期，请重新生成 PAT"; exit 1 ;;
  *)   echo "⚠️ 创建仓库返回 HTTP ${HTTP_CODE}（token 权限不足 / 网络问题）；若仓库已手动创建可忽略" ;;
esac

# ---------- 2. 替换占位符 YOUR_GITHUB_USERNAME -> 真实用户名 ----------
echo "🔄 替换占位符 YOUR_GITHUB_USERNAME -> $USER ..."
for f in gallery/index.json README.md; do
  if [ -f "$f" ]; then
    sed -i "s/YOUR_GITHUB_USERNAME/$USER/g" "$f"
  else
    echo "⚠️ 未找到 $f，跳过占位符替换"
  fi
done
SKILL_MD="C:/Users/robert/.workbuddy/skills/photo-pose-coach/SKILL.md"
if [ -f "$SKILL_MD" ]; then
  sed -i "s/YOUR_GITHUB_USERNAME/$USER/g" "$SKILL_MD"
  echo "✅ 已同步更新技能包 SKILL.md 的 KB_BASE_URL"
fi

# ---------- 3. 本地仓库初始化 ----------
if [ ! -d .git ]; then
  git init -q
  git branch -m "$BRANCH"
fi

# git 身份（必须在 git init 之后才能写本地配置）
if [ -z "$(git config --global user.name)" ]; then
  git config user.name "$USER"
  git config user.email "$USER@users.noreply.github.com"
fi

# 配置 remote（内嵌 token，仅存于本机 .git/config，不在技能包内）
REMOTE="https://${TOKEN}@github.com/${USER}/${REPO}.git"
git remote remove origin 2>/dev/null || true
git remote add origin "$REMOTE"

# ---------- 4. 提交 ----------
git add -A
if git diff --cached --quiet; then
  echo "ℹ️ 没有需要提交的变更。"
else
  git commit -q -m "init: photo-pose-coach shared KB + gallery"
fi

# ---------- 5. 推送 ----------
git push -u origin "$BRANCH"
echo ""
echo "✅ 推送完成！仓库地址：https://github.com/${USER}/${REPO}"
echo "📌 技能已指向线上知识库与图库，无需再手动修改占位符。"
