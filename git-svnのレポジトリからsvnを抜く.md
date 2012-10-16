git-svn のレポジトリからsvnを抜く
git-svn を使って svnを使ってたけど svnからgitへ移行してsvnがいらなくなった

というかGUIフロントエンドのSourceTreeが使えないgit-svnを実行してCPUとか使いまくるのでsvnを外すことにした

## 手順

### git-svnなレポジトリにgitのレポジトリを追加する

```sh
% git remote add -m master origin <git リモートレポジトリ> 
```

`-m master`はリモートのmasterブランチをHEADに設定するオプション
master ブランチが既にある場合、一度masterブランチを削除してから
git リモートレポジトリのmasterをcheckoutする

### ローカルのgit-svnブランチを削除

```sh
% git branch -l
% git log --all --graph --name-status
% git branch -D <branch name>
```

1. git branch でブランチ名を確認
1. ログを確認して消して問題なければ
1. ブランチの削除

### リモートのgit-svnブランチを削除
ローカルのブランチを削除してもgit-svnのリモートブランチが残る
ログとかにも出てくるので削除する

```.git/config
...
[svn-remote "svn"]
        url = <svnレポジトリurl>
        fetch = trunk:refs/remotes/trunk
        branches = branches/*:refs/remotes/*
        tags = tags/*:refs/remotes/tags/*
...
```

git-svnのsvnレポジトリの設定(↑)を削除

```sh
% git branch -r -d trunk
% for b in $(git branch -r|grep tags); do git branch -r -d $b; done 
```
svnのtrunkはremotes/trunkブランチになるので削除
svnのtagsはtagsのプレフィックスを付けたブランチになるのでそいつを削除
svnのbranchesは使ってなかったけど その場合も`git branch -r`で確認して削除

### ガベージコレクトしておく
git-svnのオブジェクトへの参照が消えたはずなので

```sh
% git gc
```

で不要領域を回収しておく

### git-svnのmetadataを削除

.git/svn にgit-svnのメタデータ(.git/svn/.metadata)が残っているので.git/svnごと削除

```sh
rm -rf .git/svn
```
