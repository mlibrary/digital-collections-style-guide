<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">
  <xsl:template name="build-proximity-form">

    <xsl:variable name="query" select="$search-form/SearchQuery" />
    <xsl:variable name="rgn" select="$query/RegionSearchSelect" />

    <qui:fieldset id="boolean-fieldset" slot="clause" type="boolean">
      <qui:select name="{$rgn/Name}" slot="region">
        <xsl:apply-templates select="$rgn/Option">
          <xsl:with-param name="default" select="$rgn/Default" />
        </xsl:apply-templates>
      </qui:select>
      <qui:input name="{$query/Q1/Name}" slot="query" value="{$query/Q1/Default}">
        <xsl:attribute name="data-active">true</xsl:attribute>
      </qui:input>
      <xsl:apply-templates select="$query/Amt2" mode="build-op">
        <xsl:with-param name="index">1</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="$query/Op2" mode="build-op">
        <xsl:with-param name="index">1</xsl:with-param>
      </xsl:apply-templates>      
      <qui:input name="{$query/Q2/Name}" slot="query" value="{$query/Q2/Default}">
        <xsl:attribute name="data-active">true</xsl:attribute>
      </qui:input>
      <xsl:apply-templates select="$query/Op3" mode="build-op">
        <xsl:with-param name="index">2</xsl:with-param>
      </xsl:apply-templates>
      <qui:input name="{$query/Q3/Name}" slot="query" value="{$query/Q3/Default}">
        <xsl:attribute name="data-active">true</xsl:attribute>
      </qui:input>
      <xsl:apply-templates select="$query/Amt3" mode="build-op">
        <xsl:with-param name="index">1</xsl:with-param>
      </xsl:apply-templates>
    </qui:fieldset>
  </xsl:template>
</xsl:stylesheet>