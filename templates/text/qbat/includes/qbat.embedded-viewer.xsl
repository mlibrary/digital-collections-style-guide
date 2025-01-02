<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui"
  xmlns:qbat="http://dlxs.org/quombat/quombat" xmlns:xhtml="http://www.w3.org/1999/xhtml"
  xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common"
  xmlns:fn="http://www.w3.org/2005/xpath-functions"
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  extension-element-prefixes="exsl">

  <xsl:template name="build-asset-viewer">
    <xsl:call-template name="build-iframe-embed" />
  </xsl:template>

  <xsl:template name="build-iframe-embed">
    <xsl:variable name="title">
      <xsl:text>Viewer for &quot;</xsl:text>
      <xsl:value-of select="//qui:header[@role='main']" />
      <xsl:text>&quot;</xsl:text>
    </xsl:variable>
    <xsl:variable name="viewer" select="//qui:viewer" />
    <xsl:if test="$viewer">
      <h2 id="viewer-heading" class="visually-hidden">Viewer</h2>
      <xsl:variable name="embed-href">
        <xsl:value-of select="$viewer/@embed-href" />
        <xsl:for-each select="$viewer/@*[starts-with(name(.), 'q')]">
          <xsl:choose>
            <xsl:when test="position() = 1">
              <xsl:value-of select="concat('?', name(.), '=', .)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat('&amp;', name(.), '=', .)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        <!-- <xsl:if test="normalize-space($viewer/@q1)">
          <xsl:text>?q1=</xsl:text>
          <xsl:value-of select="$viewer/@q1" />
        </xsl:if> -->
      </xsl:variable>
      <iframe 
        id="viewer" 
        class="[ viewer ]" 
        allow="fullscreen" 
        title="{$title}"
        src="{ $embed-href }"
        data-mimetype="{$viewer/@mimetype}"
        data-istruct_mt="{$viewer/@istruct_mt}"
        data-has-ocr="{$viewer/@has-ocr}"
        data-item-encoding-level="{//qui:metadata/@item-encoding-level}">
      </iframe>  
    </xsl:if>
    <xsl:if test="//qui:callout[@slot='viewer']">
      <xsl:apply-templates select="//qui:callout[@slot='viewer']" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>