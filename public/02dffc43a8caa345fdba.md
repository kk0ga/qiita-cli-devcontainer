---
title: 【AWS】CloudShell VPC environmentを触ってみる
tags:
  - AWS
  - vpc
  - 初学者
  - CloudShell
private: false
updated_at: '2024-12-09T07:33:47+09:00'
id: 02dffc43a8caa345fdba
organization_url_name: future-creation-factory
slide: false
ignorePublish: false
---
業務で本格的にAWSを使うことになりそうなので勉強中です。

今回は、運用管理のためにVPC内の各リソースに対しコマンド実行できる環境を作ろうと思い、Cloud 9 を導入しようと考えました。

しかし、AWSコンソールで Cloud 9 へアクセスすると下記のメッセージが。

![aws-cloud9-message.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/be492fcc-a5fe-7415-c910-458056b51d95.png)

あれ？と思って調べてみると、Cloud 9 の新規利用はできなくなったとのこと。
>慎重に検討した結果、2024 年 7 月 25 日をもって、AWS Cloud9 への新規顧客アクセスを終了することを決定しました。AWS Cloud9 の既存の顧客は、引き続き通常どおりサービスをご利用いただけます。AWS は、AWS Cloud9 のセキュリティ、可用性、パフォーマンスの向上に投資を続けていますが、新機能の導入は予定していません。
参考：[AWS Cloud9 から AWS IDE ツールキットまたは AWS CloudShell に移行する方法](https://aws.amazon.com/jp/blogs/devops/how-to-migrate-from-aws-cloud9-to-aws-ide-toolkits-or-aws-cloudshell/)

代替手段として、ユーザーが作成した VPC 上に CloudShell を起動できる「CloudShell VPC environment」を触ってみたのでそのメモを残しておこうと思います。

まだAWSは詳しくなく学習中のため嘘や誤り、もっといい方法があるよ、などあればコメントで教えていただけると大変助かります。

## 今回やりたいこと
今回やりたいことは Private Subnet で運用しているアプリケーションやDBに対し、インターネット経由でコマンド実行できる環境を CloudShell で構築します。

![aws-environment.drawio.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/bb96a246-bd06-1aac-62cd-0b88c22877cd.png)

## CloudShell VPS environment の導入
まずは、AWSコンソールから CloudShell へアクセスし、「+」タブから「Create VPC environment(max 2)」をクリック。

![aws-cloudshell-create_01.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/243bd6cc-9030-7563-ebfb-b7186faedc2a.png)

下記をそれぞれ設定し「Create」ボタンをクリック。
- Name
- Virtual private cloud(VPC)
- Subnet
- Secutity group

![aws-cloudshell-create_02.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/85f00d02-9740-841d-d3e0-8002d1652878.png)

すると、CloudShell で作成した環境のコンソール画面が起動できます。

![aws-cloudshell-create_03.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/f8ad0b87-2915-7b5d-c71c-3b4868e3d236.png)

## CloudShell の ENI に EIP を割り当てる
CloudShell の設定が完了したらインターネットへアクセスできるようCloudShellに割り当てられているENIにEIPを割り当てる必要があります。

### VPC 設定の確認
まずは念の為 CloudShell を導入したサブネットが パブリックサブネットであるか確認しておきます。

![aws-cloudshell-create_10.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/f0b92749-8832-43b6-3ffa-92998102dbd4.png)


### Elastic IP を作成
次に EIP を作成します。
「EC2 > Elastic IP アドレス > EIP アドレスを割り当てる」の順に。

![aws-cloudshell-create_05.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/119365dc-5932-f152-fd8a-f368940d9f17.png)

情報を設定し「割り当て」をクリック。

![aws-cloudshell-create_07.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/6846881c-e8ac-02b6-a957-c889c3ed69b8.png)

### CloudShell の ENI を特定
EIP を割り当てるために CloudShell のENI を確認しておきます。

確認方法は CloudShell で`ifconfig`コマンドを実行するか、
```
ifconfig
```
![aws-cloudshell-create_04.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/f889ffe9-3507-001a-24a1-8553dc518063.png)

「EC2 > ネットワークインターフェース」から確認できます。

![aws-cloudshell-create_06.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/33904aa7-b926-387e-e806-e43637d2722f.png)

### Elastic IP を ENI に関連付け
割り当てた EIP を ENI に関連付けしたらすべての設定が完了となります。

![aws-cloudshell-create_08.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/f180dcfe-9470-00be-dec1-4f911285996b.png)

## 接続確認
CloudShell からインターネットへアクセスできるか確認します。

```
curl -I https://github.com
```

無事に接続できました。

![aws-cloudshell-create_09.png](https://qiita-image-store.s3.ap-northeast-1.amazonaws.com/0/3733390/a283b385-e3e4-e3b0-5a8e-157f63a02af9.png)

以上。
