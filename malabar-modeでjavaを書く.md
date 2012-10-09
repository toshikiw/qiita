malabar-modeでjavaを書く
## 設定する前に

emacsでjavaを書くにはそれなりにjavaに習熟してる必要があると思う

### おすすめできない人

* eclipseやnetbeansなどのインテリジェンスな補完がないとjavaを書けない人
* javaのソースから継承ツリーが辿れない人
* java se,java eeなどのコアなクラス群をいつ使えばいいのかぱっと出てこない人
* プロジェクトで使用してるライブラリを把握できない人

つまりIDEまかせでソースの大雑把なマッピングが脳内で出来てない人は今使ってるIDEを使いづづけた方がいいです。

### メリット

* emacsからmavenが呼び出せる(eclipseもnetbeansも出来るけど)
* IDEほど重くない

あとなんだろう?
コマンド併用でeclipseってエディタだよね? って言う人には向いてます。

## malabar-mode?

malabar-mode はemacsに昔からあったjdeeの変りにemacsでjavaを書くモード
jdeeはjdk5以降に対応してないので諦めた方がいいかも

### malabar-modeの導入

[配布元](https://github.com/espenhw/malabar-mode)を見るがあまりアクティブではないので[こっち](https://github.com/buzztaiki/malabar-mode)を使ってる

```sh
% git clone  https://github.com/buzztaiki/malabar-mode.git malabar-mode
% cd malabar-mode
% vi pom.xml
```
emacsの設定を弄る
私のはhomebrew使ってるので↓こうなってる

```xml
<plugin>
 <groupId>org.codehaus.mojo</groupId>
 <artifactId>exec-maven-plugin</artifactId>
 <version>1.1.1</version>
 <executions>
  <execution>
…
   <configuration>
    <executable>/usr/local/Cellar/emacs/23.4/Emacs.app/Contents/MacOS/Emacs</executable>…
…
   </configuration>
  </execution>
…
 </executions>
</plugin>
```
ビルド

```sh
% mvn package
% ls target/malabar-1.5-SNAPSHOT-dist.zip
% cp target/malabar-1.5-SNAPSHOT-dist.zip ~/.emacs.d/lisp
% cd ~/.emacs.d/lisp
% unzip malabar-1.5-SNAPSHOT-dist.zip
```
ビルドに成功すればzipファイルが出来る
load-path が通っている場所に解凍

### 設定

付属のドキュメントに目を通してから設定すること

```cl:init.el
(require 'cedet)
(semantic-load-enable-minimum-features)
(when (require 'malabar-mode nil t)
  (setq malabar-groovy-lib-dir (concat user-emacs-directory "lisp/malabar-1.5-SNAPSHOT/lib"))
  (add-to-list 'auto-mode-alist '("\\.java\\'" . malabar-mode))
  ;; 日本語だとコンパイルエラーメッセージが化けるのでlanguageをenに設定
  (setq malabar-groovy-java-options '("-Duser.language=en"))
  ;; 普段使わないパッケージを import 候補から除外
  (setq malabar-import-excluded-classes-regexp-list
        (append 
         '(
           "^java\\.awt\\..*$"
           "^com\\.sun\\..*$"
           "^org\\.omg\\..*$"
           ) malabar-import-excluded-classes-regexp-list))
  (add-hook 'malabar-mode-hook
            (lambda ()
              (add-hook 'after-save-hook 'malabar-compile-file-silently
                        nil t)))
)
```

## 使い方

だんだんメンドーになってきたので付属ドキュメントからよく使うコマンドを転記

<dl>
<dt>malabar-groovy-restart</dt>
<dd>他のコマンドが動かない場合はmalabarが使ってるgroovyを再起動させると動く。<br/><strong>よく使う。</strong></dd>
<dt>malabar-import-one-class <span class="classifier">(C-c C-v C-z)</span></dt>
<dd>カーソル位置のクラスをインポート<br/>
補完対象が複数ある場合minibufferに出るのでパッケージ名を入力する</dd>
<dt>malabar-run-maven-command</dt>
<dd>mavenコマンドを実行する<br/>編集→compile or installを繰替えせるので便利<br/>
ただ構文エラーがあると動かないのでmalabar-groovy-restartする</dd>
<dt>malabar-jump-to-thing <span class="classifier">(C-c C-v C-y)</span></dt>
<dd>カーソル位置のクラスに移動する<br/>
プロジェクトが違うと上手く動かない</dd>
</dl>

