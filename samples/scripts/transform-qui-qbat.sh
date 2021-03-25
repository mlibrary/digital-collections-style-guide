#!/bin/bash

BINDIR=`dirname $0`
cd $BINDIR/../..
ROOT=$PWD

if [ ! -d "samples/qbat" ]
then
  mkdir samples/qbat
fi

MATCH=$1
if [ "$MATCH" = "" ]
then
  MATCH="\.xml"
fi

find samples/qbat -type f | xargs rm

cd "./samples/qui"
find . -type f | egrep "$MATCH" | while read xmlfilename
do
  echo "-- $xmlfilename"
  colldir=`dirname $xmlfilename`
  basename=`basename $xmlfilename .xml`

  mkdir -p "$ROOT/samples/qbat/$colldir"

  cat <<EOF > /tmp/qbat.$basename.xsl
<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">
  <xsl:import href="$ROOT/samples/xsl/qbat.base.xsl" />
  <xsl:import href="$ROOT/samples/xsl/qbat.$basename.xsl" />
EOF

  if [ -f "$ROOT/samples/xsl/$colldir/qbat.$basename.xsl" ]
  then
    cat <<EOF >> /tmp/qbat.$basename.xsl
  <xsl:import href="$ROOT/samples/qui/$colldir/qbat.$basename.xsl" />
EOF
  fi

  cat <<EOF >> /tmp/qbat.$basename.xsl
</xsl:stylesheet>
EOF

  xsltproc /tmp/qbat.$basename.xsl $xmlfilename | \
    awk '$0 = NR == 1 ? "<!DOCTYPE html>" : $0' > $ROOT/samples/qbat/$colldir/$basename.html

done

# now build an index of the samples
cd "../qbat"

cat <<EOF > ../index.html
<!DOCTYPE html>
<html>
  <head>
    <title>Samples Index!!</title>
    <link rel="stylesheet" href="https://unpkg.com/sakura.css/css/sakura.css" type="text/css">
  </head>
  <body>
    <h1>Samples Index</h1>
    <table>
      <thead>
        <tr>
          <th>Collection ID</th>
          <th>View</th>
          <th>DLXS XML</th>
          <th>Quombat UI XML</th>
          <th>Quombat HTML</th>
        </tr>
      </thead>
      <tbody>
EOF

find . -type f -mindepth 2 | egrep "\.html" | sort | while read filename
do
  collid=`dirname $filename`
  collid=`basename $collid`
  basename=`basename $filename .html`
  cat <<EOF >> ../index.html
    <tr>
      <td>$collid</td>
      <td>$basename</td>
      <td><a href="xml/$collid/$basename.xml">XML</a></td>
      <td><a href="qui/$collid/$basename.xml">QUI</a></td>
      <td><a href="qbat/$collid/$basename/">QBAT HTML</a></td>
    </tr>
EOF
done

cat <<EOF >>../index.html
    </table>
  </body>
</html>
EOF
