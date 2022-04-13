<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <xsl:template name="build-cqfill-script">
  </xsl:template>

  <xsl:template name="build-app-script">
    <script src="{$docroot}dist/js/image/bbopen.js"></script>
  </xsl:template>

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <link rel="stylesheet" href="{$docroot}styles/image/reslist.css" />
    <link rel="stylesheet" href="{$docroot}styles/image/bbopen.css" />
    <!-- <script src="{$docroot}dist/js/image/bbopen.js"></script> -->

    <style id="portfolio-filter-rules" type="text/css">
      .portfolio--list .portfolio[data-page="1"] {
        display: flex;
      }
    </style>
  </xsl:template>

  <xsl:template match="qui:main">

    <div class="[ flex flex-flow-rw ][ flex-gap-1 ]">
      <div class="side-panel"></div>
      <div class="main-panel">
        <xsl:call-template name="build-collection-heading" />
      </div>
    </div>
    <div class="[ flex flex-flow-rw flex-gap-1 ]">
      <div class="side-panel">
        <button data-action="toggle-side-panel" class="flex button button--ghost" aria-expanded="false">
          <span class="flex flex-center flex-space-between flex-grow-1">
            <span>Filters</span>
          </span>
        </button>
        <h3 class="[ mt-2 ]">Filters</h3>
        <details class="panel" data-list-expanded="false" data-key="filter">
          <xsl:attribute name="open">open</xsl:attribute>
          <summary>
            Portfolio Filter
          </summary>
          <div class="filter-item--list">
            <xsl:call-template name="build-filter-select">
              <xsl:with-param name="key">all</xsl:with-param>
              <xsl:with-param name="label">All Portfolios</xsl:with-param>
              <xsl:with-param name="selected"><xsl:value-of select="$username = ''" /></xsl:with-param>
              <xsl:with-param name="count">
                <xsl:value-of select="count(//qui:section[@access])" />
              </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="build-filter-select">
              <xsl:with-param name="key">recent</xsl:with-param>
              <xsl:with-param name="label">Recently Updated</xsl:with-param>
              <xsl:with-param name="count">
                <xsl:value-of select="count(//qui:section[@recent='true'])" />
              </xsl:with-param>
            </xsl:call-template>
            <xsl:call-template name="build-filter-select">
              <xsl:with-param name="key">mine</xsl:with-param>
              <xsl:with-param name="label">My Portfolios</xsl:with-param>
              <xsl:with-param name="disabled"><xsl:value-of select="$username = ''" /></xsl:with-param>
              <xsl:with-param name="selected"><xsl:value-of select="$username != ''" /></xsl:with-param>
              <xsl:with-param name="count">
                <xsl:value-of select="count(//qui:section[@mine='true'])" />
              </xsl:with-param>
            </xsl:call-template>
          </div>
        </details>
        <xsl:call-template name="build-filter-search" />
      </div>
      <div class="main-panel" data-state="loading">
        <!-- <xsl:call-template name="build-collection-heading" /> -->
        <!-- <xsl:call-template name="build-breadcrumbs" /> -->

        <xsl:call-template name="build-search-summary" />
        <xsl:call-template name="build-search-tools" />
        <div class="[ portfolio--list ]">
          <xsl:call-template name="build-results-list" />
        </div>
        <xsl:call-template name="build-results-pagination" />
      </div>
    </div>

  </xsl:template>

  <xsl:template name="build-filter-select">
    <xsl:param name="key" />
    <xsl:param name="label" />
    <xsl:param name="selected" />
    <xsl:param name="count" />
    <xsl:param name="disabled" />
    <div class="[ flex filter-item ][ gap-0_5 ]">
      <xsl:if test="$disabled = 'true'">
        <xsl:attribute name="data-disabled">true</xsl:attribute>
      </xsl:if>
      <input type="radio" id="filter-{$key}" name="filter" value="{$key}" data-action="filter" autocomplete="off" style="margin-top: 4px">
        <xsl:if test="$selected = 'true'">
          <xsl:attribute name="checked">checked</xsl:attribute>
        </xsl:if>
        <xsl:if test="$disabled = 'true'">
          <xsl:attribute name="disabled">disabled</xsl:attribute>
        </xsl:if>
      </input>
      <label for="filter-{ $key }">
        <xsl:value-of select="$label" />
        <xsl:if test="$count">
          <xsl:text> </xsl:text>
          <span class="filters__count" id="counts-{ $key}">
            <xsl:text> (</xsl:text>
            <xsl:value-of select="$count" />
            <xsl:text>)</xsl:text>
          </span>
        </xsl:if>
      </label>
    </div>
  </xsl:template>

  <xsl:template name="build-filter-search">
    <div class="[ flex ][ flex-flow-column flex-gap-0_5 ]">
      <label for="search">Search by title or description:</label>
      <input type="text" value="" name="search" id="search" data-action="search" autocomplete="off" style="flex-grow: 1; height: 40px; width: 96%" />
      <button type="submit" class="[ button button--secondary ] [ flex ]" style="align-self: flex-start" data-action="clear-lists-search" >
          Clear
      </button>
    </div>
  </xsl:template>

  <xsl:template name="build-search-summary">
    <xsl:variable name="total" select="count(//qui:section[@identifier])" />
    <p data-slot="pagination-summary">
      <xsl:text>1</xsl:text>
      <xsl:text> to </xsl:text>
      <xsl:value-of select="50" />
      <xsl:text> of </xsl:text>
      <xsl:value-of select="$total" />
      <xsl:text> results</xsl:text>
    </p>
    <p data-slot="query-summary">Showing results for all portfolios.</p>
  </xsl:template>

  <xsl:template name="build-search-tools">
    <div class="[ search-results__tools ] [ mb-1 flex-gap-1 flex-justify-end ]">
      <div>
        <label for="results-sort">Sort by:</label>
        <select name="results" id="results-sort" data-action="sort" class="[ dropdown select ]" autocomplete="off">
          <option value="collname::asc">Title</option>
          <option value="modified::desc">Last Modified</option>
          <option value="numItems::asc">Number of Items (low to high)</option>
          <option value="numItems::desc">Number of Items (high to low)</option>
        </select>

      </div>
    </div>
  </xsl:template>

  <xsl:template name="build-results-list">
    <xsl:apply-templates select="//qui:block[@slot='results']/qui:section" mode="result" />
  </xsl:template>

  <xsl:template match="qui:section" mode="result">
    <section class="[ results-list--small ][ portfolio ]">
      <xsl:if test="@recent">
        <xsl:attribute name="data-recent"><xsl:value-of select="@recent" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="@mine">
        <xsl:attribute name="data-mine"><xsl:value-of select="@mine" /></xsl:attribute>
      </xsl:if>
      <xsl:attribute name="data-page">
        <xsl:value-of select="floor(( position() - 1 ) div 50) + 1" />
      </xsl:attribute>
      <xsl:variable name="link-tmp">
        <xsl:apply-templates select="qui:link[@rel='open']" />
      </xsl:variable>
      <xsl:variable name="link" select="exsl:node-set($link-tmp)" />
      <a class="[ flex ][ flex-grow-1 ]">
        <xsl:attribute name="href">
          <xsl:value-of select="$link//@href" />
        </xsl:attribute>
        <!-- <xsl:attribute name="data-available">
          <xsl:value-of select="$link//@data-available" />
        </xsl:attribute> -->

        <xsl:choose>
          <xsl:when test="qui:link[@rel='iiif']">
            <img class="[ results-list__image ]" src="{qui:link[@rel='iiif']/@href}/full/!140,140/0/native.jpg" alt="{ItemDescription}" />
          </xsl:when>
          <xsl:otherwise>
            <div class="[ results-list__blank ]" aria-hidden="true"></div>
          </xsl:otherwise>
        </xsl:choose>
        <div class="[ results-list__content ]">
          <h3 data-key="collname">
            <xsl:apply-templates select="qui:title" />
          </h3>
          <dl class="[ results ]">
            <xsl:apply-templates select="qui:block[@slot='metadata']//qui:field" />
          </dl>
        </div>
      </a>
    </section>
  </xsl:template>

  <xsl:template name="build-results-pagination">
    <xsl:variable name="max" select="round(count(//qui:section[@identifier]) div 50)" />
    <nav aria-label="Result navigation" data-action="paginate" class="[ pagination__row ][ flex flex-space-between flex-align-center sticky-bottom ]">
      <xsl:attribute name="data-active">
        <xsl:choose>
          <xsl:when test="$max &gt; 1">
            <xsl:text>true</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>false</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <div class="pagination__group">
        <ul class="pagination">
          <li class="pagination__item" data-action="previous-link" data-active="false">
            <a href="#">Previous</a>
          </li>
          <li class="pagination__item" data-action="next-link" data-active="true">
            <a href="#">Next</a>
          </li>
        </ul>
      </div>
      <div class="pagination__group">
        <label for="results-pagination">Go to page:</label>
        <input type="number" id="results-pagination" name="page" min="1" max="{$max}" value="1" />
        <span>
          of
          <span data-slot="total-pages">
            <xsl:value-of select="$max" />
          </span>
        </span>

        <button type="submit" class="[ button button--secondary ] [ flex ]">
          Go
        </button>
      </div>
    </nav>
  </xsl:template>

  <xsl:template match="qui:head/qui:title">
    <xsl:for-each select="qui:values/qui:value">
      <xsl:value-of select="." />
      <xsl:if test="position() &lt; last()">
        <xsl:text> | </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="qui:field[@key='modified']" modified="100" />

  <xsl:template match="qui:label" mode="copy-guts">
    <xsl:variable name="key" select="@key" />
    <xsl:variable name="value" select="$labels//dlxs:field[@key=$key]" />
    <xsl:value-of select="$value" />
  </xsl:template>

</xsl:stylesheet>