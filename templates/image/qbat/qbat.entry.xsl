<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <xsl:param name="prototype">stacked</xsl:param>

  <xsl:template name="build-extra-scripts">

    <!-- <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.43/dist/themes/base.css" />
    <script type="module" src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.43/dist/shoelace.js"></script> -->

    <script>
      window.mUse = window.mUse || [];
      window.mUse.push('sl-dropdown');
    </script>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.64/dist/themes/light.css" />
    <script type="module" src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.64/dist/shoelace.js"></script>

    <link rel="stylesheet" href="{$docroot}styles/image/entry.css" />

    <xsl:call-template name="build-entry-scripts" />

  </xsl:template>

  <xsl:template name="build-entry-scripts" />

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

    <xsl:call-template name="build-cite-this-item-panel" />

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
    <xsl:call-template name="build-iframe-embed" />
  </xsl:template>

  <xsl:template name="build-iframe-embed">
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
        src="{ $viewer/@embed-href }"
        data-mimetype="{$viewer/@mimetype}"
        data-istruct_mt="{$viewer/@istruct_mt}">
        <xsl:if test="$viewer/@viewer-max-height">
          <xsl:attribute name="style">
            <xsl:text>height: </xsl:text>
            <xsl:value-of select="$viewer/@viewer-max-height" />
            <xsl:text>px</xsl:text>
          </xsl:attribute>
        </xsl:if>
      </iframe>
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
      <h2 class="[ subtle-heading ][ text-black ]" id="actions">Actions</h2>
      <div class="[ toolbar ]">
        <xsl:call-template name="build-download-action" />
        <xsl:call-template name="build-favorite-action" />
        <xsl:call-template name="build-copy-link-action" />
        <xsl:call-template name="build-copy-citation-action" />
        <!-- <xsl:apply-templates select="." mode="extra" /> -->
      </div>
      <xsl:apply-templates select="//qui:callout" />
    </div>
  </xsl:template>

  <xsl:template name="build-download-action">
    <xsl:choose>
      <xsl:when test="qui:download-options/qui:download-item[1]/@asset-type = 'IMAGE'">
        <xsl:call-template name="build-download-action-shoelace" />
      </xsl:when>
      <xsl:when test="qui:download-options/qui:download-item">
        <button class="button button--primary capitalize">
          <xsl:attribute name="data-href">
            <xsl:value-of select="qui:download-options/qui:download-item[1]/@href" />
          </xsl:attribute>
          <span class="material-icons text-xx-small">file_download</span>
          <xsl:text> Download </xsl:text> 
          <xsl:value-of select="qui:download-options/@label" />
        </button>
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-download-action-shoelace">
    <xsl:if test="qui:download-options/qui:download-item">
      <sl-dropdown id="dropdown-action">
        <sl-button slot="trigger" caret="caret" class="sl-button--primary">
          <span class="flex flex-center flex-gap-0_5">
            <span class="material-icons text-xx-small">file_download</span>
            <span class="capitalize">
              <xsl:text>Download</xsl:text>
              <xsl:text> </xsl:text>
              <xsl:value-of select="qui:download-options/@label" />
            </span>
          </span>
        </sl-button>
        <sl-menu>
          <xsl:for-each select="qui:download-options/qui:download-item">
            <xsl:if test="position() &gt; 1 and @slot = 'original'">
              <sl-divider></sl-divider>
            </xsl:if>
            <sl-menu-item data-href="{@href}" value="{@href}">
              <xsl:apply-templates select="." mode="menu-item" />
            </sl-menu-item>
          </xsl:for-each>
        </sl-menu>
      </sl-dropdown>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:download-item[@asset-type='IMAGE']" mode="menu-item">
    <xsl:value-of select="@width" />
    <xsl:text> x </xsl:text>
    <xsl:value-of select="@height" />
    <xsl:text> (</xsl:text>
    <xsl:if test="@slot = 'original'">
      <xsl:text>Original </xsl:text>
    </xsl:if>
    <xsl:value-of select="@file-type" />
    <xsl:if test="@file-type-is-zip-compressed = 'true'">
      <xsl:text>, ZIP archive</xsl:text>
    </xsl:if>
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="qui:download-item[@asset-type='AUDIO']" mode="menu-item">
    <xsl:text>Audo File (</xsl:text>
    <xsl:value-of select="@file-type" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="qui:download-item[@asset-type='DOC']" mode="menu-item">
    <xsl:text>Document (</xsl:text>
    <xsl:value-of select="@file-type" />
    <xsl:text>)</xsl:text>
  </xsl:template>

  <xsl:template match="qui:download-item" mode="menu-item">
    <xsl:text>File (</xsl:text>
    <xsl:value-of select="@file-type" />
    <xsl:text>)</xsl:text>
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
    <form method="GET" action="/cgi/i/image/image-idx">
      <xsl:apply-templates select="//qui:form[@rel='add']/qui:hidden-input" />
      <xsl:call-template name="button">
        <xsl:with-param name="label">Save to portfolios</xsl:with-param>
        <xsl:with-param name="classes">button--secondary</xsl:with-param>
        <xsl:with-param name="icon">add</xsl:with-param>
      </xsl:call-template>
    </form>
  </xsl:template>

  <xsl:template name="build-copy-link-action">
    <xsl:call-template name="button">
      <xsl:with-param name="label">Copy Link</xsl:with-param>
      <xsl:with-param name="classes">button--secondary</xsl:with-param>
      <xsl:with-param name="action">copy-text</xsl:with-param>
      <xsl:with-param name="icon">link</xsl:with-param>
      <xsl:with-param name="data-attributes">
        <qbat:attribute name="data-value">
          <xsl:value-of select="//qui:field[@key='bookmark']//qui:value" />
        </qbat:attribute>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-copy-citation-action">
    <!-- data_object -->
    <!-- save -->
    <!-- class -->
    <xsl:call-template name="button">
      <xsl:with-param name="label">Cite this Item</xsl:with-param>
      <xsl:with-param name="classes">button--secondary</xsl:with-param>
      <xsl:with-param name="action">go</xsl:with-param>
      <xsl:with-param name="icon">save</xsl:with-param>
      <xsl:with-param name="data-attributes">
        <qbat:attribute name="data-href">#cite-this-item</qbat:attribute>
      </xsl:with-param>
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
      <h2 class="[ subtle-heading ][ text-black ]" id="rights-permissions">Rights and Permissions</h2>
      <xsl:apply-templates mode="copy" />
    </section>
  </xsl:template>

  <xsl:template name="build-cite-this-item-panel">
    <!-- <xsl:variable name="brief-citation-text">
      <xsl:text>University of Michigan Library Digital Collections. </xsl:text>
      <xsl:value-of select="//qui:head/xhtml:meta[@property='og:site_name']/@content" />
      <xsl:text>. Accessed: </xsl:text>
      <xsl:value-of select="concat(date:month-name(), ' ', date:day-in-month(), ', ', date:year(), '.')" />
    </xsl:variable> -->
    <section>
      <h2 class="[ subtle-heading ][ text-black ]" id="cite-this-item">Cite this Item</h2>
      <p class="[ text-xxx-small mt-0 ]">
        <xsl:text>View the </xsl:text>
        <a href="{//qui:link[@rel='help']/@href}">Help Guide</a>
        <xsl:text> for more information.</xsl:text>
      </p>
      <dl class="record">

        <!-- do this here because passing the value causes weird encoding issues -->
        <div>
          <dt>Full citation</dt>
          <dd>
            <div class="text--copyable">
              <span>
                <xsl:apply-templates select="//qui:field[@slot='citation'][@rel='full']//qui:value" mode="copy-guts" />
              </span>
              <button class="button button--small" data-action="copy-text" aria-label="Copy Text">
                <span class="material-icons" aria-hidden="true">content_copy</span>
              </button>
            </div>
          </dd>
        </div>

        <!-- <xsl:call-template name="build-content-copy-metadata">
          <xsl:with-param name="term">Brief citatation</xsl:with-param>
          <xsl:with-param name="text" select="normalize-space($brief-citation-text)" />
        </xsl:call-template> -->
      </dl>
    </section>
  </xsl:template>

  <xsl:template name="build-panel-related-links">
    <xsl:variable name="block" select="//qui:block[@slot='related-links']" />
    <xsl:if test="$block/qui:field or //qui:portfolio-list or normalize-space(//qui:viewer/@manifest-id)">
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
  </xsl:if>
  </xsl:template>

  <xsl:template name="build-panel-iiif-manifest">
    <xsl:if test="normalize-space(//qui:viewer/@manifest-id)">
      <h3 id="iiif-links">IIIF</h3>
      <dl class="record">
        <xsl:call-template name="build-content-copy-metadata">
          <xsl:with-param name="term">Manifest</xsl:with-param>
          <xsl:with-param name="text" select="//qui:viewer/@manifest-id" />
          <xsl:with-param name="class">url</xsl:with-param>
        </xsl:call-template>
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

    <xsl:if test="$private-list//qui:portfolio or $public-list//qui:portfolio">
      <h3 id="portfolios" class="flex flex-center">
        Portfolios
      </h3>
      <dl class="record">
        <xsl:if test="$private-list//qui:portfolio">
          <div>
            <dt>In your portfolios</dt>
            <xsl:apply-templates select="$private-list" mode="dl" />
          </div>
        </xsl:if>
        <xsl:if test="$public-list//qui:portfolio">
          <div>
            <dt id="public-list">In public portfolios</dt>
            <xsl:apply-templates select="$public-list" mode="dl" />
          </div>
        </xsl:if>
      </dl>

    </xsl:if>
    

  </xsl:template>

  <xsl:template match="qui:portfolio-list" mode="dl">
    <xsl:for-each select="qui:portfolio">
      <dd>
        <div class="[ flex flex-flow-rw ]" style="justify-content: space-between">
          <a href="{qui:link[@rel='open']/@href}" class="flex flex-center flex-gap_0_5">
            <xsl:value-of select="qui:title" />
            <xsl:text> (</xsl:text>
            <xsl:value-of select="qui:field[@key='itemcount']//qui:value" />
            <xsl:text>)</xsl:text>
          </a>
          <xsl:if test="qui:form">
            <div class="[ toolbar toolbar--portfolio ]">
              <xsl:for-each select="qui:form">
                <form method="POST" name="bbaction">
                  <xsl:apply-templates select="qui:hidden-input" />
                  <button class="button button--secondary button--tiny" type="submit">Remove Item</button>
                </form>
              </xsl:for-each>
            </div>
          </xsl:if>
        </div>
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

  <xsl:template match="qui:section[qui:view-grid]" priority="100">
    <xsl:if test="@name != 'default'">
      <h3 id="{@slug}"><xsl:value-of select="@name" /></h3>
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="qui:section">
    <xsl:if test="@name != 'default'">
      <h3 id="{@slug}"><xsl:value-of select="@name" /></h3>
    </xsl:if>
    <xsl:if test="@name = 'default'">
      <h3 id="record_details">Record Details</h3>
    </xsl:if>
    <dl class="record">
      <xsl:apply-templates />
    </dl>
  </xsl:template>

  <xsl:template match="qui:view-grid">
    <h4>
      <xsl:value-of select="@name" />
      <xsl:text> (</xsl:text>
      <xsl:value-of select="count(qui:view)" />
      <xsl:text> items)</xsl:text>
    </h4>
    <div style="display: grid; gap: 0rem; border: 1px solid transparent; padding: 1rem; overflow: auto;">
      <xsl:apply-templates select="qui:view" />
    </div>
  </xsl:template>

  <xsl:template match="qui:view">
    <div style="grid-column-start: {@x}; grid-row-start: {@y}; background-color: rgba(229, 233, 237, 0.125);" class="view">
      <a href="{qui:link[@rel='result']/@href}" class="[ flex ][ flex-grow-1 ]">
        <figure>
          <div style="height: 100px">
            <xsl:if test="qui:link[@rel='iiif']">
              <img src="{qui:link[@rel='iiif']/@href}" style="width: auto" alt="Thumbnail for view {@x}x{@y}" />
            </xsl:if>
            <xsl:if test="not(qui:link[@rel='iiif'])">
              <div style="height: 100px;" class="results-list__blank" data-type="image"></div>
            </xsl:if>
          </div>
          <figcaption style="font-size: 0.875rem;">
            <ul class="mt-0">
            <xsl:for-each select="qui:caption//qui:value">
              <li>
                <xsl:value-of select="." />
              </li>
              <!-- <xsl:if test="position() &lt; last()">; </xsl:if> -->
            </xsl:for-each>
            </ul>
          </figcaption>
        </figure>
      </a>
    </div>
  </xsl:template>

  <xsl:template match="qui:field[@key='bookmark']" priority="101">
    <xsl:call-template name="build-content-copy-metadata">
      <xsl:with-param name="term"><xsl:value-of select="qui:label" /></xsl:with-param>
      <xsl:with-param name="key"><xsl:value-of select="@key" /></xsl:with-param>
      <xsl:with-param name="text" select="normalize-space(qui:values/qui:value)" />
      <xsl:with-param name="class">url</xsl:with-param>
    </xsl:call-template>    
  </xsl:template>

  <xsl:template name="button">
    <xsl:param name="label" />
    <xsl:param name="classes" />
    <xsl:param name="icon" />
    <xsl:param name="action" />
    <xsl:param name="href" />
    <xsl:param name="data-attributes" />
    <button class="button button--large {$classes}">
      <xsl:if test="$action">
        <xsl:attribute name="data-action"><xsl:value-of select="$action" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="$data-attributes">
        <xsl:for-each select="exsl:node-set($data-attributes)//qbat:attribute">
          <xsl:attribute name="{@name}"><xsl:value-of select="." /></xsl:attribute>
        </xsl:for-each>
      </xsl:if>
      <xsl:if test="normalize-space($icon)">
        <span class="material-icons" aria-hidden="true">
          <xsl:value-of select="$icon" />
        </span>
      </xsl:if>
      <span><xsl:value-of select="$label" /></span>
    </button>
  </xsl:template>

  <xsl:template name="get-rights-statement-href">
    <xsl:text>#rights-permissions</xsl:text>
  </xsl:template>

  <xsl:template match="qui:callout">
    <m-callout subtle="subtle" icon="check" dismissable="dismissable" variant="{@variant}" style="margin-top: 1rem; margin-bottom: 0">
      <xsl:apply-templates mode="copy" />
    </m-callout>
  </xsl:template>

</xsl:stylesheet>