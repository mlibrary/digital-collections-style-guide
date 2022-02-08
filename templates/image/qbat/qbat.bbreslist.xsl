<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:dlxs="http://dlxs.org" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template name="build-search-form" />

  <xsl:template name="build-filters-panel">
    <xsl:if test="//qui:link[@target='portfolio']">
      <h3 class="[ mt-2 ]">Portfolio Actions</h3>
      <div class="[ side_panel__box ]">
        <ul>
          <xsl:for-each select="//qui:link[@target='portfolio']">
            <xsl:variable name="value" select="$labels//dlxs:field[@key=current()/@rel]" />
            <li>
              <a href="{@href}"><xsl:value-of select="$value" /></a>
            </li>
          </xsl:for-each>
        </ul>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>