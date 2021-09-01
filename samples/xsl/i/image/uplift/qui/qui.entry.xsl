<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

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
    <qui:message>BOO-YAH</qui:message>
  </xsl:template>

  <xsl:template name="build-breadcrumbs">
    <qui:nav role="breadcrumb">
      <qui:link href="{/Top/Home}">
        <xsl:value-of select="/Top/Banner/Text" />
      </qui:link>
      <xsl:if test="normalize-space(/Top/BackLink)">
        <qui:link href="{/Top/BackLink}" identifier="{/Top/BackLink/@identifier}">
          <xsl:text>Search Results</xsl:text>
        </qui:link>
      </xsl:if>
      <qui:link href="{/Top//CurrentUrl}" identifier="{//EntryWindowName}" current="true">
        <xsl:call-template name="get-record-title" />
      </qui:link>
    </qui:nav>
  </xsl:template>

  <xsl:template name="build-results-navigation">
    <!-- do we have M/N available in the PI handler? -->
    <xsl:variable name="tmp-xml">
      <qui:nav role="results" total="{//TotalResults}" index="{/Top/Self/Url/@index}">
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
      <qui:link rel="{$rel}" href="{$href}" identifier="{$href/@identifier|$href/@name}" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-asset-viewer-configuration">
    <xsl:variable name="config" select="//MiradorConfig" />
    <xsl:variable name="publisher" select="//Publisher/Value" />
    <qui:viewer embed-href="{$config/@embed-href}" manifest-id="{$config/@manifest-href}" canvas-index="{$config/@canvas-index}" mode="{$config/@mode}" auth-check="{//MediaInfo/AuthCheck/@allowed}" mimetype="{//MediaInfo/mimetype}" width="{//MediaInfo/width}" height="{//MediaInfo/height}" levels="{//MediaInfo/Levels}" collid="{//MediaInfo/ic_collid}" m_id="{//MediaInfo/m_id}" m_iid="{//MediaInfo/m_iid}" />
  </xsl:template>

  <xsl:template name="build-record">
    <xsl:call-template name="build-record-header" />
    <qui:block slot="record">
      <xsl:call-template name="build-record-technical-metadata" />
      <xsl:call-template name="build-record-metadata" />
    </qui:block>
    <qui:block slot="special">
      <xsl:call-template name="build-special-metadata" />
    </qui:block>
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

      <qui:field key="m_id">
        <qui:label>Record</qui:label>
        <qui:values>
          <qui:value>
            <xsl:value-of select="/Top/EntryId" />
          </qui:value>
        </qui:values>
      </qui:field>

      <qui:field key="bookmark" component="input">
        <qui:label>Bookmark</qui:label>
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
      <qui:download-options>
        <xsl:for-each select="//ImageSizeTool/Level">
          <qui:download-item height="{LevelHeight}" width="{LevelWidth}" href="{Part[@name='MediaLink']}"></qui:download-item>
        </xsl:for-each>
      </qui:download-options>

      <xsl:call-template name="build-action-panel-portfolio" />

      <xsl:call-template name="build-action-panel-iiif-link" />

    </qui:block>

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
        <xsl:variable name="has-favorited">false</xsl:variable>
        <xsl:variable name="bbaction">
          <xsl:choose>
            <xsl:when test="$has-favorited = 'true'">
              <xsl:text>remove</xsl:text>
            </xsl:when>
            <xsl:otherwise>add</xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <qui:favorite-form action="{$bbaction}" checked="{$has-favorited}">
          <xsl:apply-templates select="/Top/BookBagForm[@action=$bbaction]/HiddenVars" />
        </qui:favorite-form>
      </xsl:if>

      <xsl:if test="/Top/Portfolios[@type='private']/Portfolio">
        <qui:portfolio-list type="private">
          <xsl:for-each select="/Top/Portfolios[@type='private']/Portfolio">
            <qui:portfolio-link href="{Field[@name='action' ]/Action[@type='open']/Url}" editable="true" bbdid="{@id}" bbidno="{/Top/BookBagForm[@action='add']//Variable[@name='bbidno']}">
              <qui:title>
                <xsl:value-of select="Field[@name='bbagname']" />
              </qui:title>
              <qui:count>
                <xsl:value-of select="Field[@name='itemcount']" />
              </qui:count>
              <qui:owner>
                <xsl:value-of select="Field[@name='username']" />
              </qui:owner>
            </qui:portfolio-link>
          </xsl:for-each>
        </qui:portfolio-list>
      </xsl:if>

      <xsl:if test="/Top/Portfolios[@type='public']/Portfolio">
        <qui:portfolio-list type="public">
          <xsl:for-each select="/Top/Portfolios[@type='public']/Portfolio">
            <qui:portfolio-link href="{Field[@name='action' ]/Action[@type='open']/Url}" editable="false" bbdid="{@id}" bbidno="{/Top/BookBagForm[@action='add']//Variable[@name='bbidno']}">
              <qui:title>
                <xsl:value-of select="Field[@name='bbagname']" />
              </qui:title>
              <qui:count>
                <xsl:value-of select="Field[@name='itemcount']" />
              </qui:count>
              <qui:owner>
                <xsl:value-of select="Field[@name='username']" />
              </qui:owner>
            </qui:portfolio-link>
          </xsl:for-each>
        </qui:portfolio-list>
      </xsl:if>

    </xsl:if>
  </xsl:template>

  <xsl:template name="build-action-panel-iiif-link">
    <qui:link rel="iiif-manifest" href="{//MiradorConfig/@manifest-id}" />
  </xsl:template>

  <xsl:template name="get-canonical-link">
    <xsl:value-of select="//ItemUrl" />
  </xsl:template>

</xsl:stylesheet>