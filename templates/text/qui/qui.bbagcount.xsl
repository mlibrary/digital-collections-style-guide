<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="BbagItemsCount" select="/Top/NavHeader/BookbagItems"/>

  <xsl:template name="build-body-main">
    <xsl:call-template name="build-breadcrumbs" />
    <qui:header role="main" data-badge="view_list">
      <xsl:value-of select="key('get-lookup', 'bookbag.str.holdings')" />
    </qui:header>

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

</xsl:stylesheet>