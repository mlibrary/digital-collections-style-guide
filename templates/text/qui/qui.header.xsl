<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />

  <xsl:variable name="item-metadata-tmp">
    <xsl:apply-templates select="/Top/Item" mode="metadata" />
  </xsl:variable>
  <xsl:variable name="item-metadata" select="exsl:node-set($item-metadata-tmp)" />

  <xsl:template name="build-body-main">
    <xsl:call-template name="build-contents-navigation" />
    <xsl:call-template name="build-breadcrumbs" />
    <qui:header role="main">
      <xsl:value-of select="$item-metadata//qui:field[@key='title']//qui:value" />
      <!-- <xsl:text>: </xsl:text> -->
      <xsl:choose>
        <xsl:when test="$view = 'toc'">
          <!-- <xsl:value-of select="key('get-lookup', 'headerutils.str.title')" /> -->
          <!-- <xsl:text> Contents</xsl:text> -->
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </qui:header>
    <xsl:call-template name="build-item-header" />
    <xsl:apply-templates select="/Top/Item/HeaderToc" />
    <!-- <xsl:call-template name="build-browse-navigation" /> -->
    <qui:message>SOB</qui:message>
  </xsl:template>


  <xsl:template name="get-title">
    Contents
  </xsl:template>

  <xsl:template name="build-item-header">
    <xsl:apply-templates select="$item-metadata" mode="copy" />
  </xsl:template>

  <xsl:template name="build-contents-navigation">
    header.str.viewentiretext
    <qui:nav role="contents">
      <xsl:if test="/Top/AuthRequired != 'true'">
        <qui:link href="{//ViewEntireTextLink}" role="view-text">
          <xsl:value-of select="key('get-lookup','header.str.viewentiretext')"/>
        </qui:link>
      </xsl:if>
      <qui:link rel="bookmark" href="{/Top/BookbagAddHref}" label="{key('get-lookup', 'results.str.21')}" />
    </qui:nav>
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    Contents
  </xsl:template>

  <xsl:template match="HeaderToc">
    <qui:block slot="contents">
      <qui:ul>
        <xsl:choose>
          <xsl:when test="ScopingPage">
            <xsl:apply-templates select="ScopingPage" mode="outline" />
          </xsl:when>
          <xsl:when test="DIV1">
            <xsl:apply-templates select="DIV1" mode="outline" />
          </xsl:when>
        </xsl:choose>
      </qui:ul>
    </qui:block>
  </xsl:template>

  <xsl:template match="ScopingPage" mode="outline">
    <xsl:variable name="do-build-link">
      <xsl:choose>
        <xsl:when test="/Top/AuthRequired='true'">false</xsl:when>
        <xsl:otherwise>true</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <qui:li>
      <xsl:choose>
        <xsl:when test="$do-build-link = 'true'">
          <qui:link href="{ViewPageLink}">
            <xsl:value-of select="key('get-lookup','headerutils.str.page')"/>
            <xsl:text> </xsl:text>
            <xsl:if test="PageNumber!='NA'">
              <xsl:value-of select="PageNumber"/>
            </xsl:if>
            <xsl:if test="PageNumber='NA'">
              <xsl:text>[unnumbered]</xsl:text>
            </xsl:if>
            <xsl:if test="PageType!='viewer.ftr.uns'"><xsl:text> - </xsl:text></xsl:if>
            <xsl:value-of select="key('get-lookup',PageType)"/>        
          </qui:link>
        </xsl:when>
      </xsl:choose>
    </qui:li>
  </xsl:template>

  <xsl:template match="DIV1" mode="outline">
    <qui:debug>TBD</qui:debug>
  </xsl:template>

  <xsl:template match="Top/Item" mode="metadata">
    <xsl:variable name="encoding-type">
      <xsl:value-of select="DocEncodingType" />
    </xsl:variable>

    <xsl:variable name="item-encoding-level">
      <xsl:choose>
        <xsl:when test="ItemHeader/HEADER/ENCODINGDESC/EDITORIALDECL/@N">
          <xsl:value-of select="ItemHeader/HEADER/ENCODINGDESC/EDITORIALDECL/@N"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:call-template name="build-item-metadata">
      <xsl:with-param name="item" select="ItemHeader" />
      <xsl:with-param name="encoding-type" select="$encoding-type" />
      <xsl:with-param name="item-encoding-level" select="$item-encoding-level" />
    </xsl:call-template>
      
  </xsl:template>  

</xsl:stylesheet>