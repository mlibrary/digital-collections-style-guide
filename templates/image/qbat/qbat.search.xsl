<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <link rel="stylesheet" href="{$docroot}styles/image/advanced_search.css" />
  </xsl:template>
    
  <xsl:template match="qui:main">

    <div class="[ mb-2 ]">
      <xsl:call-template name="build-breadcrumbs" />
      <xsl:call-template name="build-collection-heading" />
    </div>

    <div class="advanced-search--form">
      <!-- <h2 class="subtle-heading">Fielded Search Options</h2>
      <div class="message-callout">
        <p>
          <xsl:apply-templates select="//qui:callout" mode="copy-guts" />
        </p>
      </div> -->
      <xsl:call-template name="build-search-form" />
    </div>

    <!-- <div class="[ flex flex-flow-rw ]">
      <div class="main-panel" style="width: 100%">
        <xsl:call-template name="build-breadcrumbs" />
        <xsl:call-template name="build-search-form" />
      </div>
    </div> -->

  </xsl:template>

  <xsl:template name="build-search-form">
    <form id="collection-search" action="/cgi/i/image/image-idx" method="GET" autocomplete="off">
      <h2 class="subtle-heading">Fielded Search Options</h2>
      <div class="message-callout info">
        <p>
          <xsl:apply-templates select="//qui:callout[@slot='clause']" mode="copy-guts" />
        </p>
      </div>
      <div class="advanced-search--containers">
        <div class="field-groups">
          <xsl:apply-templates select="$search-form/qui:fieldset[@slot='clause']" />
        </div>
      </div>
      
      <xsl:apply-templates select="$search-form/qui:fieldset[@slot='limits']" />

      <xsl:apply-templates select="$search-form/qui:hidden-input" />

      <input type="hidden" name="view" value="reslist" />
      <input type="hidden" name="type" value="boolean" />

      <xsl:call-template name="build-form-actions" />

    </form>
  </xsl:template>

  <xsl:template name="build-form-actions">
    <button class="[ button button--cta ]">
      <svg xmlns="http://www.w3.org/2000/svg" width="16px" height="16px" viewBox="0 0 24 24" aria-hidden="true" fill="inherit" focusable="false" role="img">
        <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"></path>
      </svg>
      <span>Advanced Search</span>
    </button>
    <button class="[ button button--secondary ]" data-action="reset-form">
      <span>Clear all</span>
    </button>
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='clause']">
    <xsl:apply-templates select="qui:select[@slot='op']" />
    <fieldset class="[ no-border ][ fieldset--grid ]">
      <legend class="visually-hidden">Search Terms</legend>
      <div class="[ fieldset--clause--region ]">
        <xsl:apply-templates select="qui:select[@slot='region']" />
      </div>
      <div class="[ fieldset--clause--select ]">
        <xsl:apply-templates select="qui:select[@slot='select']" />
      </div>
      <div class="[ fieldset--clause--query ]">
        <xsl:apply-templates select="node()[@slot='query']" />
      </div>
      <xsl:if test="position() &gt; 1">
        <button class="[ button button--secondary ]" data-action="reset-clause">Clear</button>
      </xsl:if>
    </fieldset>
  </xsl:template>

  <xsl:template match="qui:select[@slot='region']">
    <label for="{@name}-{position()}" class="visually-hidden">Select a field:</label>
    <select class="[ dropdown--neutral ]" name="{@name}" id="{@name}-{position()}" autocomplete="off">
      <xsl:for-each select="qui:option">
        <option value="{@value}">
          <xsl:if test="@selected = 'true'">
            <xsl:attribute name="selected">true</xsl:attribute>
          </xsl:if>
          <xsl:value-of select="." />
        </option>
      </xsl:for-each>
    </select>
  </xsl:template>

  <xsl:template match="qui:select[@slot='select']">
    <label for="{@name}-{position()}" class="visually-hidden" data-active="{@data-active}">Select a comparison operator:</label>
    <select class="[ dropdown--neutral ]" name="{@name}" id="{@name}-{position()}" autocomplete="off">
      <xsl:apply-templates select="@data-field" mode="copy" />
      <xsl:apply-templates select="@data-active" mode="copy" />
      <xsl:if test="@data-active = 'false'">
        <xsl:attribute name="disabled">disabled</xsl:attribute>
      </xsl:if>
      <xsl:for-each select="qui:option">
        <option value="{@value}">
          <xsl:if test="@selected = 'true'">
            <xsl:attribute name="selected">true</xsl:attribute>
          </xsl:if>
          <xsl:value-of select="." />
        </option>
      </xsl:for-each>
    </select>
  </xsl:template>

  <xsl:template match="qui:select[@slot='query']">
    <label for="{@name}-{position()}" class="visually-hidden" data-active="{@data-active}">Select a value:</label>
    <select class="[ dropdown--neutral ]" name="{@name}" id="{@name}-{position()}" autocomplete="off" data-slot="query">
      <xsl:apply-templates select="@data-field" mode="copy" />
      <xsl:apply-templates select="@data-active" mode="copy" />
      <xsl:if test="@data-active = 'false'">
        <xsl:attribute name="disabled">disabled</xsl:attribute>
      </xsl:if>
      <xsl:for-each select="qui:option">
        <option value="{@value}">
          <xsl:if test="@selected = 'true'">
            <xsl:attribute name="selected">true</xsl:attribute>
          </xsl:if>
          <xsl:value-of select="." />
        </option>
      </xsl:for-each>
    </select>
  </xsl:template>

  <xsl:template match="qui:select[@slot='op']">
    <xsl:variable name="name" select="@name" />
    <xsl:variable name="position" select="position()" />
    <fieldset class="[ center-grid ][ no-border ][ fieldset--clause--operator ]">
      <legend class="visually-hidden">Radio operators</legend>
      <xsl:for-each select="qui:option">
        <label class="radio-buttons" for="{$name}-{$position}-{@value}">
          <input type="radio" id="{$name}-{$position}-{@value}" name="{$name}-{$position}" value="{@value}">
            <xsl:if test="@selected = 'true'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input>
          <span><xsl:value-of select="." /></span>
        </label>
      </xsl:for-each>
    </fieldset>
  </xsl:template>

  <xsl:template match="qui:select[@slot='op']" mode="select">
    <select class="select" name="{@name}" id="{@name}-{position()}" autocomplete="off">
      <xsl:for-each select="qui:option">
        <option value="{@value}">
          <xsl:if test="@selected = 'true'">
            <xsl:attribute name="selected">true</xsl:attribute>
          </xsl:if>
          <xsl:value-of select="." />
        </option>
      </xsl:for-each>
    </select>
  </xsl:template>

  <xsl:template match="qui:input[@slot='query']">
    <label for="{@name}" class="visually-hidden">Search</label>
    <input name="{@name}" id="{@name}" value="{@value}" type="search" autocomplete="off" placeholder="Enter search terms" data-slot="query" data-active="{@data-active}" />
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='limits']">
    <xsl:if test=".//qui:control">
      <h3>Additional Search Options</h3>
      <div class="advanced-grid--columns">
        <xsl:apply-templates select="qui:fieldset[@slot='range']" />
        <div class="advanced-search--containers">
          <div>
            <p class="bold">Limit Search to</p>
            <xsl:apply-templates select="qui:control">
              <xsl:with-param name="class">p-half</xsl:with-param>
            </xsl:apply-templates>
          </div>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='range']">
    <xsl:variable name="range-type" select="@data-range-type" />
    <div class="advanced-search--containers">
      <fieldset class="[ no-border range-filter ][ mt-1 ]" data-select="{@data-select}">
        <legend class="[ bold mb-1 ]"><xsl:value-of select="qui:legend" /></legend>
        <xsl:apply-templates select="qui:hidden-input" />
        <xsl:apply-templates select="qui:control" mode="range">
          <xsl:with-param name="range-type" select="$range-type" />
        </xsl:apply-templates>
      </fieldset>
    </div>
  </xsl:template>

  <xsl:template match="qui:control" mode="range">
    <xsl:param name="range-type" />
    <xsl:variable name="name" select="qui:input/@name" />
    
    <div class="[ flex flex-center ][ align-center gap-0_5 mb-1 ]">
      <div class="[ flex flex-center gap-0_25 ]">
        <input type="radio" name="range-type-{$name}" id="before-{$name}" value="ic_before">
          <xsl:if test="$range-type = 'ic_before'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input>
        <label for="before-{$name}">Before</label>
      </div>
      <div class="[ flex flex-center gap-0_25 ]" data-active="{$range-type}">
        <input type="radio" name="range-type-{$name}" id="after-{$name}" value="ic_after">
          <xsl:if test="$range-type = 'ic_after'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input>
        <label for="after-{$name}">After</label>
      </div>
      <div class="[ flex flex-center gap-0_25 ]">
        <input type="radio" name="range-type-{$name}" id="between-{$name}" value="ic_range">
          <xsl:if test="$range-type = 'ic_range'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input>
        <label for="between-{$name}">Between</label>
      </div>
    </div>
    <div class="[ flex ][ flex-center gap-0_5 ]" data-range-type="{$range-type}">   
      <xsl:for-each select="qui:input">
        <input type="text" aria-label="{@aria-label}" id="{@id}" name="{@name}" value="{@value}" placeholder="{@aria-label}" data-slot="ic_range {@slot}" />
        <xsl:if test="position() &lt; last()">
          <span data-slot="ic_range"> to </span>
        </xsl:if>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="qui:control">
    <xsl:param name="class" />
    <div>
      <xsl:if test="normalize-space($class)">
        <xsl:attribute name="class">
          <xsl:value-of select="$class" />
        </xsl:attribute>
      </xsl:if>
      <label>
        <xsl:apply-templates select="qui:input[@type='checkbox']" />
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="qui:label" mode="copy-guts" />
      </label>
    </div>
  </xsl:template>

  <xsl:template match="qui:input[@type='checkbox']">
    <input type="checkbox" name="{@name}" value="{@value}" autocomplete="off">
      <xsl:apply-templates select="@checked" mode="copy" />
    </input>
  </xsl:template>

</xsl:stylesheet>