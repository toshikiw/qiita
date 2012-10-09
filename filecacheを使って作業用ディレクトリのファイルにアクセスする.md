filecacheを使って作業用ディレクトリのファイルにアクセスする
## filecache?

filecacheとはemacsに標準で付いている使用頻度の高いファイルに簡単にアクセスする為の仕組みです。
通常は特定のディレクトリ(~ とか ~/binとか)に限って使うものなのでディレクトリを再帰的に辿れません。

そこでこのfilecacheをディレクトリを再帰的に辿ってcacheを作る方法です。

### 前提

filecacheは指定されたディレクトリ内のファイル名をキャッシュする為、
ディレクトリを大量に指定すると一気にディスクアクセスが増えます。
その為、再帰的指定するディレクトリは、SSDなどの高速なディスク上にあることを前提にしています。

### 作業用ディレクトリ?

プロジェクトファイルとかgitとかsvnのworking copyとか
ディレクトリが再帰的に一杯あるよね?

## 概要

以下の処理をinit.el内で実行する

1. shellスクリプトで対象ディレクトリを再帰スキャン
1. スキャン結果からディレクトリ一覧のelファイルを作成
1. filecacheの対象リストに追加

## 設定

#### 再帰スキャン用のshellスクリプト

```sh:~/.emacs.d/filecachedir.sh
#!/bin/sh

function abs_path() {
  d=$(dirname $0)
  (cd $d;pwd)
}

TARGET_DIR=~/work
EXCLUDE_DIR="target log logs .git tmp mnt .settings document documents doc .svn *.bak"
OUTPUT="$(basename $0 .sh).el"

EXC=""

for d in $EXCLUDE_DIR; do
  if [ -n "$EXC" ]; then
      EXC="$EXC -o -name $d"
  else
      EXC="-name $d"
  fi
done

cd $(abs_path)
[ -r $OUTPUT ] && rm -f ${OUTPUT}{,c}
echo "(setq my-filedir" >> $OUTPUT
echo " '(" >> $OUTPUT
find $TARGET_DIR \( $EXC \) -prune -o -path "*/git/*" -type d -print0 \
| perl -0 -ne 'chomp;print qq{ "$_"\n}' >> $OUTPUT
echo "))" >> $OUTPUT
```
$TARGET_DIR 以下をfindしてディレクトリ名を一覧
my-filedirデータをセットするelファイルを作る
対象外のファイル・フォルダは$EXCLUDE_DIRで指定する

#### filecacheの設定

```cl:init.el
(require 'filecache)
(let ((prg (concat user-emacs-directory "filecachedir.sh")))
  (when (file-readable-p prg)
    ;; ディレクトリを追加
    ;; ディレクトリの更新は filecachedir.sh を使う
    (call-process prg nil nil nil "")
    (load-file (concat user-emacs-directory "filecachedir.el"))
    (file-cache-add-directory-list
     my-filedir)
    )
  )
```
call-process で ~/.emacs.d/filecachedir.sh を呼び出す
生成された~/.emacs.d/filecachedir.elを読み込んでfilecacheのディレクトリリストに追加する

#### anythingの設定

anythingもfilecacheに対応しているのでソースに足してあげる

```cl:init.el
  (setq anything-sources
        '(
...
          anything-c-source-file-cache
...
          )
        )
```
