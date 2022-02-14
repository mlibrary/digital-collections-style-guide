<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <link rel="stylesheet" href="{$docroot}styles/image/advanced_search.css" />
    <script src="{$docroot}js/image/base.js"></script>

    <script src="https://unpkg.com/blingblingjs@2.1.1/dist/index.js"></script>
    <script src="{$docroot}js/image/advanced_search.js"></script>
  </xsl:template>
    
  <xsl:template match="qui:main">

    <xsl:call-template name="build-collection-heading" />

    <div class="[ flex flex-flow-rw ]">
      <xsl:call-template name="build-breadcrumbs" />
    </div>

    <div class="advanced-search--form">
      <h2>Search</h2>
      <div class="message-callout">
        <p>
          <xsl:apply-templates select="//qui:callout" mode="copy-guts" />
        </p>
      </div>
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
      <span>Advanced Search</span>
      <svg xmlns="http://www.w3.org/2000/svg" width="16px" height="16px" viewBox="0 0 24 24" aria-hidden="true" fill="inherit" focusable="false" role="img">
        <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"></path>
      </svg>
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
        <xsl:apply-templates select="qui:input[@slot='query']" />
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
    <input name="{@name}" id="{@name}" value="{@value}" type="search" autocomplete="off" placeholder="Enter search terms" />
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='limits']">
    <h3>Additional Search Options</h3>
    <div class="advanced-grid--columns">
      <div class="advanced-search--containers">
        <div>
          <p class="bold">Limit Search to</p>
          <xsl:apply-templates select="qui:control" />
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="qui:control">
    <div>
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