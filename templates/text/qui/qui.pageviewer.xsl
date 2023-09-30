<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" xmlns:qui="http://dlxs.org/quombat/ui" extension-element-prefixes="exsl date" >
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />
  <xsl:strip-space elements="*"/>

  <xsl:variable name="has-plain-text" select="//ViewSelect/Option[Value='text']" />
  <xsl:variable name="is-subj-search">yes</xsl:variable>
  <xsl:variable name="include-useguidelines-metadata">yes</xsl:variable>

  <xsl:variable name="idno" select="translate(//Param[@name='idno'], 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
  <xsl:variable name="seq" select="//Param[@name='seq']" />
  <xsl:variable name="label" select="//DocNavigation/PageNavForm/PageSelect/Option[Focus='true']/Label" />

  <xsl:variable name="item-metadata-tmp">
    <xsl:apply-templates select="/Top/DocMeta" mode="metadata" />
  </xsl:variable>
  <xsl:variable name="item-metadata" select="exsl:node-set($item-metadata-tmp)" />

  <xsl:template name="build-head-block">
    <!-- <xsl:call-template name="build-social-twitter" />
    <xsl:call-template name="build-social-facebook" /> -->
  </xsl:template>

  <xsl:template name="build-breadcrumbs-intermediate-links">
    <!-- header.str.contents ?? -->
    <xsl:if test="//DocMeta/TocHref">
      <qui:link href="{//DocMeta/TocHref}">
        <xsl:value-of select="key('get-lookup', 'uplift.str.contents')" />
      </qui:link>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-body-main">
    <xsl:call-template name="build-results-navigation" />
    <xsl:call-template name="build-breadcrumbs" />
    <xsl:call-template name="build-asset-viewer-configuration" />
    <xsl:call-template name="build-action-panel" />
    <xsl:call-template name="build-record" />
    <xsl:call-template name="build-rights-statement" />
    <xsl:call-template name="build-related-links" />
    <xsl:call-template name="build-item-search" />
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
        embed-href="{$api_url}/cgi/t/text/api/embed/{$collid}:{//CurrentCgi/Param[@name='idno']}:{//CurrentCgi/Param[@name='seq']}" 
        manifest-id="{$api_url}/cgi/t/text/api/manifest/{$collid}:{//CurrentCgi/Param[@name='idno']}" 
        canvas-index="{//CurrentCgi/Param[@name='seq']}" 
        mode="{$behavior}" 
        auth-check="true" 
        mimetype="{$mimetype}" 
        width="{//MediaInfo/width}" 
        height="{//MediaInfo/height}" 
        levels="{//MediaInfo/Levels}" 
        collid="{$collid}" 
        q1="{//Param[@name='q1']}"
        >
        <xsl:if test="$has-plain-text">
          <xsl:attribute name="has-ocr">true</xsl:attribute>
        </xsl:if>
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
      <qui:download-options label="Item">
        <qui:download-item href="{$api_url}/cgi/t/text/pdf-idx?cc={/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']};idno={/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']};seq={$seq}" file-type="PDF" type="FILE">
          Page PDF
        </qui:download-item>
        <qui:download-item href="{$api_url}/cgi/t/text/api/image/{/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']}:{/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']}:{$seq}/full/full/0/default.jpg" file-type="JPEG" type="IMAGE">
          Page Image
        </qui:download-item>
        <xsl:if test="$has-plain-text">
            <qui:download-item href="{$api_url}/cgi/t/text/text-idx?cc={/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']};idno={/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']};seq={$seq};view=text;tpl=plaintext.viewer" file-type="TEXT" type="TEXT">
              Page Text
            </qui:download-item>
        </xsl:if>
        <xsl:if test="//AllowFullPdfDownload = 'true'">
          <qui:hr />
          <qui:download-item href="{$api_url}/cgi/t/text/request-pdf-idx?cc={/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']};idno={/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']}" file-type="PDF" type="FILE">
            <xsl:value-of select="key('get-lookup','results.str.container')"/>
            <xsl:text> PDF</xsl:text>
          </qui:download-item>  
        </xsl:if>
      </qui:download-options>

      <xsl:call-template name="build-action-panel-portfolio" />

      <xsl:call-template name="build-action-panel-iiif-link" />

      <xsl:call-template name="build-action-panel-extra" />
    </qui:block>
  </xsl:template>

  <xsl:template name="build-action-panel-extra" />

  <xsl:template name="build-action-panel-portfolio">
    <xsl:choose>
      <xsl:when test="/Top/BookbagResults/Item[@idno=$idno]">
        <qui:form slot="bookbag" rel="remove" href="{/Top/BookbagResults/Item[@idno=$idno]/AddRemoveUrl}" data-identifier="{$idno}">
          <qui:hidden-input name="via" value="pageview" />
        </qui:form>
      </xsl:when>
      <xsl:when test="/Top/BookbagAddHref">
        <qui:form slot="bookbag" rel="add" href="{/Top/BookbagAddHref}" data-identifier="{$idno}">
          <qui:hidden-input name="via" value="pageview" />
        </qui:form>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-action-panel-iiif-link">
    <xsl:if test="true() or normalize-space(//MiradorConfig/@manifest-id)">
      <qui:link rel="iiif-manifest" href="{$api_url}/cgi/t/text/api/manifest/{$collid}:{//CurrentCgi/Param[@name='idno']}" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-record">
    <qui:header role="main">
      <xsl:value-of select="$item-metadata//qui:field[@key='title']//qui:value" />
      <xsl:text>: </xsl:text>
      <xsl:choose>
        <xsl:when test="$view = 'toc'">
          <xsl:value-of select="key('get-lookup', 'headerutils.str.title')" />
          <xsl:text> Contents</xsl:text>
        </xsl:when>
        <xsl:when test="$view = 'text'">
          <xsl:value-of select="key('get-lookup', 'headerutils.str.viewentiretext')" />
          <xsl:text> Entire Text</xsl:text>
        </xsl:when>
        <xsl:when test="normalize-space($label/PageNumber) and $label/PageNumber != 'viewer.nopagenum'">
          <qui:span data-key="canvas-label">
            <!-- Page no. -->
            <xsl:value-of select="key('get-lookup', 'headerutils.str.page')" />
            <xsl:value-of select="$label/PageNumber" />
            <xsl:if test="$label/PageType != 'viewer.ftr.uns'">
              <xsl:text> - </xsl:text>
              <xsl:value-of select="key('get-lookup', $label/PageType)" />  
            </xsl:if>
          </qui:span>
        </xsl:when>
        <xsl:when test="//CurrentCgi/Param[@name='seq']">
          <qui:span data-key="canvas-label">
            <xsl:value-of select="key('get-lookup', 'headerutils.str.page')" />
            <xsl:text> #</xsl:text>
            <xsl:value-of select="//CurrentCgi/Param[@name='seq']" />  
            <xsl:if test="$label/PageType != 'viewer.ftr.uns'">
              <xsl:text> - </xsl:text>
              <xsl:value-of select="key('get-lookup', $label/PageType)" />  
            </xsl:if>
          </qui:span>
        </xsl:when>
        <xsl:otherwise />
      </xsl:choose>  
    </qui:header>

    <qui:block slot="record">
      <xsl:apply-templates select="$item-metadata//qui:section" mode="copy" />
      <xsl:call-template name="build-record-technical-metadata" />
    </qui:block>

    <!-- <xsl:apply-templates select="$item-metadata" mode="copy" /> -->
    <!-- <xsl:call-template name="build-record-technical-metadata"> -->
      <!-- <xsl:with-param name="item" select="ItemHeader" />
      <xsl:with-param name="encoding-type" select="$encoding-type" />
      <xsl:with-param name="item-encoding-level" select="$item-encoding-level" /> -->
    <!-- </xsl:call-template> -->
    <!-- <xsl:apply-templates select="/Top/DocMeta" mode="metadata" /> -->
  </xsl:template>

  <xsl:template match="DocMeta" mode="metadata">
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

    <xsl:call-template name="build-item-metadata">
      <xsl:with-param name="item" select="ItemHeader" />
      <xsl:with-param name="encoding-type" select="$encoding-type" />
      <xsl:with-param name="item-encoding-level" select="$item-encoding-level" />
      <xsl:with-param name="slot">item</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-rights-statement">
    <qui:block slot="rights-statement">
      <xsl:apply-templates select="/Top/DocMeta//HEADER/FILEDESC/PUBLICATIONSTMT/AVAILABILITY/P" />
    </qui:block>
  </xsl:template>

  <xsl:template name="build-related-links">

  </xsl:template>

  <xsl:template name="get-title">
    <xsl:value-of select="normalize-space($item-metadata//qui:field[@key='title'])/qui:values" />
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

  <xsl:template name="get-record-title">
    <xsl:choose>
      <xsl:when test="$view = 'toc'">
        <xsl:value-of select="key('get-lookup', 'headerutils.str.title')" />
        <xsl:text> Contents</xsl:text>
      </xsl:when>
      <xsl:when test="$view = 'text'">
        <xsl:value-of select="key('get-lookup', 'headerutils.str.viewentiretext')" />
        <xsl:text> Entire Text</xsl:text>
      </xsl:when>
      <xsl:when test="normalize-space($label/PageNumber) and $label/PageNumber != 'viewer.nopagenum'">
      <!-- Page no. -->
        <xsl:value-of select="key('get-lookup', 'headerutils.str.page')" />
        <xsl:value-of select="$label/PageNumber" />
        <xsl:text> - </xsl:text>
        <xsl:value-of select="key('get-lookup', $label/PageType)" />  
      </xsl:when>
      <xsl:when test="//CurrentCgi/Param[@name='seq']">
        <xsl:value-of select="key('get-lookup', 'headerutils.str.page')" />
        <xsl:text> #</xsl:text>
        <xsl:value-of select="//CurrentCgi/Param[@name='seq']" />
        <xsl:text> - </xsl:text>
        <xsl:value-of select="key('get-lookup', $label/PageType)" />  
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-record-technical-metadata">
    <!-- <xsl:param name="item" />
    <xsl:param name="encoding-type" />
    <xsl:param name="item-encoding-level" /> -->

    <!-- <qui:block slot="technical-metadata"> -->
      <qui:section name="Technical Details" slug="technical_details">

        <qui:field key="collection">
          <qui:label>Collection</qui:label>
          <qui:values>
            <qui:value>
              <qui:link href="{/Top/NavHeader/MainNav/NavItem[Name='home']/Link}">
                <xsl:apply-templates select="/Top/DlxsGlobals/TitleComplex" />
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

        <!-- <qui:field key="idno">
          <qui:label>Record</qui:label>
          <qui:values>
            <qui:value>
              <xsl:value-of select="/Top/EntryId" />
            </qui:value>
          </qui:values>
        </qui:field> -->

        <qui:field key="bookmark" component="input">
          <qui:label>Link to this Item</qui:label>
          <qui:values>
            <qui:value>
              <xsl:text>https://name.umdl.umich.edu/</xsl:text>
              <xsl:value-of select="dlxs:downcase(//Param[@name='idno'])" />  
            </qui:value>
          </qui:values>
        </qui:field>

      </qui:section>
    <!-- </qui:block> -->
    <qui:block slot="citation">
      <qui:section>
        <qui:field slot="citation" rel="full">
          <qui:values>
            <qui:value>
              <xsl:text>&quot;</xsl:text>
              <xsl:value-of select="$item-metadata//qui:field[@key='title']//qui:value" />
              <xsl:text>.&quot; </xsl:text>
              <xsl:if test="true()">
              <em>
                <xsl:value-of select="//TitleComplex" />
                <xsl:text>. </xsl:text>
              </em>
              <xsl:text>https://name.umdl.umich.edu/</xsl:text>
              <xsl:value-of select="substring($collid, 1, 1)" />
              <xsl:text>/</xsl:text>
              <xsl:value-of select="$collid" />
              <xsl:text>/</xsl:text>
              <xsl:value-of select="//Param[@name='idno']" />
              <xsl:text>. </xsl:text>
              <xsl:text>Accessed </xsl:text>
              <xsl:value-of select="concat(date:month-name(), ' ', date:day-in-month(), ', ', date:year(), '.')" />
            </xsl:if>
            </qui:value>
          </qui:values>
        </qui:field>    
      </qui:section>
    </qui:block>
  </xsl:template>

  <xsl:template name="build-citation-monograph">
    <xsl:param name="item" />
    <xsl:param name="encoding-type" />
    <xsl:param name="item-encoding-level" />

    <!-- 
      Sargent, Charles Sprague. Garden and Forest ; a Journal of Horticulture, Landscape Art and Forestry. v. 1-10 (Feb 29, 1888-Dec. 29 1897), The Garden and Forest Publishing Company, 1888-1897.
    -->

    <xsl:value-of select="concat($metadata//qui:field[@key='title']//qui:value, '. ')" />
    <xsl:for-each select="$metadata//qui:field[@key='pubinfo']//qui:value">
      <xsl:value-of select="." />
      <xsl:if test="position() &lt; last()">, </xsl:if>
    </xsl:for-each>
    <xsl:text>, </xsl:text>
    <xsl:value-of select="$metadata//qui:field[@key='publication-date']//qui:value" />
    <xsl:text>. </xsl:text>

  </xsl:template>

  <xsl:template name="build-item-search">
    <qui:form id="item-search" action="{/Top/DlxsGlobals/ScriptName[@application='text']}">
      <qui:hidden-input name="type" value="simple" />
      <qui:hidden-input name="rgn" value="full text" />
      <xsl:apply-templates select="//PageNavForm/HiddenVars/Variable[@name!='q1'][@name!='view'][@name!='seq'][@name!='size']" />
      <qui:input name="q1" value="{//Param[@name='q1']}" type="text" style="width: auto; flex-grow: 1;">
        <qui:label>
          <xsl:choose>
            <xsl:when test="/Top/Item/DocEncodingType='serialissue'">
              <xsl:value-of select="key('get-lookup','header.str.searchthisissue')"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="key('get-lookup','header.str.searchthistext')"/>
            </xsl:otherwise>
          </xsl:choose>
        </qui:label>
      </qui:input>
      <qui:link href="{/Top/SimpleSearchWithinLink}" rel="advanced" />
    </qui:form>
  </xsl:template>

  <xsl:template match="TitleComplex">
    <xsl:choose>
      <xsl:when test="img">
        <xsl:value-of select="img/@alt" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="." />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>