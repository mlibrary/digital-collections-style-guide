<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="current-page" select="/Top/CurrentPage" />

  <xsl:template name="get-title">
    <xsl:choose>
      <xsl:when test="key('get-lookup', concat('uplift.str.page.', $current-page))">
        <xsl:value-of select="key('get-lookup', concat('uplift.str.page.', $current-page))" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="//Content/div[@class='content']/h1" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-head-block">
    <qui:base href="/{substring($collid, 1, 1)}/{$collid}/" />
  </xsl:template>

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <xsl:call-template  name="get-title" />
    </qui:header>

    <xsl:call-template name="build-breadcrumbs" />
    <xsl:call-template name="build-static-content" />

    <xsl:apply-templates select="//Navigation" />

  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    <xsl:call-template name="get-title" />
  </xsl:template>

  <xsl:template name="build-static-content">
    <qui:block slot="content" data-current-page="{$current-page}">
      <xsl:apply-templates select="//Content" mode="copy-guts" />
    </qui:block>
  </xsl:template>

  <xsl:template match="h1" mode="copy" priority="100" />

  <xsl:template match="h2[not(@id)]" mode="copy" priority="100">
    <xhtml:h2 id="{generate-id(.)}">
      <xsl:apply-templates mode="copy" />
    </xhtml:h2>
  </xsl:template>

  <xsl:template name="get-view">static</xsl:template>

  <xsl:template match="Navigation[Link or Section]">
    <qui:nav rel="pages">
      <qui:ul>
        <xsl:apply-templates select="Link|Section" mode="navigation" />
      </qui:ul>
    </qui:nav>
  </xsl:template>

  <xsl:template match="Link" mode="navigation">
    <qui:li>
      <qui:link href="{@href}">
        <xsl:if test="@current">
          <xsl:attribute name="data-current"><xsl:value-of select="@current" /></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates mode="copy" />
      </qui:link>
    </qui:li>
  </xsl:template>

  <xsl:template match="Section[@href]" mode="navigation">
    <qui:li>
      <qui:link href="{@href}">
        <xsl:apply-templates mode="copy" />
      </qui:link>
    </qui:li>
  </xsl:template>

  <xsl:template match="Section" mode="navigation">
    <qui:li>
      <qui:span>
        <xsl:value-of select="Label" />
      </qui:span>
      <qui:ul>
        <xsl:apply-templates select="Link" mode="navigation" />
      </qui:ul>
    </qui:li>
  </xsl:template>

</xsl:stylesheet>
