#!/bin/bash

cat $1 | hu=$2 en=$3 awk 'BEGIN { i=0; while ((getline < ENVIRON["hu"])!=0) { hu[i]=$0; ++i }; i=0; while ((getline < ENVIRON["en"])!=0) { en[i]=$0; ++i } } { printf("%s\t",prev3) ; for (i=prev1; i<$1; ++i ) { printf("%s",hu[i]) ; if (i<$1-1) { printf(" ~~~ ") } } ; printf("\t"); for (i=prev2; i<$2; ++i ) { printf("%s",en[i]) ; if (i<$2-1) { printf(" ~~~ ") } } ; print ""; prev1=$1; prev2=$2; prev3=$3}'

# Value is the third column:
# cat $1 | hu=$2 en=$3 awk 'BEGIN { i=0; while ((getline < ENVIRON["hu"])!=0) { hu[i]=$0; ++i }; i=0; while ((getline < ENVIRON["en"])!=0) { en[i]=$0; ++i } } { for (i=prev1; i<$1; ++i ) { printf("%s",hu[i]) ; if (i<$1-1) { printf(" ~~~ ") } } ; printf("\t"); for (i=prev2; i<$2; ++i ) { printf("%s",en[i]) ; if (i<$2-1) { printf(" ~~~ ") } } ; print "\t" prev3 ; prev1=$1; prev2=$2; prev3=$3}'
