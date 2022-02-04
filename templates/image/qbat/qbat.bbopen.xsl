<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <xsl:variable name="labels-tmp">
    <dlxs:labels>
      <dlxs:field key="itemcount">Number of items</dlxs:field>
      <dlxs:field key="username">Owner</dlxs:field>
      <dlxs:field key="modified_display">Last Modified</dlxs:field>
    </dlxs:labels>
  </xsl:variable>
  <xsl:variable name="labels" select="exsl:node-set($labels-tmp)" />

  <xsl:template name="build-cqfill-script">
  </xsl:template>

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <link rel="stylesheet" href="{$docroot}styles/image/reslist.css" />
    <script src="https://unpkg.com/blingblingjs@2.1.1/dist/index.js"></script>
    <script src="{$docroot}js/image/bbopen.js"></script>

    <style>
      .main-panel[data-state="loading"] {
        visibility: hidden;
      }

      .filter-item[data-disabled="true"] {
        opacity: 0.25;
      }

      .flex-justify-end {
        justify-content: flex-end;
      }

      .flex-nowrap {
        flex-wrap: nowrap;
      }

      input[type="text"] {
        padding: 0.5rem;
        width: 25ch;
      }

      .portfolio {
        display: none;
      }

    </style>
    <style id="portfolio-filter-rules" type="text/css">
      .portfolio--list .portfolio {
        display: flex;
      }
    </style>
  </xsl:template>

  <xsl:template match="qui:main">

    <!-- <div class="message-callout">
      <p>
        This collection index re-design is still under construction.
      </p>
    </div> -->

    <xsl:call-template name="build-collection-heading" />

    <div class="[ flex flex-flow-row flex-gap-1 ]">
      <div class="side-panel">
        <details class="panel" data-list-expanded="false" data-key="filter">
          <xsl:attribute name="open">open</xsl:attribute>
          <summary>
            Filter Portfolios
          </summary>
          <div class="filter-item--list">
            <xsl:call-template name="build-filter-select">
              <xsl:with-param name="key">all</xsl:with-param>
              <xsl:with-param name="label">All Portfolios</xsl:with-param>
              <xsl:with-param name="selected">true</xsl:with-param>
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
              <xsl:with-param name="count">
                <xsl:value-of select="count(//qui:section[@mine='true'])" />
              </xsl:with-param>
            </xsl:call-template>
          </div>
        </details>
      </div>
      <div class="main-panel" data-state="loading">
        <xsl:call-template name="build-search-summary" />
        <xsl:call-template name="build-search-tools" />
        <div class="[ portfolio--list ]">
          <xsl:call-template name="build-results-list" />
        </div>
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

  <xsl:template name="build-search-summary">
  </xsl:template>

  <xsl:template name="build-search-tools">
    <div class="[ search-results__tools ] [ mb-1 flex-gap-1 flex-nowrap ]">
      <div style="display: flex; flex-wrap: wrap; flex-grow: 1">
        <label for="search">Search by title or description:</label>
        <input type="text" value="" name="search" id="search" data-action="search" autocomplete="off" style="flex-grow: 1; height: 40px" />
      </div>
      <div>
        <label for="result-sort">Sort by:</label>
        <select name="results" id="result-sort" data-action="sort" class="[ dropdown select ]" autocomplete="off">
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
      <xsl:variable name="link-tmp">
        <xsl:apply-templates select="qui:link[@rel='open']" />
      </xsl:variable>
      <xsl:variable name="link" select="exsl:node-set($link-tmp)" />
      <a class="[ flex ]">
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
          <h4 data-key="collname">
            <xsl:apply-templates select="qui:title" />
          </h4>
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

  <xsl:template match="qui:field[@key='modified']" modified="100" />

  <xsl:template match="qui:label" mode="copy-guts">
    <xsl:variable name="key" select="@key" />
    <xsl:variable name="value" select="$labels//dlxs:field[@key=$key]" />
    <xsl:value-of select="$value" />
  </xsl:template>

</xsl:stylesheet>