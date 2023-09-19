<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template name="build-extra-scripts">
    <link rel="stylesheet" href="{$docroot}styles/text/pageviewer.css" />
  </xsl:template>

  <xsl:template match="qui:main">

    <div class="[ mb-2 ]">
      <xsl:call-template name="build-navigation" />
      <xsl:call-template name="build-collection-heading" />
    </div>

    <div class="[ flex flex-flow-rw ][ flex-gap-1 ]">
      <xsl:variable name="has-side-actions">
        <xsl:value-of select="count(//qui:nav[@role='contents']/qui:link) != 0" />
      </xsl:variable>
      <xsl:if test="false()">
      <div class="side-panel">
        <xsl:if test="$has-side-actions = 'true'">
          <button data-action="toggle-side-panel" class="flex button button--ghost" aria-expanded="false">
            <span class="flex flex-center flex-gap-0_5 flex-grow-1">
              <span class="material-icons" aria-hidden="true">filter_alt</span>
              <span>Filters</span>
            </span>
          </button>
          <h2 class="visually-hidden">Options</h2>
          <xsl:call-template name="build-filters-panel" />
        </xsl:if>
      </div>
      </xsl:if>
      <div class="main-panel">
        <xsl:call-template name="build-item-header" />
        <xsl:call-template name="build-actions-toolbar" />
        <xsl:call-template name="build-contents-list" />
        <xsl:call-template name="build-contents-pagination" />
      </div>
    </div>

  </xsl:template>  

  <xsl:template name="build-collection-heading-xxx">
    <xsl:variable name="header" select="//qui:header[@role='main']" />
    <div class="flex flex-space-between flex-align-center">
      <h1 class="collection-heading mb-0">
        <xsl:if test="normalize-space($header/@data-badge)">
          <span class="material-icons" aria-hidden="true">
            <xsl:value-of select="$header/@data-badge" />
          </span>
        </xsl:if>
        <xsl:call-template name="build-collection-header-string">
          <xsl:with-param name="header" select="normalize-space($header)" />
        </xsl:call-template>
      </h1>
      <form>
        <div class="flex flex-align-center gap-0_5">
          <label for="q1" style="text-wrap: nowrap">Search in this text: </label>
          <input type="text" id="q1" name="q1" />
          <button class="button button--small">Search</button>  
        </div>
      </form>
    </div>
  </xsl:template>

  <xsl:template name="build-item-header">
    <xsl:apply-templates select="//qui:block[@slot='metadata']/qui:section" />
  </xsl:template>

  <xsl:template name="build-filters-panel">
    <div class="[ side-panel__box ]">
      <xsl:apply-templates select="//qui:link[@role='view-text']" mode="button" />
    </div>
  </xsl:template>

  <xsl:template name="build-contents-list">
    <h2 class="subtle-heading">Contents</h2>
    <xsl:apply-templates select="//qui:block[@slot='contents']/qui:ul" />
  </xsl:template>

  <xsl:template name="build-contents-pagination"></xsl:template>

  <xsl:template name="build-actions-toolbar">
    <div class="[ actions ][ actions--toolbar-wrap ]">
      <h2 class="[ subtle-heading ][ text-black ]" id="actions">Actions</h2>
      <div class="[ toolbar ]">
        <xsl:call-template name="build-fullview-action" />
        <xsl:call-template name="build-favorite-action" />
      </div>
    </div>
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

  <xsl:template name="build-fullview-action">
    <xsl:apply-templates select="//qui:link[@role='view-text']" mode="button">
      <xsl:with-param name="icon">article</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="build-navigation">
    <xsl:call-template name="build-breadcrumbs" />
  </xsl:template>

  <xsl:template match="qui:header" mode="build-title">
    <xsl:apply-templates mode="build-title" />
  </xsl:template>

  <xsl:template match="qui:link" mode="button">
    <xsl:param name="icon" />
    <a href="{@href}" class="button button--secondary text--small">
      <xsl:if test="$icon">
        <span class="material-icons" aria-hidden="true">
          <xsl:value-of select="$icon" />
        </span>
      </xsl:if>
      <xsl:value-of select="." />
    </a>
  </xsl:template>

  <xsl:template match="qui:section" priority="101">
    <!-- <xsl:if test="@name != 'default'">
      <h3 id="{@slug}"><xsl:value-of select="@name" /></h3>
    </xsl:if>
    <xsl:if test="@name = 'default'">
      <h3 id="record_details">Record Details</h3>
    </xsl:if> -->
    <dl class="record" data-message="wtf">
      <xsl:apply-templates />
    </dl>
  </xsl:template>

  <xsl:template name="build-breadcrumbs-extra-nav">
    <xsl:apply-templates select="//qui:form[@id='item-search']" />
  </xsl:template>

  <xsl:template match="text()" mode="build-title">
    <xsl:copy></xsl:copy>
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
</xsl:stylesheet>