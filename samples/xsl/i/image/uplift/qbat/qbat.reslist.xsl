<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />
  <xsl:variable name="sort-options" select="//qui:form[@id='sort-options']" />

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <link rel="stylesheet" href="/samples/styles/reslist.css" />
    <script src="/samples/js/base.js"></script>
  </xsl:template>

  <xsl:template match="qui:main">

    <xsl:call-template name="build-collection-heading" />

    <div class="[ flex flex-flow-rw ]">
      <div class="side-panel">
        <xsl:call-template name="build-filters-panel" />
      </div>
      <div class="main-panel">
        <xsl:call-template name="build-breadcrumbs" />
        <xsl:call-template name="build-search-form" />
        <xsl:call-template name="build-search-summary" />
        <xsl:if test="//qui:nav[@role='results']/@total &gt; 0">
          <xsl:call-template name="build-search-tools" />
        </xsl:if>
        <xsl:call-template name="build-results-list" />
        <xsl:call-template name="build-results-pagination" />
      </div>
    </div>

  </xsl:template>

  <xsl:template name="build-search-summary">
    <xsl:variable name="nav" select="//qui:nav[@role='results']" />
    <xsl:choose>
      <xsl:when test="$nav/@total = 0">
        <p>
          <span class="[ bold ]">No results</span>
          <xsl:text> match your search.</xsl:text>
        </p>
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:value-of select="$nav/@start" />
          <xsl:text> to </xsl:text>
          <xsl:value-of select="$nav/@end" />
          <xsl:text> of </xsl:text>
          <xsl:value-of select="$nav/@total" />
          <xsl:text> results</xsl:text>
        </p>
      </xsl:otherwise>
    </xsl:choose>
    <p>
      <!-- needs to address advanced search -->
      <xsl:text>Showing results for </xsl:text>
      <xsl:for-each select="$search-form/qui:control[@slot='clause'][normalize-space(qui:input[@slot='q']/@value)]">
        <xsl:if test="qui:input[@slot='op']">
          <xsl:text> </xsl:text>
          <span class="[ lowercase ]">
            <xsl:value-of select="qui:input[@slot='op']/@label" />
          </span>
          <xsl:text> </xsl:text>
        </xsl:if>
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
    <div class="[ search-results__tools ] [ mb-1 ]">
      <div class="[ flex flex-align-center ]">
          <input type="checkbox" id="add-portfolio" name="portfolio" />
          <label for="add-portfolio" class="visually-hidden"
            >Add to portfolio</label
          >
          <button
            class="[ button button--secondary ] [ flex ]"
            type="submit"
            aria-label="Search"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="16"
              height="16"
              viewBox="0 0 24 24"
              fill="currentColor"
              aria-hidden="true"
              focusable="false"
              role="img"
            >
              <path d="M19 13h-6v6h-2v-6H5v-2h6V5h2v6h6v2z" />
            </svg>

            <span>Add to portfolio</span>
          </button>
      </div>
      <xsl:if test="$sort-options//qui:option">
        <div class="select-group">
          <form method="GET" action="/cgi/i/image/image-idx" autocomplete="off">
            <label for="result-sort">Sort by:</label>
            <select
              name="results"
              id="result-sort"
              class="[ dropdown select ]"
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
            style="width: {$nav/@max + 4}ch"
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

  <xsl:template name="build-filters-panel">
    <xsl:variable name="filters" select="//qui:filters-panel" />

    <xsl:variable name="selected-filters" select="$filters//qui:filter[not(@arity)]//qui:value[@selected='true']" />
    <xsl:if test="$search-form/@data-has-query = 'true'">
      <section class="[ filters__selected ]">
        <xsl:if test="$selected-filters">
          <h3 class="[ mt-2 ]">Current Filters</h3>
          <xsl:for-each select="$selected-filters">
            <xsl:variable name="filter" select="ancestor-or-self::qui:filter" />
            <xsl:variable name="key" select="$filter/@key" />
            <div>
              <input type="checkbox" id="x-{$key}-{position()}" name="{$key}" value="{.}" data-action="facet" checked="checked" />
              <label for="x-{$key}-{position()}">
                <xsl:choose>
                  <xsl:when test="$filter/@arity = '1'">
                    <span>
                      <xsl:value-of select="$filter/qui:label" />
                    </span>
                  </xsl:when>
                  <xsl:otherwise>
                    <span class="separator">
                      <xsl:value-of select="$filter/qui:label" />
                    </span>
                    <span>
                      <xsl:value-of select="." />
                    </span>
                  </xsl:otherwise>
                </xsl:choose>
              </label>
            </div>
          </xsl:for-each>
        </xsl:if>

        <a>
          <xsl:if test="not($selected-filters)">
            <xsl:attribute name="class">mt-2 block</xsl:attribute>
          </xsl:if>
          <xsl:attribute name="href">
            <xsl:choose>
              <xsl:when test="$search-form/@data-advanced = 'true'">
                <xsl:text>/cgi/i/image/image-idx?page=search;cc=</xsl:text>
                <xsl:value-of select="$collid" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>/cgi/i/image/image-idx?cc=</xsl:text>
                <xsl:value-of select="$collid" />
                <xsl:text>;q1=</xsl:text>
                <xsl:value-of select="$collid" />
                <xsl:text>;view=reslist</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:text>Start Over</xsl:text>
        </a>
      </section>      
    </xsl:if>

    <xsl:if test="$filters//qui:filter">
      <h3 class="[ mt-2 ]">Filters</h3>
      <div class="[ side-panel__box ]">
        <xsl:for-each select="$filters//qui:filter">
          <xsl:choose>
            <xsl:when test="@arity = 1">
              <xsl:call-template name="build-single-filter-option" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="qui:values/qui:value[not(@selected)]">
                <xsl:call-template name="build-filter-panel" />
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-single-filter-option">
    <xsl:variable name="key" select="@key" />
    <xsl:variable name="value" select="qui:values/qui:value" />
    <xsl:if test="true() or not($value/@selected = 'true')">
      <div class="panel" style="padding: 1rem 0">
        <div class="[ flex ][ gap-0_5 ]">
          <input type="checkbox" id="{ $key }-1" name="{$key}" value="{ normalize-space($value) }" data-action="facet" style="margin-top: 4px">
            <xsl:if test="$value/@selected = 'true'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input>
          <label for="{ $key }-1">
            <xsl:value-of select="qui:label" />
          </label>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-filter-panel">
    <xsl:variable name="key" select="@key" />
    <details class="panel" data-list-expanded="false">
      <xsl:if test="qui:values/qui:value[@selected='true']">
        <xsl:attribute name="open">open</xsl:attribute>
      </xsl:if>
      <summary>
        <xsl:value-of select="qui:label" />
      </summary>
      <xsl:for-each select="qui:values/qui:value[not(@selected)]">
        <div class="[ flex filter-item ][ gap-0_5 ]">
          <input type="checkbox" id="{ $key }-{ position() }" name="{$key}" value="{ . }" data-action="facet" style="margin-top: 4px">
            <xsl:if test="@selected = 'true'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input>
          <label for="{ $key }-{ position() }">
            <xsl:value-of select="." />
            <xsl:text></xsl:text>
            <span class="filters__count">
              <xsl:text> (</xsl:text>
              <xsl:value-of select="@count" />
              <xsl:text>)</xsl:text>
            </span>
          </label>
        </div>
      </xsl:for-each>
      <xsl:if test="count(qui:values/qui:value) &gt; 10">
        <p>
          <button class="[ button filter__button ]" data-action="expand-filter-list">
            <span data-expanded="true">
              <xsl:text>Show fewer </xsl:text>
            </span>
            <span data-expanded="false">
              <xsl:text>Show all </xsl:text>
              <xsl:value-of select="count(qui:values/qui:value)" />
              <xsl:text> </xsl:text>
            </span>
            <xsl:value-of select="qui:label" />
            <xsl:text> filters</xsl:text>
          </button>
        </p>
      </xsl:if>
    </details>
  </xsl:template>

  <xsl:template match="qui:section" mode="result">
    <section class="[ results-list--small ]">
      <!-- <xsl:variable name="link" select="qui:link[@rel='result']" /> -->
      <xsl:variable name="link-tmp">
        <xsl:apply-templates select="qui:link[@rel='result']" />
      </xsl:variable>
      <xsl:variable name="link" select="exsl:node-set($link-tmp)" />
      <a class="[ flex ]">
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
          <h4><xsl:apply-templates select="qui:title" /></h4>
          <dl class="[ results ]">
            <xsl:apply-templates select="qui:block[@slot='metadata']//qui:field" />
          </dl>
        </div>
      </a>
      <label class="[ portfolio-selection ]">
        <input type="checkbox" name="box{generate-id(.)}" value="{@identifier}" />
        <span class="visually-hidden">Add item to portfolio</span>
      </label>
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

  <xsl:template name="build-search-hints">
    <h3>Other suggestions</h3>
    <ul class="[ list-bulleted ]">
      <li>Check your spelling.</li>
      <li>Try more general keywords.</li>
      <li>Try different keywords that mean the same thing.</li>
      <li>Try searching in <strong>Anywhere in record</strong>.</li>
    </ul>
  </xsl:template>

</xsl:stylesheet>