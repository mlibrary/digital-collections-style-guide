<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:tei="http://www.tei-c.org/ns/1.0" extension-element-prefixes="exsl date" >
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />
  <xsl:strip-space elements="*"/>

  <xsl:variable name="has-plain-text" select="//ViewSelect/Option[Value='text']" />
  <xsl:variable name="is-subj-search">yes</xsl:variable>

  <xsl:variable name="idno" select="//Param[@name='idno']" />

  <xsl:variable name="item-encoding-level">
    <xsl:choose>
      <xsl:when test="/Top/FullTextResults/ItemHeader/HEADER/ENCODINGDESC/EDITORIALDECL/@N">
        <xsl:value-of select="/Top/FullTextResults/ItemHeader/HEADER/ENCODINGDESC/EDITORIALDECL/@N"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="''"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

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
        <xsl:value-of select="key('get-lookup', 'uplift.str.contents')" />
      </qui:link>
    </xsl:if>
    <xsl:apply-templates select="//ItemDetails/*" mode="build-nav" />
  </xsl:template>

  <xsl:template match="node()[Link]" mode="build-nav">
    <qui:link href="{Link}">
      <xsl:value-of select="Divhead/HEAD" />
    </qui:link>
    <xsl:apply-templates select="./node()[Link]" mode="build-nav" />
  </xsl:template>

  <xsl:template name="build-body-main">
    <!-- <xsl:call-template name="build-results-navigation" /> -->
    <xsl:call-template name="build-section-navigation" />
    <xsl:call-template name="build-breadcrumbs" />
    <!-- <xsl:call-template name="build-record" />
    <xsl:call-template name="build-rights-statement" />
    <xsl:call-template name="build-related-links" /> -->

    <qui:header role="main">
      <xsl:apply-templates select="$item-metadata//qui:field[@key='title']/qui:values" mode="copy" />
    </qui:header>
   
    <qui:block slot="metadata">
      <xsl:apply-templates select="$item-metadata" mode="copy" />
    </qui:block>

    <qui:block slot="content" 
      mimetype="application/tei+xml" 
      is-target="{$is-target}"
      item-encoding-level="{$item-encoding-level}" >
      <xsl:choose>
        <xsl:when test="/Top/FullTextResults/DocContent/DLPSTEXTCLASS">
          <xsl:apply-templates select="/Top/FullTextResults/DocContent/DLPSTEXTCLASS" mode="copy-guts" />
        </xsl:when>
        <xsl:when test="/Top/FullTextResults/DocContent/DLPSWRAP">
          <xsl:apply-templates select="/Top/FullTextResults/DocContent/DLPSWRAP" mode="copy" />
        </xsl:when>
        <xsl:when test="/Top/FullTextResults/DocContent">
          <xsl:apply-templates select="/Top/FullTextResults/DocContent" mode="copy-guts" />
        </xsl:when>
      </xsl:choose>
    </qui:block>

    <qui:block slot="notes"
      mimetype="application/tei+xml"
      >
      <!-- <xsl:for-each select="/Top/FullTextResults/DocContent//NOTE1[@HREF]|/Top/FullTextResults/DocContent//NOTE2[@HREF]">
        <tei:NOTE>
          <xsl:apply-templates select="." mode="copy" />
        </tei:NOTE>
      </xsl:for-each> -->
      <xsl:apply-templates select="/Top/FullTextResults/NOTES" mode="copy-guts" />
    </qui:block>

    <qui:message>BOO-YAH</qui:message>
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    <xsl:choose>
      <xsl:when test="//Param[@name='rgn'] = 'main'">Entire Text</xsl:when>
      <xsl:when test="false() and //DLPSWRAP[1]/node()[@TYPE]">
        <xsl:value-of select="//DLPSWRAP[1]/node()/@TYPE" />
      </xsl:when>
      <xsl:when test="false() and //DLPSWRAP[1]/node()">
        <xsl:value-of select="local-name(//DLPSWRAP[1]/node())" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="key('get-lookup', 'uplift.section')" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-section-navigation">
    <!-- do we have M/N available in the PI handler? -->
    <xsl:variable name="tmp-xml">
      <qui:nav role="sections" total="{normalize-space(//ReturnToResultsLink)}">
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
        <xsl:apply-templates select="/Top/FullTextResults/PrevNextSectionLinks" />
      </qui:nav>
    </xsl:variable>

    <xsl:variable name="tmp" select="exsl:node-set($tmp-xml)" />

    <xsl:if test="$tmp//qui:link">
      <xsl:apply-templates select="$tmp" mode="copy" />
    </xsl:if>

  </xsl:template>

  <xsl:template match="PrevNextSectionLinks">
    <xsl:call-template name="build-results-navigation-link">
      <xsl:with-param name="rel">previous-section</xsl:with-param>
      <xsl:with-param name="href" select="PrevSectionLink" />
      <xsl:with-param name="label" select="key('get-lookup', 'uplift.previous.section')" />
    </xsl:call-template>
    <xsl:call-template name="build-results-navigation-link">
      <xsl:with-param name="rel">next-section</xsl:with-param>
      <xsl:with-param name="href" select="NextSectionLink" />
      <xsl:with-param name="label" select="key('get-lookup', 'uplift.next.section')" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Top/FullTextResults" mode="metadata">
    <xsl:variable name="encoding-type">
      <xsl:value-of select="DocEncodingType" />
    </xsl:variable>

    <xsl:call-template name="build-header-metadata">
      <xsl:with-param name="item" select="." />
      <xsl:with-param name="encoding-type" select="$encoding-type" />
      <xsl:with-param name="item-encoding-level" select="$item-encoding-level" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="FullTextResults//node()[name()][namespace-uri() = '']" mode="copy" priority="99">
    <xsl:element name="tei:{name()}">
      <xsl:apply-templates select="*|@*|text()" mode="copy" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="DLPSTEXTCLASS/HEADER" mode="copy" priority="99" />
  <xsl:template match="DLPSTEXTCLASS/TEXT/BODY/DIV1/BIBL" mode="copy" priority="99" />

  <xsl:template name="build-results-navigation-link">
    <xsl:param name="rel" />
    <xsl:param name="identifier" />
    <xsl:param name="marker" />
    <xsl:param name="href" />
    <xsl:param name="label" />
    <xsl:choose>
      <xsl:when test="normalize-space($href)">
        <qui:link rel="{$rel}" href="{$href}" type="section">
          <xsl:if test="normalize-space($identifier)">
            <xsl:attribute name="identifier">
              <xsl:value-of select="$identifier" />
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="normalize-space($marker)">
            <xsl:attribute name="marker">
              <xsl:value-of select="$marker" />
            </xsl:attribute>
          </xsl:if>
          <xsl:if test="$label">
            <qui:label><xsl:value-of select="$label" /></qui:label>
          </xsl:if>
        </qui:link>
      </xsl:when>
      <xsl:otherwise>
        <qui:link rel="{$rel}" disabled="disabled" type="section">
          <xsl:if test="$label">
            <qui:label><xsl:value-of select="$label" /></qui:label>
          </xsl:if>
        </qui:link>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>  
</xsl:stylesheet>