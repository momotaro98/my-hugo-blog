---
title: "GitのコミットメッセージでCHANGELOGをいい感じに運用したい"
date: 2019-12-04T00:09:34+09:00
tags: [Git]
---

この記事は [Git Advent Calendar 2019 - Qiita](https://qiita.com/advent-calendar/2019/git) 7日目の記事です。

## CHANGELOGっていうのはね

よく見るこんなやつ

{{< figure src="https://raw.githubusercontent.com/momotaro98/my-project-images/master/my-blog-post/post-1/20191203204149.png" >}}


このバージョンではどんな改修があったのか利用者がザッと見て把握してもらうためのもの。

つまり作成するには前バージョンからの差分をサマライズする作業が必要になるがこれを自動化でいい感じにしたい！

## コミットメッセージからCHANGELOG用テキストを出力してくれるツール git-chglog

素晴らしいツールがあった。

[git-chglog](https://blog.wadackel.me/2018/git-chglog)

これはコミットメッセージからキーワードを抽出集約してCHANGELOG用のテキストを標準出力に出力してくれるツール。

同様なツールで[これとか](https://github.com/conventional-changelog/conventional-changelog)が有名らしいがgit-chglogはどの言語にも依存しない汎用的なツール。

自分がプライベートで開発してるプロジェクトのコミットメッセージを使って試してみる。

### git-chglogの設定ファイル上でコミットメッセージからの抽出条件と集約方法を定義する

#### コミットメッセージを確認

{{< figure src="https://raw.githubusercontent.com/momotaro98/my-project-images/master/my-blog-post/post-1/20191203210547.png" >}}

こんな感じ。

普段なんとなくで、バグ改修したら`:bug:`、何か機能実装したら`:sparkles:` か `:tada:` を先頭につけていた。
`:bug:`と`:sparkles:` はGitHubなどでそれぞれ 🐛 ✨のemojiが表示される。

今回はこのコミットメッセージのタイトルをCHANGELOGの出力対象にするのをゴールにする。

emojiについては後述。

※ ちなみに上記の画像のようにコミットメッセージだけ得るには

```
git log --pretty=oneline --abbrev-commit
```

とやると良いとのこと from  https://stackoverflow.com/a/4488858

#### git-chglogの設定ファイル

設定ファイルとテンプレートファイルを用意する必要がある。

本家は→のような感じ https://github.com/git-chglog/git-chglog/tree/master/.chglog

この2ファイルは同一レポジトリ上になくても良く`-c`オプションで指定できる。

設定を以下の様にする。

`config.yml`
```
style: github
template: CHANGELOG.tpl.md
info:
  title: CHANGELOG
  #repository_url: https://github.com/momotaro98/XXXX
options:
  commits:
    filters: # 集約対象のType(emoji)を設定 
      Type:
        - sparkles
        - bug
  commit_groups:
    title_maps:
      sparkles: Features
      bug: Bug Fixes
  header:
    pattern: "^:(\\w*)\\:\\s(.*)$" #抽出条件を正規表現で。今回は `:emoji: message...`なものが対象
    pattern_maps:
      - Type
      - Subject
  issues:
    prefix:
      - #
  notes:
    keywords:
      - BREAKING CHANGE
```

`CHANGELOG.tpl.md`
```
{{ range .Versions }}
<a name="{{ .Tag.Name }}"></a>

## {{ .Tag.Name }}

> {{ datetime "2006-01-02" .Tag.Date }}

{{ range .CommitGroups -}}
### {{ .Title }}

{{ range .Commits -}}
* {{ .Subject }}
{{ end }}
{{ end -}}

{{- if .NoteGroups -}}
{{ range .NoteGroups -}}
### {{ .Title }}

{{ range .Notes }}
{{ .Body }}
{{ end }}
{{ end -}}
{{ end -}}
{{ end -}}
```

#### コマンドを叩いて出力

予めGitのタグを付与し指定してコマンドを叩く。指定しない場合はすべてのタグバージョン分が出力される。

```
$ git-chglog --config PATHTO/.chglog/config.yml v1.0.1

<a name="v1.0.1"></a>

## v1.0.1

> 2019-11-17

### Bug Fixes

* Fix bug for birthday query in userservice
* :+1: Update tag type type
* Fix missing part
* Add 8081 port into docker-compose yaml
* Fix JSON struct bug in party service

### Features

* Apply wire for DI management :recycle:
* Implement GET user API
* Add domain logic of user service and refactor tag service :green_heart:
* Add photoUrl column in users table
* Add feature of creating chat room in Firebase Cloud Firestore
* Adopt Redis
* Un:rocket: :up: Add user repository to fetch user data from Firebase
* Add GetParties by using time range in gRPC part
* Implement GetEachUserSchedules method
* Add new tables, parties and partymembers
* Implement func of returning a newly added userschedule
* Adopt Go Modules and create a Dockerfile
```

いい感じに標準出力に出た。

後はこの出力をどうするかはチームでの運用次第になる。`CHANGELOG.md`上で管理するならば

```
$ git-chglog --config PATHTO/.chglog/config.yml v1.0.1 >> CHANGELOG.md
```

とできる。GitHub、GitLabのリリースノート上に記載するならばAPIを使ってCIに乗せてタグのPushのキックで自動で出力させる運用も可能。

上記の開発者さんのブログにもあるが、出力された内容を後からも修正することを想定していて現実的で良い。

#### ちなみに

後述するemoji用のテンプレ設定もあれば良いじゃないかということでプルリクを投げマージしてもらうことができた。

https://github.com/git-chglog/git-chglog/pull/59


## チームでのコミットメッセージ統一の運用はチョトメンドイ

上記のようなツールを使うには開発チーム全員でコミットメッセージのルールを決めて普段から従う必要がある。

面倒をなんとか工夫する方法としてはGitのHookの機能を使うことがあげられる。

[https://gist.github.com/pgilad/5d7e4db725a906bd7aa7#file-commit-msg-sh:embed:cite]

{{< gist pgilad 5d7e4db725a906bd7aa7 >}}

こんな感じでCommitするときにチェックのスクリプトが走ってNGだとコミットできないという具合。
他にも(そのように運用している場合)ブランチ名からIssue番号を抽出してコミットメッセージにデフォで出すとかもスクリプトを書けばできる。例→ 
https://github.com/momotaro98/dotfiles/blob/master/.git_template/hooks/prepare-commit-msg

しかし！ これには

* `.git/hooks`の設定ファイルをどうやってチームメンバでシェアするか
* SourceTreeとかGitKrakenとかのGitクライアントを使うとHookがうまく動かない！

という課題が出てしんどい。費用対効果的にそんな頑張れないぞ(それを言っちゃぁおしめぇよ)

## emoji

### emoji format

今のチームメンバにゆる〜く提案してやってもらおうとしているのが上記と同様のemojiフォーマットなコミットメッセージを書くこと。

グローバルにみんなemojiが大好き！

https://gitmoji.carloscuesta.me/

しかしコミットのタイプとemojiの対応に標準はなく色々な定義マップがネットに存在してしまっている。

例えばリファクタリングのコミット用の絵文字には :hammer: 🔨, :recycle: ♻️などいくつかあるっぽい。

CHANGELOGにはFeaturesとFix Bugsだけで十分なはずなので、機能をこのコミットで実装できた！っていうときは:sparkles: ✨ 、バグ直した〜っていうときは:bug:🐛を先頭につけよう、それだけの運用にしようとしている。

### いつもemojiを

最後に。Gitのコミット時のエディタ上にテンプレートを持つことができる。

https://github.com/momotaro98/dotfiles/blob/master/.gitmessage.txt

こういったファイルを`.gitconfig`上で

```
[commit]
	template = ~/.gitmessage.txt # commit template texts
```

のようにしよう。これにより

* エディタ上の検索でどのemojiを使えば良いかがわかる
* エディタの補完でタイポしないで済む

デモ

{{< figure src="https://raw.githubusercontent.com/momotaro98/my-project-images/master/my-blog-post/post-1/20191203222756.gif" >}}

Vimはいいぞ〜(主旨が変わる)
