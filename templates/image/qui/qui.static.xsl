<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template name="get-title">
    <xsl:value-of select="//Content/div[@class='content']/h1" />
  </xsl:template>

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <xsl:call-template  name="get-title" />
    </qui:header>

    <xsl:call-template name="build-breadcrumbs" />
    <xsl:call-template name="build-static-content" />

  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    <xsl:call-template name="get-title" />
  </xsl:template>

  <xsl:template name="build-static-content">
    <qui:block slot="content">
      <xsl:apply-templates select="//Content/div" mode="copy-guts" />
    </qui:block>
  </xsl:template>

  <xsl:template match="h1" mode="copy" priority="100" />

</xsl:stylesheet>
