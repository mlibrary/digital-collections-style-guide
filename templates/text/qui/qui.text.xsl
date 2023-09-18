<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" xmlns:qui="http://dlxs.org/quombat/ui" extension-element-prefixes="exsl date" >
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />
  <xsl:strip-space elements="*"/>

  <xsl:variable name="has-plain-text" select="//ViewSelect/Option[Value='text']" />
  <xsl:variable name="is-subj-search">yes</xsl:variable>

  <xsl:variable name="idno" select="//Param[@name='idno']" />

  <xsl:variable name="item-metadata-tmp">
    <xsl:apply-templates select="/Top/FullTextResults" mode="metadata" />
  </xsl:variable>
  <xsl:variable name="item-metadata" select="exsl:node-set($item-metadata-tmp)" />

  <xsl:template name="build-head-block">
    <!-- <xsl:call-template name="build-social-twitter" />
    <xsl:call-template name="build-social-facebook" /> -->
  </xsl:template>

  <xsl:template name="get-title">
    <xsl:value-of select="normalize-space($item-metadata//qui:field[@key='title']/qui:values)" />
  </xsl:template>

  <xsl:template name="build-breadcrumbs-intermediate-links">
    <xsl:if test="/Top/FullTextResults/TocHref">
      <qui:link href="{/Top/FullTextResults/TocHref}">
        <xsl:value-of select="key('get-lookup', 'header.str.contents')" />
      </qui:link>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-body-main">
    <!-- <xsl:call-template name="build-results-navigation" /> -->
    <xsl:call-template name="build-breadcrumbs" />
    <!-- <xsl:call-template name="build-record" />
    <xsl:call-template name="build-rights-statement" />
    <xsl:call-template name="build-related-links" /> -->
    
    <xsl:apply-templates select="$item-metadata" mode="copy" />

    <xsl:apply-templates select="/Top/FullTextResults/DocContent" />

    <qui:message>BOO-YAH</qui:message>
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    <xsl:text>Entire Text</xsl:text>
  </xsl:template>

  <xsl:template name="build-results-navigation">
    <!-- do we have M/N available in the PI handler? -->
    <xsl:variable name="tmp-xml">
      <qui:nav role="results" total="{normalize-space(//ReturnToResultsLink)}">
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">back</xsl:with-param>
          <xsl:with-param name="href" select="/Top/ReturnToResultsLink" />
        </xsl:call-template>
        <!-- <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">next</xsl:with-param>
          <xsl:with-param name="href" select="/Top/Next/Url" />
        </xsl:call-template>
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">previous</xsl:with-param>
          <xsl:with-param name="href" select="/Top/Prev/Url" />
        </xsl:call-template> -->
      </qui:nav>
    </xsl:variable>

    <xsl:variable name="tmp" select="exsl:node-set($tmp-xml)" />

    <xsl:if test="$tmp//qui:link">
      <xsl:apply-templates select="$tmp" mode="copy" />
    </xsl:if>

  </xsl:template>

  <xsl:template match="Top/FullTextResults" mode="metadata">
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