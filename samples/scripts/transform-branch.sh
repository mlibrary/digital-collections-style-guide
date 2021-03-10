#!/bin/bash

BINDIR=`dirname $0`
cd $BINDIR/..
ROOT=$PWD

filename=$1

if [[ $filename =~ .*qui/.* ]]
then
  ./scripts/transform-qui-qbat.sh
else
  ./scripts/transform-xml-qui.sh
fi

