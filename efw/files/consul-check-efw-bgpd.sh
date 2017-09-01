#!/bin/sh

. /usr/local/etc/efw-check.conf

netstat -an -p tcp -finet | awk '
BEGIN { x=0 }
$6 ~ "LISTEN" {
  if ($4 ~ "179$") {
    print;
    c=split($4,l,".");
    if (l[1] ~ "\\*") { exit 0; }
    else { i[x]=$4;x++}; }
  }
END {
 for (a in i) {
  if (i[a] ~ "'${listener}'.179") { exit 0; }
 };
exit 2 }'
