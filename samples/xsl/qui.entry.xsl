<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template name="build-head-block">
    <qui:block slot="meta-social">
      <xsl:call-template name="build-social-twitter" />
      <xsl:call-template name="build-social-facebook" />
    </qui:block>
  </xsl:template>

  <xsl:template name="build-body-main">
    <xsl:call-template name="build-results-navigation" />
    <xsl:call-template name="build-asset-viewer-configuration" />
    <xsl:call-template name="build-record" />
    <xsl:call-template name="build-action-panel" />
    <qui:message>BOO-YAH</qui:message>
  </xsl:template>

  <xsl:template name="build-results-navigation">
    <!-- do we have M/N available in the PI handler? -->
    <xsl:variable name="tmp-xml">
      <qui:nav total="{//TotalResults}" index="{/Top/Self/Url/@index}">
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
      <qui:link rel="{$rel}" href="{$href}" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-asset-viewer-configuration">
    <xsl:variable name="config" select="//MiradorConfig" />
    <xsl:variable name="publisher" select="//Publisher/Value" />
    <qui:viewer
      manifest-id="{$config/@manifest-id}"
      canvas-index="{$config/@canvas-index}"
      mode="{$config/@mode}"
      auth-check="{//MediaInfo/AuthCheck/@allowed}"
      mimetype="{//MediaInfo/mimetype}"
      width="{//MediaInfo/width}"
      height="{//MediaInfo/height}"
      levels="{//MediaInfo/Levels}"
      collid="{//MediaInfo/ic_collid}"
      m_id="{//MediaInfo/m_id}"
      m_iid="{//MediaInfo/m_iid}" />
  </xsl:template>

  <xsl:template name="build-record">
    <qui:block>
      <xsl:call-template name="build-record-header" />
      <xsl:call-template name="build-record-metadata" />
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

  <xsl:template name="build-record-metadata">
    <xsl:apply-templates select="//Record[@name='entry']/Section" />
  </xsl:template>

  <xsl:template match="Section">
    <qui:section name="{@name}">
      <xsl:apply-templates select="Field" />
    </qui:section>
  </xsl:template>

  <xsl:template match="Field">
    <qui:field key="{@abbrev}">
      <qui:label>
        <xsl:value-of select="Label" />
      </qui:label>
      <qui:values>
        <xsl:for-each select="Values/Value">
          <qui:value>
            <xsl:apply-templates select="." />
          </qui:value>
        </xsl:for-each>
      </qui:values>
    </qui:field>
  </xsl:template>

  <xsl:template match="Value[@link]">
    <qui:link href="{@link}"><xsl:value-of select="." /></qui:link>
  </xsl:template>

  <xsl:template match="Value">
    <xsl:apply-templates select="." mode="copy-guts" />
  </xsl:template>

  <xsl:template match="Value/Highlight" mode="copy" priority="100">
    <xhtml:span class="{@class}" data-result-seq="{@seq}"><xsl:value-of select="." /></xhtml:span>
  </xsl:template>

  <xsl:template name="build-action-panel">
    <!-- context -->
    <qui:panel>
    </qui:panel>

    <!-- download options -->
    <qui:panel>
      
    </qui:panel>

    <!-- links for robots -->
    <qui:panel>
    </qui:panel>
  </xsl:template>

  <xsl:template name="build-head-title">
    <qui:values>
      <qui:value>
        <xsl:call-template name="get-record-title" />
      </qui:value>
      <qui:value>
        <xsl:call-template name="get-collection-title" />
      </qui:value>
    </qui:values>
  </xsl:template>

</xsl:stylesheet>