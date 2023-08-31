<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE root [
<!ENTITY nbsp "&#160;">  
]>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="search-form" select="//SearchForm" />

  <xsl:template name="get-title">
    Index
  </xsl:template>

  <xsl:template name="build-body-main">
    <xsl:call-template name="build-body-page-index" />
  </xsl:template>

  <xsl:template name="build-body-page-index">
    <qui:header role="main">
      <xsl:call-template name="build-sub-header-badge-data" />
      <xsl:call-template name="get-collection-title" />
    </qui:header>
    
    <qui:block slot="information">
      <xsl:apply-templates select="//Content" mode="copy-guts" />
    </qui:block>

    <!-- can do we cards? -->
    <xsl:if test="//HomePage//xhtml:div[contains(@class, 'series-cards')]//xhtml:div[contains(@class, 'series-card')]">
      <qui:block slot="gallery">
        <xsl:for-each select="//HomePage//xhtml:div[contains(@class, 'series-cards')]//xhtml:div[contains(@class, 'series-card')]">
          <qui:card>
            <qui:img src="{.//xhtml:img/@src}" />
            <qui:link href="{.//xhtml:a/@href}" />
            <qui:header>
              <xsl:value-of select=".//xhtml:h3" />
            </qui:header>
            <qui:body>
              <xsl:apply-templates select=".//xhtml:p" mode="copy" />
            </qui:body>
          </qui:card>
        </xsl:for-each>
      </qui:block>
    </xsl:if>

    <qui:block slot="copyright">
      <xsl:apply-templates select="//HomePage//xhtml:div[@id='copyright']" mode="copy-guts" />
    </qui:block>
    <qui:block slot="more-information">
      <xsl:apply-templates select="//HomePage//xhtml:div[@id='more_info']" mode="copy-guts" />
    </qui:block>

    <xsl:if test="//HomePage//xhtml:section[xhtml:h1]/xhtml:img/@src">
      <qui:hero-image src="{//HomePage//xhtml:section[xhtml:h1]/xhtml:img/@src}" />
    </xsl:if>

    <xsl:call-template name="build-panel-custom" />
    <xsl:call-template name="build-panel-browse-links" />
    <xsl:call-template name="build-search-form" />
  </xsl:template>

  <xsl:template name="build-panel-custom">
    <qui:panel slot="custom">
      <qui:header>Links</qui:header>
      <qui:nav>
        <xsl:call-template name="build-nav-link">
          <xsl:with-param name="slug">about</xsl:with-param>
        </xsl:call-template>
      </qui:nav>
    </qui:panel>
    <xsl:apply-templates select="//qui:panel[@slot='custom']" mode="copy" />
  </xsl:template>

  <xsl:template name="build-nav-link">
    <xsl:param name="slug" />
    <xsl:variable name="nav-item" select="//MainNav/NavItem[Name=$slug]" />
    <xsl:variable name="key" select="concat('navheader.str.', $slug)" />
    <xsl:if test="$nav-item">
      <qui:link href="{$nav-item/Link}" data-key="{$key}"><xsl:value-of select="key('get-lookup',$key)" /></qui:link>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-panel-browse-links">
    <qui:panel class="callout" slot="browse">
      <qui:nav>
        <xsl:apply-templates select="//qui:panel[@slot='browse'][@weight=0]//qui:link" mode="copy" />
        <xsl:for-each select="//BrowseFields/Field">
          <qui:link href="{Link}" data-rel="browse-items" icon="layers">
            <xsl:text>Browse by </xsl:text>
            <xsl:value-of select="key('get-lookup', concat('headerutils.str.', Name))" />
          </qui:link>
        </xsl:for-each>
      <!-- <qui:link href="/cgi/i/image/image-idx?c={$collid};view=reslist;q1={$collid};med=1" rel="browse-images" data-count="{//Stats/Images}" /> -->
        <xsl:apply-templates select="//qui:panel[@slot='browse'][not(@weight)]//qui:link" mode="copy" />
      </qui:nav>
    </qui:panel>
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    <xsl:call-template name="get-title" />
  </xsl:template>

  <xsl:template match="//HomePage//xhtml:div[@id='copyright']//xhtml:h2" mode="copy" />

  <xsl:template match="Option">
    <xsl:param name="default" />
    <qui:option value="{Value}">
      <xsl:if test="Focus = 'true' or Value = $default">
        <xsl:attribute name="selected">true</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="Label" />
    </qui:option>
  </xsl:template>

</xsl:stylesheet>