<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:qbat="http://dlxs.org/quombat/quombat" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common" xmlns:tei="http://www.tei-c.org/ns/1.0" extension-element-prefixes="exsl">

  <xsl:template name="build-extra-scripts">

    <script>
      window.mUse = window.mUse || [];
    </script>

    <link rel="stylesheet" href="{$docroot}styles/text/pageviewer.css" />
    <link rel="stylesheet" href="{$docroot}styles/text/text.css" />

    <xsl:call-template name="build-entry-scripts" />

  </xsl:template>

  <xsl:template name="build-entry-scripts" />

  <xsl:template name="build-extra-main-class">
    <!-- <xsl:text>[ mt-0 ]</xsl:text> -->
  </xsl:template>

  <xsl:template match="qui:main">

    <xsl:call-template name="build-navigation" />

    <xsl:call-template name="build-page-heading" />

    <div class="[ flex flex-flow-rw ][ aside--wrap ]">

      <div class="[ aside ]">
        <nav class="[ page-index ]" xx-aria-labelledby="page-index-label">
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
          <h2 id="page-index-label" class="[ subtle-heading ][ text-black js-toc-ignore ]">Page Index</h2>
          <div class="toc js-toc"></div>
          <select id="action-page-index"></select>
        </nav>
      </div>
      
      <div class="[ main-panel ]">

        <xsl:call-template name="build-item-header" />

        <xsl:apply-templates select="//qui:block[@slot='content']" />

      </div>
    </div>

  </xsl:template>

  <xsl:template name="build-navigation">
    <xsl:call-template name="build-breadcrumbs" />
  </xsl:template>

  <xsl:template name="build-page-heading">
    <h1 class="collection-heading--small">
      <!-- <xsl:value-of select="//qui:header[@role='main']" /> -->
      <xsl:apply-templates select="//qui:header[@role='main']" mode="build-title" />
    </h1>
  </xsl:template>

  <xsl:template name="build-item-header">
    <xsl:apply-templates select="//qui:block[@slot='metadata']/qui:section" />
  </xsl:template>

  <xsl:template match="qui:block[@slot='content']">
    <section class="[ records ]">
      <h2 class="subtle-heading">Pages</h2>
      <!-- <xsl:apply-templates select="qui:section/qui:div"></xsl:apply-templates> -->
      <xsl:apply-templates />
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

  <xsl:template match="qui:section" priority="101">
    <!-- <xsl:if test="@name != 'default'">
      <h3 id="{@slug}"><xsl:value-of select="@name" /></h3>
    </xsl:if>
    <xsl:if test="@name = 'default'">
      <h3 id="record_details">Record Details</h3>
    </xsl:if> -->
    <h2 class="subtle-heading">About this Item</h2>
    <dl class="record" data-message="wtf">
      <xsl:apply-templates />
    </dl>
  </xsl:template>

  <xsl:template name="build-breadcrumbs-extra-nav">
    <xsl:apply-templates select="//qui:form[@id='item-search']" />
  </xsl:template>
  
  <xsl:template match="tei:HEADER" priority="101" />

  <xsl:template match="text()" mode="build-title">
    <xsl:copy></xsl:copy>
  </xsl:template>
  
</xsl:stylesheet>