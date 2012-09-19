#!/bin/bash

if [ "x${HOME}" == "x" ] ;then
  exit 1
fi

FLAG=1
LOGDIR="$HOME/.dnssec"
DIFFSRC="$LOGDIR/diffsrc"
DIFFDST="$LOGDIR/diffdst"
MAILBODY="$LOGDIR/logbody"

test -d "$LOGDIR" || mkdir "$LOGDIR"
test -f "$DIFFSRC" || DIFFSRC="$DIFFDST"
test -f "$DIFFDST" || touch "$DIFFDST"
test -f "$MAILBODY" || touch "$MAILBODY"

test -x /etc/profile.d/proxy.sh && . /etc/profile.d/proxy.sh

w3m -dump http://stats.research.icann.org/dns/tld_report/ | \
  grep "^TLD\|^[a-z]*\. " | \
  sed s/"   *"/"\"\,\""/g | \
  sed s/"^\|\$"/"\""/g    | \
  sed s/"\? "/"\?\",\""/g > "$DIFFDST"

grep "TLD\|jp" $DIFFDST > "$MAILBODY"
echo -e "\n\n" >> "$MAILBODY"

DIFFSRC="$LOGDIR/diffsrc"
cp "$DIFFDST" "$DIFFSRC"
env LANG=C diff -s "$DIFFSRC" "$DIFFDST" | \
  grep "identical" > /dev/null 2>&1 || FLAG=0

if [ "$FLAG" == "0" ] ;then
  w3m -dump http://www.iana.org/domains/root/db/jp.html >> "$MAILBODY"
  cat "$MAILBODY" | mail -s "Check DNSSEC $0" root
fi

unset FLAG LOGDIR DIFFSRC DIFFDST MAILBODY
exit 0
