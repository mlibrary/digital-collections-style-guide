<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />

  <xsl:template name="build-extra-styles">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.4.0/dist/themes/light.css" />
    <script type="module" src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.4.0/dist/shoelace-autoloader.js"></script>
    <link rel="stylesheet" href="{$docroot}styles/text/tabs.css" />

    <!-- <link rel="stylesheet" href="{$docroot}styles/text/item.css" /> -->

    <style>
      h2 {
        font-size: 1.25rem;
      }

      .float-right {
        float: right;
        margin: 1rem;
      }
        
      
      .float-right img, img.float-right {
        padding: 1rem;
        border: 1px solid var(--color-neutral-100);
      }

      .float-right figcaption {
        font-size: 0.875rem;
        max-width: 20ch;
      }

    </style>
  </xsl:template>

  <xsl:template match="qui:main">
    <div class="[ mb-2 ]">
      <xsl:call-template name="build-breadcrumbs" />
      <xsl:call-template name="build-collection-heading" />
    </div>

    <div class="[ flex flex-flow-rw flex-gap-1 ][ aside--wrap ]">
      <xsl:if test="//qui:nav[@role='browse']">
        <div class="[ side-panel ]"></div>
      </xsl:if>
      <xsl:if test="//qui:block[@slot='content']//xhtml:h2 or //qui:nav[@rel='pages']">
        <div class="[ aside ]">
          <nav class="[ page-index ]" xx-aria-labelledby="page-index-label">
            <h2 id="page-index-label" class="[ subtle-heading ][ text-black js-toc-ignore ]">Page Index</h2>
            <div class="toc js-toc"></div>
            <select id="action-page-index"></select>
            <xsl:apply-templates select="//qui:nav[@rel='pages']" />
          </nav>
        </div>
      </xsl:if>
      <div>
        <xsl:attribute name="class">
          <xsl:text>main-panel</xsl:text>
          <xsl:if test="
            count(//qui:block[@slot='content']//xhtml:h2) &lt; 1
            and
            not(//qui:nav[@rel='pages'])
            and
            not(//qui:nav[@role='browse'])">
            <xsl:text> full</xsl:text>
          </xsl:if>
        </xsl:attribute>
        <xsl:call-template name="build-browse-navigation" />
        <div class="text-block">
          <xsl:apply-templates select="//qui:block[@slot='content']">
            <!-- <xsl:with-param name="classes">[ viewport-narrow ]</xsl:with-param> -->
          </xsl:apply-templates>
        </div>
        <xsl:call-template name="build-search-form" />
      </div>
    </div>

  </xsl:template>

  <xsl:template match="qui:block[@data-current-page='contents']//xhtml:section" mode="copy">
    <section>
      <xsl:attribute name="class">border-bottom pb-1 mb-2</xsl:attribute>
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </section>
  </xsl:template>

  <xsl:template match="qui:block[@data-current-page='contents']//xhtml:ul[@class='list-tree']//xhtml:details" mode="copy">
    <details>
      <xsl:attribute name="class">tree</xsl:attribute>
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </details>
  </xsl:template>

  <xsl:template match="qui:block[@data-current-page='contents']//xhtml:details" mode="copy">
    <details>
      <xsl:attribute name="class">panel w-100</xsl:attribute>
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </details>
  </xsl:template>

  <xsl:template match="qui:block[@data-current-page='contents']//xhtml:details/xhtml:div" mode="copy">
    <div>
      <xsl:attribute name="class">pl-1</xsl:attribute>
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </div>
  </xsl:template>

  <xsl:template match="qui:block[@data-current-page]//xhtml:ul[@class='list-tree']" mode="copy" priority="101">
    <div class="mb-1 flex flex-flow-row">
      <button class="button button--small button--secondary" data-action="expand-all">
        <span class="material-icons" aria-hidden="true">add</span>
        <span>Expand All</span>
      </button>
      <button class="button button--small button--secondary" data-action="collapse-all">
        <span class="material-icons" aria-hidden="true">remove</span>
        <span>Collapse All</span>
      </button>
    </div>
    <ul class="list-tree">
      <xsl:apply-templates mode="copy" />
    </ul>
  </xsl:template>

  <xsl:template match="qui:block[@data-current-page='contents']//xhtml:ul" mode="copy">
    <ul>
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="@class">
            <xsl:value-of select="@class" />
          </xsl:when>
          <xsl:otherwise>list-unstyled</xsl:otherwise>
        </xsl:choose>  
      </xsl:attribute>
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </ul>
  </xsl:template>

  <xsl:template match="qui:block[@data-current-page='contents']//xhtml:ul//xhtml:li" mode="copy">
    <li>
      <!-- <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="@class"><xsl:value-of select="@class" /></xsl:when>
          <xsl:otherwise>mb-1</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute> -->
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </li>
  </xsl:template>

  <xsl:template match="qui:block[@data-current-page='contents']//xhtml:img[@class='badge']" mode="copy" priority="101" />

  <xsl:template match="qui:nav[@rel='pages']">
    <div class="page-navigation">
      <h2 class="subtle-heading mt-1 text-black">
        <xsl:choose>
          <xsl:when test="qui:header">
            <xsl:value-of select="qui:header" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Page Index</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </h2>
      <xsl:apply-templates select="qui:ul" />  
    </div>
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
    
</xsl:stylesheet>