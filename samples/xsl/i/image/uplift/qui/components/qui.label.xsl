<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:template match="Label">
    <xsl:param name="value" select="." />

    <xsl:variable name="label" select="key('gui-txt', $value)" />
    <xsl:choose>
      <xsl:when test="normalize-space($label)">
        <xsl:value-of select="$label" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space($value)" />
      </xsl:otherwise>
    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>