<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template match="BookbagResults/Item">
    <xsl:variable name="bookbag-url">
      <xsl:choose>
        <xsl:when test="AddRemoveUrl">
          <xsl:value-of select="AddRemoveUrl" />
        </xsl:when>
        <xsl:when test="BookbagAddHref">
          <xsl:value-of select="BookbagAddHref" />
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <qui:form name="bookbag" data-identifier="{@idno}" href="{$bookbag-url}">
      <xsl:attribute name="mode">
        <xsl:choose>
          <xsl:when test="//Param[@name='via'] != 'reslist'">
            <xsl:text>full</xsl:text>
          </xsl:when>
          <xsl:otherwise>brief</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="rel">
        <xsl:choose>
          <xsl:when test="contains($bookbag-url, 'bbaction=remove')">
            <xsl:text>remove</xsl:text>
          </xsl:when>
          <xsl:otherwise>add</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:call-template name="build-header-metadata">
        <xsl:with-param name="item" select="." />
        <xsl:with-param name="encoding-type" select="DocEncodingType" />
        <xsl:with-param name="item-encoding-level" select="ItemEncodingLevel" />
      </xsl:call-template>
    </qui:form>
  </xsl:template>

</xsl:stylesheet>