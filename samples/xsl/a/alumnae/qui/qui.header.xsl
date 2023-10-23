<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:template name="should-div-not-be-linked">
    <xsl:message>INSIDE CUSTOMIZATION: <xsl:value-of select="local-name()" /></xsl:message>
    <xsl:choose>
      <xsl:when test="ancestor::Item/DocEncodingType='serialarticle'">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:when test="@STATUS='nolink'">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:when test="local-name() = 'DIV2'">
        <xsl:value-of select="'true'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>