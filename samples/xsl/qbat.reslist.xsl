<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template match="qui:main">

    <xsl:call-template name="build-collection-heading" />

    <div class="flex">
      <div class="side-panel"></div>
      <div class="main-panel">
        <xsl:call-template name="build-breadcrumbs" />
        <xsl:call-template name="build-search-form" />
        <xsl:call-template name="build-search-summary" />
        <xsl:call-template name="build-results-list" />
      </div>
    </div>

  </xsl:template>

  <xsl:template name="build-breadcrumbs">
    <section class="[ breadcrumb ]">
      <nav aria-label="Breadcrumb">
        <ol>
          <xsl:for-each select="qui:nav[@role='breadcrumb']/qui:link">
            <li>
              <xsl:choose>
                <xsl:when test="./@href=''">
                  <span>
                    <xsl:if test="position() = last()">
                      <xsl:attribute name="aria-current">page</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="." />
                  </span>
                </xsl:when>
                <xsl:when test="./@href">
                  <a href="{@href}">
                    <xsl:if test="position() = last()">
                      <xsl:attribute name="aria-current">page</xsl:attribute>
                    </xsl:if>
                    <xsl:value-of select="." />
                  </a>
                </xsl:when>
                <xsl:otherwise></xsl:otherwise>
              </xsl:choose>
              <xsl:if test="position() &lt; last()">
                <svg height="18px" viewBox="0 0 20 20" width="12px" fill="#06080a" aria-hidden="true">
                  <g>
                    <g>
                      <rect fill="none" height="20" width="20" />
                    </g>
                  </g>
                  <g>
                    <polygon points="4.59,16.59 6,18 14,10 6,2 4.59,3.41 11.17,10" />
                  </g>
                </svg>
              </xsl:if>
            </li>
          </xsl:for-each>
        </ol>
      </nav>
    </section>
  </xsl:template>

  <xsl:template name="build-search-form">
    <xsl:variable name="form" select="//qui:block[@slot='search-form']" />
    <fieldset class="[ results-search ][ no-border ]">
      <legend class="visually-hidden">Search</legend>
      <div class="[ search-container ] [ flex ]">
        <select class="[ dropdown select ] [ bold no-border ]">
          <xsl:for-each select="$form/qui:select/qui:option">
            <option value="{@value}"><xsl:value-of select="." /></option>
          </xsl:for-each>
        </select>
        <div class="[ border ]">
          <label class="visually-hidden" for="search-collection">
            <span>Search</span>
          </label>
        </div>
        <input id="search-collection" class="results-search_input" type="search" name="query" placeholder="" />
        <div class="flex">
          <button class="[ button button--primary button--small ]" type="submit" aria-label="Search">
            <svg width="20px" height="20px" viewBox="0 0 24 24" class="button-icon" aria-hidden="true">
              <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"></path>
            </svg>
            <span class="visually-hidden" style="border: 0px; clip: rect(0px, 0px, 0px, 0px); height: 1px; margin: -1px; overflow: hidden; padding: 0px; position: absolute; width: 1px; white-space: nowrap; overflow-wrap: normal;">Submit</span>
          </button>
        </div>
      </div>
    </fieldset>
  </xsl:template>

  <xsl:template name="build-search-summary">
    <xsl:variable name="nav" select="//qui:nav[@role='results']" />
    <p>
      <xsl:text>Showing </xsl:text>
      <xsl:value-of select="$nav/@start" />
      <xsl:text>-</xsl:text>
      <xsl:value-of select="$nav/@end" />
      <xsl:text> of </xsl:text>
      <xsl:value-of select="$nav/@total" />
      <xsl:text> results</xsl:text>
    </p>
  </xsl:template>

  <xsl:template name="build-results-list">
    <xsl:apply-templates select="//qui:block[@slot='results']/qui:section" mode="result" />
  </xsl:template>

  <xsl:template match="qui:section" mode="result">
    <section class="[ results-list--small ]">
      <a class="[ flex ]" href="{qui:link[@rel='result']/@href}">
        <img class="[ results-list__image ]" src="{qui:link[@rel='iiif']/@href}/full/!140,140/0/native.jpg" alt="{ItemDescription}" />
        <div class="[ results-list__content ]">
          <h4><xsl:apply-templates select="qui:title" /></h4>
          <dl class="[ results ]">
            <xsl:apply-templates select="qui:block[@slot='metadata']//qui:field" />
          </dl>
        </div>
      </a>
    </section>
  </xsl:template>

  <xsl:template match="qui:head/qui:title">
    <xsl:for-each select="qui:values/qui:value">
      <xsl:value-of select="." />
      <xsl:if test="position() &lt; last()">
        <xsl:text> | </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="build-navigation"></xsl:template>

</xsl:stylesheet>