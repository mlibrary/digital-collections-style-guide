<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui"
  xmlns:qbat="http://dlxs.org/quombat/quombat" xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  extension-element-prefixes="exsl">

  <xsl:template name="build-asset-embedded-viewer" match="qui:viewer[@mode='viewer-embedded']">
    <xsl:call-template name="build-iframe-embed" />
  </xsl:template>

  <xsl:template name="build-iframe-embed">
    <xsl:variable name="title">
      <xsl:text>Viewer for &quot;</xsl:text>
      <xsl:value-of select="//qui:header[@role='main']" />
      <xsl:text>&quot;</xsl:text>
    </xsl:variable>
    <xsl:apply-templates select="//qui:viewer">
      <xsl:with-param name="title" select="$title" />
    </xsl:apply-templates>
  </xsl:template>


</xsl:stylesheet>