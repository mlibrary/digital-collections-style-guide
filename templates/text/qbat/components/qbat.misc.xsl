<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
  <xsl:template name="makeRendVar">
    <xsl:choose>
        <xsl:when test="@REND">
            <xsl:call-template name="normAttr">
                <xsl:with-param name="attr" select="@REND"/>
            </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
            <xsl:text>italic</xsl:text>
        </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>