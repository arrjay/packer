#!/usr/bin/env awk -f
BEGIN{ RS="}" ; FS="\n" ; g=0 ; q=0 }

{
  for ( f=1 ; f <= NF ; f++ ) {
    if ( $f ~ ";$" ) {
      sub(/;$/,"",$f)
      c=split($f,o," ")
      if ( o[2] ~ "option-84" ) {
        n[g]=o[3] ; g++
      }
      if ( o[1] ~ "fixed-address" ) {
        b[q]=o[2] ; q++
      }
    }
  }
}

END {
  r=split(n[g-1],i,":")
  bind=(b[q-1])
  x=0
  for ( s=1 ; s <= r ; s=s+4 ) {
    delim=""
    ip=""
      i[s]=sprintf("%02x","0x"i[s])
    i[s+1]=sprintf("%02x","0x"i[s+1])
    i[s+2]=sprintf("%02x","0x"i[s+2])
    i[s+3]=sprintf("%02x","0x"i[s+3])
    ii=sprintf("%d","0x"i[s]""i[s+1]""i[s+2]""i[s+3])
    for ( e=3 ; e>=0; e-- ) {
      octet=int(ii/(256^e))
      ii-=octet*256^e
      ip=ip delim octet
      delim="."
    }
    res[x]=ip ; x++
  }
  printf("{\n")
  printf(" \"bind_addr\": \"%s\",\n",bind)
  printf(" \"retry_join\": [")
  delim=""
  for ( z=0 ; z<x ; z++ ) {
    printf("\n%s  \"%s\"",delim,res[z])
    delim=","
  }
  printf("\n ]\n}\n")
}
