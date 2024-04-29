<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl str date">

  <xsl:template name="build-head-block">
    <xsl:call-template name="build-social-twitter" />
    <xsl:call-template name="build-social-facebook" />
  </xsl:template>

  <xsl:template name="build-body-main">
    <xsl:call-template name="build-results-navigation" />
    <xsl:call-template name="build-breadcrumbs" />
    <xsl:call-template name="build-asset-viewer-configuration" />
    <xsl:call-template name="build-action-panel" />
    <xsl:call-template name="build-record" />
    <xsl:call-template name="build-rights-statement" />
    <xsl:call-template name="build-related-links" />
    <xsl:if test="//Callout">
      <xsl:apply-templates select="//Callout" />
    </xsl:if>
    <qui:message>BOO-YAH</qui:message>
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    <xsl:text>Item View</xsl:text>
  </xsl:template>

  <xsl:template name="build-breadcrumbs-xx">
    <qui:nav role="breadcrumb">
      <qui:link href="{normalize-space(/Top/Home)}">
        <xsl:text>Home</xsl:text>
      </qui:link>
      <xsl:if test="normalize-space(/Top/BackLink)">
        <qui:link href="{normalize-space(/Top/BackLink)}" identifier="{/Top/BackLink/@identifier}">
          <xsl:text>Search Results</xsl:text>
        </qui:link>
      </xsl:if>
      <qui:link href="{normalize-space(/Top//CurrentUrl)}" identifier="{//EntryWindowName}" current="true">
        <!-- <xsl:call-template name="get-record-title" /> -->
        <xsl:text>Item View</xsl:text>
      </qui:link>
    </qui:nav>
  </xsl:template>

  <xsl:template name="build-results-navigation">
    <!-- do we have M/N available in the PI handler? -->
    <xsl:variable name="tmp-xml">
      <qui:nav role="results" total="{normalize-space(//TotalResults)}" index="{/Top/Self/Url/@index}">
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">back</xsl:with-param>
          <xsl:with-param name="href" select="/Top/BackLink" />
        </xsl:call-template>
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">next</xsl:with-param>
          <xsl:with-param name="href" select="/Top/Next/Url" />
        </xsl:call-template>
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">previous</xsl:with-param>
          <xsl:with-param name="href" select="/Top/Prev/Url" />
        </xsl:call-template>
      </qui:nav>
    </xsl:variable>

    <xsl:variable name="tmp" select="exsl:node-set($tmp-xml)" />

    <xsl:if test="$tmp//qui:link">
      <xsl:apply-templates select="$tmp" mode="copy" />
    </xsl:if>

  </xsl:template>

  <xsl:template name="build-results-navigation-link">
    <xsl:param name="rel" />
    <xsl:param name="href" />
    <xsl:if test="normalize-space($href)">
      <qui:link rel="{$rel}" href="{normalize-space($href)}" identifier="{$href/@identifier|$href/@name}" marker="{$href/@marker}" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-asset-viewer-configuration">
    <xsl:variable name="config" select="//MiradorConfig" />
    <xsl:variable name="publisher" select="//Publisher/Value" />
    <xsl:if test="//MediaInfo/istruct_ms = 'P' and //MediaInfo/AuthCheck/@allowed = 'yes'">
      <qui:viewer 
        access="allowed"
        embed-href="{$config/@embed-href}" 
        manifest-id="{$config/@manifest-href}" 
        canvas-index="{$config/@canvas-index}" 
        mode="{$config/@mode}" 
        auth-check="{//MediaInfo/AuthCheck/@allowed}" 
        mimetype="{//MediaInfo/mimetype}" 
        istruct_mt="{//MediaInfo/istruct_mt}" 
        width="{//MediaInfo/width}" 
        height="{//MediaInfo/height}" 
        levels="{//MediaInfo/Levels}" 
        collid="{//MediaInfo/ic_collid}" 
        m_id="{//MediaInfo/m_id}" 
        m_iid="{//MediaInfo/m_iid}">
        <xsl:if test="//MediaInfo/ViewerMaxSize">
          <xsl:attribute name="viewer-max-width"><xsl:value-of select="//MediaInfo/ViewerMaxSize/@width" /></xsl:attribute>
          <xsl:attribute name="viewer-max-height"><xsl:value-of select="//MediaInfo/ViewerMaxSize/@height" /></xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="//MediaInfo/AuthCheck/@viewer-advisory" mode="copy" />
      </qui:viewer>
    </xsl:if>
    <xsl:if test="//MediaInfo/istruct_ms = 'P' and //MediaInfo/AuthCheck/@allowed = 'no'">
      <xsl:variable name="possible" select="//AuthCheck/@possible" />
      <xsl:choose>
        <xsl:when test="$possible = 'yes'">
          <qui:viewer access="possible" />
        </xsl:when>
        <xsl:when test="$possible = 'no'">
          <qui:viewer access="restricted" m_entryauth="{//AuthCheck/@m_entryauth}" />
        </xsl:when>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-record">
    <xsl:call-template name="build-record-header" />
    <qui:block slot="record">
      <xsl:call-template name="build-related-views" />
      <xsl:call-template name="build-record-metadata" />
      <xsl:call-template name="build-record-technical-metadata" />
    </qui:block>
    <qui:block slot="special">
      <xsl:call-template name="build-special-metadata" />
    </qui:block>
    <qui:field slot="citation" rel="full">
      <qui:values>
        <qui:value>
          <xsl:apply-templates select="//RecordCitation[@format='full']" mode="copy-guts" />
        </qui:value>
      </qui:values>
    </qui:field>
    <!-- <qui:field key="full-citation">
      <qui:values>
        <qui:value>
          <xsl:text>"</xsl:text>
          <xsl:value-of select="$title" />
          <xsl:text>". </xsl:text>
          <xhtml:span>
            <xsl:value-of select="ItemUrl" disable-output-escaping="yes" />
          </xhtml:span>
          <xsl:text>. </xsl:text>
          <xsl:text>University of Michigan Library Digital Collections. </xsl:text>
          <xsl:text>Accessed: </xsl:text>
          <xsl:value-of select="concat(date:month-name(), ' ', date:day-in-month(), ', ', date:year(), '.')" />
        </qui:value>
      </qui:values>
    </qui:field> -->
  </xsl:template>

  <xsl:template name="build-record-header">
    <qui:header role="main">
      <xsl:call-template name="get-record-title" />
    </qui:header>
  </xsl:template>

  <xsl:template name="get-record-title">
    <xsl:for-each select="//Record[@name='special']//Field[@abbrev='dlxs_ma']//Value">
      <xsl:value-of select="." />
      <xsl:if test="position() &lt; last()">
        <xsl:text> / </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="build-related-views">
    <xsl:if test="//RelatedViews/View">
      <qui:section name="Related Views" slug="related_views">
        <xsl:apply-templates select="//RelatedViews/View" />
      </qui:section>
    </xsl:if>
  </xsl:template>

  <xsl:template match="View">
    <qui:view-grid name="{Name}">
      <xsl:for-each select=".//Column[@blank='no']">
        <qui:view x="{@x}" y="{@y}" type="{Type}">
          <xsl:if test="Url[@name='Thumb']">
            <qui:link rel="iiif" href="{Url[@name='Thumb']}" />
          </xsl:if>
          <qui:link rel="result" href="{Url[@name='EntryLink']}" />
          <qui:caption>
            <qui:values>
              <xsl:for-each select="Caption">
                <qui:value><xsl:value-of select="." /></qui:value>
              </xsl:for-each>
            </qui:values>
          </qui:caption>
        </qui:view>
      </xsl:for-each>
    </qui:view-grid>
  </xsl:template>

  <xsl:template name="build-record-technical-metadata">
    <qui:section name="Technical Details" slug="technical_details">

      <qui:field key="collection">
        <qui:label>Collection</qui:label>
        <qui:values>
          <qui:value>
	    <qui:link href="/cgi/i/image/image-idx?c={//CurrentCgi/Param[@name='cc']}">
              <xsl:value-of select="//CollName/Full" />
            </qui:link>
          </qui:value>
        </qui:values>
      </qui:field>

      <xsl:if test="normalize-space(//MediaInfo/istruct_ms) = 'P'">
        <xsl:if test="//MediaInfo/Type = 'image'">
          <qui:field key="image_size">
            <qui:label>Image Size</qui:label>
            <qui:values>
              <qui:value>
                <xsl:value-of select="/Top/MediaInfo/width" />
                <xsl:text> x </xsl:text>
                <xsl:value-of select="/Top/MediaInfo/height" />
              </qui:value>
            </qui:values>
          </qui:field>
        </xsl:if>
        <xsl:if test="/Top/MediaInfo/ReportedSize">
          <qui:field key="reported_size">
            <qui:label>File Size</qui:label>
            <qui:values>
              <qui:value>
                <xsl:value-of select="/Top/MediaInfo/ReportedSize" />
              </qui:value>
            </qui:values>
          </qui:field>
        </xsl:if>
      </xsl:if>

      <qui:field key="m_id">
        <qui:label>Record</qui:label>
        <qui:values>
          <qui:value>
            <xsl:value-of select="/Top/EntryId" />
          </qui:value>
        </qui:values>
      </qui:field>

      <qui:field key="bookmark" component="input">
        <qui:label>Link to this Item</qui:label>
        <qui:values>
          <qui:value>
            <xsl:value-of select="/Top/ItemUrl" />
          </qui:value>
        </qui:values>
      </qui:field>

    </qui:section>
  </xsl:template>

  <xsl:template name="build-record-metadata">
    <xsl:apply-templates select="//Record[@name='entry']/Section" />
  </xsl:template>

  <xsl:template name="build-rights-statement">
    <xsl:variable name="rights" select="//Field[@abbrev='dc_ri' or @abbrev='dlxs_ri']/Values/Value" />
    <qui:block slot="rights-statement">
      <xsl:choose>
        <xsl:when test="$rights = 'CC BY-SA' or $rights = 'CC-BY-SA'">
          <qui:creative-commons-link license="CC-BY-SA" />
        </xsl:when>
        <xsl:when test="//MediaInfo/m_pd = '1'">
          <xhtml:p>This item is in the public domain.</xhtml:p>
        </xsl:when>
        <xsl:when test="$rights/p">
          <xsl:apply-templates select="$rights" mode="copy-guts" />
        </xsl:when>
        <xsl:otherwise>
          <xhtml:p>
            <xsl:apply-templates select="$rights" mode="copy-guts" />
          </xhtml:p>
        </xsl:otherwise>
      </xsl:choose>
    </qui:block>
  </xsl:template>

  <xsl:template name="build-special-metadata">
    <xsl:apply-templates select="//Record[@name='special']/Section/Field" />
  </xsl:template>

  <xsl:template match="//Record[@name='special']/Section/Field[@abbrev='dlxs_ma']" priority="100" />

  <xsl:template match="//Record[@name='entry']//Field[@abbrev='dlxs_catalog']" priority="100">
    <xsl:message>AHOY</xsl:message>
  </xsl:template>

  <xsl:template match="Field[@abbrev='dlxs_catalog']" priority="99">
    <xsl:apply-templates select="." mode="system-link">
      <xsl:with-param name="component">catalog-link</xsl:with-param>
      <xsl:with-param name="label">Catalog Record</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="Field[@abbrev='dlxs_hathitrust']" priority="99">
    <xsl:apply-templates select="." mode="system-link">
      <xsl:with-param name="label">HathiTrust</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="Field[@abbrev='dlxs_findaid']" priority="99">
    <xsl:apply-templates select="." mode="system-link">
      <xsl:with-param name="label">Finding Aid</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="build-related-links">
    <qui:block slot="related-links">
      <xsl:apply-templates select="//Record[@name='special']//Field[@abbrev='dlxs_catalog']" mode="system-link">
        <xsl:with-param name="component">catalog-link</xsl:with-param>
        <xsl:with-param name="label">Catalog Record</xsl:with-param>
      </xsl:apply-templates>
      <xsl:call-template name="build-extra-holdings-links">
        <xsl:with-param name="dlxs_catalog" select="//Record[@name='special']//Field[@abbrev='dlxs_catalog']" />
      </xsl:call-template>
      <xsl:apply-templates select="//Record[@name='special']//Field[@abbrev='dlxs_hathitrust']" mode="system-link">
        <xsl:with-param name="label">HathiTrust</xsl:with-param>
      </xsl:apply-templates>
      <xsl:apply-templates select="//Record[@name='special']//Field[@abbrev='dlxs_findaid']" mode="system-link">
        <xsl:with-param name="label">Finding Aid</xsl:with-param>
      </xsl:apply-templates>
    </qui:block>
  </xsl:template>

  <xsl:template name="build-extra-holdings-links" />

  <xsl:template name="build-page-navigator">
    <qui:page-navigator>
      <qui:anchor href="#actions" label="Actions" />
      <qui:anchor href="#details" label="Details">
        <xsl:call-template name="build-page-navigator-metadata" />
      </qui:anchor>
      <qui:anchor href="#rights-statement" label="Rights Statement" />
      <qui:anchor href="#related-links" label="Related Links">
        <xsl:if test="/Top/BookBagForm[ActionAllowed='1'][@action='add'] or /Top/Portfolios[@type='private']/Portfolio">
          <qui:anchor href="#private-list" label="In your portfolios" />
        </xsl:if>
        <xsl:if test="/Top/Portfolios[@type='public']/Portfolio">
          <qui:anchor href="#public-list" label="In public portfolios" />
        </xsl:if>
      </qui:anchor>
    </qui:page-navigator>
  </xsl:template>

  <xsl:template name="build-page-navigator-metadata">
    <xsl:if test="//Record[@name='entry']/Section[@name != 'default']">
      <qui:anchor href="#item_details" label="Item Details" />
    </xsl:if>
    <xsl:for-each select="//Record[@name='entry']/Section[@name != 'default']">
      <qui:anchor href="#{@class}" label="{@name}">
        <!-- <xsl:value-of select="@name" /> -->
      </qui:anchor>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="build-action-panel">
    <qui:block slot="actions">
      <!-- download options -->
      <xsl:if test="//MediaInfo/istruct_ms = 'P' and //MediaInfo/AuthCheck/@allowed = 'yes'">
        <xsl:variable name="type">
          <xsl:choose>
            <xsl:when test="normalize-space(/Top/MediaInfo/type[@class='imgInfHashRef'])">
              <xsl:value-of select="/Top/MediaInfo/type[@class='imgInfHashRef']" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="//MediaInfo/istruct_mt" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <qui:download-options>
          <xsl:attribute name="label">
            <xsl:value-of select="key('gui-txt', $type)" />
          </xsl:attribute>
          <xsl:apply-templates select="//ImageSizeTool" />
        </qui:download-options>
      </xsl:if>

      <xsl:call-template name="build-action-panel-portfolio" />

      <xsl:call-template name="build-action-panel-iiif-link" />

      <xsl:call-template name="build-action-panel-extra" />

    </qui:block>

  </xsl:template>

  <xsl:template name="build-action-panel-extra" />

  <xsl:template match="ImageSizeTool">
    <xsl:apply-templates select="Level" />
  </xsl:template>

  <xsl:template match="Level[FileType!='NA']">
    <xsl:variable name="part" select="Part[@name='MediaLink']" />
    <qui:download-item height="{LevelHeight}" width="{LevelWidth}" href="{$part}" file-type="{FileType}" asset-type="{Type}">
      <xsl:apply-templates select="@slot" mode="copy" />
      <xsl:apply-templates select="$part/@filename" mode="copy" />
      <xsl:if test="FileTypeIsZipCompressed = 'TRUE'">
        <xsl:attribute name="file-type-is-zip-compressed">true</xsl:attribute>
      </xsl:if>
    </qui:download-item>
  </xsl:template>

  <xsl:template name="get-head-title">
    <qui:values>
      <qui:value>
        <xsl:call-template name="get-record-title" />
      </qui:value>
      <qui:value>
        <xsl:call-template name="get-collection-title" />
      </qui:value>
    </qui:values>
  </xsl:template>

  <xsl:template name="build-action-panel-portfolio">
    <xsl:if test="/Top/BookBagForm[ActionAllowed='1'][@action='add'] or /Top/Portfolios/Portfolio">

      <xsl:if test="/Top/BookBagForm[ActionAllowed='1'][@action='add']">
        <xsl:variable name="xx-has-favorited" select="normalize-space(//Portfolios/Portfolio/Field[@name='action']/Action[@type='bbdel']/Url) != ''" />
        <xsl:variable name="has-favorited" select="false()" />
        <xsl:variable name="bbaction">
          <xsl:choose>
            <xsl:when test="$has-favorited = 'true'">
              <xsl:text>remove</xsl:text>
            </xsl:when>
            <xsl:otherwise>add</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>

        <qui:form rel="add">
          <xsl:apply-templates select="/Top/BookBagForm[@action='add']/HiddenVars" />
          <qui:hidden-input name="backlink" value="{/Top/BookBagForm[@action='add']/BackLink}" />
        </qui:form>
      </xsl:if>

      <xsl:if test="/Top/Portfolios/Portfolio[@mine='true']">
        <qui:portfolio-list type="private">
          <xsl:apply-templates select="/Top/Portfolios/Portfolio[@mine='true']" />
        </qui:portfolio-list>
      </xsl:if>

      <xsl:if test="/Top/Portfolios/Portfolio[not(@mine)]">
        <qui:portfolio-list type="public">
          <xsl:apply-templates select="/Top/Portfolios/Portfolio[not(@mine)]" />
        </qui:portfolio-list>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="Portfolio">
    <qui:portfolio id="{@id}">
      <xsl:variable name="bbdbid" select="@id" />
      <qui:title><xsl:value-of select="Field[@name='bbagname']" /></qui:title>
      <xsl:for-each select="Field[@name='action']/Action">
        <qui:link href="{Url}" rel="{@type}" />
      </xsl:for-each>
      <xsl:apply-templates select="//BookBagForm[@action='remove'][.//Variable[@name='bbdbid'] = $bbdbid]" />
      <xsl:for-each select="Field">
        <xsl:choose>
          <xsl:when test="@name = 'action'"></xsl:when>
          <xsl:otherwise>
            <qui:field key="{@name}">
              <qui:values>
                <xsl:choose>
                  <xsl:when test="@name = 'shared'">
                    <xsl:choose>
                      <xsl:when test="Public = '0'">private</xsl:when>
                      <xsl:otherwise>public</xsl:otherwise>
                    </xsl:choose>
                  </xsl:when>
                  <xsl:when test="@name = 'username'">
                    <xsl:for-each select="str:split(., ' ')">
                      <qui:value><xsl:value-of select="." /></qui:value>
                    </xsl:for-each>
                  </xsl:when>
                  <xsl:otherwise>
                    <qui:value>
                      <xsl:value-of select="." />
                    </qui:value>
                  </xsl:otherwise>
                </xsl:choose>
              </qui:values>
            </qui:field>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:for-each>
    </qui:portfolio>
  </xsl:template>

  <xsl:template match="BookBagForm[@action='remove']">
    <qui:form rel="remove">
      <xsl:for-each select=".//Variable">
        <qui:hidden-field name="{@name}" value="{.}" />
      </xsl:for-each>
    </qui:form>
  </xsl:template>

  <xsl:template name="build-action-panel-iiif-link">
    <xsl:if test="normalize-space(//MiradorConfig/@manifest-id)">
      <qui:link rel="iiif-manifest" href="{//MiradorConfig/@manifest-id}" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="get-canonical-link">
    <xsl:value-of select="//ItemUrl" />
  </xsl:template>

  <xsl:template match="Callout">
    <qui:callout variant='success' slot="actions">
      <xhtml:p>
        <xsl:value-of select="num_added" />
        <xsl:text> item</xsl:text>
        <xsl:if test="num_added &gt; 1">
          <xsl:text>s</xsl:text>
        </xsl:if>
        <xsl:text> added to </xsl:text>
        <xhtml:a href="/cgi/i/image/image-idx?type=bbaglist;view=bbreslist;bbdbid={bbdbid}">
          <xsl:value-of select="bbname" />
        </xhtml:a>
      </xhtml:p>
    </qui:callout>
  </xsl:template>
</xsl:stylesheet>
