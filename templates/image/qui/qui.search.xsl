<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:template name="build-body-main">
    <xsl:call-template name="build-breadcrumbs" />
    <qui:header role="main">
      <xsl:call-template name="get-title" />
    </qui:header>
    <xsl:apply-templates select="/Top/SearchForm" />
    <qui:message>BOO-YAH-NAH-NAH</qui:message>
  </xsl:template>

  <xsl:template name="get-title">
    Search Options
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    <xsl:call-template name="get-title" />
  </xsl:template>

  <xsl:template match="SearchForm">
    <qui:callout slot="clause">
      <xsl:value-of select="key('gui-txt', 'instructionsearch1')" />
      <xsl:text> </xsl:text>
      <xsl:value-of select="key('gui-txt', 'instructionsearch2')" />
    </qui:callout>
    <qui:form id="collection-search" data-num-qs="{NumQs}">
      <xsl:apply-templates select="Q" />
      <qui:fieldset slot="limits">
        <xsl:apply-templates select="Range" />
        <xsl:call-template name="build-custom-search-options" />
        <xsl:apply-templates select="MediaOnly"/>
      </qui:fieldset>
      <xsl:apply-templates select="FacetLimits" />
      <xsl:apply-templates select="HiddenVars" />
    </qui:form>
  </xsl:template>

  <xsl:template match="SearchForm/Q">
    <xsl:variable name="current-field">
      <xsl:choose>
        <xsl:when test="Rgn/Option[Focus='true']">
          <xsl:value-of select="Rgn/Option[Focus='true']/Value" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="Rgn/Default" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <qui:fieldset id="{@name}-fieldset" data-name="{@name}" slot="clause">
      <xsl:if test="@name = 'q0'">
        <xsl:attribute name="role">template</xsl:attribute>
      </xsl:if>
      <qui:input name="{@name}" slot="query" value="{Value}">
        <xsl:attribute name="data-active">
          <xsl:choose>
            <xsl:when test="Qlist[@active = 'TRUE']">false</xsl:when>
            <xsl:otherwise>true</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </qui:input>
      <qui:select name="{Rgn/@name}" slot="region">
        <xsl:apply-templates select="Rgn/Option">
          <xsl:with-param name="default" select="Rgn/Default" />
        </xsl:apply-templates>
      </qui:select>
      <xsl:call-template name="build-operator-select" />
      <xsl:apply-templates select="Sel">
        <xsl:with-param name="current-field" select="$current-field" />
      </xsl:apply-templates>
      <xsl:apply-templates select="Qlist">
        <xsl:with-param name="current-field" select="$current-field" />
      </xsl:apply-templates>
    </qui:fieldset>
  </xsl:template>

  <xsl:template match="Sel">
    <xsl:param name="current-field" />
    <qui:select name="{@name}" data-field="{@abbr}" data-active="{@abbr = $current-field}" slot="select">
      <xsl:apply-templates select="Option" />
    </qui:select>
  </xsl:template>

  <xsl:template match="Qlist">
    <xsl:param name="current-field" />
    <xsl:variable name="default" select="Default" />
    <qui:select name="{@name}" data-field="{@abbr}" data-active="{@abbr = $current-field}" slot="query">
      <xsl:apply-templates select="Option">
        <xsl:with-param name="default" select="$default" />
      </xsl:apply-templates>
    </qui:select>
  </xsl:template>

  <xsl:template match="SearchForm/Range">
    <qui:fieldset slot="range" data-select="{Sel/@name}" data-range-type="{Sel/Option/Value}">
      <qui:legend><xsl:value-of select="Q/Rgn/Label" /></qui:legend>
      <xsl:apply-templates select="Q" />
      <qui:input type="hidden" name="{Op/@name}" value="{Op/Option/Value}" />
    </qui:fieldset>
  </xsl:template>

  <xsl:template match="SearchForm/Range/Q">
    <xsl:variable name="abbr" select="Rgn/Value" />
    <xsl:variable name="name" select="Rgn/@name" />
    <qui:hidden-input name="{Rgn/@name}" value="{Rgn/Value}" />
    <qui:control>
      <qui:input slot="ic_after" aria-label="Start Date" data-field="{$abbr}" name="{@name}" id="{@name}-min" value="{Value[1]}" />
      <qui:input slot="ic_before" aria-label="End Date" data-field="{$abbr}" name="{@name}" id="{@name}-max" value="{Value[2]}" />
      <qui:input slot="ic_exact_range" aria-label="Exact Date" data-field="{$abbr}" name="{@name}" id="{@name}-max" value="{Value[1]}" />
    </qui:control>
  </xsl:template>

  <xsl:template match="MediaOnly">
    <qui:control>
      <qui:label>Only include records with digital media</qui:label>
      <qui:input type="checkbox" slot="limit-media" name="med" value="1">
        <xsl:if test="Focus = 'true'">
          <xsl:attribute name="checked">checked</xsl:attribute>
        </xsl:if>
      </qui:input>
    </qui:control>
  </xsl:template>

  <xsl:template name="build-operator-select">
    <xsl:choose>
      <xsl:when test="preceding::Q[1]/Op and preceding::Q[1]/@name != 'q0'">
        <xsl:apply-templates select="preceding::Q[1]/Op" />
      </xsl:when>
      <xsl:when test="@name = 'q0'">
        <xsl:apply-templates select="Op" />
      </xsl:when>
      <xsl:otherwise>
        <!-- empty -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Q/Op">
    <qui:select name="{@name}" slot="op">
      <xsl:apply-templates select="Option" />
    </qui:select>
  </xsl:template>

  <xsl:template match="Option">
    <xsl:param name="default" />
    <qui:option value="{Value}">
      <xsl:if test="Focus = 'true' or Value = $default">
        <xsl:attribute name="selected">true</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="Label" />
    </qui:option>
  </xsl:template>
  
  <xsl:template name="build-custom-search-options">
    <xsl:apply-templates select="CustomLimits" mode="copy-guts" />
  </xsl:template>

  <xsl:template match="FacetLimits">
    <xsl:apply-templates select="Field" />
    <xsl:apply-templates select="qui:filter" mode="copy" />
  </xsl:template>

</xsl:stylesheet>