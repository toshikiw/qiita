#!/bin/sh


sanitize() {
 t1=$(echo "$1"|sed -e 's,<[^>]*>,,g') #strip_tags
 t1=$(echo "$t1"|sed -e 's/[\~\`\!\@\#\$\%\^\&\*\=\+{}\\|;:\"\,\<\.\>\/\?]+//g' -e "s,[']+,,g")
 echo "$t1"
}

DIR=$PWD
DB_FILE=$HOME/Library/Kobito/Kobito.db
SQLITE3=/usr/bin/sqlite3
$MSG='Automatic Update'
SQL_SELECT_ID='select ZUID  from ZITEM where ZUID is not null and ZPRIVATE = 0 ORDER BY ZPOSTED_AT DESC;'
SQL_SELECT_TITLE_AND_URL='select ZURL,ZTITLE  from ZITEM where ZUID = '
SQL_SELECT_BODY='select ZRAW_BODY from ZITEM where ZUID = '

MD="Posts on Qiita\n=====\n\n"
echo "Collecting your posts from Kobito...\n"
for zuid in $($SQLITE3 $DB_FILE "$SQL_SELECT_ID"); do
 SQL="$SQL_SELECT_TITLE_AND_URL '$zuid'";
 TAU=$($SQLITE3 $DB_FILE "$SQL");
 URL=$(echo $TAU|cut -d"|" -f 1);
 TITLE=$(sanitize "$(echo $TAU|cut -d"|" -f 2-)");
 SQL="$SQL_SELECT_BODY '$zuid'"
 $SQLITE3 $DB_FILE "$SQL" > "$DIR/${TITLE}.md"
 echo "title: $TITLE url: $URL";
 MD="$MD* [$TITLE]($URL \"see on Qiita\")\n"
done

echo $MD > "CONTENT.md"