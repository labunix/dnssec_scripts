#!/bin/bash

if [ "x${HOME}" == "x" ] ;then
  exit 1
fi

LOGDIR="$HOME/.dnssec"
DIFFSRC="$LOGDIR/diffsrc"
DIFFDST="$LOGDIR/diffdst"
MAILBODY="$LOGDIR/logbody"

test -d "$LOGDIR" || mkdir "$LOGDIR"
test -f "$DIFFSRC" || DIFFSRC="$DIFFDST"
test -f "$DIFFDST" || touch "$DIFFDST"
test -f "$MAILBODY" || touch "$MAILBODY"

w3m -dump http://stats.research.icann.org/dns/tld_report/ | \
  grep "^TLD\|^[a-z]*\. " | \
  sed s/"   *"/"\"\,\""/g | \
  sed s/"^\|\$"/"\""/g    | \
  sed s/"\? "/"\?\",\""/g > "$DIFFDST"

grep "TLD\|jp" $DIFFDST > "$MAILBODY"
echo -e "\n\n" >> "$MAILBODY"

diff "$DIFFSRC" "$DIFFDST" || \
  w3m -dump http://www.iana.org/domains/root/db/jp.html >> "$MAILBODY"

cat "$MAILBODY" | mail -s "Check DNSSEC $0" root

