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
    <xsl:variable name="is-advanced" select="//SearchForm/Advanced" />
    <xsl:variable name="is-browse" select="//Param[@name='page'] = 'browse'" />
    <qui:form id="collection-search" data-edit-action="{//SearchLink}">
      <xsl:attribute name="data-has-query">
        <xsl:choose>
          <xsl:when test="//Facets/Value[@selected='true']">true</xsl:when>
          <xsl:when test="normalize-space(//BrowseStringForm/Value)">true</xsl:when>
          <xsl:when test="//SearchForm/Range//Value[normalize-space(.)]">true</xsl:when>
          <xsl:when test="count(//SearchForm/Q[@name != 'q0'][normalize-space(Value)]) = 1 and //SearchForm/Q[@name != 'q0']/Value = //SearchForm/HiddenVars/Variable[@name='c']">false</xsl:when>
          <xsl:when test="normalize-space(//SearchForm/Q[@name != 'q0']/Value)">true</xsl:when>
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
      <xsl:apply-templates select="//Facets" mode="search-form" />
      <xsl:apply-templates select="//SearchForm/HiddenVars/Variable" />
      <xsl:if test="//SearchForm/HiddenVars/Variable[@name='xc'] = '1'">
        <xsl:for-each select="//Param[@name='c']">
          <qui:hidden-input name="c" value="{.}" />
        </xsl:for-each>
      </xsl:if>
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
      <qui:input name="{$field}" slot="query" value="{$q}" data-active="true" />
      <qui:input slot="rgn" name="key" type="select">
        <qui:option value="simple">
          <xsl:if test="not($is-browse)">
            <xsl:attribute name="selected">selected</xsl:attribute>
          </xsl:if>
          <xsl:text>Collection</xsl:text>
        </qui:option>
        <xsl:for-each select="/Top/NavHeader/BrowseFields/Field">
          <qui:option value="{Name}">
            <xsl:if test="Name/@default = '1'">
              <xsl:attribute name="selected">selected</xsl:attribute>
            </xsl:if>
            <xsl:value-of select="dlxs:capitalize(Name)" />
          </qui:option>
        </xsl:for-each>
      </qui:input>  
    </qui:control>
  </xsl:template>

</xsl:stylesheet>