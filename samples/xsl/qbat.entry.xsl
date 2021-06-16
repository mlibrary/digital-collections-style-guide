<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:param name="prototype">stacked</xsl:param>

  <xsl:template name="build-extra-scripts">
    <script src="https://unpkg.com/mirador@latest/dist/mirador.min.js"></script>
    <xsl:if test="false()">
      <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.0.1/dist/css/bootstrap.min.css" rel="stylesheet" integrity="sha384-+0n0xVW2eSR5OomGNYDnhzAbDsOXxcvSN1TPprVMTNDbiYZCxYbOOl7+AMvyTG2x" crossorigin="anonymous" />
      <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.0.1/dist/js/bootstrap.bundle.min.js" integrity="sha384-gtEjrD/SeCtmISkJkNUaaKMoLD0//ElJ19smozuHV6z3Iehds+3Ulb9Bn9Plx0x4" crossorigin="anonymous"></script>
    </xsl:if>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.43/dist/themes/base.css" />
    <script type="module" src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.43/dist/shoelace.js"></script>

    <!-- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/tocbot/4.11.1/tocbot.css" /> -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/tocbot/4.11.1/tocbot.js"></script>

    <link rel="stylesheet" href="/samples/styles/entry.css" />
    <script src="/samples/js/entry.js"></script>
  </xsl:template>

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <!-- ideally would be the whole viewport width -->
    <style>
    </style>
  </xsl:template>

  <xsl:template match="qui:main">

    <xsl:call-template name="build-navigation" />

    <xsl:call-template name="build-asset-viewer" />

    <xsl:call-template name="build-collection-heading" />

    <div class="[ container ] [ flex ]">

      <div class="[ aside ]">
        <div class="toc js-toc"></div>
      </div>

        <div class="[ container ]">
          <xsl:choose>
            <xsl:when test="$prototype = 'sidebar'">
              <xsl:call-template name="build-main-sidebar" />
            </xsl:when>
            <xsl:when test="$prototype = 'stacked'">
              <xsl:call-template name="build-main-stacked"></xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <pre>TBD</pre>
            </xsl:otherwise>
          </xsl:choose>
        </div>

    </div>



  </xsl:template>

  <xsl:template name="build-main-sidebar">
    <div class="sidebar">
      <section class="record-container">
        <xsl:apply-templates select="qui:block" />
      </section>
      <div>
        <section class="action-panel">
          <xsl:apply-templates select="qui:panel" />
        </section>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="build-main-stacked">

    <!-- <xsl:call-template name="build-page-navigator" /> -->

    <xsl:apply-templates select="qui:block[@slot='actions']" />

    <xsl:apply-templates select="qui:block[@slot='record']" />

    <xsl:apply-templates select="qui:block[@slot='rights-statement']" />

    <xsl:call-template name="build-panel-related-links" />

  </xsl:template>

  <xsl:template name="build-navigation">
    <!-- <xsl:apply-templates select="qui:nav[@role='results']" mode="back-link" /> -->
    <xsl:call-template name="build-breadcrumbs" />
  </xsl:template>

  <xsl:template match="qui:main/qui:nav[@role='results']" mode="back-link">
    <section aria-labelledby="results-nav-heading">
      <h2 id="results-nav-heading" class="visually-hidden">
        Results navigation
      </h2>
      <a href="qui:link[@rel='back']/@href">Back to search results</a>
    </section>
  </xsl:template>

  <xsl:template name="build-breadcrumbs">
    <section class="[ breadcrumb ]">
      <nav aria-label="Breadcrumb">
        <ol>
          <xsl:for-each select="qui:nav[@role='breadcrumb']/qui:link">
            <li>
              <a href="{@href}">
                <xsl:if test="position() = last()">
                  <xsl:attribute name="aria-current">page</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="." />
              </a>
              <xsl:if test="position() &lt; last()">
                <svg
                  height="18px"
                  viewBox="0 0 20 20"
                  width="12px"
                  fill="#06080a"
                  aria-hidden="true"
                >
                  <g>
                    <g><rect fill="none" height="20" width="20" /></g>
                  </g>
                  <g>
                    <polygon
                      points="4.59,16.59 6,18 14,10 6,2 4.59,3.41 11.17,10"
                    />
                  </g>
                </svg>
              </xsl:if>
            </li>
          </xsl:for-each>
        </ol>
      </nav>
      <xsl:apply-templates select="qui:nav[@role='results']" mode="pagination-link" />
    </section>
  </xsl:template>

  <xsl:template match="qui:nav[@role='results']" mode="pagination-link">
    <p class="color-neutral-300">
      <xsl:if test="qui:link[@rel='previous']">
        <svg
          height="18px"
          viewBox="0 0 20 20"
          width="12px"
          fill="#06080a"
          aria-hidden="true"
          style="transform: rotate(-180deg)"
        >
          <g>
            <g><rect fill="none" height="20" width="20" /></g>
          </g>
          <g>
            <polygon
              points="4.59,16.59 6,18 14,10 6,2 4.59,3.41 11.17,10"
            />
          </g>
        </svg>
        <a href="qui:link[@rel='previous']/@href">Previous</a>
      </xsl:if>
      <span>
        <xsl:value-of select="@index + 1" />
        <xsl:text> of </xsl:text>
        <xsl:value-of select="@total" />
      </span>
      <xsl:if test="qui:link[@rel='next']">
        <a href="qui:link[@rel='next']/@href">Next</a>
          <svg
            height="18px"
            viewBox="0 0 20 20"
            width="12px"
            fill="#06080a"
            aria-hidden="true"
          >
            <g>
              <g><rect fill="none" height="20" width="20" /></g>
            </g>
            <g>
              <polygon
                points="4.59,16.59 6,18 14,10 6,2 4.59,3.41 11.17,10"
              />
            </g>
          </svg>
      </xsl:if>
    </p>
  </xsl:template>

  <xsl:template match="qui:main/qui:nav">
    <section aria-labelledby="results-nav-heading">
      <h2 id="results-nav-heading" class="visually-hidden">
        Results navigation
      </h2>

      <section class="[ breadcrumb ]">
        <nav aria-label="Breadcrumb">
          <ol>
          </ol>
        </nav>
        <p class="color-neutral-300">
          <xsl:if test="qui:link[@rel='previous']">
            <a href="qui:link[@rel='previous']/@href">Previous</a>
          </xsl:if>
          <span>
            <xsl:value-of select="@index + 1" />
            <xsl:text> of </xsl:text>
            <xsl:value-of select="@total" />
          </span>
          <xsl:if test="qui:link[@rel='next']">
            <a href="qui:link[@rel='next']/@href">Next</a>
          </xsl:if>
        </p>
      </section>
    </section>
  </xsl:template>

  <xsl:template name="build-asset-viewer">
    <xsl:variable name="title">
      <xsl:text>Image viewer for &quot;</xsl:text>
      <xsl:value-of select="//qui:header[@role='main']" />
      <xsl:text>&quot;</xsl:text>
    </xsl:variable>
    <xsl:variable name="viewer" select="//qui:viewer" />
    <iframe 
      id="viewer" 
      class="[ viewer ]" 
      allow="fullscreen" 
      title="{$title}"
      src="https://quod.lib.umich.edu/cgi/i/image/api/embed/{$viewer/@collid}:{$viewer/@m_id}:{$viewer/@m_iid}"></iframe>
  </xsl:template>

  <xsl:template name="build-asset-viewer--inline">
    <xsl:variable name="viewer" select="//qui:viewer" />
    <div 
      id="viewer"
      class="viewer"
      data-manifest-id="{$viewer/@manifest-id}" 
      data-canvas-index="{$viewer/@canvas-index}"
      data-provider="{$viewer/@provider}"
      data-mode="{$viewer/@mode}">
    </div>
  </xsl:template>

  <xsl:template name="build-collection-heading">
    <h1 class="collection-heading">
      <xsl:value-of select="//qui:header[@role='main']" />
    </h1>
  </xsl:template>

  <xsl:template match="qui:block[@slot='actions']">
    <div class="[ actions ]">
      <h2>Actions</h2>
      <div class="[ toolbar ]">
        <xsl:call-template name="build-download-action" />
        <xsl:call-template name="build-favorite-action" />
        <xsl:call-template name="build-copy-link-action" />
        <xsl:apply-templates select="." mode="extra" />
      </div>
    </div>
  </xsl:template>

  <xsl:template name="build-download-action">
    <xsl:call-template name="build-download-action-shoelace" />
    <!-- <xsl:call-template name="build-download-action-html" /> -->
  </xsl:template>

  <xsl:template name="build-download-action-shoelace">
    <sl-dropdown id="dropdown-action">
      <sl-button slot="trigger" caret="caret">Download</sl-button>
      <sl-menu>
        <xsl:for-each select="qui:download-options/qui:download-item">
          <sl-menu-item data-href="{@href}">
            <xsl:value-of select="@width" />
            <xsl:text> x </xsl:text>
            <xsl:value-of select="@height" />
          </sl-menu-item>
        </xsl:for-each>
      </sl-menu>
    </sl-dropdown>
  </xsl:template>

  <xsl:template name="build-download-action-html">
    <div class="dropdown">
      <xsl:call-template name="button">
        <xsl:with-param name="label">Download</xsl:with-param>
      </xsl:call-template>
      <ul class="dropdown-menu" aria-labelledby="download-action">
        <xsl:for-each select="qui:download-options/qui:download-item">
          <li>
            <a class="dropdown-item" href="{@href}">
              <xsl:value-of select="@width" />
              <xsl:text> x </xsl:text>
              <xsl:value-of select="@height" />
            </a>
          </li>
        </xsl:for-each>
      </ul>
    </div>
  </xsl:template>

  <xsl:template name="build-favorite-action">
    <xsl:call-template name="button">
      <xsl:with-param name="label">
        <xsl:choose>
          <xsl:when test="qui:favorite-form/@checked='true'">
            <xsl:text>Remove from favorites</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Save to favorites</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-copy-link-action">
    <xsl:call-template name="button">
      <xsl:with-param name="label">Copy Link</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="qui:block[@slot='record']">
    <section class="[ record-container ]">
      <h2 id="details">Details</h2>
      <xsl:apply-templates select="qui:section" />
    </section>
  </xsl:template>

  <xsl:template match="qui:block[@slot='rights-statement']">
    <section class="[ record-container ]">
      <h2 id="rights-statement">Rights/Permissions</h2>
      <xsl:apply-templates mode="copy" />
    </section>
  </xsl:template>

  <xsl:template name="build-panel-related-links">
    <xsl:variable name="block" select="//qui:block[@slot='related-links']" />
    <section class="[ record-container ]">
      <h2 id="related-links">Related Links</h2>
      <xsl:if test="$block/qui:field">
        <dl class="record">
          <dt>More Item Details</dt>
          <xsl:apply-templates select="$block/qui:field" mode="dl" />
        </dl>
      </xsl:if>

      <xsl:call-template name="build-panel-portfolios-dl" />

      <h3>IIIF</h3>
      <dl class="record">
        <dt>Manifest</dt>
        <dd>
          <input type="text" value="{//qui:viewer/@manifest-id}" />
        </dd>

      </dl>
    </section>
  </xsl:template>

  <xsl:template match="qui:field[@component='catalog-link']" mode="dl">
    <dd>
      <a class="catalog-link" href="https://search.lib.umich.edu/catalog/Record/{qui:values/qui:value}">
        <xsl:value-of select="qui:label" />
      </a>
    </dd>
  </xsl:template>

  <xsl:template match="qui:field[@component='system-link']" mode="dl">
    <dd>
      <a class="system-link" href="{qui:values/qui:value}">
        <xsl:value-of select="qui:label" />
      </a>
    </dd>
  </xsl:template>

  <xsl:template name="build-panel-portfolios-dl">
    <xsl:variable name="private-list" select="//qui:portfolio-list[@type='private']" />
    <xsl:variable name="public-list" select="//qui:portfolio-list[@type='public']" />

    <xsl:if test="$private-list//qui:portfolio-link or $public-list//qui:portfolio-link">
      <h3 id="portfolios">Portfolios</h3>
      <dl class="record">
        <xsl:if test="$private-list//qui:portfolio-link">
          <dt>In your portfolios</dt>
          <xsl:apply-templates select="$private-list" mode="dl" />
        </xsl:if>
        <xsl:if test="$public-list//qui:portfolio-link">
          <dt id="public-list">In public portfolios</dt>
          <xsl:apply-templates select="$public-list" mode="dl" />
        </xsl:if>
      </dl>

    </xsl:if>
    

  </xsl:template>

  <xsl:template match="qui:portfolio-list" mode="dl">
    <xsl:for-each select="qui:portfolio-link">
      <dd>
        <a href="{@href}">
          <xsl:value-of select="qui:title" />
          <xsl:text> (</xsl:text>
          <xsl:value-of select="qui:count" />
          <xsl:text>)</xsl:text>
        </a>
      </dd>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="qui:portfolio-list">
    <ul>
      <xsl:for-each select="qui:portfolio-link">
        <li>
          <a href="{@href}">
            <xsl:value-of select="qui:title" />
            <xsl:text> (</xsl:text>
            <xsl:value-of select="qui:count" />
            <xsl:text>)</xsl:text>
          </a>
          <xsl:if test="@editable = 'true'">
            <form method="POST" action="#">
              <input type="hidden" name="bbidno" value="{@bbidno}" />
              <input type="hidden" name="bbdid" value="{@bbdid}" />
              <xsl:call-template name="button">
                <xsl:with-param name="label">Remove</xsl:with-param>
                <xsl:with-param name="classes">small</xsl:with-param>
              </xsl:call-template>
            </form>
          </xsl:if>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="qui:field" mode="dd">
    <dd>

    </dd>
  </xsl:template>

  <xsl:template name="build-panel-related-links-dl">
    <xsl:variable name="block" select="//qui:block[@slot='related-links']" />
    <div class="[ panel ]">
      <h2 id="related-links">Related Links</h2>

      <xsl:if test="$block/qui:field">
        <h3>More Item Details</h3>
        <xsl:apply-templates select="$block/qui:field" />
      </xsl:if>

      <xsl:call-template name="build-panel-portfolios" />

      <h3 id="iiif-links">IIIF</h3>
      <dl class="record">
        <dt>
          Manifest Link
        </dt>
        <dd>
          <input type="text" value="{//qui:viewer/@manifest-id}" />
        </dd>
      </dl>

    </div>
  </xsl:template>

  <xsl:template name="build-panel-portfolios">
    <xsl:variable name="private-list" select="//qui:portfolio-list[@type='private']" />
    <xsl:variable name="public-list" select="//qui:portfolio-list[@type='public']" />

    <xsl:if test="$private-list//qui:portfolio-link">
      <h3 id="private-list">In your portfolios</h3>
      <xsl:apply-templates select="$private-list" />
    </xsl:if>
    <xsl:if test="$public-list//qui:portfolio-link">
      <h3 id="public-list">In public portfolios</h3>
      <xsl:apply-templates select="$public-list" />
    </xsl:if>

  </xsl:template>

  <xsl:template match="qui:portfolio-list">
    <ul>
      <xsl:for-each select="qui:portfolio-link">
        <li>
          <a href="{@href}">
            <xsl:value-of select="qui:title" />
            <xsl:text> (</xsl:text>
            <xsl:value-of select="qui:count" />
            <xsl:text>)</xsl:text>
          </a>
          <xsl:if test="@editable = 'true'">
            <form method="POST" action="#">
              <input type="hidden" name="bbidno" value="{@bbidno}" />
              <input type="hidden" name="bbdid" value="{@bbdid}" />
              <xsl:call-template name="button">
                <xsl:with-param name="label">Remove</xsl:with-param>
                <xsl:with-param name="classes">small</xsl:with-param>
              </xsl:call-template>
            </form>
          </xsl:if>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template name="build-page-navigator">
    <xsl:variable name="navigator-tmp">
      <qui:navigator>
        <qui:anchor href="#actions" label="Actions" />
        <qui:anchor href="#details" label="Details">
          <xsl:for-each select="//qui:block[@slot='record']/qui:section[@name != '']">
            <qui:anchor href="#{@slug}" label="{@name}" />
          </xsl:for-each>
        </qui:anchor>
        <qui:anchor href="#rights-statement" label="Rights Statement" />
        <qui:anchor href="#related-links" label="Related Links">
          <xsl:if test="//qui:block[@slot='related-links']/qui:field">
            <qui:anchor href="#more-item-details" label="More Item Details" />
          </xsl:if>
          <xsl:if test="//qui:portfolio-list[@type='private']/qui:portfolio-link">
            <qui:anchor href="#private-list" label="In your portfolios" />
          </xsl:if>
          <xsl:if test="//qui:portfolio-list[@type='public']/qui:portfolio-link">
            <qui:anchor href="#public-list" label="In public portfolios" />
          </xsl:if>
          <qui:anchor href="#iiif" label="IIIF" />
        </qui:anchor>
      </qui:navigator>
    </xsl:variable>
    <xsl:variable name="navigator" select="exsl:node-set($navigator-tmp)" />
    <div class="[ navigator ]">
      <h2>Contents</h2>
      <nav id="contents-navigator">
        <ul class="outline">
          <xsl:apply-templates select="$navigator/qui:navigator/qui:anchor" />
        </ul>
      </nav>
    </div>
  </xsl:template>

  <xsl:template match="qui:anchor">
    <li>
      <a href="{@href}"><xsl:value-of select="@label" /></a>
      <xsl:if test="qui:anchor">
        <ul>
          <xsl:apply-templates select="qui:anchor" />
        </ul>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match="qui:block">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="qui:anchor">
    <li>
      <a href="{@href}"><xsl:value-of select="@label" /></a>
      <xsl:if test="qui:anchor">
        <ul>
          <xsl:apply-templates select="qui:anchor" />
        </ul>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template match="qui:block">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="qui:header[@role='main']">
  </xsl:template>

  <xsl:template match="qui:section">
    <xsl:if test="@name != 'default'">
      <h3 id="{@class}"><xsl:value-of select="@name" /></h3>
    </xsl:if>
    <xsl:if test="@name = 'default'">
      <h3 id="record_details">Record Details</h3>
    </xsl:if>
    <dl class="record">
      <xsl:apply-templates />
    </dl>
  </xsl:template>

  <xsl:template match="qui:section" mode="v1">
    <section class="record-container">
      <xsl:if test="@name != 'default'">
        <h3><xsl:value-of select="@name" /></h3>
      </xsl:if>
      <dl class="record">
        <xsl:apply-templates />
      </dl>
    </section>
  </xsl:template>

  <xsl:template match="qui:field[@component='catalog-link']" priority="99">
    <p>
      <a class="catalog-link" href="https://search.lib.umich.edu/catalog/Record/{qui:values/qui:value}">
        <xsl:value-of select="qui:label" />
      </a>
    </p>
  </xsl:template>

  <xsl:template match="qui:field[@component='system-link']" priority="99">
    <p>
      <a class="system-link" href="{qui:values/qui:value}">
        <xsl:value-of select="qui:label" />
      </a>
    </p>
  </xsl:template>

  <xsl:template match="qui:field[@component='input']//qui:value" mode="copy-guts" priority="99">
    <input type="text" value="{.}" />
  </xsl:template>

  <xsl:template match="qui:field">
    <dt data-key="{@key}">
      <xsl:apply-templates select="qui:label" mode="copy-guts" />
    </dt>
    <xsl:for-each select="qui:values/qui:value">
      <dd>
        <xsl:apply-templates select="." mode="copy-guts" />
      </dd>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="button">
    <xsl:param name="label" />
    <xsl:param name="classes" />
    <button class="button {$classes}"><xsl:value-of select="$label" /></button>
  </xsl:template>

</xsl:stylesheet>