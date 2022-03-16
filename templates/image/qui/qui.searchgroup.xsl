<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:template name="build-body-main">
    <xsl:call-template name="build-breadcrumbs" />
    <qui:header role="main">
      <!-- <xsl:call-template name="get-title" /> -->
      <xsl:text>Group Search</xsl:text>
    </qui:header>
    <qui:header role="group">
      <xsl:call-template name="get-group-title" />
    </qui:header>
    <xsl:apply-templates select="/Top/SearchForm" />
    <qui:message>BOO-YAH-NAH-NAH</qui:message>
  </xsl:template>

  <xsl:template name="get-title">
    <xsl:choose>
      <xsl:when test="//CurrentCgi/Param[@name='g']">
        <!-- <xsl:text>Search Group</xsl:text> -->
        <xsl:value-of select="/Top/GroupName" />
      </xsl:when>
      <xsl:otherwise>
        Selected Collections
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-group-title">
    <xsl:choose>
      <xsl:when test="//CurrentCgi/Param[@name='g']">
        <xsl:value-of select="/Top/GroupName" />
      </xsl:when>
      <xsl:otherwise>
        Selected Collections
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    <xsl:text>Group Search</xsl:text>
  </xsl:template>

  <xsl:template match="SearchForm">
    <qui:callout slot="collids">
      <xsl:text>You can search all the collections in this group, or use the list of collections to restrict your search to a subset.</xsl:text>
    </qui:callout>
    <qui:callout slot="clause">
      <xsl:value-of select="key('gui-txt', 'instructionsearch1')" />
      <xsl:text></xsl:text>
      <xsl:value-of select="key('gui-txt', 'instructionsearch2')" />
    </qui:callout>
    <qui:form id="collection-search" data-num-qs="{NumQs}">
      <xsl:apply-templates select="Q" />
      <qui:fieldset slot="limits">
        <xsl:call-template name="build-custom-search-options" />
        <xsl:apply-templates select="MediaOnly" />
      </qui:fieldset>
      <xsl:call-template name="build-collection-select" />
      <xsl:apply-templates select="HiddenVars" />
      <!-- <xsl:for-each select="/Top/SearchFields/Coll">
        <xsl:if test="Checked">
          <qui:hidden-input name="c" value="{@collid}" />
        </xsl:if>
      </xsl:for-each> -->
    </qui:form>
  </xsl:template>

  <xsl:template name="build-collection-select">
    <qui:fieldset slot="collids">
      <xsl:for-each select="/Top/SearchFields/Coll">
        <xsl:apply-templates select="." />
      </xsl:for-each>
    </qui:fieldset>
  </xsl:template>

  <!-- <xsl:template match="Coll[@collid='DC']" priority="100" /> -->

  <xsl:template match="Coll">
    <qui:option value="{@collid}" data-href="{HomeLink}">
      <xsl:if test="Checked">
        <xsl:attribute name="checked">checked</xsl:attribute>
      </xsl:if>
      <xsl:if test="@collid = 'DC'">
        <xsl:attribute name="type">hidden</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="Name" />
    </qui:option>
  </xsl:template>

</xsl:stylesheet>