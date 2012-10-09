Qiitaの投稿をGitHubにバックアップ
[この](http://qiita.com/items/a98dffc4b1ad095898b1 "original")記事を見てなるほど
と思いシェルスクリプト版を作ってみた

### オリジナルとの違い

* シェルスクリプトで書かれている
* githubにコミットされるのは差分or新規
* カレントディレクトリの内容を削除せず上書き
* デバッグモードの場合、githubに自動コミットしない

### 使い方

オリジナルからコピー

0. まず、自分のGitHubに新規にリポジトリを作成します。
	* "Repository Name"を「Qiita」に。(別の名称でも構わないですが、以降適宜読み替えて下さい)
	* "Initialize this repository with a README"のオプションをチェック。
	* "Create Repository"をクリック。
0. Macにクローン。
	* "Clone in Mac"ボタンをクリック。
0. 次のコマンドを実行。

```sh
$ cd ~/github/Qiita
$ curl -s https://raw.github.com/toshikiw/qiita/master/tool/update.sh|sh
```

### スクリプト解説

[GitHub](https://github.com/toshikiw/qiita/blob/master/tool/update.sh)にもアップされています。
基本はオリジナルと同じ処理。
バックアップ対象もオリジナルと同じ。
コメントはなるべくオリジナルから拾ってきています。
mdファイル名にスペースが入っているとgitが上手くファイルを拾えないのでファイル名(つまりタイトル)からスペースを除去しています。

↓の様に引数を何か付けるとgitへのコミットを行いません

```sh
$ sh update.sh DEBUG
```

以下ソース

```sh:update.sh
#!/bin/sh


#ファイル名のサニタイズ関数
sanitize() {
 t1=$(echo "$1"|sed -e 's,<[^>]*>,,g') #strip_tags
 t1=$(echo "$t1"|sed -e 's/[\~\`\!\@\#\$\%\^\&\*\=\+{}\\|;:\"\,\<\.\>\/\?]+//g' -e "s,[']+,,g") #str_replace
 echo "$t1"|sed -e 's, ,,g' #スペースを削除
}

DEBUG="$@"
DIR=$PWD
DB_FILE=$HOME/Library/Kobito/Kobito.db
SQLITE3=/usr/bin/sqlite3
MSG='Automatic Update'
SQL_SELECT_ID='select ZUID  from ZITEM where ZUID is not null and ZPRIVATE = 0 ORDER BY ZPOSTED_AT DESC;'
SQL_SELECT_TITLE_AND_URL='select ZURL,ZTITLE  from ZITEM where ZUID = '
SQL_SELECT_BODY='select ZRAW_BODY from ZITEM where ZUID = '

#1レコードずつファイルに保存
MD="Posts on Qiita\n=====\n\n"
echo "Collecting your posts from Kobito...\n"
for zuid in $($SQLITE3 $DB_FILE "$SQL_SELECT_ID"); do
 SQL="$SQL_SELECT_TITLE_AND_URL '$zuid'";
 TAU=$($SQLITE3 $DB_FILE "$SQL");
 URL=$(echo $TAU|cut -d"|" -f 1);
 TITLE=$(sanitize "$(echo $TAU|cut -d"|" -f 2-)");
 SQL="$SQL_SELECT_BODY '$zuid'"
 $SQLITE3 $DB_FILE "$SQL" > "$DIR/${TITLE}.md"
 echo "* $TITLE url: $URL";
 MD="$MD* [$TITLE]($URL \"see on Qiita\")\n"
done

#目次がわりのREADME.mdを作成
echo $MD > "README.md"

#デバックモードを追加
if [ -z "$DEBUG" ]; then
 #GitHubにコミット
 echo "\nConnecting to GitHub...\n"
 git add -u *.md
 UNTRACKED=$(git status -s -uall *.md|grep -v '^M'|tr -d "?")
 if [ -n "$UNTRACKED" ]; then
   git add $UNTRACKED
 fi
 git commit -m "$MSG"
 git push origin master
fi
```
