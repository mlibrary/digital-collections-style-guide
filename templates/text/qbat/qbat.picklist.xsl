<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />
  <xsl:variable name="sort-options" select="//qui:form[@id='sort-options']" />
  <xsl:variable name="xc" select="//qui:block[@slot='results']/@data-xc" />
  <xsl:variable name="key" select="//qui:block[@slot='results']/@data-key" />
  <xsl:variable name="value" select="//qui:block[@slot='results']/@data-value" />
  <xsl:variable name="is-selectable" select="count(//qui:block[@slot='results']//qui:section[@type='item']) &gt; 0" />
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
          <xsl:call-template name="build-filters-panel" />
        </xsl:if>
      </div>
      <div class="main-panel">
        <xsl:call-template name="build-browse-navigation" />
        <!-- <xsl:call-template name="build-search-form" /> -->
        <xsl:call-template name="build-results-summary-sort" />
        <xsl:if test="false() and $is-selectable">
          <xsl:call-template name="build-portfolio-actions" />
        </xsl:if>
        <xsl:call-template name="build-results-list" />
        <!-- <xsl:call-template name="build-results-pagination" /> -->
        <xsl:call-template name="build-hidden-portfolio-form" />
      </div>
    </div>

  </xsl:template>

  <xsl:template name="check-side-actions">
    <xsl:choose>
      <xsl:when test="//qui:filter">true</xsl:when>
      <xsl:when test="//qui:nav[@role='index'][.//qui:link]">true</xsl:when>
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
      <xsl:choose>
        <xsl:when test="normalize-space($value)">
          <xsl:text>Browsing items having </xsl:text>
          <strong><xsl:value-of select="dlxs:capitalize($key)" /></strong>      
          <xsl:text> starting with </xsl:text>
          <strong><xsl:value-of select="dlxs:capitalize($value)" /></strong>  
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Browsing items by </xsl:text>
          <strong><xsl:value-of select="dlxs:capitalize($key)" /></strong>      
        </xsl:otherwise>
      </xsl:choose>
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
      <!-- <xsl:call-template name="build-search-summary" /> -->
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
        <form id="form-results-sort" method="GET" action="/cgi/t/text/text-idx" autocomplete="off" style="display: none">
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
      <div class="[ side-panel__box ]">
        <ul class="[ browse-index ][ flex flex-gap-0_5 flex-flow-rw flex-shrink-0 ]">
          <xsl:apply-templates select="//qui:nav[@role='index']/qui:link/qui:link" mode="index" />
        </ul>
      </div>
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
    <!-- <div class="message-callout info mt-1" style="display: none" id="bookbag-overview"></div> -->
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
  </xsl:template>

  <xsl:template name="build-results-list">
    <xsl:apply-templates select="//qui:block[@slot='results']" mode="result" />
  </xsl:template>

  <xsl:template match="qui:block[qui:tag]" mode="result">
    <ul class="list--striped">
      <xsl:apply-templates mode="result" />
    </ul>
  </xsl:template>

  <xsl:template match="qui:block" mode="result">
    <xsl:apply-templates mode="result" />
  </xsl:template>

  <xsl:template match="qui:tag" mode="result">
    <li>
      <a 
        class="flex flex-space-between flex-align-center"
        href="{@href}">
        <span><xsl:value-of select="." /></span>
        <span><xsl:value-of select="@count" /></span>
      </a>
    </li>
  </xsl:template>

  <xsl:template match="qui:section[@type='volume']" mode="result" priority="10">
    <section class="[ results-list--grid ]" id="{@identifier}">
      <div class="[ results-list__blank ]" aria-hidden="true" data-type="inventory_2">
      </div>
      <div class="[ results-card ]">
        <div class="results-list__content flex flex-flow-column flex-grow-1">
          <h3>
            <a href="{qui:link[@rel='volume']/@href}" class="results-link">
              <xsl:apply-templates select="qui:header/qui:title" mode="title" />
            </a>
          </h3>
        </div>
      </div>
      <div class="results-details">
        <dl class="[ results ]">
          <div>
            <dt>Issues</dt>
            <xsl:for-each select="qui:section[@type='issue']">
              <dd>
                <a href="{qui:link/@href}">
                  <xsl:apply-templates select="qui:header/qui:title" mode="title" />
                </a>
              </dd>
            </xsl:for-each>
          </div>
        </dl>
      </div>
    </section>
  </xsl:template>

  <xsl:template match="qui:section[@type='item']" mode="result">
    <section class="[ results-list--grid ]">
      <!-- <xsl:variable name="link" select="qui:link[@rel='result']" /> -->
      <xsl:variable name="link-href">
        <xsl:choose>
          <xsl:when test="qui:metadata/@data-tombstone = 'true'">
            <!-- this should not be a link -->
          </xsl:when>
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
            <xsl:apply-templates select="qui:metadata[@slot='metadata']//qui:field[@key='title']" mode="title" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="qui:metadata/@data-tombstone='true'">
          <div class="[ results-list__blank ]" aria-hidden="true" data-type="blank"></div>
        </xsl:when>
        <xsl:when test="@access = 'restricted'">
          <div class="[ results-list__blank ]" aria-hidden="true" data-type="blank"></div>
        </xsl:when>
        <xsl:when test="qui:link[@rel='iiif']">
          <img class="[ results-list__image ]" loading="lazy" src="{qui:link[@rel='iiif']/@href}" aria-hidden="true" alt="" />
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
      <div class="results-card">
        <div class="results-list__content flex flex-flow-column flex-grow-1">
          <h3>
            <xsl:choose>
              <xsl:when test="normalize-space($link-href)">
                <a href="{$link-href}" class="results-link">
                  <xsl:value-of select="$link-title" />
                </a>    
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$link-title" />
              </xsl:otherwise>
            </xsl:choose>
          </h3>
        </div>
      </div>
      <div class="results-details">
        <xsl:choose>
          <xsl:when test="@access = 'restricted'">
            <m-callout variant="warning" icon="warning">
              <xsl:value-of select="key('get-lookup', 'results.str.9')" />
            </m-callout>
          </xsl:when>
          <xsl:when test="@access != 'fullaccessallowed'">
            <xsl:variable name="key" select="concat('header.str.', @access)" />
            <m-callout variant="warning" icon="warning">
              <xsl:value-of select="key('get-lookup', $key)" />
            </m-callout>
          </xsl:when>
        </xsl:choose>
        <dl class="[ results ]">
          <!-- <xsl:apply-templates select="qui:collection" /> -->
          <xsl:apply-templates select="qui:metadata[@slot='metadata']//qui:field" />
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
        <xsl:call-template name="build-tombstone-notification" />
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

  <xsl:template match="qui:field[@key='title']" priority="99">
    <xsl:choose>
      <xsl:when test="//qui:block[@slot='item']">
        <xsl:apply-templates select="." mode="build" />
      </xsl:when>
    </xsl:choose>
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
	<li>Use fewer words, especially when searching names -- this is an exact search and names appear many ways</li>
	<li>Check your spelling</li>
	<li>Try the Search Options to find two or three words</li>
    </ul>
  </xsl:template>

  <xsl:template match="qui:label[@for='input-value']">
    <label class="text-muted text-xx-small flex--wide" style="margin-bottom: -0.5rem">
      <xsl:apply-templates select="." mode="copy-guts" />
    </label>
  </xsl:template>

  <xsl:template name="build-extra-portfolio-actions"></xsl:template>

  <xsl:template match="*[qui:values]" mode="title">
    <xsl:for-each select="qui:values/qui:value">
      <xsl:value-of select="." />
      <xsl:if test="position() &lt; last()">
        <xsl:text>: </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="qui:field[@key='title']" priority="99">
    <xsl:choose>
      <xsl:when test="//qui:block[@slot='item']">
        <xsl:apply-templates select="." mode="build" />
      </xsl:when>
    </xsl:choose>
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

</xsl:stylesheet>
