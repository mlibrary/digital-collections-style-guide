<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />

  <xsl:variable name="current-browse-field" select="'picklist'" />

  <xsl:variable name="volume-header">
    <xsl:value-of select="key('get-lookup','headerutils.str.volume')"/>
  </xsl:variable>

  <xsl:variable name="issue-header">
    <xsl:value-of select="key('get-lookup','headerutils.str.issue')"/>
  </xsl:variable>
 
  <xsl:variable name="format">
    <xsl:call-template name="get-picklist-format"></xsl:call-template>
  </xsl:variable>

  <xsl:variable name="main-title">
    <xsl:choose>
      <xsl:when test="$format = 'Volume/Issue'">
        <xsl:value-of select="key('get-lookup','uplift.picklist.str.browseVolIss')"/>
      </xsl:when>
      <xsl:when test="$format = 'Volume'">
        <xsl:value-of select="key('get-lookup','uplift.picklist.str.browseVol')"/>
      </xsl:when>
      <xsl:when test="$format = 'Issue'">
        <xsl:value-of select="key('get-lookup','uplift.picklist.str.browseIss')"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="key('get-lookup','uplift.picklist.str.morethanoneitem')"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="build-body-main">
    <xsl:call-template name="build-results-navigation" />
    <xsl:call-template name="build-browse-navigation" />
    <xsl:call-template name="build-breadcrumbs" />

    <qui:header role="main">
      <xsl:text>Browse Collection: </xsl:text>
      <xsl:value-of select="$main-title" />
    </qui:header>

    <xsl:apply-templates select="/Top/Picklist" />

  </xsl:template>

  <xsl:template match="Picklist">
    <qui:block slot="results" data-key="{Format}">
      <xsl:choose>
        <xsl:when test="Volume">
          <xsl:call-template name="build-picklist-results-volume" />
        </xsl:when>
        <xsl:when test="Issue">
          <xsl:call-template name="build-picklist-results-issue" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:call-template name="build-picklist-results-item" />
        </xsl:otherwise>
      </xsl:choose>

    </qui:block>
  </xsl:template>


  <xsl:template name="build-picklist-results-volume">
    <xsl:for-each select="Volume">
      <xsl:sort order="descending" data-type="number" select="VOLNO"/>
      <xsl:call-template name="group-by-volume"/>
    </xsl:for-each>    
  </xsl:template>

  <xsl:template name="build-picklist-results-issue">
  </xsl:template>

  <xsl:template name="build-picklist-results-item">
    <xsl:for-each select="Item">
      <xsl:variable name="encoding-type">
        <xsl:choose>
          <xsl:when test="DocEncodingType">
            <xsl:value-of select="normalize-space(DocEncodingType)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="normalize-space(parent::*/DocEncodingType)"/>
          </xsl:otherwise>
        </xsl:choose>
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

      <xsl:variable name="identifier" select="translate(ItemHeader/HEADER/FILEDESC/PUBLICATIONSTMT/IDNO[@TYPE='dlps' or @TYPE='DLPS'], 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />

      <qui:section type="item" identifier="{$identifier}" auth-required="{AuthRequired}" encoding-type="{$encoding-type}" encoding-level="{$item-encoding-level}">
        <!-- <xsl:if test="ItemHeader/HEADER/@TYPE = 'restricted'">
          <xsl:attribute name="access">restricted</xsl:attribute>
        </xsl:if> -->
        <xsl:choose>
          <xsl:when test="HEADER/@TYPE='restricted'">
            <xsl:attribute name="access">restricted</xsl:attribute>
          </xsl:when>
          <xsl:when test="ItemAccessState != 'fullaccessallowed'">
            <xsl:attribute name="access"><xsl:value-of select="ItemAccessState" /></xsl:attribute>
          </xsl:when>
          <xsl:otherwise />
        </xsl:choose>
        <qui:link rel="result" href="{Url}" />
        <qui:link rel="iiif" href="{$api_url}/cgi/t/text/api/image/{$collid}:{$identifier}:1/full/!250,250/0/default.jpg" />
        <xsl:apply-templates select="ItemHeader/HEADER[@TYPE='tombstone']" mode="build-tombstone-link" />
        <xsl:call-template name="build-header-metadata">
          <xsl:with-param name="item" select="." />
          <xsl:with-param name="encoding-type" select="$encoding-type" />
          <xsl:with-param name="item-encoding-level" select="$item-encoding-level" />
          <xsl:with-param name="slot">metadata</xsl:with-param>
        </xsl:call-template>  
      </qui:section>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="get-picklist-format">
    <xsl:choose>
      <xsl:when test="/Top/Picklist/Format">
        <xsl:value-of select="/Top/Picklist/Format"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Unknown</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-title">
    <xsl:text>Browse Collection | </xsl:text>
    <xsl:value-of select="$main-title" />
  </xsl:template>

  <xsl:template name="build-browse-navigation">
    <xsl:if test="//CollectionIdno">
      <qui:nav role="browse">
        <qui:link key="picklist" href="/cgi/t/text/text-idx?idno={//CollectionIdno}" current="true">
          <qui:label>
            <xsl:value-of select="key('get-lookup', 'uplift.picklist.str.morethanoneitem')" />
          </qui:label>
        </qui:link>
        <xsl:for-each select="/Top/NavHeader/BrowseFields/Field">
          <qui:link href="{Link}" key="{Name}">
            <qui:label>
              <xsl:value-of select="key('get-lookup', concat('browse.str.', Name, '.column'))" />
              <!-- <xsl:value-of select="dlxs:capitalize(Name)" /> -->
            </qui:label>
          </qui:link>
        </xsl:for-each>
      </qui:nav>
    </xsl:if>    
  </xsl:template>

  <xsl:template name="build-results-navigation" />  

  <xsl:template name="get-current-page-breadcrumb-label">
    Browse Collection
  </xsl:template>

  <xsl:template name="group-by-volume">
    <qui:section type="volume" identifier="{IDNO[@TYPE='dlps' or @TYPE='DLPS']}">
      <xsl:call-template name="build-volume-group" />
      <xsl:call-template name="iterate-issues" />  
    </qui:section>
  </xsl:template>

  <xsl:template name="build-volume-group">
    <xsl:variable name="volume-number" select="VOLNO" />
    <qui:header>
      <qui:link rel="volume" href="{Url}" />
      <qui:title>
        <xsl:choose>
          <xsl:when test="$volume-number = 'spec'">
            <xsl:value-of select="key('get-lookup','headerutils.str.spec')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$volume-header" />
            <xsl:text> </xsl:text>
            <xsl:value-of select="$volume-number" />
          </xsl:otherwise>
        </xsl:choose>
      </qui:title>
    </qui:header>
  </xsl:template>

  <xsl:template name="iterate-issues">
    <xsl:for-each select="Issue">
      <xsl:sort order="descending" data-type="text" select="DATE[@TYPE='sort']"/>
      <xsl:sort order="descending" data-type="number" select="ISSNO"/>

      <xsl:variable name="date">
        <xsl:choose>
          <xsl:when test="DATE[not(@TYPE='sort')]">
            <xsl:value-of select="DATE[not(@TYPE='sort')]"/>
          </xsl:when>
          <xsl:when test="DATE[@TYPE='sort']">
            <xsl:value-of select="DATE[@TYPE='sort']"/>
          </xsl:when>
          <xsl:otherwise/>
        </xsl:choose>  
      </xsl:variable>

      <qui:section type="issue" identifier="{IDNO[@TYPE='dlps' or @TYPE='DLPS']}">
        <qui:link rel="issue" href="{Url}" />
        <qui:header>
          <qui:title>
            <qui:values>
              <qui:value>
                <xsl:value-of select="key('get-lookup','headerutils.str.18')"/>
                <xsl:text> </xsl:text>
                <xsl:value-of select="ISSNO" />
              </qui:value>
              <xsl:if test="normalize-space($date)">
                <qui:value>
                  <xsl:value-of select="$date" />
                </qui:value>
              </xsl:if>
            </qui:values>
          </qui:title>
        </qui:header>
      </qui:section>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>