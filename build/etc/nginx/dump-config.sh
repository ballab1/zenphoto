#!/bin/sh
START=`pwd`
cd /etc/nginx

if [ -x $0 ]
    then CMD=$0
    else CMD=$START/$0
fi

if [ "$1" ]
    then FILE=$1
    else FILE="nginx.conf"
fi

echo "# start: $FILE"
cat $FILE | awk '{
    gsub("#.*","",$0);
    gsub(";",";\n",$0);
    gsub("{","\n{\n",$0);
    gsub("}","\n}\n",$0);
    print;
}' | awk -v HK="'" -v CMD=$CMD '{
    gsub("[ \t]+"," ",$0);
    gsub("^[ \t]","",$0);
    gsub("[ \t]$","",$0);
    gsub(HK,"%%",$0);
    if ($1=="include") {
        sub(";$","",$2);
        print CMD" "HK$2HK; }
    else {
        print "echo "HK$0HK; }
}' | sh | awk -v HK="'" '{
    gsub("%%",HK,$0);
    if ($0=="") {
        pass; }
    else {
        print; }
}' | cat
echo "# stop: $FILE"

cd $START
#exit 0
