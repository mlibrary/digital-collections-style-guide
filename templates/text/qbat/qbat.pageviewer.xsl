<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:qbat="http://dlxs.org/quombat/quombat" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template name="build-extra-scripts">

    <script>
      window.mUse = window.mUse || [];
      window.mUse.push('sl-dropdown');
    </script>

    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.4.0/dist/themes/light.css" />
    <script type="module" src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.4.0/dist/shoelace-autoloader.js"></script>

    <link rel="stylesheet" href="{$docroot}styles/text/pageviewer.css" />

    <xsl:call-template name="build-entry-scripts" />

  </xsl:template>

  <xsl:template name="build-entry-scripts" />

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

  <xsl:template name="build-navigation">
    <xsl:call-template name="build-breadcrumbs" />
  </xsl:template>

  <xsl:template name="build-page-heading">
    <h1 class="collection-heading--small">
      <xsl:value-of select="//qui:header[@role='main']" />
    </h1>
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
      <xsl:choose>
        <xsl:when test="true() and $viewer/@plaintext-href">
          <xsl:variable name="plaintext-href" select="//qui:viewer/@plaintext-href" />
          <div class="[ viewer viewer-grid ]">
            <iframe 
              id="viewer" 
              class="[ xx-viewer ]" 
              allow="fullscreen" 
              title="{$title}"
              src="{ $viewer/@embed-href }"
              data-mimetype="{$viewer/@mimetype}"
              data-istruct_mt="{$viewer/@istruct_mt}">
            </iframe>
            <div class="plaintext-viewer-wrap">
              <div class="[ text-block ]" id="plaintext-viewer" data-href="{$plaintext-href}" data-tmp="{$plaintext-href}">
                <xsl:value-of select="$plaintext-href" />
              </div>  
            </div>
          </div>
        </xsl:when>
        <xsl:otherwise>
          <iframe 
            id="viewer" 
            class="[ viewer ]" 
            allow="fullscreen" 
            title="{$title}"
            src="{ $viewer/@embed-href }"
            data-mimetype="{$viewer/@mimetype}"
            data-istruct_mt="{$viewer/@istruct_mt}">
          </iframe>  
        </xsl:otherwise>
      </xsl:choose>      
    </xsl:if>
    <xsl:if test="//qui:callout[@slot='viewer']">
      <xsl:apply-templates select="//qui:callout[@slot='viewer']" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-main-stacked">
    <xsl:apply-templates select="qui:block[@slot='actions']" />

    <section class="[ records ]">
      <h2 class="[ subtle-heading ][ text-black ]" id="details">About this Item</h2>
      <xsl:apply-templates select="qui:block[@slot='record']/qui:section" />
      <!-- <xsl:apply-templates select="qui:block[@slot='technical-metadata']/qui:section" /> -->

      <xsl:if test="false() and //qui:viewer/@plaintext-href">
        <xsl:variable name="plaintext-href" select="//qui:viewer/@plaintext-href" />
        <h2 class="[ subtle-heading ][ text-black ]" id="plaintext">Text</h2>
        <div class="[ text-block ]" id="plaintext-viewer" data-href="{$plaintext-href}" data-tmp="{$plaintext-href}">
          <xsl:value-of select="$plaintext-href" />
        </div>
      </xsl:if>

    </section>

    <xsl:apply-templates select="qui:block[@slot='rights-statement']" />

    <xsl:call-template name="build-panel-related-links" />

    <xsl:call-template name="build-cite-this-item-panel" />
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

  <xsl:template match="qui:block[@slot='rights-statement']">
    <section>
      <h2 class="[ subtle-heading ][ text-black ]" id="rights-permissions">Rights and Permissions</h2>
      <xsl:apply-templates mode="copy" />
    </section>
  </xsl:template>

  <xsl:template name="build-cite-this-item-panel">
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
      </dl>
    </section>
  </xsl:template>

  <xsl:template match="qui:block[@slot='actions']">
    <div class="[ actions ][ actions--toolbar-wrap ]">
      <h2 class="[ subtle-heading ][ text-black ]" id="actions">Actions</h2>
      <div class="[ toolbar ]">
        <xsl:call-template name="build-download-action" />
        <xsl:call-template name="build-favorite-action" />
        <xsl:call-template name="build-copy-link-action" />
        <xsl:call-template name="build-copy-citation-action" />
        <xsl:apply-templates select="." mode="extra" />
      </div>
      <xsl:apply-templates select="//qui:callout[@slot='actions']" />
    </div>
  </xsl:template>

  <xsl:template match="qui:block[@slot='actions']" mode="extra">
    <xsl:apply-templates select="*[@slot='extension']" mode="action" />
  </xsl:template>  

  <xsl:template name="build-favorite-action">
    <xsl:variable name="form" select="//qui:form[@rel='add']" />
    <form method="GET" action="{$form/@href}">
      <xsl:call-template name="button">
        <xsl:with-param name="label">Save to bookbag</xsl:with-param>
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
          <xsl:value-of select="//CurrentUrl" />
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

  <xsl:template name="build-download-action">
    <xsl:choose>
      <xsl:when test="true() or qui:download-options/qui:download-item[1]/@asset-type = 'IMAGE'">
        <xsl:call-template name="build-download-action-shoelace" />
      </xsl:when>
      <xsl:when test="qui:download-options/qui:download-item">
        <button class="button button--primary capitalize">
          <xsl:attribute name="data-href">
            <xsl:value-of select="qui:download-options/qui:download-item[1]/@href" />
          </xsl:attribute>
          <xsl:attribute name="data-attachment">download</xsl:attribute>
          <span class="material-icons text-xx-small">
            file_download</span>
          <xsl:text> Download </xsl:text> 
          <xsl:value-of select="qui:download-options/@label" />
        </button>
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-download-action-shoelace">
    <xsl:if test="qui:download-options/qui:download-item">
      <sl-dropdown id="dropdown-action" placement="bottom">
        <sl-button slot="trigger" caret="caret" class="sl-button--primary">
          <span class="flex flex-center flex-gap-0_5 text-xx-small">
            <span class="material-icons text-xx-small">file_download</span>
            <span class="capitalize">
              <xsl:text>Download</xsl:text>
              <xsl:text> </xsl:text>
              <xsl:value-of select="qui:download-options/@label" />
            </span>
          </span>
        </sl-button>
        <sl-menu>
          <xsl:apply-templates select="qui:download-options/*" />
        </sl-menu>
      </sl-dropdown>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:download-options/qui:download-item">
    <sl-menu-item data-href="{@href}" value="{@href}">
      <xsl:choose>
        <xsl:when test="@file-type = 'PDF'">
          <sl-icon name="file-pdf" slot="prefix"></sl-icon>
        </xsl:when>
        <xsl:when test="@type = 'IMAGE'">
          <sl-icon name="file-image" slot="prefix"></sl-icon>
        </xsl:when>
        <xsl:when test="@type = 'TEXT'">
          <sl-icon name="file-text" slot="prefix"></sl-icon>          
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="." mode="menu-item" />
    </sl-menu-item>
  </xsl:template>

  <xsl:template match="qui:download-options/qui:hr">
    <sl-divider></sl-divider>
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
    <xsl:variable name="icon">
      <xsl:choose>
        <xsl:when test="@icon"><xsl:value-of select="@icon" /></xsl:when>
        <xsl:otherwise>check</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="dismissable">
      <xsl:choose>
        <xsl:when test="@dismissable">
          <xsl:value-of select="@dismissable" />
        </xsl:when>
        <xsl:otherwise>dismissable</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <m-callout subtle="subtle" icon="{$icon}" dismissable="{$dismissable}" variant="{@variant}" style="margin-top: 1rem; margin-bottom: 0">
      <xsl:apply-templates mode="copy" />
    </m-callout>
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

  <xsl:template match="qui:field[@key='bookmark']" priority="101">
    <xsl:call-template name="build-content-copy-metadata">
      <xsl:with-param name="term"><xsl:value-of select="qui:label" /></xsl:with-param>
      <xsl:with-param name="key"><xsl:value-of select="@key" /></xsl:with-param>
      <xsl:with-param name="text" select="normalize-space(qui:values/qui:value)" />
      <xsl:with-param name="class">url</xsl:with-param>
    </xsl:call-template>    
  </xsl:template>
</xsl:stylesheet>