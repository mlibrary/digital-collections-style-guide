<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">
  <xsl:template name="build-simple-form">
    <xsl:call-template name="build-clause">
      <xsl:with-param name="name" select="'q1'" />
      <xsl:with-param name="q" select="$search-form/SearchQuery/Q1" />
      <xsl:with-param name="rgn" select="$search-form/SearchQuery/RegionSearchSelect" />
    </xsl:call-template>
  </xsl:template>
</xsl:stylesheet>