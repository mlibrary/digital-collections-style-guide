<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">
  <xsl:template name="process-monograph">
    <xsl:param name="item-encoding-level" />
    <xsl:param name="item" select="." />
    <xsl:variable name="main-title">
      <!-- use the 245 title if there is one -->
      <xsl:choose>
        <xsl:when test="$item/HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245']">
          <xsl:value-of select="$item/HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$item/HEADER/FILEDESC/TITLESTMT/TITLE"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="main-author">
      <xsl:choose>
        <xsl:when test="$item/HEADER/FILEDESC/TITLESTMT/AUTHOR">
          <xsl:value-of select="$item/HEADER/FILEDESC/TITLESTMT/AUTHOR"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$item/HEADER/FILEDESC/TITLESTMT/EDITOR"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="inverted-author" select="''"/>

    <xsl:variable name="sort-title">
      <xsl:value-of select="$item/HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='sort']"/>
    </xsl:variable>

    <xsl:variable name="main-date">
      <xsl:value-of select="$item/HEADER/FILEDESC/SOURCEDESC/BIBLFULL/PUBLICATIONSTMT/DATE"/>
    </xsl:variable>

    <xsl:call-template name="build-metadata">
      <xsl:with-param name="main-title" select="$main-title"/>
      <xsl:with-param name="sort-title" select="$sort-title"/>
      <xsl:with-param name="main-author" select="$main-author"/>
      <xsl:with-param name="inverted-author" select="$inverted-author"/>
      <xsl:with-param name="main-date" select="$main-date"/>
      <xsl:with-param name="item-encoding-level" select="$item-encoding-level"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-metadata">
    <xsl:param name="main-title" />
    <xsl:param name="sort-title" />
    <xsl:param name="main-author" />
    <xsl:param name="inverted-author" />
    <xsl:param name="main-date" />
    <xsl:param name="item-encoding-level" />
    <qui:title>
      <qui:values>
        <qui:value>
          <xsl:value-of select="$main-title" />
        </qui:value>
      </qui:values>
    </qui:title>
    <qui:block slot="metadata">
      <qui:section>
        <xsl:if test="normalize-space($main-author) or normalize-space($inverted-author)">
          <qui:field key="author">
            <qui:label>Author</qui:label>
            <qui:values>
              <qui:value>
                <xsl:choose>
                  <xsl:when test="$inverted-author">
                    <xsl:value-of select="$inverted-author" />
                  </xsl:when>
                  <xsl:when test="$main-author">
                    <xsl:value-of select="$main-author" />
                  </xsl:when>
                </xsl:choose>    
              </qui:value>
            </qui:values>
          </qui:field>
        </xsl:if>
        <xsl:if test="normalize-space($main-date)">
          <qui:field key="publication-date">
            <qui:label>Publication Date</qui:label>
            <qui:values>
              <qui:value>
                <xsl:value-of select="translate(dlxs:stripEndingChars($main-date,'.'), '][','')"/>
              </qui:value>
            </qui:values>
          </qui:field>
        </xsl:if>
        <xsl:apply-templates select="CollName"/>
      </qui:section>
    </qui:block>
  </xsl:template>

  <xsl:template match="DetailHref">
    <xsl:if test="not($is-bib-srch='yes') and $is-all-rgn-srch='yes'">
      <qui:link rel="detail" href="{.}">
        <xsl:attribute name="label">
          <xsl:choose>
            <xsl:when test="following-sibling::AuthRequired='true'">
              <xsl:value-of select="key('get-lookup', 'results.str.9')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="key('get-lookup', 'results.str.10')" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </qui:link>
    </xsl:if>
  </xsl:template>

  <xsl:template match="FirstPageHref">
    <qui:link rel="result" href="{.}" label="{key('get-lookup', 'results.str.18')}" />
  </xsl:template>

  <xsl:template match="TocHref">
    <xsl:param name="item-encoding-level" />
    <qui:link rel="toc" href="{.}">
      <xsl:attribute name="label">
        <xsl:choose>
          <xsl:when test="$item-encoding-level = '1'">
            <xsl:value-of select="key('get-lookup','results.str.16')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="key('get-lookup','results.str.17')"/>            
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </qui:link>
  </xsl:template>

  <xsl:template match="Tombstone">
    <xsl:attribute name="data-tombstone">true</xsl:attribute>
  </xsl:template>

  <xsl:template match="HitSummary">
    <xsl:if test="node() and $is-bib-srch='no' and $is-all-rgn-srch='yes' and child::*">
      <qui:block slot="summary" label="{key('get-lookup','results.str.2')}">
        <xsl:choose>
          <xsl:when test="$searchtype='basic' or $searchtype='proximity'">
            <xsl:call-template name="SimpleHitSumm"/>
          </xsl:when>
          <xsl:when test="$searchtype='boolean'">
            <xsl:call-template name="BooleanHitSumm"/>
          </xsl:when>
        </xsl:choose>
      </qui:block>
    </xsl:if>
  </xsl:template>

  <xsl:template name="SimpleHitSumm">
    <xsl:value-of select="HitCount"/>
    <xsl:value-of select="key('get-lookup','results.str.3')"/>
    <xsl:apply-templates mode="HitSummPl" select="HitCount"/>
    <xsl:value-of select="key('get-lookup','results.str.4')"/>
    <xsl:if test="HitRegionsCount">
      <xsl:value-of select="HitRegionsCount"/>
      <xsl:value-of select="key('get-lookup','results.str.5')"/>
      <xsl:value-of select="AllRegionCount"/>
      <xsl:text>&#xa0;</xsl:text>
    </xsl:if>
    <xsl:value-of select="dlxs:stripEndingChars(HitRegion,'s')"/>
    <xsl:apply-templates mode="HitSummPl" select="AllRegionCount"/>
  </xsl:template>

  <xsl:template name="BooleanHitSumm">
    <xsl:choose>
      <xsl:when test="child::*">
        <xsl:value-of select="HitRegionsCount"/>
        <xsl:value-of select="key('get-lookup','results.str.6')"/>
        <xsl:value-of select="dlxs:stripEndingChars(HitRegion,'s')"/>
        
        <xsl:apply-templates mode="HitSummPl" select="HitRegionsCount"/>
        <xsl:value-of select="key('get-lookup','results.str.7')"/>
        <xsl:value-of select="AllRegionCount"/>
        <xsl:value-of select="key('get-lookup','results.str.8')"/>
        <xsl:value-of select="dlxs:stripEndingChars(HitRegion,'s')"/>
        <xsl:apply-templates mode="HitSummPl" select="AllRegionCount"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>  

  <xsl:template match="*" mode="HitSummPl">
    <xsl:choose>
      <xsl:when test=".!=1">
        <xsl:if test="name()='HitCount'">
          <xsl:value-of select="key('get-lookup','results.str.31')"/>
        </xsl:if>
        <xsl:value-of select="key('get-lookup','results.str.32')"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>