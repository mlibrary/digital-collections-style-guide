<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="BbagItemsCount" select="/Top/NavHeader/BookbagItems"/>
  <xsl:variable name="search-form" select="//SearchForm" />

  <xsl:template name="build-body-main">
    <xsl:call-template name="build-breadcrumbs" />
    <qui:header role="main" data-badge="view_list">
      <xsl:value-of select="key('get-lookup', 'bookbag.str.holdings')" />
    </qui:header>

    <xsl:choose>
      <xsl:when test="/Top/Bookbag/BookbagItems = 0">
        <qui:callout slot="empty">
          <xhtml:p>
            <xsl:value-of select="key('get-lookup','bookbag.str.no.items')"/>
          </xhtml:p>
        </qui:callout>
      </xsl:when>
      <xsl:when test="$page = 'bbagemail'">
        <xsl:call-template name="build-bookbag-email-form" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="build-bookbag-search-form" />
        <xsl:call-template name="build-action-panel-bookbag" />
        <xsl:call-template name="build-bookbag-items" />
      </xsl:otherwise>
    </xsl:choose>

    <qui:block slot="overview">
      <p>
        <xsl:value-of select="key('get-lookup','bookbagitemsstring.str.yourlisthas')"/>
        <xsl:value-of select="$BbagItemsCount"/>
        <xsl:choose>
          <xsl:when test="$BbagItemsCount=1">
            <xsl:value-of select="key('get-lookup','bookbagitemsstring.str.itemsingular')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="key('get-lookup','bookbagitemsstring.str.itemplural')"/>
          </xsl:otherwise>
        </xsl:choose>
      </p>
    </qui:block>
    <qui:block slot="items">
      <xsl:apply-templates select="/Top//BookbagResults/Item" />
    </qui:block>
  </xsl:template>

  <xsl:template name="get-title">
    <xsl:value-of select="key('get-lookup', 'bookbag.str.holdings')" />
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    Bookbag
  </xsl:template>

  <xsl:template name="build-bookbag-search-form">
    <xsl:call-template name="build-advanced-search-form" />
  </xsl:template>

  <xsl:template name="build-bookbag-email-form">
    <qui:form name="email" href="{/Top/DlxsGlobals/ScriptName[@application='text']}">
      <xsl:apply-templates select="/Top/Bookbag/BookbagActionForm/HiddenVars"/>
      <qui:form-control>
        <qui:label><xsl:value-of select="key('get-lookup','bookbag.str.sendto')" /></qui:label>
        <qui:input name="email" type="text" />
      </qui:form-control>
      <qui:input type="submit" name="submit" value="Email Records" />
    </qui:form>
  </xsl:template>

  <xsl:template name="build-action-panel-bookbag">
    <qui:block slot="actions">
      <xsl:call-template name="build-bookbag-action-form">
        <xsl:with-param name="bbaction">email</xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="build-bookbag-action-form">
        <xsl:with-param name="bbaction">download</xsl:with-param>
      </xsl:call-template>
    </qui:block>    
  </xsl:template>

  <xsl:template name="build-bookbag-items">
    <qui:block slot="items">
      <xsl:apply-templates select="/Top//BookbagResults/Item" />
    </qui:block>    
  </xsl:template>

  <xsl:template name="build-bookbag-action-form">
    <xsl:param name="bbaction" />
    <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="$bbaction = 'email'">
          <xsl:value-of select="key('get-lookup','bookbag.str.emailcontents')"/>
        </xsl:when>
        <xsl:when test="$bbaction = 'download'">
          <xsl:value-of select="key('get-lookup','bookbag.str.downloadcontents')"/>
        </xsl:when>
        <xsl:when test="$bbaction = 'empty'">
          <xsl:value-of select="key('get-lookup','bookbag.str.emptycontents')"/>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>
    <qui:form href="{/Top/DlxsGlobals/ScriptName[@application='text']}">
      <xsl:apply-templates select="/Top/Bookbag/BookbagActionForm/HiddenVars"/>
      <xsl:choose>
        <xsl:when test="$bbaction = 'email' or $bbaction = 'list'">
          <qui:hidden-input name="page" value="bbag{$bbaction}" />
        </xsl:when>
        <xsl:otherwise>
          <qui:hidden-input name="bbaction" value="{$bbaction}" />
        </xsl:otherwise>
      </xsl:choose>
      <qui:input type="submit" name="submit" value="{normalize-space($label)}" />
    </qui:form>
  </xsl:template>


</xsl:stylesheet>