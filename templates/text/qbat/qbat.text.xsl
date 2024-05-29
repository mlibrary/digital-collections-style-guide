<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:qbat="http://dlxs.org/quombat/quombat" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common" xmlns:tei="http://www.tei-c.org/ns/1.0" extension-element-prefixes="exsl">

  <xsl:variable name="has-annotations">
    <xsl:choose>
      <xsl:when test="//qui:block[@slot='metadata']/qui:metadata/@item-encoding-level = 4">
        <xsl:variable name="content" select="//qui:block[@slot='content']" />
        <xsl:choose>
          <xsl:when test="
          $content//tei:CHOICE[not(tei:ORIG)] or 
          $content//tei:XXADD or $content//tei:XXDEL or 
          $content//tei:ABBR">
            <xsl:value-of select="true()" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="false()" />
          </xsl:otherwise>          
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="false()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="item-encoding-level" select="//qui:block[@slot='metadata']/qui:metadata/@item-encoding-level" />

  <xsl:template name="build-extra-scripts">

    <script>
      window.mUse = window.mUse || [];
    </script>

    <xsl:call-template name="build-entry-scripts" />

  </xsl:template>

  <xsl:template name="build-extra-html-attributes">
    <xsl:attribute name="data-annotations-state">off</xsl:attribute>
  </xsl:template>

  <xsl:template name="build-entry-scripts" />

  <xsl:template name="build-extra-main-class">
    <!-- <xsl:text>[ mt-0 ]</xsl:text> -->
  </xsl:template>

  <xsl:template name="build-cqfill-script" />  

  <xsl:template match="qui:main">

    <xsl:call-template name="build-navigation" />

    <xsl:call-template name="build-page-heading" />

    <div class="[ flex flex-flow-rw ][ aside--wrap ]">

      <div class="[ aside ]">
        <nav class="[ page-index ]">
          <!-- this needs to be smarter -->
          <div class="annotations-panel" style="display: none;">
            <h2 id="annotations-label" class="[ subtle-heading ][ text-black js-toc-ignore visually-hidden ]">Annotations Tools</h2>
            <div class="annotations-tools flex flex-flow-column gap-0_5 mb-1">
              <button id="action-toggle-annotations" class="button button--ghost m-0">
                <span class="material-icons" aria-hidden="true">visibility</span>
                <span>Show annotations</span>
              </button>
            </div>
          </div>
          <xsl:if test="count($highlights) &gt; 0">
            <h2 id="search-highlight-label" class="[ subtle-heading ][ text-black js-toc-ignore ]">Search Highlight Tools</h2>
            <div class="highlight-tools flex flex-flow-column gap-0_5 mb-1">
              <a href="#hl{$highlight-seq-first}" class="button button--ghost m-0">First matched term</a>
              <button id="action-toggle-highlight" class="button button--ghost m-0">
                <span class="material-icons" aria-hidden="true">visibility</span>
                <span>Turn highlights off</span>
              </button>
            </div>  
          </xsl:if>
          <!-- <h2 id="page-index-label" class="[ subtle-heading ][ text-black js-toc-ignore ]">Page Index</h2>
          <div class="toc js-toc"></div>
          <select id="action-page-index"></select> -->
        </nav>
      </div>
      
      <div class="[ main-panel ]">

        <xsl:call-template name="build-item-header" />

        <!-- <div style="width: 99dvw;">
          <xsl:apply-templates select="//qui:block[@slot='content']" />
        </div> -->

        <!-- <xsl:apply-templates select="//qui:block[@slot='content']" />
        <xsl:apply-templates select="//qui:block[@slot='notes']" /> -->

        <xsl:apply-templates select="//qui:block[@slot='metadata']/qui:metadata" mode="build-coins" />

      </div>
    </div>

    <xsl:call-template name="build-not-main" />

    <xsl:apply-templates select="//qui:nav[@role='sections']" mode="pagination-footer-link" />

  </xsl:template>

  <xsl:template name="build-not-main">
    <!-- <xsl:message>AHOY qbat/content/start</xsl:message> -->
    <xsl:apply-templates select="//qui:block[@slot='content']" mode="not-main" />
    <!-- <xsl:message>AHOY qbat/content/fin</xsl:message> -->
    <xsl:apply-templates select="//qui:block[@slot='notes']" />
  </xsl:template>  

  <xsl:template name="build-navigation">
    <xsl:call-template name="build-breadcrumbs" />
  </xsl:template>

  <xsl:template name="build-page-heading">
    <h1 class="collection-heading--small">
      <!-- <xsl:value-of select="//qui:header[@role='main']" /> -->
      <xsl:choose>
        <xsl:when test="//qui:header[@role='main']">
          <xsl:apply-templates select="//qui:header[@role='main']" mode="build-title" />
        </xsl:when>
        <xsl:when test="//qui:block[@slot='content']/DLPSWRAP">

        </xsl:when>
      </xsl:choose>
    </h1>
  </xsl:template>

  <xsl:template name="build-item-header">
    <xsl:apply-templates select="//qui:block[@slot='metadata']/qui:metadata" />
  </xsl:template>

  <xsl:template match="qui:block[@slot='content']" mode="in-main">
    <h2 class="subtle-heading" id="pages">Pages</h2>
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="qui:block[@slot='content']" mode="not-main">
    <section class="records">
      <h2 class="subtle-heading" id="pages">Pages</h2>
      <!-- <xsl:apply-templates select="qui:section/qui:div"></xsl:apply-templates> -->
      <xsl:choose>
        <xsl:when test=".//tei:DLPSWRAP">
          <xsl:apply-templates select=".//tei:DLPSWRAP" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>
    </section>
  </xsl:template>

  <xsl:template match="qui:block[@slot='notes'][tei:NOTE]">
    <section class="[ records ]">
      <h2 id="notes" class="subtle-heading">Notes</h2>
      <ul class="list-unstyled">
        <xsl:for-each select="tei:NOTE">
          <li class="mb-2 p-1 border-bottom" data-id="{node()/@ID}">
            <xsl:apply-templates select="*" mode="note" />
          </li>
        </xsl:for-each>
      </ul>
    </section>
  </xsl:template>

  <xsl:template match="qui:div[@class='page']">
    <div class="fullview-page">
      <h3 class="[ xx-subtle-heading ]" id="{@id}">
        <a href="{qui:nav/qui:link/@href}">
          <xsl:value-of select="qui:nav/qui:link" />
        </a>
      </h3>
      <xsl:apply-templates mode="copy" />
    </div>
  </xsl:template>

  <xsl:template match="qui:div/qui:nav" mode="copy" />

  <xsl:template match="qui:section|qui:metadata" priority="101">
    <h2 class="subtle-heading">About this Item</h2>
    <dl class="record" data-message="wtf">
      <xsl:apply-templates />
    </dl>
  </xsl:template>

  <xsl:template match="qui:nav[@role='sections']" mode="pagination-footer-link">
    <xsl:if test="qui:link[@rel='next-section' or @rel='previous-section'][not(@disabled)]">
      <nav aria-label="Section navigation" class="[ pagination__row ][ flex flex-align-center justify-end sticky-bottom ]" style="padding-bottom: 0">
        <xsl:apply-templates select="." mode="pagination-link" />
      </nav>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:nav[@role='sections']" mode="pagination-link">
    <xsl:if test="qui:link[@rel='next-section' or @rel='previous-section'][not(@disabled)]">
      <p class="[ pagination ][ nowrap ml-2 ]">
        <xsl:if test="qui:link[@rel='previous-section']">
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
          <xsl:apply-templates select="qui:link[@rel='previous-section']" />
        </xsl:if>
        <span class="text-muted" aria-hidden="true" style="color: var(--color-neutral-200)">
          <xsl:text>◆</xsl:text>
        </span>
        <!-- <span>
          <xsl:value-of select="@current" />
          <xsl:text> of </xsl:text>
          <xsl:value-of select="@total" />
        </span> -->
        <xsl:if test="qui:link[@rel='next-section']">
          <xsl:apply-templates select="qui:link[@rel='next-section']" />
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
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-breadcrumbs-extra-nav">
    <xsl:apply-templates select="//qui:form[@id='item-search']" />
    <xsl:apply-templates select="//qui:nav[@role='sections']" mode="pagination-link" />
  </xsl:template>
  
  <xsl:template match="tei:HEADER" priority="101" />

  <xsl:template match="qui:field[@key='bookmark']" priority="101">
    <xsl:call-template name="build-content-copy-metadata">
      <xsl:with-param name="term"><xsl:value-of select="qui:label" /></xsl:with-param>
      <xsl:with-param name="key"><xsl:value-of select="@key" /></xsl:with-param>
      <xsl:with-param name="text" select="normalize-space(qui:values/qui:value)" />
      <xsl:with-param name="class">url</xsl:with-param>
    </xsl:call-template>    
  </xsl:template>

  <xsl:template match="text()" mode="build-title">
    <xsl:copy></xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>