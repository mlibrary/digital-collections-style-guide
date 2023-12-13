<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />
  <xsl:variable name="sort-options" select="//qui:form[@id='sort-options']" />
  <xsl:variable name="xc" select="//qui:block[@slot='results']/@data-xc" />
  <xsl:variable name="key" select="//qui:block[@slot='results']/@data-key" />
  <xsl:variable name="value" select="//qui:block[@slot='results']/@data-value" />
  <xsl:variable name="has-results" select="//qui:nav[@role='results']/@total &gt; 0" />
  <xsl:variable name="nav" select="//qui:nav[@role='results']" />

  <xsl:template match="qui:main">

    <div class="[ mb-2 ]">
      <xsl:call-template name="build-navigation" />
      <xsl:call-template name="build-collection-heading" />
    </div>

    <div class="[ flex flex-flow-rw ][ flex-gap-1 ]">
      <xsl:variable name="has-side-actions">
        <xsl:call-template name="check-side-actions" />
      </xsl:variable>
      <div class="side-panel">
        <xsl:if test="$has-side-actions = 'true'">
          <button data-action="toggle-side-panel" class="flex button button--ghost" aria-expanded="false">
            <span class="flex flex-center flex-gap-0_5 flex-grow-1">
              <span class="material-icons" aria-hidden="true">filter_alt</span>
              <span>Filters</span>
            </span>
          </button>
          <h2 class="visually-hidden">Options</h2>
          <xsl:call-template name="build-selected-filters-panel" />
          <xsl:if test="count($filters) or //qui:panel[@slot='guide-frame']">
            <h3>
              <xsl:attribute name="class">mt-2</xsl:attribute>
              <xsl:text>Filters</xsl:text>
            </h3>
            <xsl:apply-templates select="//qui:panel[@slot='guide-frame']" />      
            <xsl:call-template name="build-filters-panel" />
          </xsl:if>
        </xsl:if>
      </div>
      <div class="main-panel">
        <xsl:call-template name="build-search-form" />
        <xsl:if test="qui:metadata[@slot='item']">
          <xsl:apply-templates select="qui:metadata[@slot='item']" mode="callout" />
        </xsl:if>
        <xsl:call-template name="build-results-summary-sort" />
        <xsl:if test="$has-results">
          <xsl:call-template name="build-portfolio-actions" />
        </xsl:if>
        <xsl:call-template name="build-results-list" />
        <xsl:call-template name="build-results-pagination" />
        <xsl:call-template name="build-hidden-portfolio-form" />
      </div>
    </div>

  </xsl:template>  

  <xsl:template name="check-side-actions">
    <xsl:choose>
      <xsl:when test="//qui:filter">true</xsl:when>
      <xsl:when test="$search-form/@data-has-query='true'">true</xsl:when>
      <xsl:when test="//qui:nav[@role='index']">true</xsl:when>
      <xsl:when test="//qui:panel[@slot='guide-frame']">true</xsl:when>
      <xsl:otherwise>false</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-results-summary-sort">
    <xsl:call-template name="build-search-tools" />
  </xsl:template>

  <xsl:template name="build-search-summary">
    <div class="search-summary">
      <xsl:call-template name="build-search-summary-body" />
      <xsl:choose>
        <xsl:when test="$nav/@total = 0">
          <h2 class="results-heading">
            <span class="[ bold ]">No results</span>
            <xsl:text> match your search.</xsl:text>
          </h2>
        </xsl:when>
        <xsl:otherwise>
          <h2 class="results-heading">
            <xsl:choose>
              <xsl:when test="$nav/@start = $nav/@end">
                <xsl:value-of select="$nav/@start" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$nav/@start" />
                <xsl:text> to </xsl:text>
                <xsl:value-of select="$nav/@end" />
                <xsl:text> of </xsl:text>
                <xsl:value-of select="$nav/@total" />    
              </xsl:otherwise>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="$nav/@subview = 'short'">
                <xsl:text> results </xsl:text>
                <!-- <xsl:text> (</xsl:text>
                <xsl:value-of select="$nav/@number-matches" />
                <xsl:text> matches</xsl:text>
                <xsl:text>)</xsl:text> -->
              </xsl:when>
              <xsl:when test="$nav/@subview = 'detail' and $nav/@end = 1">
                <xsl:text> hit in this item</xsl:text>
              </xsl:when>
              <xsl:when test="$nav/@subview = 'detail'">
                <xsl:text> hits in this item</xsl:text>
              </xsl:when>
            </xsl:choose>
            <xsl:if test="$nav/@is-truncated='true'">
              <span>
                <xsl:text> </xsl:text>
                <a href="?page=help#truncated-results">(truncated)</a>
              </span>
            </xsl:if>
            <xsl:if test="false() and $nav/@subview = 'detail'">
              <xsl:variable name="details" select="//qui:nav[@role='details']" />
              <br />
              <span>
                <xsl:value-of select="$details/@hit-count" />
                <xsl:text> matches in </xsl:text>
                <xsl:value-of select="$details/@total" />
                <xsl:text> items</xsl:text>
              </span>
            </xsl:if>
          </h2>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>

  <xsl:template name="build-search-summary-body">
    <p>
      <xsl:apply-templates select="//qui:block[@slot='search-summary']" mode="copy-guts" />
    </p>
    <xsl:if test="false() and $search-form/qui:control[@slot='clause'][normalize-space(qui:input[@slot='q']/@value)]">
      <p>
        <xsl:text>Showing results for </xsl:text>
        <xsl:for-each select="$search-form/qui:control[@slot='clause'][@data-name!='q0'][normalize-space(qui:input[@slot='q']/@value)]">
          <xsl:variable name="select" select="qui:input[@slot='select']/@value" />
          <xsl:if test="qui:input[@slot='op'] and position() &gt; 1">
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
              <xsl:when test="qui:input[@slot='rgn']/node()[@selected='selected']">
                <xsl:value-of select="qui:input[@slot='rgn']/node()[@selected='selected']" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="qui:input[@slot='rgn']/@label" />
              </xsl:otherwise>
            </xsl:choose>
          </span>
        </xsl:for-each>
        <xsl:text>.</xsl:text>
      </p>
    </xsl:if>
    <xsl:if test="$nav/@total = 0">
      <xsl:call-template name="build-search-hints" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-search-tools">
    <div class="[ search-results__tools ][ mb-1 gap-1 ]">
      <xsl:call-template name="build-search-summary" />
      <xsl:if test="$has-results and $sort-options//qui:option">
        <sl-dropdown id="action-results-sort">
          <sl-button slot="trigger" caret="caret" class="sl-button--ghost">
            <span class="sl-dropdown-label">
              <span class="material-icons text-xx-small">sort</span>
              <span>
                <span>Sort by </span>
                <span class="capitalize">
                  <xsl:value-of select="$sort-options//qui:option[@selected]" />
                </span>
              </span>
            </span>
          </sl-button>
          <sl-menu>
            <xsl:for-each select="$sort-options//qui:option">
              <sl-menu-item value="{@value}">
                <xsl:if test="@selected='selected'">
                  <xsl:attribute name="checked">checked</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="." />
              </sl-menu-item>
            </xsl:for-each>
          </sl-menu>
        </sl-dropdown>
        <form id="form-results-sort" method="GET" action="/cgi/t/text/text-idx" autocomplete="off" style="display: none">
          <xsl:apply-templates select="$sort-options/qui:hidden-input" />
        </form>        
      </xsl:if>
      <xsl:if test="$has-results and //qui:message[@id='sort-options']">
        <xsl:apply-templates select="//qui:message[@id='sort-options']" />
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="build-results-list">
    <xsl:apply-templates select="//qui:block[@slot='results']/qui:section" mode="result" />
  </xsl:template>

  <xsl:template name="build-results-pagination">
    <xsl:variable name="nav" select="//qui:main/qui:nav[@role='results']" />
    <xsl:if test="$nav/@min &lt; $nav/@max and $nav/qui:link[@href]">
      <nav id="pagination" aria-label="Result navigation" class="[ pagination__row ][ flex flex-space-between flex-align-center sticky-bottom ]">
        <div class="[ pagination__group ][ flex flex-align-center gap-0_5 ]">
          <xsl:if test="$nav/qui:link">
            <ul class="pagination">
              <li class="pagination__item">
                <xsl:apply-templates select="$nav/qui:link[@rel='previous']" />
              </li>
              <li class="pagination__item">
                <xsl:apply-templates select="$nav/qui:link[@rel='next']" />
              </li>
            </ul>
          </xsl:if>
        </div>
        <div class="[ pagination__group ][ flex flex-align-center gap-0_5 ]">
          <label for="results-pagination" class="pr-0">Go to page:</label>
          <input
            type="number"
            id="results-pagination"
            name="page"
            min="1"
            max="{$nav/@max}"
            value="{$nav/@current}"
          />
          <span>of <xsl:value-of select="$nav/@max" /></span>

          <button id="action-goto-results-page" class="[ button button--secondary ] [ flex ]">
            Go
          </button>
        </div>
      </nav>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:section" mode="result">
    <xsl:variable name="link-href">
      <xsl:choose>
        <xsl:when test="qui:link[@rel='result']">
          <xsl:value-of select="qui:link[@rel='result']/@href" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="qui:link[@rel='toc']/@href" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="link-title">
      <xsl:choose>
        <xsl:when test="qui:title">
          <xsl:apply-templates select="qui:title" mode="title" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="qui:metadata//qui:field[@key='title']" mode="title" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <section class="[ results-list--grid ]">
      <xsl:call-template name="build-results-item-badge" />

      <div class="results-card">
        <div class="results-list__content flex flex-flow-column flex-grow-1">
          <h3>
            <a href="{$link-href}" class="results-link">
              <xsl:value-of select="$link-title" />
            </a>
          </h3>
        </div>
      </div>
      <div class="results-details">
        <xsl:apply-templates select="qui:metadata" mode="build-coins" />
        <xsl:if test="@access = 'restricted'">
          <m-callout variant="warning" icon="warning">
            <xsl:value-of select="key('get-lookup', 'results.str.9')" />
          </m-callout>
        </xsl:if>
        <dl class="[ results ]">
          <!-- <xsl:apply-templates select="qui:collection" /> -->
          <!-- <xsl:apply-templates select="qui:block[@slot='metadata']//qui:field" /> -->
          <xsl:apply-templates select="qui:metadata//qui:field" />
          <xsl:if test="qui:link[@rel='toc' or @rel='detail']">
            <div>
              <dt>Links</dt>
              <!-- <xsl:apply-templates select="qui:link[@rel='detail']" mode="summary" /> -->
              <xsl:apply-templates select="qui:link[@rel='toc']" mode="summary">
                <xsl:with-param name="title" select="normalize-space($link-title)" />
              </xsl:apply-templates>
            </div>
          </xsl:if>
          <xsl:apply-templates select="qui:block[@slot='matches']//qui:field" />
        </dl>
        <xsl:apply-templates select="qui:block[@slot='summary']" mode="callout">
          <xsl:with-param name="title" select="normalize-space($link-title)" />
        </xsl:apply-templates>
      </div>

      <xsl:variable name="form" select="qui:form[@slot='bookbag']" />
      <xsl:if test="$form">
        <xsl:variable name="bb-id" select="generate-id()" />
        <label class="[ portfolio-selection ]" for="bb{$bb-id}">
          <input id="bb{$bb-id}" type="checkbox" name="bbidno" value="{$form/@data-identifier}" autocomplete="off" />
          <span class="visually-hidden">Add item to bookbag</span>
        </label>  
      </xsl:if>
    </section>
    <xsl:variable name="identifier" select="@identifier" />
    <xsl:apply-templates select="qui:block[@slot='details'][@for=$identifier]" />

    <xsl:if test="position() mod 10 = 0 and position() != last()">
      <div class="[ results--jump-toolbar flex flex-gap-0_5 flex-align-center ]">
        <a href="#maincontent" data-behavior="focus-center" class="button button--ghost">Back to Top</a>
        <a href="#pagination" data-behavior="focus-center" class="button button--ghost">Go to Pagination</a>
      </div>
    </xsl:if>

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

  <xsl:template match="*[qui:values]" mode="title">
    <xsl:for-each select="qui:values/qui:value">
      <xsl:value-of select="." />
      <xsl:if test="position() &lt; last()">
        <xsl:text>; </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="qui:field[@key='title']" priority="99">
    <!-- only render the title field if the section 
         doesn't have its own title -->
    <xsl:choose>
      <xsl:when test="ancestor::qui:section/qui:title">
        <xsl:apply-templates select="." mode="build" />
      </xsl:when>
      <xsl:otherwise>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- <xsl:when test="//qui:block[@slot='item']">
    <xsl:apply-templates select="." mode="build" />
  </xsl:when> -->

  <xsl:template match="qui:field[@key='path'][not(.//qui:value)]" priority="99" />

  <xsl:template match="qui:values[@format='ordered']">
    <dd>
      <ol>
        <xsl:for-each select="qui:value">
          <li>
            <xsl:apply-templates select="." mode="copy-guts" />
          </li>
        </xsl:for-each>
      </ol>  
    </dd>
  </xsl:template>

  <!-- we did this in ImageClass to disable links in fields, but we use them in TextClass -->
  <!-- <xsl:template match="qui:field//qui:link" mode="copy" priority="105">
    <xsl:value-of select="." />
  </xsl:template> -->

  <xsl:template match="qui:link[@rel='previous']" priority="100">
    <a>
      <xsl:call-template name="build-href-or-identifier" />
      <xsl:apply-templates select="@disabled" mode="copy" />
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
      <xsl:apply-templates select="@disabled" mode="copy" />
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

  <xsl:template match="@disabled" mode="copy" priority="100">
    <xsl:attribute name="disabled">disabled</xsl:attribute>
    <xsl:attribute name="aria-hidden">true</xsl:attribute>
    <xsl:attribute name="tabindex">-1</xsl:attribute>
  </xsl:template>

  <xsl:template name="build-navigation">
    <xsl:call-template name="build-breadcrumbs" />
  </xsl:template>

  <xsl:template match="qui:callout[@variant='warning']" priority="100">
    <m-callout subtle="subtle" variant="{@variant}">
      <xsl:apply-templates select="@*[starts-with(name(), 'data-')]" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </m-callout>
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

  <xsl:template match="qui:label[@for='input-value']">
    <label class="text-muted text-xx-small flex--wide" style="margin-bottom: -0.5rem">
      <xsl:apply-templates select="." mode="copy-guts" />
    </label>
  </xsl:template>

  <xsl:template match="qui:block[@slot='summary']" mode="callout-v1">
    <m-callout variant="info" icon="info" style="flex-grow: 1; margin-bottom: 0; z-index: 1;">
      <div class="[ flex ]" style="justify-content: space-between">
        <div>
          <a href="{../qui:link[@rel='detail']/@href}">Results detail</a>
          <xsl:text>: </xsl:text>
          <!-- <xsl:value-of select="concat(@label, ' ')" /> -->
          <xsl:apply-templates select="." mode="copy-guts" />
        </div>
        <!-- <a href="{../qui:link[@rel='detail']/@href}">Results detail</a> -->
      </div>
    </m-callout>
  </xsl:template>

  <xsl:template match="qui:block[@slot='summary']" mode="callout">
    <xsl:param name="title" />
    <xsl:variable name="access" select="ancestor::qui:section/@access" />
    <m-callout variant="info" icon="info" style="flex-grow: 1; margin-bottom: 0; z-index: 1;">
      <div class="[ flex ]" style="justify-content: space-between">
        <div>
          <span>Results detail: </span>
          <xsl:choose>
            <xsl:when test="$access != 'restricted' and ../qui:link[@rel='detail']">
              <a href="{../qui:link[@rel='detail']/@href}">
                <xsl:apply-templates select="." mode="copy-guts" />
                <span class="visually-hidden">
                  <xsl:text> in </xsl:text>
                  <xsl:value-of select="$title" />
                </span>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates select="." mode="copy-guts" />
            </xsl:otherwise>
          </xsl:choose>
        </div>
        <!-- <a href="{../qui:link[@rel='detail']/@href}">Results detail</a> -->
      </div>
    </m-callout>
  </xsl:template>

  <xsl:template match="qui:block[@slot='summary']">
    <div>
      <dt><xsl:value-of select="@label" /></dt>
      <dd>
        <xsl:apply-templates select="." mode="copy-guts" />
      </dd>
    </div>
  </xsl:template>

  <xsl:template match="qui:link" mode="summary">
    <xsl:param name="title" />
    <dd>
      <a href="{@href}">
        <xsl:value-of select="@label" />
        <xsl:if test="@rel = 'toc' and normalize-space($title)">
          <span class="visually-hidden">
            <xsl:text> of </xsl:text>
            <xsl:value-of select="$title" />
          </span>
        </xsl:if>
      </a>
    </dd>
  </xsl:template>

  <xsl:template match="qui:block[@slot='details']">
    <div style="margin-left: 10rem">
      <xsl:apply-templates select="qui:block[@slot='scoping-page']"></xsl:apply-templates>
    </div>
  </xsl:template>

  <xsl:template match="qui:block[@slot='scoping-page']">
    <h4><xsl:apply-templates select="qui:label" mode="copy-guts" /></h4>
    <xsl:apply-templates select="qui:ul" />
  </xsl:template>

  <xsl:template match="qui:block[@slot='scoping-page']/qui:ul">
    <ul class="text-xx-small">
      <xsl:for-each select="qui:li">
        <li class="mb-1">
          <xsl:apply-templates select="." mode="copy-guts" />
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template name="build-extra-portfolio-actions"></xsl:template>

  <xsl:template name="build-portfolio-actions">
    <xsl:apply-templates select="//qui:callout[@slot='portfolio']" />
    <!-- <div class="message-callout info mt-1" style="display: none" id="bookbag-overview"></div> -->
    <xsl:if test="$nav/@subview != 'detail'">
      <div id="bookbag-overview" style="display: none"></div>
      <div class="[ flex flex-align-center ][ mb-1 gap-0_5 ]">
        <button class="[ button button--secondary ] [ flex ]" aria-label="Select all items" data-action="select-all" data-checked="false">
          <span>Select all items</span>
        </button>
        <button class="[ button button--secondary ] [ flex ]" aria-label="Add items to bookbag" data-action="add-items">
          <span class="material-icons" aria-hidden="true">add</span>
          <span>Add items to bookbag</span>
        </button>
        <xsl:call-template name="build-extra-portfolio-actions" />
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-collection-header-string">
    <xsl:variable name="header" select="//qui:header[@role='main']" />
    <xsl:choose>
      <xsl:when test="//qui:metadata[@slot='item']">
        <xsl:value-of select="$header" />
        <xsl:text> / </xsl:text>
        <xsl:value-of select="//qui:metadata[@slot='item']//qui:field[@key='title']//qui:values" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$header" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-breadcrumbs-extra-nav">
    <xsl:apply-templates select="qui:nav[@role='details']" mode="pagination-link" />
  </xsl:template>

  <xsl:template match="qui:nav[@role='details']" mode="pagination-link">
    <xsl:if test="qui:link[not(@disabled)]">
      <p class="[ pagination ][ nowrap ml-2 ]">
        <xsl:if test="qui:link[@rel='previous-item']">
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
          <xsl:apply-templates select="qui:link[@rel='previous-item']" />
        </xsl:if>
        <span>
          <xsl:value-of select="@current" />
          <xsl:text> of </xsl:text>
          <xsl:value-of select="@total" />
        </span>
        <xsl:if test="qui:link[@rel='next-item']">
          <xsl:apply-templates select="qui:link[@rel='next-item']" />
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
        </xsl:if>
      </p>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:message[@id='sort-options']">
    <div class="text--bold">
      <xsl:apply-templates mode="copy" />
    </div>
  </xsl:template>

  <xsl:template match="qui:panel[@slot='guide-frame']">
    <details class="panel mt-2" open="open">
      <summary>Collection</summary>
      <div class="filter-item--list">
        <xsl:apply-templates select="qui:section" />
      </div>
    </details>
  </xsl:template>

  <xsl:template match="qui:panel[@slot='guide-frame']/qui:section">
    <xsl:variable name="href" select="qui:link[@rel='results']/@href" />
    <a class="[ flex filter-item bedazzled-link ][ gap-0_5 mt-0_5 ]" href="{$href}">
      <xsl:if test="@selected = 'selected'">
        <xsl:attribute name="data-selected">true</xsl:attribute>
      </xsl:if>
      <span class="material-icons text-black no-underline" aria-hidden="true" href="{$href}">
        <xsl:choose>
          <xsl:when test="@selected = 'selected'">radio_button_checked</xsl:when>
          <xsl:otherwise>radio_button_unchecked</xsl:otherwise>
        </xsl:choose>
      </span>
      <span>
        <xsl:if test="@selected = 'selected'">
          <xsl:attribute name="style">text-decoration: none !important;</xsl:attribute>
        </xsl:if>
        <span>
          <xsl:value-of select="qui:header" />
        </span>
        <span class="filters__count">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="@data-hit-count" />
          <xsl:text>)</xsl:text>
        </span>
      </span>
    </a>
  </xsl:template>

  <xsl:template match="qui:panel[@slot='guide-frame']/qui:section" mode="v1">
    <xsl:param name="classes" />
    <div class="[ mt-1 ]">
      <p>
        <a class="[ flex flex-start ][ gap-0_25 bedazzled-link ]" href="{qui:link[@rel='home']/@href}">
          <xsl:if test="@selected = 'selected'">
            <xsl:attribute name="style">color: black;</xsl:attribute>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="@icon">
              <span class="material-icons flex-shrink-0" aria-hidden="true"><xsl:value-of select="@icon" /></span>
            </xsl:when>
            <xsl:otherwise>
              <span class="material-icons flex-shrink-0" aria-hidden="true" style="opacity: 0.5">check_box_outline_blank</span>
            </xsl:otherwise>
          </xsl:choose>
          <span><xsl:value-of select="qui:header" /></span>
        </a>  
      </p>
      <p class="text--small text--muted" style="margin-top: 0; margin-left: 1.5rem">
        <xsl:apply-templates select="qui:block[@slot='summary']" mode="copy-guts" />
      </p>
    </div>
    <xsl:if test="false()">
    <div class="[ link-box ][ flex flex-center ][ mt-2 {$classes} ]">
      <a class="[ flex flex-start ][ gap-0_25 bedazzled-link ]" href="{qui:link[@rel='home']/@href}">
        <xsl:choose>
          <xsl:when test="@icon">
            <span class="material-icons flex-shrink-0" aria-hidden="true"><xsl:value-of select="@icon" /></span>
          </xsl:when>
          <xsl:otherwise>
            <span class="material-icons flex-shrink-0" aria-hidden="true" style="opacity: 0.5">check_box_outline_blank</span>
          </xsl:otherwise>
        </xsl:choose>
        <span><xsl:value-of select="qui:header" /></span>
      </a>
    </div>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:metadata[@slot='item']" mode="callout">
    <div calss="mt-1">
      <dl class="record">
        <xsl:apply-templates select="qui:field[@key!='subjects']" />
        <!-- <div>
          <dt>Links</dt>
          <dd>
            <a href="../qui:link[@rel='toc']/@href">Item Information</a>
          </dd>
        </div> -->
      </dl>  
    </div>              
  </xsl:template>

  <xsl:template match="qui:field[@key='bookmark']"></xsl:template>

</xsl:stylesheet>