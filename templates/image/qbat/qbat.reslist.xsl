<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />
  <xsl:variable name="sort-options" select="//qui:form[@id='sort-options']" />
  <xsl:variable name="xc" select="//qui:block[@slot='results']/@data-xc" />

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <link rel="stylesheet" href="{$docroot}styles/image/reslist.css" />
  </xsl:template>

  <xsl:template match="qui:main">

    <div class="[ flex flex-flow-rw ][ flex-gap-1 ]">
      <div class="side-panel">
        <h2 class="visually-hidden">Options</h2>
        <xsl:call-template name="build-filters-panel" />
      </div>
      <div class="main-panel">
        <xsl:call-template name="build-collection-heading" />
        <xsl:call-template name="build-breadcrumbs" />
        <xsl:call-template name="build-search-form" />
        <xsl:call-template name="build-search-summary" />
        <xsl:if test="//qui:nav[@role='results']/@total &gt; 0">
          <xsl:call-template name="build-search-tools" />
        </xsl:if>
        <xsl:call-template name="build-results-list" />
        <xsl:call-template name="build-results-pagination" />
        <xsl:call-template name="build-hidden-portfolio-form" />
      </div>
    </div>

  </xsl:template>

  <xsl:template name="build-search-summary">
    <xsl:variable name="nav" select="//qui:nav[@role='results']" />
    <xsl:choose>
      <xsl:when test="$nav/@total = 0">
        <h2 class="results-heading">
          <span class="[ bold ]">No results</span>
          <xsl:text> match your search.</xsl:text>
        </h2>
      </xsl:when>
      <xsl:otherwise>
        <h2 class="results-heading">
          <xsl:value-of select="$nav/@start" />
          <xsl:text> to </xsl:text>
          <xsl:value-of select="$nav/@end" />
          <xsl:text> of </xsl:text>
          <xsl:value-of select="$nav/@total" />
          <xsl:text> results</xsl:text>
        </h2>
      </xsl:otherwise>
    </xsl:choose>
    <p>
      <!-- needs to address advanced search -->
      <xsl:text>Showing results for </xsl:text>
      <xsl:for-each select="$search-form/qui:control[@slot='clause'][normalize-space(qui:input[@slot='q']/@value)]">
        <xsl:variable name="select" select="qui:input[@slot='select']/@value" />
        <xsl:if test="qui:input[@slot='op']">
          <xsl:text> </xsl:text>
          <span class="[ lowercase ]">
            <xsl:value-of select="qui:input[@slot='op']/@label" />
          </span>
          <xsl:text> </xsl:text>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="$select = 'all'"></xsl:when>
          <xsl:when test="$select = 'any'"> any of </xsl:when>
          <xsl:when test="$select = 'phrase'"> the phrase </xsl:when>
          <xsl:when test="$select = 'ic_exact'"> the exact keyword </xsl:when>
          <xsl:when test="$select = 'regex'"> the expression </xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
        <span class="[ bold ]">
          <xsl:choose>
            <xsl:when test="qui:input[@slot='q']/@name = 'q1' and qui:input[@slot='q']/@value = $collid">
              <xsl:text>*</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>&quot;</xsl:text>
              <xsl:value-of select="qui:input[@slot='q']/@value" />
              <xsl:text>&quot;</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </span>
        <xsl:text> in </xsl:text>
        <span class="[ bold ]">
          <xsl:choose>
            <xsl:when test="qui:input[@slot='rgn']/qui:option[@selected='selected']">
              <xsl:value-of select="qui:input[@slot='rgn']/qui:option[@selected='selected']" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="qui:input[@slot='rgn']/@label" />
            </xsl:otherwise>
          </xsl:choose>
        </span>
      </xsl:for-each>
      <xsl:text>.</xsl:text>
    </p>
    <xsl:if test="$nav/@total = 0">
      <xsl:call-template name="build-search-hints" />
    </xsl:if>

  </xsl:template>

  <xsl:template name="build-search-tools">
    <xsl:apply-templates select="//qui:callout" />
    <div class="[ search-results__tools ] [ mb-1 gap-1 ]">
      <div class="[ flex flex-align-center ]">
          <input type="checkbox" id="add-portfolio" name="portfolio" data-action="select-all" autocomplete="off" />
          <label for="add-portfolio" class="visually-hidden"
            >Select all results for portfolio</label
          >
          <button
            class="[ button button--secondary ] [ flex ]"
            aria-label="Add items to portfolio"
            data-action="add-items"
          >
            <span class="material-icons" aria-hidden="true">add</span>
            <span>Add to portfolio</span>
          </button>
          <xsl:call-template name="build-extra-portfolio-actions" />
      </div>
      <xsl:if test="$sort-options//qui:option">
        <div class="select-group">
          <form method="GET" action="/cgi/i/image/image-idx" autocomplete="off">
            <label for="results-sort">Sort by:</label>
            <select
              name="results"
              id="results-sort"
              class="[ dropdown select ]"
              autocomplete="off"
            >
              <xsl:for-each select="$sort-options//qui:option">
                <option value="{@value}">
                  <xsl:if test="@selected = 'selected'">
                    <xsl:attribute name="selected">selected</xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="." />
                </option>
              </xsl:for-each>
            </select>
            <xsl:apply-templates select="$sort-options/qui:hidden-input" />
          </form>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="build-results-list">
    <xsl:apply-templates select="//qui:block[@slot='results']/qui:section" mode="result" />
  </xsl:template>

  <xsl:template name="build-results-pagination">
    <xsl:variable name="nav" select="//qui:main/qui:nav[@role='results']" />
    <xsl:if test="$nav/@min &lt; $nav/@max">
      <nav aria-label="Result navigation" class="[ pagination__row ][ flex flex-space-between flex-align-center ]">
        <div class="pagination__group">
          <xsl:if test="$nav/qui:link">
            <ul class="pagination">
              <xsl:if test="$nav/qui:link[@rel='previous']">
                <li class="pagination__item">
                  <xsl:apply-templates select="$nav/qui:link[@rel='previous']" />
                </li>
              </xsl:if>
              <xsl:if test="$nav/qui:link[@rel='next']">
                <li class="pagination__item">
                  <xsl:apply-templates select="$nav/qui:link[@rel='next']" />
                </li>
              </xsl:if>
            </ul>
          </xsl:if>
        </div>
        <div class="pagination__group">
          <label for="results-pagination">Go to page:</label>
          <input
            type="number"
            id="results-pagination"
            name="page"
            min="1"
            max="{$nav/@max}"
            value="{$nav/@current}"
          />
          <span>of <xsl:value-of select="$nav/@max" /></span>

          <button type="submit" class="[ button button--secondary ] [ flex ]">
            Go
          </button>
        </div>
      </nav>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:section" mode="result">
    <section class="[ results-list--small ]">
      <!-- <xsl:variable name="link" select="qui:link[@rel='result']" /> -->
      <xsl:variable name="link-tmp">
        <xsl:apply-templates select="qui:link[@rel='result']" />
      </xsl:variable>
      <xsl:variable name="link" select="exsl:node-set($link-tmp)" />
      <a class="[ flex ][ flex-grow-1 ]">
        <xsl:attribute name="href">
          <xsl:value-of select="$link//@href" />
        </xsl:attribute>
        <xsl:attribute name="data-available">
          <xsl:value-of select="$link//@data-available" />
        </xsl:attribute>

        <xsl:choose>
          <xsl:when test="qui:link[@rel='iiif']">
            <img class="[ results-list__image ]" src="{qui:link[@rel='iiif']/@href}/full/!140,140/0/native.jpg" alt="{ItemDescription}" />
          </xsl:when>
          <xsl:otherwise>
            <div class="[ results-list__blank ]" aria-hidden="true">
            </div>
          </xsl:otherwise>
        </xsl:choose>
        <div class="[ results-list__content ]">
          <h3><xsl:apply-templates select="qui:title" /></h3>
          <dl class="[ results ]">
            <xsl:apply-templates select="qui:collection" />
            <xsl:apply-templates select="qui:block[@slot='metadata']//qui:field" />
          </dl>
        </div>
      </a>
      <label class="[ portfolio-selection ]">
        <input type="checkbox" name="bbidno" value="{@identifier}" autocomplete="off" />
        <span class="visually-hidden">Add item to portfolio</span>
      </label>
    </section>
  </xsl:template>

  <xsl:template match="qui:collection">
    <xsl:if test="$xc = 'true'">
      <div>
        <dt data-key="collid">Collection</dt>
        <dd>
          <xsl:value-of select="qui:title" />
        </dd>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:head/qui:title">
    <xsl:for-each select="qui:values/qui:value">
      <xsl:value-of select="." />
      <xsl:if test="position() &lt; last()">
        <xsl:text> | </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="qui:section/qui:title">
    <xsl:for-each select="qui:values/qui:value">
      <xsl:value-of select="." />
      <xsl:if test="position() &lt; last()">
        <xsl:text>; </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="qui:field//qui:link" mode="copy" priority="105">
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="qui:link[@rel='previous']" priority="100">
    <a>
      <xsl:call-template name="build-href-or-identifier" />
      <svg
          height="18px"
          viewBox="0 0 20 20"
          width="12px"
          fill="#06080a"
          aria-hidden="true"
          style="transform: rotate(-180deg)"
          focusable="false"
          role="img"
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
        <span>Previous</span>
      </a>
  </xsl:template>

  <xsl:template match="qui:link[@rel='next']" priority="100">
    <a>
      <xsl:call-template name="build-href-or-identifier" />
      <span>Next</span>
      <svg
          height="18px"
          viewBox="0 0 20 20"
          width="12px"
          fill="#06080a"
          aria-hidden="true"
          focusable="false"
          role="img"
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
    </a>
  </xsl:template>


  <xsl:template name="build-navigation"></xsl:template>

  <xsl:template name="build-hidden-portfolio-form">
    <form style="display: none" method="GET" action="/cgi/i/image/image-idx" id="bbaction-form">
      <xsl:apply-templates select="//qui:form[@action='bbaction']/qui:hidden-input" />
      <input type="hidden" name="bbaction" value="" id="bbaction-page" />
    </form>
  </xsl:template>

  <xsl:template match="qui:callout">
    <m-callout subtle="subtle" icon="check" dismissable="dismissable" variant="{@variant}">
      <xsl:apply-templates mode="copy" />
    </m-callout>
  </xsl:template>

  <xsl:template name="build-search-hints">
    <h3>Other suggestions</h3>
    <ul class="[ list-bulleted ]">
      <li>Check your spelling.</li>
      <li>Try more general keywords.</li>
      <li>Try different keywords that mean the same thing.</li>
      <li>Try searching in <strong>Anywhere in record</strong>.</li>
    </ul>
  </xsl:template>

  <xsl:template name="build-extra-portfolio-actions"></xsl:template>


</xsl:stylesheet>