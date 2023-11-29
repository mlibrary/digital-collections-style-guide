<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="current-page" select="/Top/CurrentPage" />

  <xsl:template name="get-title">
    <xsl:choose>
      <xsl:when test="//PageTitle">
        <xsl:value-of select="//PageTitle" />
      </xsl:when>
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

    <xsl:call-template name="build-browse-navigation" />

    <xsl:call-template name="build-static-content" />

    <xsl:apply-templates select="//Navigation" />

  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    <xsl:call-template name="get-title" />
  </xsl:template>

  <xsl:template name="build-breadcrumbs-intermediate-links">
    <xsl:if test="//Navigation and $current-page != //Navigation//Page[1]/Link/@page">
      <qui:link href="{//Navigation//Page[1]/Link}">
        <xsl:value-of select="//Navigation//Page[1]/Label" />
      </qui:link>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-browse-navigation">
    <xsl:if test="//qui:panel[@slot='browse']//qui:link[@key]">
      <qui:nav role="browse">
        <xsl:for-each select="//qui:panel[@slot='browse']//qui:link[@key]">
          <qui:link key="{@key}" href="{@href}">
            <xsl:if test="//CurrentPage = @key">
              <xsl:attribute name="current">true</xsl:attribute>
            </xsl:if>
            <qui:label>
              <xsl:value-of select="key('get-lookup', concat('uplift.str.page.', @key))" />
            </qui:label>
          </qui:link>
        </xsl:for-each>
        <xsl:for-each select="/Top/NavHeader/BrowseFields/Field">
          <qui:link href="{Link}" key="{Name}">
            <qui:label>
              <xsl:value-of select="key('get-lookup', concat('browse.str.', Name, '.column'))" />
              <!-- <xsl:value-of select="dlxs:capitalize(Name)" /> -->
            </qui:label>
          </qui:link>
        </xsl:for-each>
      </qui:nav>
    </xsl:if>    
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
      <xsl:if test="Label">
        <qui:header>
          <xsl:value-of select="Label" />
        </qui:header>  
      </xsl:if>
      <qui:ul>
        <xsl:apply-templates select="Page|Section" mode="navigation" />
      </qui:ul>
    </qui:nav>
  </xsl:template>

  <xsl:template match="Page" mode="navigation">
    <qui:li>
      <qui:link href="{Link}">
        <xsl:if test="Link/@current">
          <xsl:attribute name="data-current"><xsl:value-of select="Link/@current" /></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="Label" mode="copy-guts" />
      </qui:link>
    </qui:li>
  </xsl:template>

  <xsl:template match="Section[Link]" mode="navigation">
    <qui:li>
      <qui:link href="{Link}">
        <xsl:apply-templates select="Label" mode="copy-guts" />
      </qui:link>
    </qui:li>
  </xsl:template>

  <xsl:template match="Section" mode="navigation">
    <qui:li>
      <qui:span>
        <xsl:value-of select="Label" />
      </qui:span>
      <qui:ul>
        <xsl:apply-templates select="Page" mode="navigation" />
      </qui:ul>
    </qui:li>
  </xsl:template>

</xsl:stylesheet>
