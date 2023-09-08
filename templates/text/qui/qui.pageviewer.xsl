<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:qui="http://dlxs.org/quombat/ui" extension-element-prefixes="exsl" >
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />
  <xsl:strip-space elements="*"/>

  <xsl:variable name="has-plain-text" select="//ViewSelect/Option[Value='text']" />

  <xsl:template name="build-head-block">
    <!-- <xsl:call-template name="build-social-twitter" />
    <xsl:call-template name="build-social-facebook" /> -->
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

  <xsl:template name="build-results-navigation-link">
    <xsl:param name="rel" />
    <xsl:param name="href" />
    <xsl:if test="normalize-space($href)">
      <qui:link rel="{$rel}" href="{normalize-space($href)}" identifier="{$href/@identifier|$href/@name}" marker="{$href/@marker}" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-asset-viewer-configuration">
    <xsl:variable name="behavior">
      <xsl:choose>
        <xsl:when test="//DocNavigation//Behavior">
          <xsl:value-of select="//DocNavigation//Behavior" />
        </xsl:when>
        <xsl:otherwise>continuous</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="mimetype">image/tiff</xsl:variable>
  
    <xsl:if test="true() or //MediaInfo/istruct_ms = 'P' and //MediaInfo/AuthCheck/@allowed = 'yes'">
      <qui:viewer 
        embed-href="https://roger.quod.lib.umich.edu/cgi/t/text/api/embed/{$collid}:{//CurrentCgi/Param[@name='idno']}" 
        manifest-id="https://roger.quod.lib.umich.edu/cgi/t/text/api/manifest/{$collid}:{//CurrentCgi/Param[@name='idno']}" 
        canvas-index="{//CurrentCgi/Param[@name='seq']}" 
        mode="{$behavior}" 
        auth-check="true" 
        mimetype="{$mimetype}" 
        width="{//MediaInfo/width}" 
        height="{//MediaInfo/height}" 
        levels="{//MediaInfo/Levels}" 
        collid="{$collid}" 
        >
        <xsl:if test="//MediaInfo/ViewerMaxSize">
          <xsl:attribute name="viewer-max-width"><xsl:value-of select="//MediaInfo/ViewerMaxSize/@width" /></xsl:attribute>
          <xsl:attribute name="viewer-max-height"><xsl:value-of select="//MediaInfo/ViewerMaxSize/@height" /></xsl:attribute>
        </xsl:if>
      </qui:viewer>
    </xsl:if>
    <!-- does this have an analog -->
    <xsl:if test="//MediaInfo/istruct_ms = 'P' and //MediaInfo/AuthCheck/@allowed = 'no'">
      <qui:callout icon="warning" variant="warning" slot="viewer" dismissable="false">
        <p>Access to this resource is restricted.</p>
      </qui:callout>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-action-panel">
    <qui:block slot="actions">
      <qui:download-options>
        <qui:download-item href="/cgi/t/text/pdf-idx?cc={/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']};idno={/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']};seq={//CurrentCgi/Params[@name='seq']}" file-type="PDF" type="FILE">
          Page PDF
        </qui:download-item>
        <qui:download-item href="/cgi/t/text/api/image/{/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']}:{/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']}:{//CurrentCgi/Params[@name='seq']}/full/full/0/default.jpg" file-type="JPEG" type="IMAGE">
          Page Image
        </qui:download-item>
        <xsl:if test="$has-plain-text">
            <qui:download-item href="/cgi/t/text/text-idx?cc={/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']};idno={/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']};seq={//CurrentCgi/Params[@name='seq']};view=text;tpl=plaintext.viewer" file-type="JPEG" type="IMAGE">
              Page Text
            </qui:download-item>
        </xsl:if>
        <qui:hr />
        <qui:download-item href="/cgi/t/text/request-pdf-idx?cc={/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']};idno={/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']}" file-type="PDF" type="FILE">
          <xsl:value-of select="key('get-lookup','results.str.container')"/>
        </qui:download-item>
      </qui:download-options>
    </qui:block>
  </xsl:template>

  <xsl:template name="build-record">

  </xsl:template>

  <xsl:template name="build-rights-statement">

  </xsl:template>

  <xsl:template name="build-related-links">

  </xsl:template>

  <xsl:template name="get-title">
    <xsl:value-of select="//qui:title" />
  </xsl:template>

</xsl:stylesheet>