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

    <xsl:variable name="has-plain-text">
      <xsl:choose>
        <xsl:when test="//Record[@name='entry']//Field[@iiif-plaintext='true']">true</xsl:when>
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:template name="build-asset-inline-viewer-configuration">
      <xsl:if test="//MediaInfo/istruct_ms = 'P' and //MediaInfo/AuthCheck/@allowed = 'yes'">
        <xsl:call-template name="build-asset-inline-viewer-configuration-allowed" />
      </xsl:if>
      <xsl:if test="//MediaInfo/istruct_ms = 'P' and //MediaInfo/AuthCheck/@allowed = 'no'">
        <xsl:variable name="possible" select="//AuthCheck/@possible" />
        <xsl:choose>
          <xsl:when test="$possible = 'yes'">
            <qui:viewer access="possible" />
          </xsl:when>
          <xsl:when test="$possible = 'no'">
            <qui:viewer access="restricted" m_entryauth="{//AuthCheck/@m_entryauth}" />
          </xsl:when>
        </xsl:choose>
      </xsl:if>  
    </xsl:template>

    <xsl:template name="build-asset-inline-viewer-configuration-allowed">
      <xsl:variable name="behavior">
        <xsl:choose>
          <xsl:when test="/Top/Manifest/@mode">
            <xsl:value-of select="/Top/Manifest/@mode" />
          </xsl:when>
          <xsl:otherwise>continuous</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
    
      <xsl:variable
        name="manifest" select="/Top/Manifest/fn:map" />
  
      <xsl:variable name="mimetype">image/jp2</xsl:variable>
  
      <xsl:variable name="page_type">
        <xsl:choose>
          <xsl:when test="normalize-space(key('get-lookup', 'headerutils.str.page'))">
            <xsl:value-of select="normalize-space(key('get-lookup', 'headerutils.str.page'))" />
          </xsl:when>
          <xsl:otherwise>Image</xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
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

      <xsl:variable name="mode" select="/Top/Manifest/@mode" />
  
      <qui:viewer
        viewer-mode="inline"
        access="allowed"
        manifest-id="{$manifest/fn:string[@key='id']}"
        canvas-index="{/Top/Manifest/@canvas-index}"
        mode="{$mode}" 
        total-canvases="{/Top/Manifest/@total-canvases}"
        has-plain-text="{$has-plain-text}"
        data-entryid="{//MediaInfo/m_iid}"
        data-viewid="{//MediaInfo/m_iid}"
        data-cc="{//CurrentCgi/Param[@name='cc']}"
        data-page-type="{$page_type}"
        data-pages-type="{$pages_type}"
      >
        <xsl:attribute name="has-ocr"><xsl:value-of select="$has-plain-text" /></xsl:attribute>
        <xsl:if test="//MediaInfo/ViewerMaxSize">
          <xsl:attribute name="viewer-max-width"><xsl:value-of select="//MediaInfo/ViewerMaxSize/@width" /></xsl:attribute>
          <xsl:attribute name="viewer-max-height"><xsl:value-of select="//MediaInfo/ViewerMaxSize/@height" /></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="//MediaInfo/AuthCheck/@viewer-advisory" mode="copy" />

        <xsl:copy-of select="$manifest" />
  
        <qui:block slot="plaintext">
        </qui:block>
  
      </qui:viewer>
  
    </xsl:template>

    <xsl:template match="*" mode="copy-dlxs-guts">
      <xsl:apply-templates mode="copy-dlxs" />
    </xsl:template>
  
    <xsl:template match="text()" mode="copy-dlxs" priority="101">
      <xsl:copy></xsl:copy>
    </xsl:template>
  
    <xsl:template match="node()[name()][namespace-uri() = '']" mode="copy-dlxs" priority="99">
      <xsl:element name="dlxs:{name()}">
        <xsl:apply-templates select="@*" mode="copy" />
        <xsl:apply-templates select="*|text()" mode="copy-dlxs" />
      </xsl:element>
    </xsl:template>
  
</xsl:stylesheet>