---
title: 【VSCode】settings.json設定メモ
tags:
  - VSCode
private: false
updated_at: '2024-06-18T20:14:55+09:00'
id: ce39a8fcfc6284d7bfb2
organization_url_name: future-creation-factory
slide: false
ignorePublish: false
---
いつも忘れてしまうので、Visual Studio Codeでよく設定する項目をメモしておく。
※随時、更新していきます。

## settings.jsonの開き方
- Macの場合、`command + ,`
- Windowsの場合、`Ctrl + ,`

## ユーザ設定
どの環境でも共通で設定する項目。

### 常に新しいタブでファイルを開く
```settings.json
"workbench.editor.enablePreview": false
```
### ファイル保存時に自動でコードフォーマット
```settings.json
"editor.formatOnSave": true
```

## ワークスペース設定
ワークスペース固有に設定する項目。

### コードフォーマッターをPrettierにする。

```settings.json
"editor.defaultFormatter": "esbenp.prettier-vscode"
```
※VSCodeの「Prettier - Code formatter」プラグインをインストールしている前提。
