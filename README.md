# qiita-cli-devcontainer

VS Code の Dev Container 上で Qiita CLI を使い、記事の執筆・プレビュー・公開を行うための設定リポジトリです。
記事の校正・レビューは GitHub Copilot CLI（任意）で自動化できます。

## できること

- Dev Container（Node.js 22 / Debian）で執筆環境を統一
- Qiita CLI（`qiita`）で新規作成・プレビュー・pull/publish
- GitHub Copilot CLI（`copilot`）で校正・レビュー（有償プラン等が必要）
- GitHub CLI（`gh`）で GitHub 操作（任意）
- プレビュー用ポート（8888）をフォワード

## 前提

- VS Code
- Dev Containers 拡張（Microsoft）
- Docker

## セットアップ（初回）

1. このリポジトリを VS Code で開く
2. コマンドパレットから Dev Containers: Rebuild and Reopen in Container を実行
3. コンテナ内で確認

```bash
node --version
qiita version
copilot --version
```

## 認証

### Qiita（必須）

このリポジトリでは、Qiita の認証情報をワークスペース内の `/workspace/.qiita-cli` に保存する運用にしています（Git 管理対象外）。

```bash
qiita login --credential /workspace/.qiita-cli
```

トークンは Qiita の設定ページから取得できます：https://qiita.com/settings/applications

### GitHub Copilot CLI（任意）

`copilot` を使う場合は、最初に Copilot へのログインが必要です。

```bash
copilot --config-dir /workspace/.copilot-cli
```

起動した対話画面で以下を実行します。

- `/login`

このリポジトリの校正/レビュースクリプトは `--config-dir /workspace/.copilot-cli` を付けて実行するため、Copilot の設定・状態はワークスペース内（Git 管理対象外）に保存されます。

トークンで注入したい場合は、環境変数（優先順：`COPILOT_GITHUB_TOKEN` → `GH_TOKEN` → `GITHUB_TOKEN`）でも認証できます。

### GitHub CLI（任意）

`gh auth login` は GitHub CLI のログインであり、Copilot CLI のログイン（`/login`）とは別物です。
GitHub の PR/Issue 操作などが必要な場合に使ってください。

```bash
gh auth login
```

## ふだんの流れ

### 1) 新規記事の作成

```bash
qiita new
```

もしくはタスク「Qiita: New Article」を実行。

### 2) プレビュー

```bash
qiita preview --credential /workspace/.qiita-cli
```

もしくはタスク「Qiita: Preview」を実行。

ブラウザで http://localhost:8888 を開きます（Dev Container のポートフォワードで 8888 を開放済み）。

### 2.5) Copilot による校正・レビュー（任意）

公開前に、Copilot で文章の校正や内容レビューを行えます（事前に `copilot --config-dir /workspace/.copilot-cli` で `/login` 済みであること）。

```bash
bash scripts/proofread-article.sh public/<article>.md
bash scripts/review-article.sh public/<article>.md
```

もしくはタスク「Copilot: Proofread Article」または「Copilot: Review Article」を実行。

GitHub Copilot 有償プランを契約していない方は、Copilot CLI を使えない場合は、後述の「Copilot Chat（GUI）での実行」を参照してください。

### 3) 公開（全記事）

```bash
qiita publish --all --credential /workspace/.qiita-cli
```

もしくはタスク「Qiita: Publish All」を実行。

> **補足**: このコマンドは変更があった記事のみを更新します。具体的には以下の記事が対象になります：
> - `modified: true`（ローカルで変更がある記事）
> - `id: null`（まだ投稿されていない新規記事）
> - `ignorePublish: false`（公開除外されていない記事）
>
> 特定の記事を公開対象から除外したい場合は、Front Matter に `ignorePublish: true` を設定してください。
> 強制的に記事ファイルの内容を反映させたい場合は `--force` オプションを使用できます。

## VS Code Tasks

コマンドパレット → Tasks: Run Task から実行できます。

- Qiita: Login
- Qiita: New Article
- Qiita: Preview
- Qiita: Pull
- Qiita: Publish All
- Qiita: Publish All (force)
- Copilot: Proofread Article
- Copilot: Review Article

## npm scripts

`package.json` にはタスクと同等のコマンドを用意しています。

```bash
npm run login
npm run preview
npm run pull
npm run publish:all
npm run publish:all:force
```

## Copilot による校正・レビュー

> 注意: GitHub Copilot CLI の利用には GitHub Copilot の契約・組織ポリシー等が必要な場合があります。

### スクリプト実行

```bash
bash scripts/proofread-article.sh public/<article>.md
bash scripts/review-article.sh public/<article>.md
```

両スクリプトは既定で `gpt-5.2` を使用します。モデルを変えたい場合は `COPILOT_MODEL` で上書きできます。

```bash
COPILOT_MODEL=gpt-4.1 bash scripts/proofread-article.sh public/<article>.md
```

`--config-dir` の保存先を変えたい場合は `COPILOT_CONFIG_DIR` で上書きできます。

```bash
COPILOT_CONFIG_DIR=/tmp/copilot bash scripts/review-article.sh public/<article>.md
```

### Copilot Chat（GUI）での実行（Copilot CLI を使えない方向け）

Copilot CLI を使えない場合（無償プラン・組織ポリシー・認証制約など）は、VS Code の Copilot Chat でプロンプトを実行できます。

1. VS Code で対象記事（`public/<article>.md`）を開く
2. Copilot Chat を開く（サイドバーの Copilot アイコン）
3. 以下のどちらかを貼り付けて送信

- 校正: `.vscode/prompts/proofread.prompt.md` の内容 + 記事本文
- レビュー: `.vscode/prompts/review.prompt.md` の内容 + 記事本文

例（校正）:

```text
このプロンプトを使って校正してください:
.vscode/prompts/proofread.prompt.md

対象ファイル: public/0d9b1de806d60350d313.md
```

出力が長くなる場合は、記事を「セクションごと」に分けて送ると安定します。

## GitHub Actions での自動公開

`.github/workflows/publish.yml` により、`main` / `master` への push 時に公開できます。
リポジトリの Secrets に `QIITA_TOKEN` を登録してください。

## トラブルシューティング

### qiita login したのに認証エラーになる

- `--credential /workspace/.qiita-cli` を付けて実行しているか確認してください（Tasks / npm scripts は付与済み）。

### プレビューが開けない

- 8888 が競合していないか確認: `lsof -i :8888`
- VS Code の PORTS タブで 8888 が Forwarded になっているか確認

### copilot が "Missing required authentication information" になる

- `copilot --config-dir /workspace/.copilot-cli` を起動して `/login` を完了してください
- もしくは `COPILOT_GITHUB_TOKEN` / `GH_TOKEN` / `GITHUB_TOKEN` を設定してください

## 参考

- Qiita CLI: https://github.com/increments/qiita-cli
- GitHub Copilot CLI: https://github.com/github/copilot-cli
- GitHub CLI: https://cli.github.com
- VS Code Dev Containers: https://code.visualstudio.com/docs/devcontainers/containers

## ライセンス

LICENSE を参照してください。
