<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <link rel="stylesheet" href="/samples/styles/advanced_search.css" />
    <script src="/samples/js/base.js"></script>
    <script src="https://unpkg.com/blingblingjs@2.1.1/dist/index.js"></script>
    <script src="/samples/js/advanced_search.js"></script>
  </xsl:template>
    
  <xsl:template match="qui:main">

    <xsl:call-template name="build-collection-heading" />

    <div class="[ flex flex-flow-rw ]">
      <div class="main-panel" style="width: 100%">
        <xsl:call-template name="build-breadcrumbs" />
        <xsl:call-template name="build-search-form" />
      </div>
    </div>

  </xsl:template>

  <xsl:template name="build-search-form">
    <form id="collection-search" action="/cgi/i/image/image-idx" method="GET" autocomplete="off">
      <xsl:apply-templates select="$search-form/qui:fieldset[@slot='clause']" />
      <xsl:apply-templates select="$search-form/qui:fieldset[@slot='limits']" />
      <xsl:apply-templates select="$search-form/qui:hidden-input" />

      <input type="hidden" name="view" value="reslist" />
      <input type="hidden" name="type" value="boolean" />

      <p>
        <button type="submit" class="[ button button--primary ]">Advanced Search</button>
        <button class="[ button button--secondary ]" data-action="reset-form">Clear All</button>
      </p>

    </form>
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='clause']">
    <div class="[ fieldset--clause ][ flex flex-flow-rw ][ gap-0_5 ]">
      <div class="[ fieldset--clause--op ]">
        <xsl:apply-templates select="qui:select[@slot='op']" />
      </div>
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
    </div>
  </xsl:template>

  <xsl:template match="qui:select[@slot='region']">
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

  <xsl:template match="qui:select[@slot='select']">
    <select class="select" name="{@name}" id="{@name}-{position()}" autocomplete="off">
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
    <input name="{@name}" value="{@value}" type="text" autocomplete="off" />
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='limits']">
    <xsl:apply-templates select="qui:control" />
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