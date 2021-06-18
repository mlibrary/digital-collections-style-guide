#!/bin/bash

BINDIR=`dirname $0`
cd $BINDIR/../..
ROOT=$PWD

MATCH=$1
if [ "$MATCH" = "" ]
then
  MATCH="\.xml"
fi

if [ ! -d "samples/qui" ]
then
  mkdir samples/qui
fi

find samples/qui -type f | xargs rm

cd "./samples/xml"
find . -type f | egrep "$MATCH" | while read xmlfilename
do
  colldir=`dirname $xmlfilename`
  basename=`basename $xmlfilename .xml`
  template=`echo $basename | cut -d'-' -f1`

  mkdir -p "$ROOT/samples/qui/$colldir"

  cat <<EOF > /tmp/qui.$template.xsl
<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">
  <xsl:import href="$ROOT/samples/xsl/qui.base.xsl" />
  <xsl:import href="$ROOT/samples/xsl/qui.social-links.xsl" />
  <xsl:import href="$ROOT/samples/xsl/qui.$template.xsl" />
EOF

  if [ -f "$ROOT/samples/xsl/$colldir/qui.$template.xsl" ]
  then
    cat <<EOF >> /tmp/qui.$template.xsl
  <xsl:import href="$ROOT/samples/xsl/$colldir/qui.$template.xsl" />
EOF
  fi

  cat <<EOF >> /tmp/qui.$template.xsl
</xsl:stylesheet>
EOF

  xsltproc /tmp/qui.$template.xsl $xmlfilename > $ROOT/samples/qui/$colldir/$basename.xml

done

# # now build an index of the QUI
# cd "../qui"
# cat <<EOF > index.html
# <!DOCTYPE html>
# <html>
#   <head>
#     <title>QUI Index</title>
#   </head>
#   <body>
#     <h1>Sample QUI XML</h1>
#     <p><a href="../qbat/index.html">Sample QBAT HTML</a></p>
#     <ul>
# EOF

# find . -type f | egrep "\.xml" | sort | while read xmlfilename
# do
#   cat <<EOF >> index.html
#     <li><a href="$xmlfilename">$xmlfilename</a></li>
# EOF
# done

# cat <<EOF >>index.html
#     </ul>
#   </body>
# </html>
# EOF
