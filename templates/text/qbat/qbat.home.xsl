<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />
  <xsl:variable name="template" select="//qui:root/@template" />

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <link rel="stylesheet" href="{$docroot}styles/text/index.css" />

    <style>
    </style>
  </xsl:template>

  <xsl:template match="qui:main">
    <xsl:call-template name="build-main-index" />
  </xsl:template>

  <xsl:template name="build-main-index">
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
        <h2 class="visually-hidden">Options</h2>
        
        <xsl:apply-templates select="//qui:panel[@slot='browse']">
          <xsl:with-param name="classes">browse-link</xsl:with-param>
        </xsl:apply-templates>

        <xsl:if test="count(//qui:block[@slot != 'information' and @slot != 'links']) &gt; 0">
          <div class="[ pr-1 mb-1 ]">
            <h3>Page Index</h3>
            <div class="toc js-toc"></div>
            <xsl:if test="false()">
            <ul class="toc-list">
              <xsl:for-each select="//qui:block[@slot != 'information' and @slot != 'links'][normalize-space(.)]">
                <li class="toc-list-item">
                  <div class="flex flex-align-center gap-0_5">
                    <!-- <a style="font-size: 0.75rem" class="material-icons text-black no-underline" aria-hidden="true" href="{@href}">tag</a> -->
                    <a class="toc-link" href="#{@slot}">
                      <xsl:apply-templates select="." mode="build-link-text" />
                    </a>  
                  </div>
                  <xsl:if test="@slot = 'contents'">
                    <ul class="toc-list">
                      <xsl:for-each select="xhtml:figure">
                        <li class="toc-list-item">
                          <div class="flex flex-align-center gap-0_5">
                            <!-- <a style="font-size: 0.75rem;" class="material-icons text-black no-underline" aria-hidden="true" href="{@href}">tag</a> -->
                            <a class="toc-link" href="{@href}"><xsl:value-of select=".//xhtml:h3" /></a>  
                          </div>
                        </li>
                      </xsl:for-each>
                    </ul>  
                  </xsl:if>
                </li>
              </xsl:for-each>
            </ul>
            </xsl:if>
          </div>    
        </xsl:if>

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
          <xsl:apply-templates select="//qui:block[@slot='contents']" />
          <xsl:apply-templates select="//qui:block[@slot='contentwarning']" />
          <xsl:apply-templates select="//qui:block[@slot='access']" />
          <xsl:apply-templates select="//qui:block[@slot='copyright' or @slot='useguidelines']" />
          <xsl:apply-templates select="//qui:block[@slot='download']" />
          <xsl:apply-templates select="//qui:block[@slot='more-information']" />
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

  <xsl:template match="qui:block[@slot='contents'][.//qui:card]">
    <h2 id="{@slot}">Digitized Collection Contents</h2>
    <div class="[ gallery-view ]">
      <xsl:for-each select="qui:card">
        <!-- <div class="[ card ]"> -->
          <a class="[ card ][ border mb-1 ]" style="padding: 1rem; width: 50%;" href="{qui:link/@href}">
            <xsl:apply-templates select="qui:img" mode="card-image" />
            <xsl:apply-templates select="qui:header" mode="card-title" />
            <xsl:apply-templates select="qui:body" mode="card-body" />
          </a>  
        <!-- </div> -->
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="qui:block[@slot='contents'][.//xhtml:figure]">
    <h2 id="{@slot}">Digitized Collection Contents</h2>
    <div class="[ gallery-view ]">
      <xsl:for-each select="xhtml:figure">
        <!-- <div class="[ card ]"> -->
          <a class="[ card ][ border mb-1 ]" href="{@href}">
            <xsl:apply-templates select="xhtml:img" mode="card-image" />
            <xsl:apply-templates select="xhtml:xfigcaption/xhtml:h3" mode="card-title" />
            <xsl:apply-templates select="xhtml:figcaption" mode="card-body" />
          </a>  
        <!-- </div> -->
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="qui:img|xhtml:img" mode="card-image">
    <img class="[ card__image ]" src="{@src}" alt="" />
  </xsl:template>

  <xsl:template match="qui:header|xhtml:h3" mode="card-title">
    <h3 class="[ card__heading ]" style="max-width: max(25ch); width: auto;"><xsl:value-of select="." /></h3>
  </xsl:template>

  <xsl:template match="qui:body|xhtml:figcaption" mode="card-body">
    <xsl:apply-templates select="." mode="copy-guts" />
  </xsl:template>

  <xsl:template match="xhtml:figcaption/xhtml:h3" mode="copy-guts" priority="101" />

  <xsl:template match="qui:block[@slot='contentwarning']">
    <xsl:if test="normalize-space(.)">
      <div class="alert-info">
        <xsl:if test="normalize-space(.//xhtml:h2) = ''">
          <h2 id="{@slot}">Content Warning</h2>
        </xsl:if>
        <xsl:apply-templates mode="copy" />
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:block[@slot='access']">
    <xsl:if test="normalize-space(.)">
      <h2 id="{@slot}">Access</h2>
      <xsl:apply-templates mode="copy" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:block[@slot='copyright' or @slot='useguidelines']">
    <xsl:if test="normalize-space(.)">
      <h2 id="{@slot}">Rights and Permissions</h2>
      <xsl:apply-templates mode="copy" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:block[@slot='download']">
    <xsl:if test="normalize-space(.)">
      <h2 id="{@slot}">Downloadable Data</h2>
      <xsl:apply-templates mode="copy" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:block[@slot='links']">
    <div class="[ flex flex-justify-center ][ mt-1 ]">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="qui:figure[@href]">
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
      <xsl:apply-templates select="." mode="build-figure" />
    </a>
  </xsl:template>

  <xsl:template match="qui:figure">
    <xsl:apply-templates select="." mode="build-figure" />
  </xsl:template>

  <xsl:template match="qui:figure" mode="build-figure">
    <figure class="flex align-center flex-flow-column">
      <xsl:apply-templates select="qui:img" />
      <xsl:apply-templates select="qui:caption" />
    </figure>
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
    <h3 class="{$classes} js-toc-ignore">Browse this collection</h3>
    <!-- <div class="[ link-box ][ flex flex-center ]{$classes}">
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
    </div> -->
    <!-- <xsl:apply-templates select="qui:nav"></xsl:apply-templates> -->
    <xsl:apply-templates select=".//qui:link[not(@rel)]" mode="browse-link">
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

  <xsl:template match="qui:block" mode="build-link-text">
    <xsl:choose>
      <xsl:when test="@slot = 'contents'">Digitized Collection Contents</xsl:when>
      <xsl:when test="@slot = 'contentwarning'">
        <xsl:choose>
          <xsl:when test=".//xhtml:h2">
            <xsl:value-of select=".//xhtml:h2" />
          </xsl:when>
          <xsl:otherwise>Content Warning</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="@slot = 'access'">Access</xsl:when>
      <xsl:when test="@slot = 'copyright'">Rights and Permissions</xsl:when>
      <xsl:when test="@slot = 'useguidelines'">Rights and Permissions</xsl:when>
      <xsl:when test="@slot = 'more-information'">More Information</xsl:when>
      <xsl:when test="@slot = 'download'">Downloadable Data</xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>