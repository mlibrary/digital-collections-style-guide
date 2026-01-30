<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />
  <xsl:variable name="template" select="//qui:root/@template" />
  <xsl:variable name="view" select="//qui:root/@view" />

  <xsl:template match="qui:main">
    <div class="[ mb-2 ]">
      <xsl:call-template name="build-navigation" />
      <xsl:call-template name="build-collection-heading" />
    </div>

    <div class="[ flex flex-flow-rw ][ aside--wrap ]">
      <div class="[ aside ]">
        <xsl:if test="$view != 'bbagemail'">
          <nav class="[ page-index ]" xx-aria-labelledby="page-index-label">
            <h2 id="page-index-label" class="[ subtle-heading ][ text-black js-toc-ignore ]">Page Index</h2>
            <div class="toc js-toc"></div>
            <label class="visually-hidden" for="action-page-index">Jump to section:</label>
            <select id="action-page-index"></select>
          </nav>  
        </xsl:if>
      </div>

      <div class="main-panel">
        <xsl:choose>
          <xsl:when test="$view = 'bbagemail'">
            <xsl:call-template name="build-bookbag-email-form" />
          </xsl:when>
          <xsl:when test="$template = 'bookbag'">
            <xsl:call-template name="build-bookbag-list" />
          </xsl:when>
        </xsl:choose>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="build-navigation">
    <xsl:call-template name="build-breadcrumbs" />
  </xsl:template>

  <xsl:template name="build-bookbag-list">

    <div class="[ mb-2 ]">
      <xsl:apply-templates select="//qui:block[@slot='overview']" mode="copy-guts" />
    </div>

    <xsl:if test="$search-form">
      <div class="[ mb-2 ]">
        <h2 class="[ subtle-heading ][ text-black ]">Search Bookbag Items</h2>
        <xsl:call-template name="build-advanced-search-form-tabs" />
      </div>
      <xsl:call-template name="build-advanced-search-form" />
    </xsl:if>
    
    <xsl:apply-templates select="qui:block[@slot='actions']" />  

    <div class="[ mb-2 ]">
      <h2 class="[ subtle-heading ][ text-black ]">Bookbag Items</h2>
      <xsl:choose>
        <xsl:when test="//qui:block[@slot='items']/qui:section">
          <xsl:call-template name="build-portfolio-actions" />
          <xsl:apply-templates select="//qui:block[@slot='items']/qui:section" mode="result">
            <xsl:with-param name="mode">full</xsl:with-param>
          </xsl:apply-templates>  
        </xsl:when>
        <xsl:otherwise>
          <div class="alert-info">
            <p>You have no items in your bookbag.</p>
          </div>
        </xsl:otherwise>
      </xsl:choose>
    </div>

    <xsl:call-template name="build-hidden-portfolio-form">
      <xsl:with-param name="target" select="_top" />
    </xsl:call-template>

  </xsl:template>

  <xsl:template name="build-bookbag-email-form">
    <div class="[ mb-2 ]">
      <h2 class="[ subtle-heading ][ text-black ]">Email Citations</h2>
      <xsl:apply-templates select="qui:form[@name='email']" mode="email" />
    </div>
  </xsl:template>

  <xsl:template match="qui:form" mode="email">
    <form name="{@name}" action="{@href}" method="GET">
      <xsl:apply-templates select="qui:hidden-input" />
      <xsl:apply-templates select="qui:form-control" />
      <div>
        <xsl:call-template name="button">
          <xsl:with-param name="label">
            <xsl:value-of select="qui:input[@type='submit']/@value" />
          </xsl:with-param>
          <xsl:with-param name="icon" select="'email'" />
          <xsl:with-param name="classes">button--secondary</xsl:with-param>
          <xsl:with-param name="type">submit</xsl:with-param>
        </xsl:call-template>
      </div>
      <input type="hidden" name="bbaction" value="email" />
    </form>
  </xsl:template>

  <xsl:template match="qui:form-control">
    <div class="flex gap-0_25 mb-1 flex-flow-column">
      <xsl:variable name="id" select="generate-id()" />
      <label for="ix{$id}"><xsl:value-of select="qui:label" /></label>
      <input type="text" name="email" id="ix{$id}" />
    </div>
  </xsl:template>

  <xsl:template match="qui:section" mode="result">
    <section class="[ results-list--grid ]">
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
            <xsl:apply-templates select="qui:metadata[@slot='item']//qui:field[@key='title']" mode="title" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>

      <xsl:choose>
        <xsl:when test="qui:link[@rel='iiif']">
          <img loading="lazy" class="[ results-list__image ]" src="{qui:link[@rel='iiif']/@href}" aria-hidden="true" alt="" />
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
          <h3 class="js-toc-ignore">
            <a href="{$link-href}" class="results-link">
              <xsl:value-of select="$link-title" />
            </a>
          </h3>
        </div>
      </div>
      <div class="results-details">
          <dl class="[ results ]">
            <!-- <xsl:apply-templates select="qui:collection" /> -->
            <xsl:apply-templates select="qui:metadata[@slot='item']//qui:field" />
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

      <xsl:variable name="bb-id" select="generate-id()" />
      <label class="[ portfolio-selection ]" for="bb{$bb-id}">
        <input id="bb{$bb-id}" type="checkbox" name="bbidno" value="{concat(@bcc, '/', @identifier)}" autocomplete="off" />
        <span class="visually-hidden">Remove item from bookbag</span>
      </label>  
    </section> 
  </xsl:template>

  <xsl:template name="build-portfolio-actions">
    <xsl:apply-templates select="//qui:callout[@slot='portfolio']" />
    <!-- <div class="message-callout info mt-1" style="display: none" id="bookbag-overview"></div> -->
    <div id="bookbag-overview" style="display: none"></div>
    <div class="[ flex flex-align-center ][ mb-1 gap-0_5 ]">
      <button class="[ button button--secondary ] [ flex ]" aria-label="Select all items" data-action="select-all" data-checked="false">
        <span>Select all items</span>
      </button>
      <button class="[ button button--secondary ] [ flex ]" aria-label="Remove items to bookbag" data-action="remove-items">
        <span class="material-icons" aria-hidden="true">remove</span>
        <span>Remove items from bookbag</span>
      </button>
    </div>
  </xsl:template>

  <xsl:template match="qui:block[@slot='actions']">
    <div class="[ actions ][ actions--toolbar-wrap ]">
      <h2 class="[ subtle-heading ][ text-black ]" id="actions">Actions</h2>
      <div class="[ toolbar ]">
        <xsl:apply-templates select="qui:form[@name='email']" mode="action" />
        <xsl:apply-templates select="qui:form[@name='download']" mode="action" />
      </div>
    </div>
  </xsl:template>

  <xsl:template match="qui:form" mode="action">
    <form name="{@name}" method="GET" action="{@href}">
      <xsl:apply-templates select="qui:hidden-input" />
      <xsl:call-template name="button">
        <xsl:with-param name="label">
          <xsl:value-of select="qui:input[@type='submit']/@value" />
        </xsl:with-param>
        <xsl:with-param name="icon" select="@rel" />
        <xsl:with-param name="classes">button--secondary</xsl:with-param>
        <xsl:with-param name="type">submit</xsl:with-param>
      </xsl:call-template>
    </form>
  </xsl:template>

  <xsl:template name="build-form-actions">
    <button type="submit" class="[ button button--cta ]">
      <svg xmlns="http://www.w3.org/2000/svg" width="16px" height="16px" viewBox="0 0 24 24" aria-hidden="true" fill="inherit" focusable="false" role="img">
        <path d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"></path>
      </svg>
      <span>Search</span>
    </button>
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
    <xsl:choose>
      <xsl:when test="//qui:block[@slot='item']">
        <xsl:apply-templates select="." mode="build" />
      </xsl:when>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>