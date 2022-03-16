<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <link rel="stylesheet" href="{$docroot}styles/image/index.css" />

    <style>
    </style>
  </xsl:template>

  <xsl:template match="qui:main">
    <xsl:choose>
      <xsl:when test="//qui:hero-image">
        <xsl:apply-templates select="//qui:hero-image" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="build-collection-heading">
          <xsl:with-param name="badge">
            <xsl:value-of select="@data-badge" />
          </xsl:with-param>
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>

    <!-- <div class="message-callout">
      <p>
        This collection index re-design is still under construction.
      </p>
    </div> -->

    <div class="[ flex flex-flow-row flex-gap-1 ]">
      <div class="side-panel">
        <xsl:apply-templates select="//qui:panel[@slot='browse']" />
        <xsl:apply-templates select="//qui:panel[@slot='custom']" />
        <xsl:call-template name="build-filters-panel" />
        <xsl:apply-templates select="//qui:panel[@slot='related-collections']" />
        <xsl:apply-templates select="//qui:panel[@slot='access-restrictions']" />
      </div>
      <div class="main-panel">
        <xsl:apply-templates select="//qui:panel[@slot='browse']">
          <xsl:with-param name="classes">[ viewport-narrow ]</xsl:with-param>
        </xsl:apply-templates>
        <xsl:call-template name="build-search-form" />
        <div class="text-block">
          <xsl:apply-templates select="//qui:block[@slot='information']" />
          <xsl:apply-templates select="//qui:block[@slot='copyright']" />
          <xsl:apply-templates select="//qui:block[@slot='links']" />
        </div>
      </div>
    </div>

  </xsl:template>

  <xsl:template match="qui:hero-image">
    <div class="hero">
      <div class="hero--banner" style="--background-src: url(https://quod.lib.umich.edu/cgi/i/image/api/image/{@identifier}/full/1000,/0/default.jpg)">
        <div class="collection-title">
          <xsl:call-template name="build-collection-heading">
            <xsl:with-param name="badge">
              <xsl:value-of select="@data-badge" />
            </xsl:with-param>
          </xsl:call-template>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="qui:block[@slot='copyright']">
    <h2>Rights and Permissions</h2>
    <xsl:apply-templates mode="copy" />
  </xsl:template>

  <xsl:template match="qui:block[@slot='links']">
    <div class="[ flex ][ mt-1 ]">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="qui:figure">
    <xsl:variable name="id" select="generate-id()" />
    <a href="{@href}" id="{$id}">
      <xsl:if test="qui:style">
        <style>
          <xsl:apply-templates select="qui:style">
            <xsl:with-param name="id" select="$id" />
          </xsl:apply-templates>
        </style>
      </xsl:if>
      <figure>
        <xsl:apply-templates select="qui:img" />
        <xsl:apply-templates select="qui:caption" />
      </figure>
    </a>
  </xsl:template>

  <xsl:template match="qui:style">
    <xsl:param name="id" />
    <xsl:value-of select="concat('#', $id, ' ', .)" />
  </xsl:template>

  <xsl:template match="qui:img">
    <img height="{@height}" width="{@width}">
      <xsl:attribute name="src">
        <xsl:choose>
          <xsl:when test="starts-with(@src, 'http')">
            <xsl:value-of select="@src" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat('https://quod.lib.umich.edu', @src)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </img>
  </xsl:template>

  <xsl:template match="qui:block[@slot='help']" priority="100">
    <p class="help-text">
      <xsl:apply-templates mode="copy" />
    </p>
  </xsl:template>

  <xsl:template match="qui:caption">
    <figcaption>
      <xsl:apply-templates mode="copy" />
    </figcaption>
  </xsl:template>

  <xsl:template match="qui:panel[@slot='browse']" priority="100">
    <xsl:param name="classes" />
    <div class="[ link-box ][ flex flex-center ]{$classes}">
      <!-- <svg xmlns="http://www.w3.org/2000/svg" height="16px" viewBox="0 0 24 24" width="16px" fill="#106684" aria-hidden="true" focusable="false" role="presentation">
        <path d="M0 0h24v24H0V0z" fill="none" />
        <path d="M19 19H5V5h7V3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z" />
      </svg> -->
      <xsl:variable name="link" select="qui:link[@rel='browse-items']" />
      <a href="{$link/@href}">
        <xsl:text>Browse </xsl:text>
        <xsl:value-of select="$link/@data-count" />
        <xsl:text> collection items</xsl:text>
      </a>
    </div>
  </xsl:template>

  <xsl:template name="build-single-filter-option" />

  <xsl:template name="build-search-additional-fields">
    <div class="[ flex ]" style="margin-top: -0.5rem">
      <xsl:apply-templates select="//qui:filter[@key='med']" mode="index" />
    </div>
  </xsl:template>

  <xsl:template match="qui:filter[@key='med']" mode="index" priority="100">
    <div>
      <label>
        <input type="checkbox" value="{qui:values/qui:value}" name="med">
          <xsl:if test="qui:values/qui:value/@selected = 'true'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input>
        <xsl:text> </xsl:text>
        <xsl:value-of select="qui:label" />
      </label>
    </div>
  </xsl:template>

  <xsl:template name="build-filter-item--value-list">
    <xsl:param name="key" />
    <ul class="[ nav ]">
      <xsl:for-each select="qui:values/qui:value[not(@selected)]">
        <xsl:call-template name="build-filter-item--value">
          <xsl:with-param name="key" select="$key" />
        </xsl:call-template>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template name="build-filter-item--value">
    <xsl:param name="key" />
    <li>
      <a href="/cgi/i/image/image-idx?cc={$collid};fn1={$key};fq1={.};q1=*;rgn1=ic_all;view=reslist">
        <span><xsl:value-of select="." /></span>
        <xsl:text> </xsl:text>
        <span class="filters__count">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="@count" />
          <xsl:text>)</xsl:text>
        </span>
      </a>
    </li>
  </xsl:template>

</xsl:stylesheet>