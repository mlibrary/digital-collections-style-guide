<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:qbat="http://dlxs.org/quombat/quombat" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template match="qui:form[@name='bookbag']">
    <xsl:param name="mode">
      <xsl:choose>
        <xsl:when test="@mode"><xsl:value-of select="@mode" /></xsl:when>
        <xsl:otherwise>brief</xsl:otherwise>
      </xsl:choose>
    </xsl:param>
    <xsl:variable name="form" select="." />
    <form name="bookbag" method="GET" action="{$form/@href}" data-identifier="{@data-identifier}">
      <xsl:call-template name="button">
        <xsl:with-param name="label">
          <xsl:choose>
            <xsl:when test="$form/@rel = 'add'">
              Save to bookbag
            </xsl:when>
            <xsl:when test="$form/@rel = 'remove'">
              Remove from bookbag
            </xsl:when>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="icon" select="$form/@rel" />
        <xsl:with-param name="classes">
          <xsl:choose>
            <xsl:when test="$mode = 'brief'">button--ghost</xsl:when>
            <xsl:otherwise>button--secondary</xsl:otherwise>
          </xsl:choose>
        </xsl:with-param>
        <xsl:with-param name="label-classes">
          <xsl:if test="$mode = 'brief'">
            <xsl:text>visually-hidden</xsl:text>
          </xsl:if>
        </xsl:with-param>
      </xsl:call-template>
    </form>
  </xsl:template>
  
</xsl:stylesheet>