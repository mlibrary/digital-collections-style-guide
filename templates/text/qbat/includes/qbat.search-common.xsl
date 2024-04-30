<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <!-- search form -->
  <xsl:template name="build-advanced-search">
    <div class="[ mb-2 ]">
      <xsl:call-template name="build-breadcrumbs" />
      <xsl:call-template name="build-collection-heading" />

      <xsl:call-template name="build-advanced-search-form-tabs" />
    </div>
    <xsl:call-template name="build-advanced-search-form" />
  </xsl:template>

  <xsl:template name="build-advanced-search-form-tabs">
    <xsl:if test="//qui:nav[@role='search']">
      <nav aria-label="Advanced Search Options" class="horizontal-navigation-container mb-2">
        <ul class="horizontal-navigation-list">
          <xsl:for-each select="//qui:nav[@role='search']/qui:link">
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

  <xsl:template name="build-advanced-search-form">

    <xsl:apply-templates select="//qui:callout[@slot='restriction']" />

    <div class="advanced-search--form">

      <form id="collection-search" action="/cgi/t/text/text-idx" method="GET" autocomplete="off" data-num-qs="{$search-form/@data-num-qs}">

        <xsl:if test="$search-form/qui:fieldset[@slot='collids']">
          <xsl:call-template name="build-collection-selection" />
        </xsl:if>

        <xsl:if test="not(contains($view, 'bbag'))">
        <h2 class="subtle-heading">Fielded Search Options</h2>
        <div class="message-callout info">
          <xsl:apply-templates select="//qui:callout[@slot='clause']" mode="copy-guts" />
        </div>
        </xsl:if>

        <xsl:choose>
          <xsl:when test="contains($view, 'simple')">
            <xsl:call-template name="build-simple-form" />
          </xsl:when>
          <xsl:when test="$view = 'bbaglist'">
            <xsl:call-template name="build-simple-form" />            
          </xsl:when>
          <xsl:when test="contains($view, 'boolean')">
            <xsl:call-template name="build-boolean-form" />
          </xsl:when>
          <xsl:when test="contains($view, 'proximity')">
            <xsl:call-template name="build-proximity-form" />
          </xsl:when>
          <xsl:when test="$view = 'bib'">
            <xsl:call-template name="build-bib-form" />
          </xsl:when>
        </xsl:choose>

        <xsl:if test="$view != 'bib' and not(contains($view, 'bbag'))">
          <h3>Additional Search Options</h3>
        
          <div class="advanced-search--containers">
            <div class="field-groups" style="xxpadding: 0.5rem">
              <xsl:apply-templates select="$search-form/qui:fieldset[@slot='restriction-cite']" />
            </div>
          </div>
  
          <xsl:for-each select="$search-form/qui:fieldset[@slot='restriction']">
            <div class="advanced-search--containers">
              <div class="field-groups" style="xxpadding: 0.5rem">
                <xsl:apply-templates select="." />
              </div>
            </div>
          </xsl:for-each>  
        </xsl:if>

        <!-- <xsl:apply-templates select="$search-form/qui:fieldset[@slot='restriction']" /> -->

        <xsl:apply-templates select="$search-form/qui:hidden-input" />

        <input type="hidden" name="view" value="reslist" />

        <xsl:call-template name="build-form-actions" />

      </form>
    </div>
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='restriction-cite']">
    <h4 style="margin: 0; padding: 0 1rem;">Limit to:</h4>
    <xsl:for-each select="qui:fieldset">
      <fieldset class="[ no-border ][ fieldset--grid ]">
        <div class="[ fieldset--clause--region ]">
          <xsl:apply-templates select="qui:select[@slot='region']" />
        </div>
        <div class="[ fieldset--clause--select flex flex-align-center ]">
          <span style="padding: 0rem 1rem; font-weight: bold;">matches the expression</span>
        </div>
          <div class="[ fieldset--clause--query ]">
          <xsl:apply-templates select="qui:input[@slot='query']" />
        </div>
      </fieldset>
      <xsl:if test="position() &lt; last()">
        <div style="padding: 0rem 1rem; margin: 0rem; text-align: center;">AND</div>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='restriction'][@class='range']">
    <fieldset class="[ no-border ][ xx-fieldset--grid ]">
      <legend style="font-weight: bold; margin-bottom: 1rem;"><xsl:value-of select="qui:legend" /></legend>
      <div style="display: flex; gap: 1rem; align-items: center;">
        <xsl:apply-templates select="qui:select[1]" />
        <span>and</span>
        <xsl:apply-templates select="qui:select[2]" />
      </div>
    </fieldset>
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='clause']">
    <xsl:call-template name="build-fieldset-clause" />
  </xsl:template>

  <xsl:template name="build-fieldset-clause">
    <xsl:apply-templates select="qui:select[@slot='op']" mode="radio" />
    <fieldset class="[ no-border ][ fieldset--grid ]" data-index="{substring(@data-name, 2)}">
      <legend class="visually-hidden">Search Terms</legend>
      <div class="[ fieldset--clause--region ]">
        <xsl:apply-templates select="qui:select[@slot='region']" />
      </div>
      <div class="[ fieldset--clause--select flex flex-align-center ]">
        <!-- <xsl:apply-templates select="qui:select[@slot='select']" /> -->
        <span style="padding: 0rem 1rem; font-weight: bold;">matches the expression</span>
      </div>
      <div class="[ fieldset--clause--query ]">
        <xsl:apply-templates select="node()[@slot='query']" />
      </div>
      <xsl:if test="false() or @data-name != 'q1'">
        <button type="button" class="[ button button--secondary ]" data-action="reset-clause">Clear</button>
      </xsl:if>
    </fieldset>
  </xsl:template>

  <xsl:template match="qui:select[@slot='region']">
    <label for="{@name}-{position()}" class="visually-hidden">Select a field:</label>
    <xsl:apply-templates select="." mode="build-select" />
  </xsl:template>

  <xsl:template match="qui:select[@slot='region']" mode="build-select">
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

  <xsl:template match="qui:input[@slot='query']">
    <label for="{@name}" class="visually-hidden">Search</label>
    <input name="{@name}" id="{@name}" value="{@value}" type="search" autocomplete="off" placeholder="Enter search terms" data-slot="query" data-active="{@data-active}">
      <xsl:if test="@data-active='false'">
        <xsl:attribute name="disabled">disabled</xsl:attribute>
      </xsl:if>
      <xsl:if test="@required">
        <xsl:attribute name="required">required</xsl:attribute>
      </xsl:if>
    </input>
  </xsl:template>
 
  <xsl:template match="qui:select">
    <xsl:param name="name" select="@name" />
    <label for="{$name}-{position()}" class="visually-hidden"><xsl:value-of select="@label" /></label>
    <select class="[ dropdown--neutral ]" name="{@name}" id="{@name}-{position()}" autocomplete="off">
      <xsl:for-each select="qui:option">
        <xsl:apply-templates select="." />
      </xsl:for-each>
    </select>
  </xsl:template>

  <xsl:template match="qui:option">
    <option value="{@value}">
      <xsl:if test="@selected = 'true'">
        <xsl:attribute name="selected">true</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="." />
    </option>
  </xsl:template>

  <xsl:template match="qui:select[@slot='op']" mode="radio">
    <xsl:variable name="name" select="@name" />
    <xsl:variable name="position" select="1" />
    <fieldset class="[ center-grid ][ no-border ][ fieldset--clause--operator ]">
      <legend class="visually-hidden">Boolean operators</legend>
      <xsl:for-each select="qui:option">
        <label class="radio-buttons" for="{$name}-{$position}-{@value}">
          <input type="radio" id="{$name}-{$position}-{@value}" name="{$name}" value="{@value}">
            <xsl:if test="@selected = 'true'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
          </input>
          <span><xsl:value-of select="." /></span>
        </label>
      </xsl:for-each>
    </fieldset>
  </xsl:template>

  <xsl:template name="build-form-actions">
    <div class="flex flex-align-center gap-1">
      <button type="submit" class="[ button button--cta ]">
        <svg xmlns="http://www.w3.org/2000/svg" width="16px" height="16px" viewBox="0 0 24 24" aria-hidden="true" fill="inherit" focusable="false" role="img">
          <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"></path>
        </svg>
        <span>Advanced Search</span>
      </button>
      <button type="button" class="[ button button--secondary ]" data-action="reset-form">
        <span>Clear all</span>
      </button>  
    </div>
  </xsl:template>

  <xsl:template match="qui:callout[@slot='restriction']" priority="100">
    <div class="xx-message-callout xx-info mt-1">
      <div></div>
      <div>
        <h2 class="subtle-heading text-black"><xsl:value-of select="qui:header" /></h2>
        <dl class="record">
          <xsl:apply-templates select="qui:block[@slot='metadata']/qui:section/qui:field[@key!='subjects']" />
        </dl>  
      </div>
    </div>
  </xsl:template>

  <xsl:template match="qui:field">
    <div>
      <dt><xsl:value-of select="qui:label" /></dt>
      <xsl:for-each select="qui:values/qui:value">
        <dd><xsl:value-of select="." /></dd>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template name="build-collection-selection">
    <h2 class="subtle-heading">Filter by Collection Options</h2>
    <div class="message-callout info">
      <p>
        <xsl:apply-templates select="//qui:callout[@slot='collids']" mode="copy-guts" />
      </p>
    </div>
    <div class="advanced-search--containers">
      <details class="panel">
        <!-- open this if not all the collections are checked -->
        <xsl:if test="//qui:fieldset[@slot='collids']/qui:option[not(@checked)]">
          <xsl:attribute name="open">open</xsl:attribute>
        </xsl:if>
        <summary class="summary--neutral">
          <span>
            <xsl:text>Select collections from the </xsl:text>
            <em>
              <xsl:value-of select="//qui:header[@role='group']" />
            </em>
            <xsl:text> group</xsl:text>
          </span>
        </summary>
        <div>
          <p style="font-size: 0.875rem">
            Select one or more collections to search.
            Follow the collection link <span class="material-icons" aria-hidden="true" style="vertical-align: bottom">link</span> to search that 
            just that collection.
          </p>
          <div class="[ flex ][ flex-gap-0_5 ]">
            <button class="button button--small button--secondary" data-action="select-all-collid">Select All</button>
            <button class="button button--small button--secondary" data-action="clear-all-collid">Clear All</button>
          </div>
          <ul>
            <xsl:for-each select="//qui:fieldset[@slot='collids']/qui:option">
              <xsl:if test="normalize-space(.)">
                <xsl:apply-templates select=".">
                  <xsl:with-param name="idx" select="position()" />
                </xsl:apply-templates>
              </xsl:if>
            </xsl:for-each>
          </ul>
          <xsl:apply-templates select="//qui:fieldset[@slot='collids']/qui:option[@type='hidden']" mode="hidden" />
        </div>
      </details>
    </div>

  </xsl:template>  

  <xsl:template match="qui:fieldset[@slot='collids']/qui:option[@type='hidden']" mode="hidden">
    <input type="hidden" name="c" value="{@collid}" />
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='collids']/qui:option[@type='hidden']" priority="100" />

  <xsl:template match="qui:fieldset[@slot='collids']/qui:option">
    <xsl:param name="idx" select="position()" />
    <li>
      <div class="[ flex ][ flex-gap-0_5 ]" style="align-items: center; padding: 0.25rem; border: 1px solid var(--color-blue-200); margin-bottom: 0.5rem">
        <input type="checkbox" name="c" value="{@value}" id="c-{$idx}">
          <xsl:if test="@checked='checked'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input>
        <label for="c-{$idx}" style="display: flex; gap: 0.25rem; flex-grow: 1; justify-content: space-between; align-items: center">
          <xsl:value-of select="." />
          <a href="{@data-href}" style="display: block; color: var(--color-teal-500)">
            <span class="visually-hidden">Open the <xsl:value-of select="." /> Collection</span>
            <span class="material-icons" aria-hidden="true" style="font-size: 2.5rem">link</span>
          </a>
        </label>
      </div>
    </li>
  </xsl:template>

</xsl:stylesheet>