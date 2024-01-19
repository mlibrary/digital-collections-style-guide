<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:tei="http://www.tei-c.org/ns/1.0" extension-element-prefixes="exsl date" >
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />
  <xsl:strip-space elements="*"/>


  <xsl:template match="/">
    <Top>
      <xsl:apply-templates select="//DlxsGlobals" mode="copy" />
      <xsl:apply-templates select="//DocMeta" mode="copy" />
      <DocContent>
        <DocSource>
          <xsl:apply-templates select="//DocContent/DocSource" mode="copy-tei-guts" />
        </DocSource>
      </DocContent>
    </Top>
  </xsl:template>

  <xsl:template match="DocSource" mode="copy-tei-guts">
    <xsl:apply-templates mode="copy-tei" />
  </xsl:template>

  <xsl:template match="text()" mode="copy-tei" priority="101">
    <xsl:copy></xsl:copy>
  </xsl:template>

  <xsl:template match="@*|*|text()" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|text()" mode="copy" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="node()[name()][namespace-uri() = '']" mode="copy-tei" priority="99">
    <xsl:element name="tei:{name()}">
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates select="*|text()" mode="copy-tei" />
    </xsl:element>
  </xsl:template>


</xsl:stylesheet>