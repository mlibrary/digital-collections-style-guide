<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />

  <xsl:template name="build-extra-styles">
  </xsl:template>

  <xsl:template match="qui:main">
    <xsl:call-template name="build-collection-heading" />

    <div class="[ flex flex-flow-row flex-gap-1 ]">
      <!-- <div class="side-panel">
        <xsl:apply-templates select="//qui:panel[@slot='browse']" />
        <xsl:apply-templates select="//qui:panel[@slot='custom']" />
        <xsl:call-template name="build-filters-panel" />
        <xsl:apply-templates select="//qui:panel[@slot='related-collections']" />
        <xsl:apply-templates select="//qui:panel[@slot='access-restrictions']" />
      </div> -->
      <div class="main-panel">
        <xsl:call-template name="build-breadcrumbs" />
        <xsl:apply-templates select="//qui:block[@slot='content']">
          <!-- <xsl:with-param name="classes">[ viewport-narrow ]</xsl:with-param> -->
        </xsl:apply-templates>
        <xsl:call-template name="build-search-form" />
      </div>
    </div>

  </xsl:template>

  

</xsl:stylesheet>