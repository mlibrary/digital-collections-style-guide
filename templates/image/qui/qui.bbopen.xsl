<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template name="get-title">
    Image Collections Portfolios Index
  </xsl:template>

  <xsl:template name="build-sub-header">
    <qui:sub-header data-badge="view_list">
      ImageClass Collections Portfolios
    </qui:sub-header>
  </xsl:template>

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <xsl:text>Portfolios Index</xsl:text>
    </qui:header>
    <xsl:call-template name="build-breadcrumbs" />
    <xsl:call-template name="build-portfolios-index" />
  </xsl:template>

  <xsl:template name="build-breadcrumbs">
    <qui:nav role="breadcrumb">
      <qui:link href="/cgi/i/image/image-idx?page=groups">
        <xsl:text>Digital Collections</xsl:text>
      </qui:link>
      <qui:link href="{/Top//CurrentUrl}" identifier="{/Top/@identifier}">
        <xsl:call-template name="get-current-page-breadcrumb-label" />
      </qui:link>
    </qui:nav>
  </xsl:template>

  <xsl:template name="build-portfolios-index">
    <qui:block slot="results">
      <xsl:apply-templates select="//Portfolios[@type='merged']/Portfolio" />
      <!-- <xsl:apply-templates select="//Portfolios[@type='public']/Portfolio" /> -->
    </qui:block>
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    Portfolios Index
  </xsl:template>

  <xsl:template match="Portfolios/Portfolio">
    <qui:section identifier="{@id}">
      <xsl:attribute name="access">
        <xsl:choose>
          <xsl:when test="Field[@name='shared']/Public = 1">
            <xsl:text>public</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>private</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:if test="@recent">
        <xsl:attribute name="recent"><xsl:value-of select="@recent" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="@mine">
        <xsl:attribute name="mine"><xsl:value-of select="@mine" /></xsl:attribute>
      </xsl:if>
      <xsl:for-each select="Field[@name='action']/Action">
        <qui:link rel="{@type}" href="{Url}" />
      </xsl:for-each>
      <qui:title>
        <qui:values>
          <qui:value>
            <xsl:value-of select="Field[@name='bbagname']" />
          </qui:value>
        </qui:values>
      </qui:title>
      <qui:block slot="metadata">
        <qui:section>
          <!-- do this in order -->
          <xsl:apply-templates select="Field[@name='itemcount']" />
          <xsl:apply-templates select="Field[@name='modified_display']" />
          <xsl:apply-templates select="Field[@name='username']" />
        </qui:section>
      </qui:block>
    </qui:section>
  </xsl:template>

  <xsl:template match="Field[@name='bbagname']" priority="100" />
  <xsl:template match="Field[@name='action']" priority="100" />

  <xsl:template match="Field[@name='shared']" priority="100" />

  <xsl:template match="Field[@name='username']" mode="field-value" priority="100">
    <xsl:attribute name="data-username"><xsl:value-of select="@username" /></xsl:attribute>
    <xsl:for-each select="str:split(., '; ')">
      <qui:value>
        <xsl:value-of select="." />
      </qui:value>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Field" mode="field-value">
    <qui:value>
      <xsl:value-of select="." />
    </qui:value>
  </xsl:template>

  <xsl:template match="Field">
    <qui:field key="{@name}">
      <xsl:if test="@name = 'modified_display'">
        <xsl:attribute name="data-machine-value">
          <xsl:value-of select="ancestor-or-self::Portfolio/Field[@name='modified']" />
        </xsl:attribute>
      </xsl:if>
      <qui:label key="{@name}" />
      <qui:values>
        <xsl:apply-templates select="." mode="field-value" />
      </qui:values>
    </qui:field>
  </xsl:template>

</xsl:stylesheet>