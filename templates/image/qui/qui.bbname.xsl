<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="count-bbidno" select="count(//Param[@name='bbidno'])" />

  <xsl:template name="get-head-title">
    Add Items to Portfolio
  </xsl:template>

  <xsl:template name="build-head-block" />
  <xsl:template name="build-canonical-link" />

  <xsl:template name="build-site-header" />

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <xsl:choose>
        <xsl:when test="$count-bbidno = 1">
          <xsl:text>Add this item to a portfolio</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Add items to a portfolio</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </qui:header>

    <qui:block slot="blurb">
      <xsl:choose>
        <xsl:when test="$count-bbidno = 1">
          <xsl:call-template name="build-blurb-single-item" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="build-blurb-multiple-items" />
        </xsl:otherwise>
      </xsl:choose>
    </qui:block>

    <qui:form action="bbaction">
      <xsl:for-each select="//PortfolioNameForm/HiddenVars/Variable">
        <qui:hidden-input name="{@name}" value="{.}" />
      </xsl:for-each>
      <xsl:if test="//PublicPortfoliosEnabled = 'true'">
        <qui:input type="checkbox" name="bbsh" value="1">
          <qui:label>Publically Viewable</qui:label>
        </qui:input>
      </xsl:if>
      <qui:select name="bbid">
        <xsl:for-each select="//Portfolios[@type='mine']/Portfolio">
          <xsl:variable name="label">
            <xsl:value-of select="Field[@name='bbagname']" />
            <xsl:text> (</xsl:text>
            <xsl:value-of select="Field[@name='itemcount']" />
            <xsl:text>)</xsl:text>
            <xsl:text> - </xsl:text>
            <xsl:value-of select="Field[@name='modified_display']" />
          </xsl:variable>
          <qui:option value="{@id}" aria-label="{normalize-space($label)}">
            <xsl:if test="@mine = 'true'">
              <xsl:attribute name="data-mine">true</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="Field[@name='bbagname']" />
            <xsl:apply-templates select="Field[@name='itemcount']" />
            <xsl:apply-templates select="Field[@name='modified_display']" />
            <xsl:apply-templates select="Field[@name='username']" />
            <xsl:apply-templates select="Field[@name='shared']" />
          </qui:option>
        </xsl:for-each>
      </qui:select>
    </qui:form>

  </xsl:template>

  <xsl:template name="build-blurb-single-item">
    <xhtml:p>Adding 1 item to a portfolio.</xhtml:p>
  </xsl:template>

  <xsl:template name="build-blurb-multiple-items">
    <xhtml:p>
      <xsl:text>Adding </xsl:text>
      <xsl:value-of select="$count-bbidno" />
      <xsl:text> items to a portfolio.</xsl:text>
    </xhtml:p>
  </xsl:template>
 
  <xsl:template match="Field[@name='username']" mode="field-value" priority="100">
    <xsl:for-each select="str:split(., ' ')">
      <qui:value>
        <xsl:value-of select="." />
      </qui:value>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Field[@name='shared']" mode="field-value" priority="100">
    <qui:value>
      <xsl:choose>
        <xsl:when test="Public = 0">Private</xsl:when>
        <xsl:otherwise>Public</xsl:otherwise>
      </xsl:choose>
    </qui:value>
  </xsl:template>

  <xsl:template match="Field" mode="field-value">
    <qui:value>
      <xsl:value-of select="." />
    </qui:value>
  </xsl:template>

  <xsl:template match="Field">
    <qui:field key="{@name}">
      <xsl:if test="@name = 'modified_display'">
        <xsl:attribute name="data-machine-value">
          <xsl:value-of select="ancestor-or-self::Portfolio/Field[@name='modified']" />
        </xsl:attribute>
      </xsl:if>
      <qui:label key="{@name}" />
      <qui:values>
        <xsl:apply-templates select="." mode="field-value" />
      </qui:values>
    </qui:field>
  </xsl:template>

</xsl:stylesheet>