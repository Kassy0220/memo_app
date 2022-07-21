# memo sampleapp

このアプリは、[フィヨルドブートキャンプ](https://bootcamp.fjord.jp)の学習課題として作られたものです。

## 概要

ローカルで立ち上げ、ブラウザ上で使うことのできるメモアプリになります。

## 使い方

最初に、リモートリポジトリからローカルへダウンロードします。

```
git clone https://github.com/Kassy0220/memo_app
```

作成されたメモアプリのディレクトリに移動し、アプリを実行するために必要なGemをダウンロードします。

```
$ cd memo_app
$ bundle install
```

以上でアプリを実行する準備が整いました。

ターミナル上で次のコマンドを実行して、メモアプリを起動しましょう。

```
$ bundle exec ruby memo.rb
```

ブラウザを起動し、次のURLにアクセスします。

`http://localhost:4567/memos`

メモアプリを終了するには、ターミナル上で`Ctrl` + `C`を入力します。

### メモアプリのページ

メモアプリには次の4つのページがあります。
+ メモ一覧ページ
+ メモ作成ページ
+ メモ内容ページ
+ メモ編集ページ

メモ一覧ページでは、作成されたメモが一覧で表示されます。

上記のURLで表示されるのが、このメモ一覧ページになります。

![index image](image/index.png)

メモ作成ページでは、「タイトル」と「メモの内容」を入力し、作成ボタンを押すとメモを作成することができます。

メモのタイトルと内容が空白の状態でメモを作成することはできません。

![new image](image/new.png)

メモ内容ページでは、メモの内容が表示されます。

変更ボタンを押すと編集ページに移動し、削除ボタンを押すとメモが削除されます。

![detail image](image/detail.png)

メモ編集ページでは、変更する内容を入力し、変更ボタンを押すとメモが変更されます。

メモ作成時と同じく、タイトルと内容が空白の状態でメモを変更することはできません。

![edit image](image/edit.png)
