<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:template name="build-search-form">
    <xsl:variable name="q" select="//SearchForm/Q[@name='q1']" />
    <xsl:variable name="is-advanced" select="//SearchForm/Advanced" />
    <qui:form id="collection-search" data-advanced="{$is-advanced}" data-edit-action="{//SearchLink}">
      <xsl:attribute name="data-has-query">
        <xsl:choose>
          <xsl:when test="//Facets/Value[@selected='true']">true</xsl:when>
          <xsl:when test="//SearchForm/MediaOnly[Focus='true']">true</xsl:when>
          <xsl:when test="count(//SearchForm/Q[normalize-space(Value)]) = 1 and //SearchForm/Q/Value = //SearchForm/HiddenVars/Variable[@name='c']">false</xsl:when>
          <xsl:when test="normalize-space(//SearchForm/Q/Value)">true</xsl:when>
          <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$is-advanced = 'true'">
          <xsl:apply-templates select="//SearchForm/Q">
            <xsl:with-param name="is-advanced" select="//SearchForm/Advanced" />
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="//SearchForm/Q[1]" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="//Facets" mode="search-form" />
    </qui:form>
  </xsl:template>

  <xsl:template match="Q">
    <xsl:param name="is-advanced" />
    <xsl:variable name="q" select="." />
    <xsl:variable name="rgn">
      <xsl:call-template name="get-selected-option">
        <xsl:with-param name="options" select="Rgn" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="ops" select="preceding::Q[1]/Op" />
    <xsl:variable name="op">
      <xsl:call-template name="get-selected-option">
        <xsl:with-param name="options" select="$ops" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sel" select="Sel[@abbr=$rgn]" />

    <xsl:variable name="select">
      <xsl:call-template name="get-selected-option">
        <xsl:with-param name="options" select="Sel[@abbr=$rgn]" />
      </xsl:call-template>
    </xsl:variable>

    <qui:control slot="clause" data-name="{@name}">
      <xsl:choose>
        <xsl:when test="$is-advanced = 'true'">
          <qui:input slot="rgn" type="hidden" name="{Rgn/@name}" value="{Rgn/Option[Value=$rgn]/Value}" label="{Rgn/Option[Value=$rgn]/Label}" />
        </xsl:when>
        <xsl:otherwise>
          <!-- build the full region options to drive the basic search form -->
          <qui:input slot="rgn" name="{Rgn/@name}" type="select">
            <xsl:for-each select="Rgn/Option">
              <xsl:variable name="value" select="Value" />
              <qui:option value="{Value}">
                <xsl:if test="Value = $rgn">
                  <xsl:attribute name="selected">selected</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="Label" />
              </qui:option>
            </xsl:for-each>
          </qui:input>
        </xsl:otherwise>
      </xsl:choose>
      <qui:input slot="select" type="hidden" name="{$sel/@name}" value="{$sel/Option[Value=$select]/Value}">
        <xsl:attribute name="label">
          <xsl:apply-templates select="$sel/Option[Value=$select]/Label" />
        </xsl:attribute>
      </qui:input>
      <xsl:if test="$ops">
        <qui:input slot="op" type="hidden" name="{$ops/@name}" value="{$op}" label="{$ops/Option[Value=$op]/Label}" />
      </xsl:if>
      <qui:input slot="q" type="text" name="{@name}" value="{Value}" />
    </qui:control>
  </xsl:template>

  <xsl:template name="get-selected-option">
    <xsl:param name="options" />
    <xsl:choose>
      <xsl:when test="$options/Option[Focus='true']">
        <xsl:value-of select="$options/Option[Focus='true']/Value" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$options/Default" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Facets" mode="search-form">
    <xsl:apply-templates select="//SearchForm/MediaOnly" mode="search-form" />
    <xsl:for-each select="Field">
      <xsl:variable name="abbrev" select="@abbrev" />
      <xsl:for-each select="Values/Value[@selected='true']">
        <xsl:variable name="fn" select="//Param[starts-with(@name, 'fn')][. = $abbrev]/@name" />
        <xsl:variable name="fq" select="//Param[starts-with(@name, 'fq')][. = .]/@name" />
        <qui:hidden-input type="hidden" name="{$fn}" value="{$abbrev}" data-role="facet" />
        <qui:hidden-input type="hidden" name="{$fq}" value="{.}" data-role="facet-value" data-facet-field="{$abbrev}" />
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="MediaOnly" mode="search-form">
    <qui:hidden-input type="hidden" name="med">
      <xsl:attribute name="value">
        <xsl:if test="Focus = 'true'">
          <xsl:text>1</xsl:text>
        </xsl:if>
      </xsl:attribute>
    </qui:hidden-input>
  </xsl:template>

</xsl:stylesheet>