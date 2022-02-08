<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />

  <xsl:template name="build-portfolio-actions">
    <xsl:apply-templates select="//BookBagInfo[Action]" />
  </xsl:template>

  <xsl:template match="BookBagInfo[Action]">
    <xsl:for-each select="Action">
      <qui:link rel="{@type}" href="{Url}" target="portfolio" />
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>