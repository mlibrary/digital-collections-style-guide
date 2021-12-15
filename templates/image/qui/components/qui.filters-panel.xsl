<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:template match="Facets">
    <qui:filters-panel>
      <xsl:apply-templates select="//SearchForm/MediaOnly" />
      <xsl:for-each select="Field">
        <qui:filter key="{@abbrev}" data-total="{@total}">
          <qui:label>
            <xsl:value-of select="Label" />
          </qui:label>
          <qui:values>
            <xsl:for-each select="Values/Value">
              <qui:value count="{@count}">
                <xsl:if test="@selected">
                  <xsl:attribute name="selected">
                    <xsl:value-of select="@selected" />
                  </xsl:attribute>
                </xsl:if>
                <xsl:if test="10 &lt; position()">
                  <xsl:attribute name="data-expandable-filter">true</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="." />
              </qui:value>
            </xsl:for-each>
          </qui:values>
        </qui:filter>
      </xsl:for-each>
    </qui:filters-panel>
  </xsl:template>
  
  <xsl:template match="MediaOnly">
    <qui:filter key="med" arity="1">
      <qui:label>Has digital media?</qui:label>
      <qui:values>
        <qui:value>
          <xsl:if test="//Param[@name='med'] = 1">
            <xsl:attribute name="selected">true</xsl:attribute>
          </xsl:if>
          <xsl:text>1</xsl:text>
        </qui:value>
      </qui:values>
    </qui:filter>
  </xsl:template>

</xsl:stylesheet>