<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:param name="prototype">stacked</xsl:param>

  <xsl:template name="build-extra-scripts">

    <!-- <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.43/dist/themes/base.css" />
    <script type="module" src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.43/dist/shoelace.js"></script> -->

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.64/dist/themes/light.css" />
    <script type="module" src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.64/dist/shoelace.js"></script>

    <!-- <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/tocbot/4.11.1/tocbot.css" /> -->
    <script src="https://cdnjs.cloudflare.com/ajax/libs/tocbot/4.11.1/tocbot.js"></script>
    <script src="https://unpkg.com/container-query-polyfill/cqfill.iife.min.js"></script>

    <link rel="stylesheet" href="{$docroot}styles/image/entry.css" />
    <script src="{$docroot}js/sr-messaging.js"></script>
    <script src="{$docroot}js/image/base.js"></script>
    <script src="{$docroot}js/image/entry.js"></script>
  </xsl:template>

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <!-- ideally would be the whole viewport width -->
    <style>
    </style>
  </xsl:template>

  <xsl:template name="build-extra-main-class">
    <xsl:text>[ mt-0 ]</xsl:text>
  </xsl:template>

  <xsl:template match="qui:main">

    <xsl:call-template name="build-navigation" />

    <xsl:call-template name="build-page-heading" />

    <xsl:call-template name="build-asset-viewer" />

    <div class="[ flex flex-flow-rw ][ aside--wrap ]">

      <div class="[ aside ]">
        <nav class="[ page-index ]" xx-aria-labelledby="page-index-label">
          <h2 id="page-index-label" class="[ subtle-heading ][ text-black js-toc-ignore ]">Page Index</h2>
          <!-- <div id="page-index-label" class="[ subtle-heading ][ mb-1 ]">Page Index</div> -->
          <div class="toc js-toc"></div>
          <select id="action-page-index"></select>
        </nav>
      </div>

      <div class="[ main-panel ]">

        <xsl:call-template name="build-main-stacked"></xsl:call-template>
      
      </div>
    </div>

  </xsl:template>

  <xsl:template name="build-main-stacked">

    <xsl:apply-templates select="qui:block[@slot='actions']" />

    <xsl:apply-templates select="qui:block[@slot='record']" />

    <xsl:apply-templates select="qui:block[@slot='rights-statement']" />

    <xsl:call-template name="build-panel-related-links" />

  </xsl:template>

  <xsl:template name="build-page-heading">
    <h1 class="collection-heading--small">
      <xsl:value-of select="//qui:header[@role='main']" />
    </h1>
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

  <xsl:template name="build-breadcrumbs-extra-nav">
    <xsl:apply-templates select="qui:nav[@role='results']" mode="pagination-link" />
  </xsl:template>

  <xsl:template match="qui:nav[@role='results']" mode="pagination-link">
    <p class="[ pagination ][ nowrap ml-2 ]">
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
        <xsl:apply-templates select="qui:link[@rel='previous']" />
      </xsl:if>
      <span>
        <xsl:value-of select="@index + 1" />
        <xsl:text> of </xsl:text>
        <xsl:value-of select="@total" />
      </span>
      <xsl:if test="qui:link[@rel='next']">
        <xsl:apply-templates select="qui:link[@rel='next']" />
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
      <xsl:text>Viewer for &quot;</xsl:text>
      <xsl:value-of select="//qui:header[@role='main']" />
      <xsl:text>&quot;</xsl:text>
    </xsl:variable>
    <xsl:variable name="viewer" select="//qui:viewer" />
    <xsl:if test="$viewer">
      <h2 id="viewer-heading" class="visually-hidden">Viewer</h2>
      <iframe 
        id="viewer" 
        class="[ viewer ]" 
        allow="fullscreen" 
        title="{$title}"
        src="{ $viewer/@embed-href }"></iframe>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-asset-viewer--inline">
    <xsl:variable name="viewer" select="//qui:viewer" />
    <xsl:if test="$viewer">
      <div 
        id="viewer"
        class="viewer"
        data-manifest-id="{$viewer/@manifest-id}" 
        data-canvas-index="{$viewer/@canvas-index}"
        data-provider="{$viewer/@provider}"
        data-mode="{$viewer/@mode}">
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:block[@slot='actions']">
    <div class="[ actions ][ actions--toolbar-wrap ]">
      <h2 class="[ subtle-heading ][ text-black ]">Actions</h2>
      <div class="[ toolbar ]">
        <xsl:call-template name="build-download-action" />
        <xsl:call-template name="build-favorite-action" />
        <xsl:call-template name="build-copy-link-action" />
        <!-- <xsl:apply-templates select="." mode="extra" /> -->
      </div>
    </div>
  </xsl:template>

  <xsl:template name="build-download-action">
    <xsl:call-template name="build-download-action-shoelace" />
    <!-- <xsl:call-template name="build-download-action-html" /> -->
  </xsl:template>

  <xsl:template name="build-download-action-shoelace">
    <xsl:if test="qui:download-options/qui:download-item">
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
    </xsl:if>
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
            <xsl:text>Remove from portfolio</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Save to portfolio</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
      <xsl:with-param name="classes">
        <xsl:text>button--secondary</xsl:text>
      </xsl:with-param>
      <xsl:with-param name="icon">
        <xsl:choose>
          <xsl:when test="qui:favorite-form/@checked='true'">
            <xsl:text>remove</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>add</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-copy-link-action">
    <xsl:call-template name="button">
      <xsl:with-param name="label">Copy Link</xsl:with-param>
      <xsl:with-param name="classes">button--secondary</xsl:with-param>
      <xsl:with-param name="icon">link</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="qui:block[@slot='record']">
    <section class="[ records ]">
      <h2 class="[ subtle-heading ][ text-black ]" id="details">About this Item</h2>
      <xsl:apply-templates select="qui:section" />
    </section>
  </xsl:template>

  <xsl:template match="qui:block[@slot='rights-statement']">
    <section>
      <h2 class="[ subtle-heading ][ text-black ]" id="rights-statement">Rights/Permissions</h2>
      <xsl:apply-templates mode="copy" />
    </section>
  </xsl:template>

  <xsl:template name="build-panel-related-links">
    <xsl:variable name="block" select="//qui:block[@slot='special']" />
    <section class="[ records ]">
      <h2 class="[ subtle-heading ][ text-black ]" id="related-links">Related Links</h2>
      <xsl:if test="$block/qui:field">
        <dl class="record">
          <div>
            <dt>More Item Details</dt>
            <xsl:apply-templates select="$block/qui:field[@component='catalog-link']" mode="dl" />
            <xsl:apply-templates select="$block/qui:field[@component='system-link']" mode="dl" />
          </div>
        </dl>
      </xsl:if>

      <xsl:call-template name="build-panel-portfolios-dl" />

      <xsl:call-template name="build-panel-iiif-manifest" />
    </section>
  </xsl:template>

  <xsl:template name="build-panel-iiif-manifest">
    <xsl:if test="//qui:viewer/@manifest-id">
      <h3>IIIF</h3>
      <dl class="record">
        <div>
          <dt>Manifest</dt>
          <dd>
            <input type="text" value="{//qui:viewer/@manifest-id}" />
          </dd>
        </div>
      </dl>
    </xsl:if>
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
          <div>
            <dt>In your portfolios</dt>
            <xsl:apply-templates select="$private-list" mode="dl" />
          </div>
        </xsl:if>
        <xsl:if test="$public-list//qui:portfolio-link">
          <div>
            <dt id="public-list">In public portfolios</dt>
            <xsl:apply-templates select="$public-list" mode="dl" />
          </div>
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
      <h2 class="[ subtle-heading ][ text-black ]" id="related-links">Related Links</h2>

      <xsl:if test="$block/qui:field">
        <h3>More Item Details</h3>
        <xsl:apply-templates select="$block/qui:field" />
      </xsl:if>

      <xsl:call-template name="build-panel-portfolios" />

      <h3 id="iiif-links">IIIF</h3>
      <dl class="record">
        <div>
          <dt>
            Manifest Link
          </dt>
          <dd>
            <input type="text" value="{//qui:viewer/@manifest-id}" />
          </dd>
        </div>
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

  <xsl:template name="button">
    <xsl:param name="label" />
    <xsl:param name="classes" />
    <xsl:param name="icon" />
    <button class="button button--large {$classes}">
      <xsl:value-of select="$label" />
      <xsl:if test="normalize-space($icon)">
        <span class="material-icons" aria-hidden="true"><xsl:value-of select="$icon" /></span>
      </xsl:if>
    </button>
  </xsl:template>

</xsl:stylesheet>