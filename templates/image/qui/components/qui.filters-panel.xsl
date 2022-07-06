<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:template match="Facets/Error" priority="100">
    <qui:callout 
      variant='warning' 
      slot="results" 
      data-threshold="{@threshold}" 
      data-max="{@max}"
      data-num="{@num}">
      <p>
        Apologies: there were too many search results to calculate filters.
      </p>
    </qui:callout>
  </xsl:template>

  <xsl:template match="Facets">
    <qui:filters-panel>
      <xsl:apply-templates select="Threshold" />
      <xsl:apply-templates select="//SearchForm/MediaOnly" />
      <xsl:for-each select="Field">
        <xsl:variable name="m" select="position()" />
        <qui:filter key="{@abbrev}" data-total="{@actual_total}">
          <qui:label>
            <xsl:value-of select="Label" />
          </qui:label>
          <qui:values>
            <xsl:for-each select="Values/Value">
              <qui:value count="{@count}" escaped="{@escaped}">
                <xsl:if test="@selected">
                  <xsl:attribute name="selected">
                    <xsl:value-of select="@selected" />
                  </xsl:attribute>
                  <xsl:if test="@selected='true'">
                    <xsl:variable name="n" select="count(preceding-sibling::Value[@selected='true']) + 1" />
                    <xsl:attribute name="num">
                      <xsl:value-of select="concat($m, $n)" />
                    </xsl:attribute>
                  </xsl:if>
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
      <qui:label>Only include records with digital media</qui:label>
      <qui:values>
        <qui:value>
          <xsl:choose>
            <xsl:when test="//Param[@name='med'] = 1">
              <xsl:attribute name="selected">true</xsl:attribute>
            </xsl:when>
            <xsl:when test="//Param[@name='med']" />
            <xsl:when test="Focus = 'true'">
              <xsl:attribute name="selected">true</xsl:attribute>
            </xsl:when>
            <xsl:otherwise />
          </xsl:choose>
          <xsl:text>1</xsl:text>
        </qui:value>
      </qui:values>
    </qui:filter>
  </xsl:template>

  <xsl:template match="Threshold">
    <xsl:attribute name="data-max"><xsl:value-of select="@max" /></xsl:attribute>
    <xsl:attribute name="data-num"><xsl:value-of select="@num" /></xsl:attribute>
    <xsl:attribute name="data-threshold"><xsl:value-of select="@threshold" /></xsl:attribute>
  </xsl:template>

</xsl:stylesheet>