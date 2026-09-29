# photo-pose-coach-data

`photo-pose-coach` 技能的**线上共享数据仓库**。该技能（拍照姿势教练）会把从网络平台每日学习到的最新网红拍照套路、以及精选的姿势参考示范照，托管在本公开仓库，供所有安装该技能的用户通过 `WebFetch` 实时读取、共享。

## 目录结构

```
photo-pose-coach-data/
├── README.md                  ← 本说明
├── kb/
│   └── trending-pose-kb.md    ← 线上知识库（每日自动更新）
└── gallery/
    ├── index.json             ← 图库索引（URL + 场景 + 姿势 + 要点 + 积分）
    └── *.png                  ← 精选姿势参考示范照（共享照片库）
```

## 线上资源访问地址（请将 robertyang45 替换为你的 GitHub 用户名）

- 知识库（每天更新的网红拍照套路）：
  `https://raw.githubusercontent.com/robertyang45/photo-pose-coach-data/main/kb/trending-pose-kb.md`
- 图库索引（JSON）：
  `https://raw.githubusercontent.com/robertyang45/photo-pose-coach-data/main/gallery/index.json`
- 单张参考照（直接图片 URL，可在聊天里以 `![alt](url)` 内联显示）：
  `https://raw.githubusercontent.com/robertyang45/photo-pose-coach-data/main/gallery/<文件名>.png`

## 本地维护（skill 作者侧）

1. 生成一个 **Personal Access Token（PAT，勾选 `repo` 权限）**：
   GitHub → Settings → Developer settings → Personal access tokens → Tokens (classic) → Generate new token。
   （找不到入口可直接打开 **https://github.com/settings/tokens** ）
2. 运行推送脚本（**仓库无需手动创建**，脚本会用 token 自动创建公开仓库；token 从环境变量读取，请勿粘贴到聊天里）：
   ```bash
   cd pose-coach-data
   GITHUB_TOKEN=你的token GITHUB_USER=你的用户名 bash push_init.sh
   ```
   脚本会自动完成：创建公开仓库 → 替换占位符 `robertyang45`（含技能包 `SKILL.md` 的 `KB_BASE_URL`）→ `git init` → 配置 remote → 提交并推送到 `main`。
3. 推送完成后技能即刻指向线上知识库与图库，无需任何手动改动。

> 本机 Git Bash 位置（如需自行执行）：`C:\Program Files\Git\git-bash.exe`，双击打开后 `cd /c/Users/robert/WorkBuddy/Claw/pose-coach-data` 即可。

## 每日自动更新

技能的每日自动化任务（每天 22:00）会：
- 联网搜索小红书 / 马蜂窝 / 抖音 / 微博 的最新拍照套路；
- 写入本仓库的 `kb/trending-pose-kb.md` 并提交推送；
- 让所有用户次日即可通过技能读到最新内容。

## 注意事项

- 仓库必须 **Public**，否则 raw URL 无法被公开读取。
- 图片单张不超过 100MB（当前均约 2MB，安全）。
- `index.json` 中 `base_url` 等字段的 `robertyang45` 占位符由 `push_init.sh` 自动替换，无需手动修改。
