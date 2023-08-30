<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <!-- search form -->
  <xsl:template name="build-advanced-search-form">

    <div class="[ mb-2 ]">
      <xsl:call-template name="build-breadcrumbs" />
      <xsl:call-template name="build-collection-heading" />

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
    </div>
    <div class="advanced-search--form">

      <form id="collection-search" action="/cgi/t/text/text-idx" method="GET" autocomplete="off" data-num-qs="{$search-form/@data-num-qs}">
        <h2 class="subtle-heading">Fielded Search Options</h2>
        <div class="message-callout info">
          <xsl:apply-templates select="//qui:callout[@slot='clause']" mode="copy-guts" />
        </div>

        <xsl:choose>
          <xsl:when test="$view = 'simple'">
            <xsl:call-template name="build-simple-form" />
          </xsl:when>
          <xsl:when test="$view = 'boolean'">
            <xsl:call-template name="build-boolean-form" />
          </xsl:when>
          <xsl:when test="$view = 'proximity'">
            <xsl:call-template name="build-boolean-form" />
          </xsl:when>
          <xsl:when test="$view = 'bib'">
            <xsl:call-template name="build-bib-form" />
          </xsl:when>
        </xsl:choose>

        <xsl:if test="$view != 'bib'">
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
      <xsl:if test="true() or @data-name != 'q1'">
        <button type="button" class="[ button button--secondary ]" data-action="reset-clause">Clear</button>
      </xsl:if>
    </fieldset>
  </xsl:template>

  <xsl:template match="qui:select[@slot='region']">
    <label for="{@name}-{position()}" class="visually-hidden">Select a field:</label>
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
    </input>
  </xsl:template>
 
  <xsl:template match="qui:select">
    <xsl:param name="name" select="@name" />
    <label for="{$name}-{position()}" class="visually-hidden"><xsl:value-of select="@label" /></label>
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
    <button type="submit" class="[ button button--cta ]">
      <svg xmlns="http://www.w3.org/2000/svg" width="16px" height="16px" viewBox="0 0 24 24" aria-hidden="true" fill="inherit" focusable="false" role="img">
        <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"></path>
      </svg>
      <span>Advanced Search</span>
    </button>
    <button type="button" class="[ button button--secondary ]" data-action="reset-form">
      <span>Clear all</span>
    </button>
  </xsl:template>

</xsl:stylesheet>