<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="count-bbidno" select="count(//Param[@name='bbidno'])" />

  <xsl:template name="get-head-title">
    Edit Portfolio
  </xsl:template>

  <xsl:template name="build-head-block" />
  <xsl:template name="build-canonical-link" />

  <xsl:template name="build-site-header" />

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <xsl:text>Edit Portfolio Settings</xsl:text>
    </qui:header>

    <qui:block slot="blurb">
      <xhtml:p>
        Editing <xsl:value-of select="/Top/Portolio/Field[@name='bbagname']" />
      </xhtml:p>
    </qui:block>

    <qui:form action="bbaction">
      <qui:hidden-input name="bbdbid" value="{/Top/Portfolio/@id}" />
      <qui:hidden-input name="bbaction" value="bbreslist.bbedit" />
      <xsl:for-each select="//PortfolioNameForm/HiddenVars/Variable">
        <qui:hidden-input name="{@name}" value="{.}" />
      </xsl:for-each>
      <qui:input type="text" name="bbnn" value="{/Top/Portfolio/Field[@name='bbagname']}" />
      <qui:textarea name="newowners">
        <xsl:for-each select="str:split(/Top/Portfolio/Field[@name='username']/@data, '|')">
          <qui:value><xsl:value-of select="." /></qui:value>
        </xsl:for-each>
      </qui:textarea>
      <qui:input type="hidden" name="status" value="{/Top/Portfolio/Field[@name='shared']/Public}" />
      <xsl:if test="//PublicPortfoliosEnabled = 'true'">
        <qui:input type="checkbox" name="newstatus" value="1">
          <xsl:if test="/Top/Portfolio/Field[@name='shared']/Public = '1'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
          <qui:label>Publically Viewable</qui:label>
        </qui:input>
      </xsl:if>
    </qui:form>

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