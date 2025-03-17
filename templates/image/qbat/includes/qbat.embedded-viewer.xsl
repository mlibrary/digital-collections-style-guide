<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui"
  xmlns:qbat="http://dlxs.org/quombat/quombat" xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  extension-element-prefixes="exsl">

  <xsl:template name="build-asset-embedded-viewer" match="qui:viewer[@viewer-mode='embedded']" priority="101">
    <xsl:call-template name="build-iframe-embed" />
  </xsl:template>

  <xsl:template name="build-iframe-embed">
    <xsl:variable name="title">
      <xsl:text>Viewer for &quot;</xsl:text>
      <xsl:value-of select="//qui:header[@role='main']" />
      <xsl:text>&quot;</xsl:text>
    </xsl:variable>
    <xsl:apply-templates select="//qui:viewer" mode="embedded">
      <xsl:with-param name="title" select="$title" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="qui:viewer[@access='allowed']" mode="embedded">
    <xsl:param name="title" />
    <xsl:variable name="viewer" select="." />
    <xsl:if test="$viewer">
      <h2 id="viewer-heading" class="visually-hidden">Viewer</h2>
      <div class="viewer">
        <xsl:if test="$viewer/@viewer-advisory='true'">
          <xsl:attribute name="data-viewer-advisory">true</xsl:attribute>
        </xsl:if>
        <xsl:if test="$viewer/@viewer-max-height">
          <xsl:attribute name="style">
            <xsl:text>height: auto;</xsl:text>
          </xsl:attribute>
        </xsl:if>
        <iframe 
          id="viewer" 
          class="[ viewer ]" 
          allow="fullscreen" 
          title="{$title}"
          src="{ $viewer/@embed-href }"
          data-mimetype="{$viewer/@mimetype}"
          data-istruct_mt="{$viewer/@istruct_mt}">
          <xsl:if test="$viewer/@viewer-max-height">
            <xsl:attribute name="style">
              <xsl:text>height: calc(</xsl:text>
              <xsl:value-of select="$viewer/@viewer-max-height" />
              <xsl:text>* 1.5px);</xsl:text>
            </xsl:attribute>
          </xsl:if>
        </iframe>
        <xsl:if test="$viewer/@viewer-advisory = 'true'">
          <div class="viewer--viewer-advisory">
            <div class="viewer-advisory-message">
              <xsl:call-template name="build-viewer-advisory-message">
                <xsl:with-param name="mode">verbose</xsl:with-param>
              </xsl:call-template>  
            </div>
          </div>
        </xsl:if>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:viewer[@access='possible']" mode="embedded">
    <xsl:apply-templates select="qui:viewer[@access='possible']" />
  </xsl:template>

  <xsl:template match="qui:viewer[@access='restricted']" mode="embedded">
    <xsl:apply-templates select="qui:viewer[@access='restricted']" />
  </xsl:template>
</xsl:stylesheet>