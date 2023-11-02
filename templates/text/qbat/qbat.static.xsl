<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />

  <xsl:template name="build-extra-styles">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.4.0/dist/themes/light.css" />
    <script type="module" src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.4.0/dist/shoelace-autoloader.js"></script>

    <link rel="stylesheet" href="{$docroot}styles/text/item.css" />

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
      <xsl:if test="//qui:block[@slot='content']//xhtml:h2">
        <div class="[ aside ]">
          <nav class="[ page-index ]" xx-aria-labelledby="page-index-label">
            <h2 id="page-index-label" class="[ subtle-heading ][ text-black js-toc-ignore ]">Page Index</h2>
            <div class="toc js-toc"></div>
            <select id="action-page-index"></select>
          </nav>
        </div>
      </xsl:if>
      <div>
        <xsl:attribute name="class">
          <xsl:text>main-panel</xsl:text>
          <xsl:if test="count(//qui:block[@slot='content']//xhtml:h2) &lt;= 1">
            <xsl:text> full</xsl:text>
          </xsl:if>
        </xsl:attribute>
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

  <xsl:template match="qui:block[@data-current-page='contents']//xhtml:ul" mode="copy">
    <ul>
      <xsl:attribute name="class">list-unstyled</xsl:attribute>
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </ul>
  </xsl:template>

  <xsl:template match="qui:block[@data-current-page='contents']//xhtml:ul//xhtml:li" mode="copy">
    <li>
      <xsl:attribute name="class">mb-1</xsl:attribute>
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </li>
  </xsl:template>

  <xsl:template match="qui:block[@data-current-page='contents']//xhtml:img[@class='badge']" mode="copy" priority="101" />

</xsl:stylesheet>