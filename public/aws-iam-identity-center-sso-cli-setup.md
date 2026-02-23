---
title: AWS IAM Identity Center の設定手順と CLI での SSO 認証方法
tags:
  - AWS
  - 初心者
  - IAM
  - aws-cli
  - IAMIdentityCenter
private: false
updated_at: '2026-02-23T14:11:11+09:00'
id: 9f22618035d6dc728849
organization_url_name: future-creation-factory
slide: false
ignorePublish: false
---
AWS サービスを利用するためには、サービスにログインできるユーザーが必要です。

以前は IAM ユーザーを作成し、その IAM ユーザーの認証情報（アクセスキーとシークレットアクセスキー）で AWS サービスを利用するのが一般的でしたが、現在は、IAM Identity Center（SSO: Single Sign-On）の利用が推奨されています。

IAM Identity Center のユーザーには、一時的な認証情報（セッショントークン）が発行され、この認証情報を使って AWS マネジメントコンソールへログインしたり、各種操作を実行したりできます。

永続的な IAM ユーザーの認証情報と異なり、IAM Identity Center の認証情報には有効期限があるため、万一漏洩しても影響を短時間に抑えられるというメリットがあります。

また、IAM Identity Center を利用すると、認証情報や権限設定を AWS アカウントごとに管理する必要がなくなり、管理コストの削減やセキュリティの向上も計れます。

本記事では、IAM Identity Center でユーザーを作成する方法と、そのユーザーを使って AWS CLI を認証する方法をまとめます。

## IAM Identity Center の構成要素
IAM Identity Center の設定で必要になる要素は、次の 3 点です。

- AWS アカウント（AWS Organizations 配下のもの）
- 許可セット
- ユーザー

IAM Identity Center は複数 AWS アカウントへのアクセス管理を前提としているため、Organizations 配下のアカウントでのみ利用できます。

これらの要素を順に設定する手順を説明します。

## IAM Identity Center の設定手順

### AWS Organizations の有効化
AWS Organizations に所属する AWS アカウントが必要なため、先に AWS Organizations を有効化します。

まずは、ルートユーザー（root）で AWS マネジメントコンソールへログインします。

ログイン後、「AWS Organizations」へアクセスし、「組織を作成する」ボタンをクリック。

![aws-identity-center-setup-01.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/ab349602-5107-4a58-91ad-bce9cf7a06eb.png)

「組織を作成する」画面が表示されるので「組織を作成する」ボタンをクリックします。

![aws-identity-center-setup-02.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/5ae57475-f481-4fd0-a250-44638b7927a8.png)

有効化されると下記のような画面が表示されます。
現在は個人用の AWS アカウントが 1 つ紐づいている状態です。

![aws-identity-center-setup-03.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/fb6059bd-8955-4052-84f0-865745b3364b.png)

検証メールが送られてくるので、メール内の「メールアドレスを確認する」リンクをクリックしておきましょう。
検証が完了すると、他の AWS アカウントを組織に招待できるようになります。

### IAM Identity Center の有効化

続いて、IAM Identity Center を有効化します。
「IAM Identity Center」へアクセスし、「有効にする」ボタンをクリック。

![aws-identity-center-setup-04.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/1387f827-296f-499d-84c9-b900d692c35e.png)

「IAM Identity Center を有効にする」画面が表示されるので、有効化するリージョンに間違いがないか確認し、「有効にする」ボタンをクリックします。

:::note info
IAM Identity Center を有効化できるリージョンは 1 つのみです。
:::

![aws-identity-center-setup-05.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/299d9a0f-7101-48de-93bc-fce7d5c363ee.png)


### 許可セットの作成
続いて、ユーザーにアタッチする許可セット（許可ポリシーのセット）を作成します。
IAM Identity Center のメニューから「許可セット」を選択し「許可セットを作成」ボタンをクリックしましょう。

![aws-identity-center-setup-06.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/d6da23c4-b40b-4964-8742-44c771c97b79.png)

「許可セットタイプを選択」画面が表示されます。
今回は、標準で定義されている事前定義から許可セットを作成します。
ユーザーに許可したいポリシーを選択し「次へ」ボタンをクリックしましょう。

※ 本記事では「AdministratorAccess」で設定したいと思います。

![aws-identity-center-setup-07.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/8c5a7b4d-e4f2-4fab-9609-81c02ab01e50.png)

「許可セットの詳細を指定」画面が表示されます。

「許可セット名」「セッション期間」を入力し「次へ」ボタンをクリック。

:::note warn
「セッション期間」はログインが有効となる期間のことです。
そのため、ユーザーに与える許可ポリシーの強さによって適切な期間を選択しましょう。
「AdministratorAccess」のような高権限のポリシーに対しては「1時間」程度が適切かと思います。
:::

![aws-identity-center-setup-08.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/b43bb59e-28d9-431d-a0bd-34e01083dd8c.png)

「確認して作成」画面が表示されるので設定内容を確認し問題なければ「作成」ボタンをクリックしましょう。

![aws-identity-center-setup-09.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/b2da42c9-6075-4cd3-9c10-66f70eb930b2.png)


### IAM Identity Center ユーザー作成
ユーザーを作成します。

IAM Identity Center のメニューから「ユーザー」を選択し「ユーザーを追加」ボタンをクリックしましょう。

![aws-identity-center-setup-11.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/ffade748-365b-4b96-a733-4e4c795a2ad2.png)

「ユーザーの詳細を指定」画面が表示されるので、「ユーザー名」「パスワード」「メールアドレス」「名」「姓」を入力し、「次へ」ボタンをクリックします。

「パスワード」については「パスワードの設定手順が記載されたメールをこのユーザーに送信します。」を選択しておくと、ユーザー作成時に、ユーザーのメールアドレス宛てにパスワード設定用のメールが送信されます。

![aws-identity-center-setup-12.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/ba1962fc-5a7d-485d-8ba9-78c9666c4416.png)

「ユーザーをグループに追加」画面が表示されますが、初期状態ではグループが作成されていないため、そのままにして「次へ」をクリックします。

![aws-identity-center-setup-13.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/bd53dcc5-d866-4947-83f7-2d1288894698.png)

「ユーザーの確認と追加」画面が表示されるので、入力内容に問題がないか確認し「ユーザーを追加」をクリックすると、ユーザー作成は完了です。

### 作成したユーザーのアクティベート
ユーザー作成後、設定したメールアドレス宛てにメールが送信されるので、メール本文の「Accept invitation」リンクをクリックします。

:::note info
メールにはアクセスポータル画面の URL が記載されています。
アクセスポータルとは、IAM Identity Center の入口になる画面です。
今後、アクセスポータル画面から AWS へログインするため、この URL はブラウザにブックマークしておきましょう。
:::

![aws-identity-center-setup-15.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/a5492c38-e5b9-40f0-9e73-29665d97fb70.png)

「Accept invitation」リンクをクリックすると「サインアップ」画面が表示されるので、ログインパスワードを設定します。
<img width="400" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/2a731cce-f688-4f38-a602-35d3a4556f6b.png">

次に、MFA 設定を行います。
任意の設定を選び「次へ」ボタンをクリックし、MFA 設定を完了させます。

<img width="400" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/67172393-fafc-46fc-93ab-84d509d629ca.png">

MFA 設定が完了すると「アクセスポータル」画面が表示されます。

:::note info
まだこの時点では AWS アカウントにユーザーを割り当てていないため何も表示されません。
:::

![aws-identity-center-setup-17.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/e5f69151-299e-4d64-88d0-0c9b1db60503.png)

### AWS アカウントへのユーザー割り当て
IAM Identity Center のメニューから「AWS アカウント」を選択し、作成したユーザーを割り当てたい AWS アカウントにチェックを入れて、「ユーザーまたはグループを割り当て」ボタンをクリックします。

![aws-identity-center-setup-18_v2.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/2e910eb7-f4e8-4b5e-a0db-824a5a315b12.png)

「ユーザーとグループの選択」画面が表示されるので、「ユーザー」タブを選択し、割り当てるユーザーを選択後、「次へ」ボタンをクリックします。

![aws-identity-center-setup-19.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/0fda8a66-8b76-44fb-b211-e33670474648.png)

「許可セットを選択」画面が表示されるので、AWS アカウントへログインできるユーザーの許可セットを選択し「次へ」ボタンをクリックします。

![aws-identity-center-setup-20_v2.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/3bd7c241-6035-4497-9b3d-aaef73d3bd52.png)

「確認して送信」画面が表示されるので、設定内容を確認し「送信」をクリックすると、AWS アカウントとユーザーの割り当てが完了します。

### アクセスポータル画面の確認
作成したユーザーで、割り当てた AWS アカウントへログインできるか確認します。

アクセスポータル画面へアクセスすると、AWS アカウントに割り当てた許可セットが表示されます。
このリンクをクリックして、AWS アカウントへログインできることを確認しましょう。

![aws-identity-center-setup-21.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/291a407d-5f31-49e8-a8a5-88fe9b7e4477.png)

正常にログインできれば、IAM Identity Center の設定はすべて完了です。

## IAM Identity Center のユーザーを AWS CLI で利用するための設定
最後に、AWS CLI で認証を行うための設定をご紹介します。

### AWS CLI の SSO 設定
AWS CLI の認証は、`aws configure sso-session` を実行し、対話形式で設定を入力することで行います。

```bash
$ aws configure sso-session
SSO session name (Recommended): my-sso
SSO start URL [None]: https://d-xxxxxxxxxx.awsapps.com/start
SSO region [None]: ap-northeast-1
SSO registration scopes [sso:account:access]: sso:account:access
```

各入力項目の概要は下記となります。
- `SSO start URL`: アクセスポータル画面の URL
- `SSO region`: IAM Identity Center を有効化したリージョン
- `SSO registration scopes`: 基本的に `sso:account:access` のままで問題ありません

SSO の設定情報を入力すると認可画面が表示されるので、「アクセスを許可」ボタンをクリックします。

<img width="600" src="https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/e61fb0d5-43e1-42c5-9124-776b7b34d722.png">

利用する許可セットを選択し Enter キーを押すと、SSO の設定が完了します。

```text
Using the role name "AdministratorAccess"
Default client Region [ap-northeast-1]: ap-northeast-1
CLI default output format (json if not specified) [json]: json
Profile name [AdministratorAccess-713262109554]: admin
```

ここで設定した情報は `~/.aws/config` に反映されるので、適切に設定できているか確認してみましょう。

```ini
$ cat ~/.aws/config
[sso-session my-sso]
sso_start_url = https://d-xxxxxxxxxx.awsapps.com/start
sso_region = ap-northeast-1
sso_registration_scopes = sso:account:access

[profile admin]
sso_session = my-sso
sso_account_id = 713262109554
sso_role_name = AdministratorAccess
region = ap-northeast-1
output = json
```

### AWS CLI でのユーザー認証（認証トークンの取得）
AWS CLI で操作する前に、`aws sso login` コマンドで一時的な認証情報を取得します。

```bash
$ aws sso login --sso-session my-sso
```

`aws sso login` コマンドを実行し、認証に成功すると認証トークンが発行され、AWS CLI を実行できるようになります。

また、発行された認証トークンは `~/.aws/sso/cache/` 配下にファイルとして格納されます。

```bash
$ ls -la ~/.aws/sso/cache/
total 16
drwxr-xr-x 2 node node 4096 Feb 21 07:14 .
drwxr-xr-x 3 node node 4096 Feb 21 07:12 ..
-rw------- 1 node node 3655 Feb 21 07:31 0ad374308c5a4e22f723adf10145eafad7c4031c.json
-rw------- 1 node node 3110 Feb 21 07:12 52f3436bc9dc54c357d426c610add7ecb2b6a386.json
```

:::note info
`aws sso login` のオプションは、SSO 設定（`--sso-session`）の代わりにプロファイル設定（`--profile`）を指定して認証することもできます。

```bash
$ aws sso login --profile admin
```

`--profile` で認証した場合、`~/.aws/config` のプロファイル情報（`[profile admin]` の `sso_session = my-sso`）に指定されている SSO 情報が参照されます。
:::

## 最後に
IAM Identity Center を利用すると、従来の IAM ユーザー＋アクセスキー管理から脱却し、一時的な認証情報を前提とした、より安全で運用しやすい認証方式に移行できます。

特に、AWS Organizations 配下で複数アカウントを管理する構成では、

- ユーザー・権限の一元管理
- 権限変更時の即時反映
- 認証情報漏洩リスクの低減

といったメリットが大きく、個人利用だけでなくチーム開発や本番運用でも非常に有効です。

また、AWS CLI との連携も一度設定してしまえば、以降は aws sso login で簡単に認証できるため、長期的に見ると運用負荷の軽減にもつながります。

本記事が、IAM Identity Center 導入の第一歩や、IAM ユーザーからの移行を検討する際の参考になれば幸いです。

参考になりましたら、ぜひ「いいね」をお願いします。
