---
title: Copilot CLI で校正・レビューもできるQiita執筆環境をVS Codeに作った（Dev Container）
tags:
  - 'devcontainer'
  - 'copilot'
  - 'CopilotCLI'
  - 'Qiita'
  - 'QiitaCLI'
private: false
updated_at: ''
id: null
organization_url_name: future-creation-factory
slide: false
ignorePublish: false
---
これまで Qiita は Web ブラウザ上で執筆していましたが、以下の理由から VS Code で執筆できる環境を構築しました。
- 使い慣れた IDE（VS Code）で執筆したい
- AI との親和性も考慮して、ローカル環境で `.md` ファイルとして管理したい
- GitHub で資産として管理したい

構築した環境は VS Code の Dev Container 上で Qiita CLI を使い、記事の執筆・プレビュー・公開と、プラスアルファとして、GitHub Copilot CLI（`copilot`） による記事の校正・レビューも行えるようにしています。

**VS Code + Dev Container + Qiita CLI** で執筆フローを固めつつ、**Copilot で校正・レビュー**まで一気通貫にしたい方に特におすすめです。

Dev Container で構築しているので、下記リポジトリをクローンしていただき、`/public`配下の記事を削除していただければ、すぐに使い始められます。

https://github.com/kk0ga/qiita-cli-devcontainer


Qiita CLI 環境を手早く構築したい方は、参考にしてみてください。

![ChatGPT Image 2026年1月18日 15_29_49.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/588df938-8fd2-431f-a9b2-d68ead096b28.png)

## できること

- Dev Container（Node.js 22 / Debian）で執筆環境を統一
- Qiita CLI（`qiita`）で記事の新規作成・プレビュー・公開（`new` / `pull` / `publish`）
- GitHub Copilot CLI（`copilot`）で校正・レビュー（有償プラン等が必要）
- Markdown 執筆支援（Markdown All in One 拡張機能の導入）
- エディタの 80 文字位置にルーラー（縦線）表示
- VS Code の Tasks から主要コマンドをワンクリック実行（コマンド入力不要）
- GitHub Actions で push をトリガーに自動公開（手動で publish する手間を削減）

## フォルダ構成
フォルダ構成は以下のとおりです。

```
qiita-cli-devcontainer/
│
├── .devcontainer/                          (Dev Container 設定)
│   ├── devcontainer.json                   - コンテナ環境定義
│   └── Dockerfile                          - コンテナイメージ定義
│
├── .github/                                (GitHub 関連設定)
│   └── workflows/
│       └── publish.yml                     - 自動公開ワークフロー
│
├── .qiita-cli/                             (Qiita CLI 認証情報・Git管理対象外)
│   └── credentials.json                    - アクセストークン
│
├── .vscode/                                (VS Code 設定)
│   ├── tasks.json                          - カスタムタスク定義
│   └── prompts/                            - Copilot プロンプトテンプレート
│       ├── proofread.prompt.md             - 校正用プロンプト
│       └── review.prompt.md                - レビュー用プロンプト
│
├── .copilot-cli/                           (Copilot CLI 設定・Git管理対象外)
│   ├── config.json                         - Copilot 設定
│   └── logs/                               - 実行ログ
│
├── public/                                 (Qiita 記事ファイル)
│
├── scripts/                                (スクリプト)
│   ├── proofread-article.sh                - Copilot による校正実行スクリプト
│   └── review-article.sh                   - Copilot によるレビュー実行スクリプト
│
├── .gitignore                              - Git 除外ファイル設定
├── LICENSE                                 - ライセンス
├── README.md                               - ドキュメント
├── package.json                            - npm パッケージ設定・スクリプト
└── qiita.config.json                       - Qiita CLI 設定
```

## 記事執筆の流れ

### 1) 新規記事の作成
記事を新規作成する場合は、タスク「Qiita: New Article」を実行することで新記事のテンプレートが作成できます。

![スクリーンショット 2026-01-18 130930.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/0f76fc54-6e17-47b1-9d1b-24df54382453.png)

> **補足**: タスクの実行はコマンドパレット（`Ctrl + Shift + P`）を開き「タスク:タスクの実行」から呼び出すことができます。

ターミナルで下記コマンドを実行することでも可能です。
```bash
qiita new
```

実行すると、新記事のテンプレートが自動で作成されます。
テンプレートには Qiita 記事の Front Matter（Markdown ファイルの先頭に書くメタデータ用の領域）がデフォルトで設定されています。

![スクリーンショット 2026-01-18 131245.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/104df597-8a83-4ad4-b00a-d35faf16559a.png)

### 2) プレビュー
作成した記事をプレビューしたい場合は、タスク「Qiita: Preview」を実行すると確認することができます。
タスク実行後、ブラウザで http://localhost:8888 を開くとプレビューできます（Dev Container で 8888 をポートフォワード済み）。

![スクリーンショット 2026-01-18 143749.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/66ba2d3b-c287-4003-ad35-9eb7389fb851.png)

ターミナルで下記コマンドを実行することでも可能です。

```bash
qiita preview --credential /workspace/.qiita-cli
```

### 3) Copilot による校正・レビュー（任意）

![ChatGPT Image 2026年1月18日 15_29_57.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/b0338f80-7c2d-4c86-b3fb-720ed363752e.png)

公開前に、Copilot で文章の校正や内容レビューを行えるようにしています。
タスク「Copilot: Proofread Article」または「Copilot: Review Article」を実行することで行えます。

![スクリーンショット 2026-01-18 132746.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/f6c1f84c-820e-4d76-914c-acc363858fa3.png)

> **補足**: 事前に `copilot --config-dir /workspace/.copilot-cli` を実行し、`/login` でサインインしておく必要があります。
> また、GitHub Copilot CLI を利用するためには、GitHub Copilot の有償プランに契約している必要があります。

ターミナルで下記コマンドを実行することでも可能です。

```bash
bash scripts/proofread-article.sh public/<article>.md
bash scripts/review-article.sh public/<article>.md
```
> **補足**: 両スクリプトは既定で `gpt-5.2` を使用します。モデルを変えたい場合は `COPILOT_MODEL` で上書きできます。
> ```bash
> COPILOT_MODEL=gpt-4.1 bash scripts/proofread-article.sh public/<article>.md
> ```
>
> `--config-dir` の保存先を変えたい場合は `COPILOT_CONFIG_DIR` で上書きできます。
>
> ```bash
> COPILOT_CONFIG_DIR=/tmp/copilot bash scripts/review-article.sh public/<article>.md
> ```

#### Copilot Chat（VS Code）で実行する方法（Copilot CLI を使えない場合）

Copilot CLI を使えない場合（無償プラン・組織ポリシー・認証制約など）は、VS Code の Copilot Chat でプロンプトを実行できます。

1. VS Code で対象記事（`public/<article>.md`）を開く
2. Copilot Chat を開く（サイドバーの Copilot アイコン）
3. 以下例のようなプロンプトを入力して送信

例（校正）:

```text
このプロンプトを使って校正してください:
.vscode/prompts/proofread.prompt.md

対象ファイル: public/0d9b1de806d60350d313.md
```

使用するプロンプトファイルは下記用途ごとに変更してください。
- 校正: `.vscode/prompts/proofread.prompt.md`
- レビュー: `.vscode/prompts/review.prompt.md`

出力が長くなる場合は、記事を「セクションごと」に分けて送ると安定します。

### 4) 公開
記事の公開は、タスク「Qiita: Publish All」を実行することで公開することができます。
また、GitHub リポジトリで記事を管理している方はリポジトリにプッシュすることでも記事を公開することができます。

ターミナルで下記コマンドを実行することでも可能です。

```bash
qiita publish --all --credential /workspace/.qiita-cli
```
> **補足**: このコマンドは変更があった記事のみを更新します。具体的には以下の記事が対象になります：
> - `modified: true`（ローカルで変更がある記事）
> - `id: null`（まだ投稿されていない新規記事）
> - `ignorePublish: false`（公開除外されていない記事）
>
> 特定の記事を公開対象から除外したい場合は、Front Matter に `ignorePublish: true` を設定してください。
> 強制的に記事ファイルの内容を反映させたい場合は `--force` オプションを使用できます。

#### GitHub Actions での自動公開

![ChatGPT Image 2026年1月18日 15_30_01.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/71e65601-9097-40a6-9f08-82bf46bbe20e.png)

`.github/workflows/publish.yml` により、`main` / `master` への push 時に公開できます。

> **補足**: リポジトリの Secrets に `QIITA_TOKEN` を事前に登録する必要があります。

![スクリーンショット 2026-01-18 134155.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/e336b500-a5f0-4eaa-b5de-45f2cdc84dd8.png)

## 最後に

最後に、実際にこの環境を作ってみて「ここは躓いた」「ここはラクになった」を簡単にまとめます。

### 躓いた点・苦労した点

まず認証まわりは、思ったよりも登場人物が多いです。Qiita は `qiita login`、GitHub Actions は `QIITA_TOKEN`、Copilot CLI は `/login` と、それぞれ別で準備が必要でした。

それと、`publish --all` が名前のわりに「全部」ではない点も最初は混乱しました。実際には「新規 or 変更あり」だけが対象で、どうしても強制反映したいときは `--force` を使う、という理解に落ち着きました。

もうひとつは `qiita pull` で取得した記事情報（差分確認用）が入る `public/.remote` の扱いです。差分確認に便利な反面、Git 管理に入れると更新のたびにノイズが増えやすいので、`.gitignore` で除外する運用が安心でした。

運用面では、Actions の起動条件を絞るのが結構効きました。記事以外の変更でもワークフローが走ると無駄が出るので、`public/**/*.md` が変わったときだけ走るようにしておくと気持ちよく回せます。

### 楽になった点（導入して良かったこと）

一番よかったのは、Dev Container によって実行環境が揃うので「自分の環境だけ動かない」を減らせたことです。Qiita CLI なども含めて同じ状態からスタートできるのが、地味に効きます。

日常の操作もかなりラクになりました。VS Code の Tasks から「新規作成/プレビュー/公開」を実行できるので、コマンド入力で手が止まる感じがほぼなくなります。

公開については、ローカルから publish するルートも残しつつ、GitHub Actions で push をトリガーに自動公開もできるようにしたことで、運用の手間がだいぶ減りました。

あと、校正・レビューまで同じ流れでできるのも便利でした。Copilot CLI（または Copilot Chat）で公開前のチェックを差し込めるので、公開前の安心感が上がります。

---

**VS Code + Dev Container + Qiita CLI** で執筆フローを固めつつ、**Copilot で校正・レビュー**まで一気通貫にしたい方に特におすすめです。

ぜひ、参考になったら「いいね」してもらえるとうれしいです。

## 参考

- Qiita CLI: https://github.com/increments/qiita-cli
- GitHub Copilot CLI: https://github.com/github/copilot-cli
- GitHub CLI: https://cli.github.com
- VS Code Dev Containers: https://code.visualstudio.com/docs/devcontainers/containers


