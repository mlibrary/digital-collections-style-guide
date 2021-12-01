<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template match="qui:main">
    <xsl:call-template name="build-collection-heading" />

    <div class="message-callout">
      <p>
        This collection index re-design is still under construction.
      </p>
    </div>

    <xsl:call-template name="build-search-form" />

    <xsl:apply-templates select="qui:panel" mode="copy-guts" />

  </xsl:template>

</xsl:stylesheet>