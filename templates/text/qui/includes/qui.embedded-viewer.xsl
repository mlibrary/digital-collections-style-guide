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

  <xsl:template name="build-asset-viewer-configuration">
    <xsl:variable name="behavior">
      <xsl:choose>
        <xsl:when test="//DocNavigation//Behavior">
          <xsl:value-of select="//DocNavigation//Behavior" />
        </xsl:when>
        <xsl:otherwise>continuous</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="mimetype">image/tiff</xsl:variable>
  
    <xsl:if test="true() or //MediaInfo/istruct_ms = 'P' and //MediaInfo/AuthCheck/@allowed = 'yes'">
      <qui:viewer 
        embed-href="{$api_url}/cgi/t/text/api/embed/{$collid}:{//CurrentCgi/Param[@name='idno']}:{//CurrentCgi/Param[@name='seq']}" 
        manifest-id="{$api_url}/cgi/t/text/api/manifest/{$collid}:{//CurrentCgi/Param[@name='idno']}" 
        canvas-index="{//CurrentCgi/Param[@name='seq']}" 
        mode="{$behavior}" 
        auth-check="true" 
        mimetype="{$mimetype}" 
        width="{//MediaInfo/width}" 
        height="{//MediaInfo/height}" 
        levels="{//MediaInfo/Levels}" 
        collid="{$collid}" 
        q1="{//Param[@name='q1']}"
        >
        <xsl:for-each select="//Param[starts-with(@name, 'q')]">
          <xsl:attribute name="{@name}"><xsl:value-of select="." /></xsl:attribute>
        </xsl:for-each>
        <xsl:attribute name="has-ocr"><xsl:value-of select="$has-plain-text" /></xsl:attribute>
        <xsl:if test="//MediaInfo/ViewerMaxSize">
          <xsl:attribute name="viewer-max-width"><xsl:value-of select="//MediaInfo/ViewerMaxSize/@width" /></xsl:attribute>
          <xsl:attribute name="viewer-max-height"><xsl:value-of select="//MediaInfo/ViewerMaxSize/@height" /></xsl:attribute>
        </xsl:if>
        <qui:debug><xsl:value-of select="$has-plain-text" /></qui:debug>
      </qui:viewer>
    </xsl:if>
    <!-- does this have an analog -->
    <xsl:if test="//MediaInfo/istruct_ms = 'P' and //MediaInfo/AuthCheck/@allowed = 'no'">
      <qui:callout icon="warning" variant="warning" slot="viewer" dismissable="false">
        <p>Access to this resource is restricted.</p>
      </qui:callout>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>