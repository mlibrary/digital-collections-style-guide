<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org"
  xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common"
  xmlns:date="http://exslt.org/dates-and-times" xmlns:qui="http://dlxs.org/quombat/ui"
  xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl date str">
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />
  <xsl:strip-space elements="*" />

  <xsl:template name="build-asset-embedded-viewer-configuration">
    <xsl:variable name="config" select="//MiradorConfig" />
    <xsl:variable name="publisher" select="//Publisher/Value" />
    <xsl:if test="//MediaInfo/istruct_ms = 'P' and //MediaInfo/AuthCheck/@allowed = 'yes'">
      <qui:viewer 
        viewer-mode="embedded"
        access="allowed"
        embed-href="{$config/@embed-href}" 
        manifest-id="{$config/@manifest-href}" 
        canvas-index="{$config/@canvas-index}" 
        mode="{$config/@mode}" 
        auth-check="{//MediaInfo/AuthCheck/@allowed}" 
        mimetype="{//MediaInfo/mimetype}" 
        istruct_mt="{//MediaInfo/istruct_mt}" 
        width="{//MediaInfo/width}" 
        height="{//MediaInfo/height}" 
        levels="{//MediaInfo/Levels}" 
        collid="{//MediaInfo/ic_collid}" 
        m_id="{//MediaInfo/m_id}" 
        m_iid="{//MediaInfo/m_iid}">
        <xsl:if test="//MediaInfo/ViewerMaxSize">
          <xsl:attribute name="viewer-max-width"><xsl:value-of select="//MediaInfo/ViewerMaxSize/@width" /></xsl:attribute>
          <xsl:attribute name="viewer-max-height"><xsl:value-of select="//MediaInfo/ViewerMaxSize/@height" /></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="//MediaInfo/AuthCheck/@viewer-advisory" mode="copy" />
      </qui:viewer>
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
</xsl:stylesheet>