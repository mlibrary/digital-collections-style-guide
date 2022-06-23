<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />

  <xsl:template name="build-extra-styles">
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.64/dist/themes/light.css" />
    <script type="module" src="https://cdn.jsdelivr.net/npm/@shoelace-style/shoelace@2.0.0-beta.64/dist/shoelace.js"></script>

    <link rel="stylesheet" href="{$docroot}styles/image/entry.css" />

    <style>
      h2 {
        font-size: 1.25rem;
      }
    </style>
  </xsl:template>

  <xsl:template match="qui:main">
    <div class="[ mb-2 ]">
      <xsl:call-template name="build-breadcrumbs" />
      <xsl:call-template name="build-collection-heading" />
    </div>

    <div class="[ flex flex-flow-rw flex-gap-1 ][ aside--wrap ]">
      <xsl:if test="//qui:block[@slot='content']//h2">
        <div class="[ aside ]">
          <nav class="[ page-index ]" xx-aria-labelledby="page-index-label">
            <h2 id="page-index-label" class="[ subtle-heading ][ text-black js-toc-ignore ]">Page Index</h2>
            <div class="toc js-toc"></div>
            <select id="action-page-index"></select>
          </nav>
        </div>
      </xsl:if>
      <div class="main-panel full">
        <div class="text-block">
          <xsl:apply-templates select="//qui:block[@slot='content']">
            <!-- <xsl:with-param name="classes">[ viewport-narrow ]</xsl:with-param> -->
          </xsl:apply-templates>
        </div>
        <xsl:call-template name="build-search-form" />
      </div>
    </div>

  </xsl:template>

  

</xsl:stylesheet>