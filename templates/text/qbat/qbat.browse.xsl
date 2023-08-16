<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />
  <xsl:variable name="sort-options" select="//qui:form[@id='sort-options']" />
  <xsl:variable name="xc" select="//qui:block[@slot='results']/@data-xc" />
  <xsl:variable name="key" select="//qui:block[@slot='results']/@data-key" />
  <xsl:variable name="value" select="//qui:block[@slot='results']/@data-value" />
  <xsl:variable name="has-results" select="//qui:nav[@role='results']/@total &gt; 0" />
  <xsl:variable name="nav" select="//qui:nav[@role='results']" />

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <link rel="stylesheet" href="{$docroot}styles/image/reslist.css" />
    <link rel="stylesheet" href="{$docroot}styles/text/tabs.css" />
    <style>
      .browse-index .button:not([data-selected]) {
        border: 1px solid transparent;
      }
      .browse-index a[disabled] {
        opacity: 0.5;
        pointer-events: none;
        color: var(--color-neutral-300);
      }
    </style>
  </xsl:template>

  <xsl:template name="build-extra-scripts">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.4.0/dist/themes/light.css" />
    <script type="module" src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.4.0/dist/shoelace-autoloader.js"></script>
  </xsl:template>

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
          <xsl:call-template name="build-filters-panel" />
        </xsl:if>
      </div>
      <div class="main-panel">
        <xsl:call-template name="build-browse-navigation" />
        <!-- <xsl:call-template name="build-search-form" /> -->
        <xsl:call-template name="build-results-summary-sort" />
        <!-- <xsl:if test="$has-results">
          <xsl:call-template name="build-portfolio-actions" />
        </xsl:if> -->
        <xsl:call-template name="build-results-list" />
        <xsl:call-template name="build-results-pagination" />
        <!-- <xsl:call-template name="build-hidden-portfolio-form" /> -->
      </div>
    </div>

  </xsl:template>

  <xsl:template name="check-side-actions">
    <xsl:choose>
      <xsl:when test="//qui:filter">true</xsl:when>
      <xsl:when test="//qui:nav[@role='index']">true</xsl:when>
      <xsl:otherwise>false</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-browse-navigation">
    <xsl:if test="//qui:nav[@role='browse']">
      <nav aria-labelledby="maincontent" class="horizontal-navigation-container mb-2">
        <ul class="horizontal-navigation-list">
          <xsl:for-each select="//qui:nav[@role='browse']/qui:link">
            <li>
              <a href="{@href}">
                <xsl:if test="@current = 'true'">
                  <xsl:attribute name="aria-current">page</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="qui:label" />
              </a>
            </li>
          </xsl:for-each>
        </ul>
      </nav>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-results-summary-sort">
    <xsl:call-template name="build-search-tools" />
  </xsl:template>

  <xsl:template name="build-search-summary">
    <div class="search-summary">
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
            <xsl:text> results </xsl:text>
            <xsl:if test="$nav/@is-truncated='true'">
              <span>
                <xsl:text> </xsl:text>
                <a href="?page=help#truncated-results">(truncated)</a>
              </span>
            </xsl:if>
          </h2>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="build-search-summary-body" />
    </div>
  </xsl:template>

  <xsl:template name="build-search-summary-body">
    <p>
      <xsl:text>Browsing items having </xsl:text>
      <strong><xsl:value-of select="dlxs:capitalize($key)" /></strong>
      <xsl:text> starting with </xsl:text>
      <strong><xsl:value-of select="dlxs:capitalize($value)" /></strong>
    </p>
    <xsl:if test="$search-form/qui:control[@slot='clause'][normalize-space(qui:input[@slot='q']/@value)]">
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
      <xsl:if test="false() and $has-results">
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
        <form id="form-results-sort" method="GET" action="/cgi/i/image/image-idx" autocomplete="off" style="display: none">
          <xsl:apply-templates select="$sort-options/qui:hidden-input" />
        </form>        
      </xsl:if>
    </div>
  </xsl:template>

  <xsl:template name="build-filters-panel">
    <xsl:variable name="browse-form" select="//qui:form[@role='browse']" />
    <xsl:if test="false()">
      <h3>Quick Browse</h3>
      <div class="[ side-panel__box ]">
        <form method="GET" action="/cgi/t/text/text-idx">
          <div class="[ flex flex-center gap-0_5 flex-flow-rw ]">
            <xsl:apply-templates select="$browse-form//qui:label" />
            <xsl:apply-templates select="$browse-form//qui:input[@type='text']" />
            <button class="button button--small button--secondary" type="submit">Lookup</button>
          </div>
          <xsl:apply-templates select="$browse-form/qui:input[@type='hidden']" mode="hidden" />
        </form>
      </div>  
    </xsl:if>
    <h3>Index</h3>
    <div class="[ side-panel__box ]">
      <ul class="[ browse-index ][ flex flex-gap-0_5 flex-flow-rw flex-shrink-0 ]">
        <xsl:apply-templates select="//qui:nav[@role='index']/qui:link" mode="index" />
      </ul>
    </div>
    <xsl:if test="//qui:nav[@role='index']/qui:link/qui:link">
      <h4 class="visually-hidden">Secondary Index</h4>
      <ul class="[ browse-index ][ flex flex-gap-0_5 flex-flow-rw flex-shrink-0 ]">
        <xsl:apply-templates select="//qui:nav[@role='index']/qui:link/qui:link" mode="index" />
      </ul>
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:link" mode="index">
    <li style="flex: 1; flex-grow: 0;">
      <xsl:choose>
        <xsl:when test="true() or normalize-space(@href)">
          <a href="{@href}" style="width: 5ch; padding: 0.5em 1em; margin: 0; border-radius: 0;">
            <xsl:attribute name="class">
              <xsl:text>button</xsl:text>
              <xsl:if test="@data-selected = 'true'">
                <xsl:text> button--ghost</xsl:text>
              </xsl:if>
            </xsl:attribute>
            <xsl:if test="not(normalize-space(@href))">
              <xsl:attribute name="disabled">disabled</xsl:attribute>
              <xsl:attribute name="aria-hidden">true</xsl:attribute>
              <xsl:attribute name="tabindex">-1</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@data-selected" mode="copy" />
            <xsl:value-of select="qui:label" />
          </a>    
        </xsl:when>
        <xsl:otherwise>
          <span style="width: 5ch; padding: 0.5em 1em; margin: 0; border-radius: 0;">
            <xsl:attribute name="class">
              <xsl:text>xbutton</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="qui:label" />
          </span>    
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="false() and qui:link">
        <ul class="[ ml-2 ]">
          <xsl:apply-templates select="qui:link" mode="index" />
        </ul>
      </xsl:if>
    </li>
  </xsl:template>

  <xsl:template name="build-portfolio-actions">
    <xsl:apply-templates select="//qui:callout[@slot='portfolio']" />
    <div class="[ flex flex-align-center ][ mb-1 gap-0_5 ]">
      <button class="[ button button--secondary ] [ flex ]" aria-label="Add items to portfolio" data-action="select-all" data-checked="false">
        <span>Select all items</span>
      </button>
      <button class="[ button button--secondary ] [ flex ]" aria-label="Add items to portfolio" data-action="add-items">
        <span class="material-icons" aria-hidden="true">add</span>
        <span>Add items to portfolio</span>
      </button>
      <xsl:call-template name="build-extra-portfolio-actions" />
    </div>
  </xsl:template>

  <xsl:template name="build-results-list">
    <xsl:apply-templates select="//qui:block[@slot='results']/qui:section" mode="result" />
  </xsl:template>

  <xsl:template name="build-results-pagination">
    <xsl:variable name="nav" select="//qui:main/qui:nav[@role='results']" />
    <xsl:if test="$nav/@min &lt; $nav/@max">
      <nav id="pagination" aria-label="Result navigation" class="[ pagination__row ][ flex flex-space-between flex-align-center sticky-bottom ]">
        <div class="pagination__group">
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

          <button id="action-goto-results-page" class="[ button button--secondary ] [ flex ]">
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
      <a class="[ flex ][ flex-grow-1 ]" data-behavior="focus-center">
        <xsl:attribute name="href">
          <xsl:value-of select="$link//@href" />
        </xsl:attribute>
        <xsl:attribute name="data-available">
          <xsl:value-of select="$link//@data-available" />
        </xsl:attribute>

        <xsl:choose>
          <xsl:when test="qui:link[@rel='iiif']">
            <img class="[ results-list__image ]" src="{qui:link[@rel='iiif']/@href}/full/140,/0/native.jpg" alt="{ItemDescription}" />
          </xsl:when>
          <xsl:otherwise>
            <div class="[ results-list__blank ]" aria-hidden="true">
              <xsl:attribute name="data-type">
                <xsl:choose>
                  <xsl:when test="qui:link[@rel='icon']/@type='audio'">
                    <span>volume_up</span>
                  </xsl:when>
                  <xsl:when test="qui:link[@rel='icon']/@type='doc'">
                    <span>description</span>
                  </xsl:when>
                  <xsl:when test="qui:link[@rel='icon']/@type='pdf'">
                    <span>description</span>
                  </xsl:when>
                  <xsl:when test="qui:link[@rel='icon']/@type='restricted'">
                    <span>lock</span>
                  </xsl:when>
                  <xsl:otherwise>blank</xsl:otherwise>
                </xsl:choose>
              </xsl:attribute>
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
      <!-- <xsl:variable name="bb-id" select="generate-id()" />
      <label class="[ portfolio-selection ]" for="bb{$bb-id}">
        <input id="bb{$bb-id}" type="checkbox" name="bbidno" value="{@identifier}" autocomplete="off" />
        <span class="visually-hidden">Add item to portfolio</span>
      </label> -->
    </section>

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

  <xsl:template match="qui:field//qui:link" mode="copy" priority="105">
    <xsl:value-of select="." />
  </xsl:template>

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

  <xsl:template name="build-hidden-portfolio-form">
    <form style="display: none" method="GET" action="/cgi/i/image/image-idx" id="bbaction-form">
      <xsl:apply-templates select="//qui:form[@action='bbaction']/qui:hidden-input" />
      <input type="hidden" name="bbaction" value="" id="bbaction-page" />
    </form>
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

  <xsl:template name="build-extra-portfolio-actions"></xsl:template>

</xsl:stylesheet>
