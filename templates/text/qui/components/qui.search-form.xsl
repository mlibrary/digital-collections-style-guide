<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:template name="build-search-form">
    <xsl:variable name="q">
      <xsl:choose>
        <xsl:when test="//Param[@name='q1']">
          <xsl:value-of select="//Param[@name='q1']" />
        </xsl:when>
        <xsl:when test="//Param[@name='value']">
          <xsl:value-of select="//Param[@name='value']" />
        </xsl:when>
        <xsl:otherwise />
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="is-advanced" select="$search-type != 'simple'" />
    <xsl:variable name="is-browse" select="//Param[@name='page'] = 'browse'" />
    <qui:form id="collection-search" data-advanced="{$is-advanced}" data-edit-action="{//SearchDescription/RefineSearchLink}">
      <xsl:attribute name="data-has-query">
        <xsl:choose>
          <xsl:when test="//SearchDescription/RefineSearchLink">true</xsl:when>
          <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$is-advanced = 'true'">
          <xsl:apply-templates select="//SearchForm/Q">
            <xsl:with-param name="is-advanced" select="//SearchForm/Advanced" />
          </xsl:apply-templates>
          <xsl:apply-templates select="//SearchForm/Range" mode="search-form" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="build-search-input">
            <xsl:with-param name="is-browse"><xsl:value-of select="$is-browse" /></xsl:with-param>
            <xsl:with-param name="q" select="$q" />
          </xsl:call-template>
        </xsl:otherwise>
      </xsl:choose>
      <!-- <xsl:apply-templates select="//Facets" mode="search-form" /> -->
      <xsl:choose>
        <xsl:when test="//ResultsLinks/HiddenVars/Variable[@name != 'q1']">
          <xsl:for-each select="//ResultsLinks/HiddenVars/Variable">
            <qui:input type="hidden" role="search" name="{@name}" value="{.}">
              <xsl:attribute name="disabled"><xsl:value-of select="$is-browse" /></xsl:attribute>
            </qui:input>
          </xsl:for-each>
        </xsl:when>
        <xsl:otherwise>
          <qui:input type="hidden" role="search" name="type" value="simple" disabled="{$is-browse}" />
        </xsl:otherwise>
      </xsl:choose>
    </qui:form>
  </xsl:template>

  <xsl:template name="build-search-input">
    <xsl:param name="is-browse" />
    <xsl:param name="q" />
    <xsl:variable name="field">
      <xsl:choose>
        <xsl:when test="$is-browse">value</xsl:when>
        <xsl:otherwise>q1</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <qui:control slot="clause" data-name="{$field}">
      <qui:input name="q1" slot="query" value="{$q}" data-active="true" />
      <qui:input slot="rgn" name="key" type="select">
        <xsl:for-each select="//SearchQuery/RegionSearchSelect/Option">
          <qui:option value="{Value}">
            <xsl:if test="Focus = 'true'">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:choose>
              <xsl:when test="Value = 'full text'">
                Full Text
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="dlxs:capitalize(Label)" />
              </xsl:otherwise>
            </xsl:choose>
          </qui:option>
        </xsl:for-each>
      </qui:input>  
    </qui:control>
  </xsl:template>

</xsl:stylesheet>