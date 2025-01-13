<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org"
  xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common"
  xmlns:date="http://exslt.org/dates-and-times" xmlns:qui="http://dlxs.org/quombat/ui"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl date str">
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />
  <xsl:strip-space elements="*" />

  <xsl:variable
    name="manifest" select="/Top/Manifest/fn:map" />

  <xsl:template name="build-asset-viewer-configuration">
    <xsl:variable name="behavior">
      <xsl:choose>
        <xsl:when test="//DocNavigation//Behavior">
          <xsl:value-of select="//DocNavigation//Behavior" />
        </xsl:when>
        <xsl:otherwise>continuous</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <!-- <xsl:variable name="item-encoding-level">
      <xsl:choose>
        <xsl:when test="ItemHeader/HEADER/ENCODINGDESC/EDITORIALDECL/@N">
          <xsl:value-of select="ItemHeader/HEADER/ENCODINGDESC/EDITORIALDECL/@N"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable> -->

    <xsl:variable name="item-encoding-level" select="$item-metadata//qui:metadata/@item-encoding-level" />

    <xsl:variable
      name="manifest" select="/Top/Manifest/fn:map" />

    <xsl:variable name="mimetype">image/tiff</xsl:variable>

    <xsl:variable name="page_type" select="normalize-space(key('get-lookup', 'headerutils.str.page'))" />
    <xsl:variable name="pages_type">
      <xsl:choose>
        <xsl:when test="normalize-space(key('get-lookup', 'headerutils.str.pages'))">
          <xsl:value-of select="normalize-space(key('get-lookup', 'headerutils.str.pages'))" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat($page_type, 's')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <qui:viewer
      manifest-id="{$api_url}/cgi/t/text/api/manifest/{$collid}:{//CurrentCgi/Param[@name='idno']}"
      canvas-index="{/Top/Manifest/@canvas-index}"
      total-canvases="{/Top/Manifest/@total-canvases}"
      item-encoding-level="{$item-encoding-level}"
      has-plain-text="{$has-plain-text}"
      data-idno="{//CurrentCgi/Param[@name='idno']}"
      data-node="{//CurrentCgi/Param[@name='node']}"
      data-rgn="{//CurrentCgi/Param[@name='rgn']}"
      data-cc="{//CurrentCgi/Param[@name='cc']}"
      data-page-type="{$page_type}"
      data-pages-type="{$pages_type}"
    >
      <xsl:attribute name="has-ocr"><xsl:value-of select="$has-plain-text" /></xsl:attribute>
      <xsl:copy-of select="$manifest" />

      <qui:block slot="plaintext">
          <xsl:apply-templates select="//DocContent/DocSource/SourcePageData" mode="copy-tei-guts" />
      </qui:block>

    </qui:viewer>

  </xsl:template>

  <xsl:template match="*" mode="copy-tei-guts">
    <xsl:apply-templates mode="copy-tei" />
  </xsl:template>

  <xsl:template match="text()" mode="copy-tei" priority="101">
    <xsl:copy></xsl:copy>
  </xsl:template>

  <xsl:template match="node()[name()][namespace-uri() = '']" mode="copy-tei" priority="99">
    <xsl:element name="tei:{name()}">
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates select="*|text()" mode="copy-tei" />
    </xsl:element>
  </xsl:template>

</xsl:stylesheet>