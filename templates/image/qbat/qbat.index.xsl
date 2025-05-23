<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="meta-noindex">false</xsl:variable>
  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />

  <xsl:template match="qui:main">
    <xsl:choose>
      <xsl:when test="//qui:hero-image">
        <xsl:apply-templates select="//qui:hero-image" />
      </xsl:when>
      <xsl:otherwise>
        <div class="[ mb-2 ]">
          <xsl:call-template name="build-collection-heading">
            <xsl:with-param name="badge">
              <xsl:value-of select="@data-badge" />
            </xsl:with-param>
          </xsl:call-template>
        </div>
      </xsl:otherwise>
    </xsl:choose>

    <div class="[ flex flex-flow-row flex-gap-1 ]">
      <div class="side-panel">
        <xsl:apply-templates select="//qui:panel[@slot='browse']">
          <xsl:with-param name="classes">browse-link</xsl:with-param>
        </xsl:apply-templates>

        <xsl:apply-templates select="//qui:panel[@slot='custom']" />
        
        <xsl:if test="//qui:filters-panel/qui:filter[@key != 'med']">
          <xsl:call-template name="build-filters-panel">
            <xsl:with-param name="margin-top">mt-0</xsl:with-param>
          </xsl:call-template>
        </xsl:if>

        <xsl:apply-templates select="//qui:panel[@slot='related-collections']" />

        <xsl:apply-templates select="//qui:panel[@slot='access-restrictions']" />
      </div>
      <div class="main-panel">
        <xsl:apply-templates select="//qui:panel[@slot='browse']">
          <xsl:with-param name="classes">[ viewport-narrow ]</xsl:with-param>
        </xsl:apply-templates>
        <xsl:call-template name="build-search-form" />
        <div class="text-block">
          <xsl:apply-templates select="//qui:block[@slot='links'][@align='top']" />
          <xsl:apply-templates select="//qui:block[@slot='information']" />
          <xsl:apply-templates select="//qui:block[@slot='contentwarning']" />
          <xsl:apply-templates select="//qui:block[@slot='copyright' or @slot='useguidelines']" />
          <xsl:apply-templates select="//qui:block[@slot='links'][not(@align)]" />
        </div>
      </div>
    </div>

  </xsl:template>

  <xsl:template match="qui:hero-image[@src]" priority="100">
    <div class="hero">
      <div class="hero--banner" style="--background-src: url({@src})">
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

  <xsl:template match="qui:hero-image">
    <xsl:variable name="position-y">
      <xsl:if test="normalize-space(@y)">
        <xsl:value-of select="concat('--background-position-y: ', @y, ';')" />
      </xsl:if>
    </xsl:variable>
    <div class="hero">
      <div class="hero--banner" style="--background-src: url({$api_url}/image/{@identifier}/{@region}/1280,/0/default.jpg);{$position-y}">
        <div class="collection-title">
          <xsl:call-template name="build-collection-heading">
            <xsl:with-param name="badge">
              <xsl:value-of select="@data-badge" />
            </xsl:with-param>
          </xsl:call-template>
        </div>
        <figure class="hero--figure">
          <!-- <img src="https://quod.lib.umich.edu/cgi/i/image/api/image/{@identifier}/full/1000,/0/default.jpg" /> -->
          <figcaption class="hero--caption">
            <a href="/cgi/i/image/image-idx?cc={$collid};entryid={@m_id};viewid={@m_iid};view=entry">
              <span class="material-icons" aria-hidden="true">info</span>
              <span class="caption visually-hidden">
                <xsl:apply-templates select="qui:caption" mode="copy-guts" />
              </span>
            </a>
          </figcaption>
        </figure>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="qui:block[@slot='contentwarning']">
    <xsl:if test="normalize-space(.)">
      <div class="alert-info">
        <xsl:if test="normalize-space(.//xhtml:h2) = ''">
          <h2>Content Warning</h2>
        </xsl:if>
        <xsl:apply-templates mode="copy" />
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:block[@slot='copyright' or @slot='useguidelines']">
    <xsl:if test="normalize-space(.)">
      <h2 id="rights-permissions">Rights and Permissions</h2>
      <xsl:apply-templates mode="copy" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:block[@slot='links']">
    <div class="[ flex flex-justify-center ][ mt-1 ]">
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
      <style>
        <xsl:value-of select="concat('#', $id, ' img { width: auto; align-self: center; }')" />
      </style>
      <figure class="flex align-center flex-flow-column">
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
      <xsl:apply-templates select="@class" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </figcaption>
  </xsl:template>

  <xsl:template match="qui:panel[@slot='browse']" priority="100">
    <xsl:param name="classes" />
    <h3 class="{$classes}">Browse this collection</h3>
    <div class="[ link-box ][ flex flex-center ]{$classes}">
      <!-- <svg xmlns="http://www.w3.org/2000/svg" height="16px" viewBox="0 0 24 24" width="16px" fill="#106684" aria-hidden="true" focusable="false" role="presentation">
        <path d="M0 0h24v24H0V0z" fill="none" />
        <path d="M19 19H5V5h7V3H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h14c1.1 0 2-.9 2-2v-7h-2v7zM14 3v2h3.59l-9.83 9.83 1.41 1.41L19 6.41V10h2V3h-7z" />
      </svg> -->
      <xsl:variable name="link" select="qui:link[@rel='browse-items']" />
      <a class="[ flex flex-start ][ gap-0_25 ]" href="{$link/@href}">
        <svg class="flex-shrink-0" xmlns="http://www.w3.org/2000/svg" height="24px" viewBox="0 0 24 24" width="24px" fill="#106684" aria-hidden="true" focusable="false" role="presentation">
          <g>
            <path d="M0,0h24v24H0V0z" fill="none"></path>
          </g>
          <g>
            <path d="M7,9H2V7h5V9z M7,12H2v2h5V12z M20.59,19l-3.83-3.83C15.96,15.69,15.02,16,14,16c-2.76,0-5-2.24-5-5s2.24-5,5-5s5,2.24,5,5 c0,1.02-0.31,1.96-0.83,2.75L22,17.59L20.59,19z M17,11c0-1.65-1.35-3-3-3s-3,1.35-3,3s1.35,3,3,3S17,12.65,17,11z M2,19h10v-2H2 V19z"></path>
          </g>
        </svg>
        <xsl:text>Browse </xsl:text>
        <xsl:value-of select="$link/@data-count" />
        <xsl:text> collection items</xsl:text>
      </a>
    </div>
    <xsl:apply-templates select="qui:link[not(@rel)]" mode="browse-link">
      <xsl:with-param name="classes"><xsl:value-of select="$classes" /></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="qui:link" mode="browse-link">
    <xsl:param name="classes" />
    <div class="[ link-box ][ flex flex-center ][ {$classes} ]">
      <a class="[ flex flex-start ][ gap-0_25 bedazzled-link ]" href="{@href}">
        <xsl:choose>
          <xsl:when test="@icon">
            <span class="material-icons flex-shrink-0" aria-hidden="true"><xsl:value-of select="@icon" /></span>
          </xsl:when>
          <xsl:otherwise>
            <span class="material-icons flex-shrink-0" aria-hidden="true" style="opacity: 0.5">check_box_outline_blank</span>
          </xsl:otherwise>
        </xsl:choose>
        <span><xsl:value-of select="." /></span>
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
      <label class="control-checkbox">
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
      <a href="/cgi/i/image/image-idx?cc={$collid};fn1={$key};fq1={@escaped};q1=*;rgn1=ic_all;view=reslist">
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