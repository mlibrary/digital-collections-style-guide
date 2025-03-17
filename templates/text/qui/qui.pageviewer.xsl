<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl date str" >
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />
  <xsl:strip-space elements="*"/>

  <xsl:variable name="has-plain-text">
    <xsl:choose>
      <xsl:when test="/Top/DocMeta/ItemHeader/HEADER/@TYPE = 'noocr'">
        <xsl:value-of select="'false'" />
      </xsl:when>
      <xsl:when test="//ViewSelect/Option[Value='text']">
        <xsl:value-of select="'true'" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'false'" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="is-subj-search">yes</xsl:variable>
  <xsl:variable name="include-useguidelines-metadata">yes</xsl:variable>

  <xsl:variable name="idno" select="translate(//Param[@name='idno'], 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
  <xsl:variable name="seq" select="//Param[@name='seq']" />
  <xsl:variable name="label" select="//DocNavigation/PageNavForm/PageSelect/Option[Focus='true']/Label" />

  <xsl:variable name="item-metadata-tmp">
    <xsl:apply-templates select="/Top/DocMeta" mode="metadata" />
  </xsl:variable>
  <xsl:variable name="item-metadata" select="exsl:node-set($item-metadata-tmp)" />


  <xsl:variable name="pdf-chunk" select="//PdfChunked/@size" />
  <xsl:variable name="is-pdf-chunked" select="//PdfChunked = 'TRUE'" />

  <xsl:template name="get-canonical-link">
    <xsl:variable name="params" select="/Top/DlxsGlobals/CurrentCgi/Param" />
    <xsl:text>https://quod.lib.umich.edu/cgi/t/text/pageviewer-idx?</xsl:text>
    <xsl:text>cc=</xsl:text>
    <xsl:value-of select="$params[@name='cc']" />
    <xsl:text>;idno=</xsl:text>
    <xsl:value-of select="$params[@name='idno']" />
    <xsl:if test="$params[@name='node']">
      <xsl:text>;node=</xsl:text>
      <xsl:value-of select="$params[@name='node']" />
    </xsl:if>
    <xsl:text>;seq=</xsl:text>
    <xsl:value-of select="$params[@name='seq']" />
  </xsl:template>

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

    <xsl:choose>
      <xsl:when test="//DocMeta/ItemHeader/HEADER/@TYPE = 'noocr'"></xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="build-item-search" />
      </xsl:otherwise>
    </xsl:choose>
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

  <xsl:template name="build-action-panel">
    <qui:block slot="actions">
      <qui:download-options label="Options">
        <xsl:for-each select="//PageSelect/Option[Focus='true']">
          <qui:option-group>
            <xsl:if test="Focus = 'true'">
              <xsl:attribute name="data-active">true</xsl:attribute>
            </xsl:if>
            <xsl:if test="/Top/DocNavigation/PageNavForm/ViewSelect/Option[Value='pdf']">
              <qui:download-item xx-href="{$api_url}/cgi/t/text/pdf-idx?cc={/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']};idno={/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']};seq={Value}" file-type="PDF" type="FILE">
                <xsl:attribute name="href">
                  <xsl:value-of select="concat($api_url, '/cgi/t/text/')" />
                  <xsl:choose>
                    <xsl:when test="$pdf-chunk &gt; 25">
                      <xsl:text>request-pdf-idx</xsl:text>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:text>pdf-idx</xsl:text>
                    </xsl:otherwise>
                  </xsl:choose>
                  <xsl:value-of select="concat('?cc=', $collid, ';idno=', $idno, ';seq=', Value)" />
                </xsl:attribute>
                <xsl:if test="$pdf-chunk &gt; 25">
                  <xsl:attribute name="data-transfer">async</xsl:attribute>
                </xsl:if>
                <xsl:if test="$is-pdf-chunked and Label/Chunk">
                  <xsl:attribute name="data-chunked">true</xsl:attribute>
                </xsl:if>
                <xsl:text>PDF - </xsl:text>
                  <xsl:choose>
                    <xsl:when test="$is-pdf-chunked and Label/Chunk"> 
                      <xsl:text>Pages </xsl:text>
                      <xsl:value-of select="Label/Chunk" />
                    </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>Page </xsl:text>
                    <xsl:apply-templates select="." mode="pagenum" />
                  </xsl:otherwise>
                </xsl:choose>
                <!-- <xsl:text>)</xsl:text> -->
              </qui:download-item>
            </xsl:if>
            <qui:download-item href="{$api_url}/cgi/t/text/api/image/{/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']}:{/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']}:{Value}/full/full/0/default.jpg" file-type="JPEG" type="IMAGE">
              <xsl:text>Image - Page </xsl:text>
              <xsl:apply-templates select="." mode="pagenum" />
              <!-- <xsl:text>)</xsl:text> -->
            </qui:download-item>
            <xsl:if test="$has-plain-text = 'true'">
              <qui:download-item href="{$api_url}/cgi/t/text/pageviewer-idx?cc={/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']};idno={/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']};seq={Value};view=text;tpl=plaintext.viewer" file-type="TEXT" type="TEXT">
                <xsl:text>Plain Text - Page </xsl:text>
                <xsl:apply-templates select="." mode="pagenum" />
                <!-- <xsl:text>)</xsl:text> -->
              </qui:download-item>
            </xsl:if>
            </qui:option-group>
        </xsl:for-each>
        <xsl:if test="//AllowFullPdfDownload = 'true'">
          <qui:hr />
          <qui:download-item href="{$api_url}/cgi/t/text/request-pdf-idx?cc={/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']};idno={/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']}" file-type="PDF" type="FILE" data-transfer="async">
            <xsl:value-of select="dlxs:capitalize(normalize-space(key('get-lookup','results.str.container')))"/>
            <xsl:text> PDF</xsl:text>
            <xsl:if test="true() or //PdfChunked = 'TRUE'">
              <xsl:text> - Pages </xsl:text>
              <xsl:value-of select="//PageSelect/Option[@index = (//Param[@name='seq'] - 1)]/Label/Chunk" />
            </xsl:if>
          </qui:download-item>  
        </xsl:if>
      </qui:download-options>
      <qui:script>
        DLXS.pageMap = {};
        <xsl:for-each select="//PageSelect/Option">
          <xsl:variable name="pageNum">
            <xsl:apply-templates select="." mode="pagenum" />
          </xsl:variable>
          <xsl:variable name="chunk">
            <xsl:choose>
              <xsl:when test="Label/Chunk">
                <xsl:value-of select="Label/Chunk" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$pageNum" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          DLXS.pageMap['<xsl:value-of select="Value" />'] = {};
          DLXS.pageMap['<xsl:value-of select="Value" />'].pageNum = '<xsl:value-of select="$pageNum" />';
          DLXS.pageMap['<xsl:value-of select="Value" />'].chunk = '<xsl:value-of select="$chunk" />';
        </xsl:for-each>
      </qui:script>
    </qui:block>
    <xsl:call-template name="build-action-panel-portfolio" />

    <xsl:call-template name="build-action-panel-iiif-link" />

    <xsl:call-template name="build-action-panel-extra" />
  </xsl:template>

  <xsl:template name="build-action-panel-v1">
    <qui:block slot="actions">
      <qui:download-options label="Item">
        <qui:download-item href="{$api_url}/cgi/t/text/pdf-idx?cc={/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']};idno={/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']};seq={$seq}" file-type="PDF" type="FILE">
          Page PDF
        </qui:download-item>
        <qui:download-item href="{$api_url}/cgi/t/text/api/image/{/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']}:{/Top/DlxsGlobals/CurrentCgi/Param[@name='idno']}:{$seq}/full/full/0/default.jpg" file-type="JPEG" type="IMAGE">
          Page Image
        </qui:download-item>
        <xsl:if test="$has-plain-text = 'true'">
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
    <qui:debug>WUT</qui:debug>
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
      <xsl:choose>
        <xsl:when test="$item-metadata//qui:field[@key='title']">
          <xsl:value-of select="$item-metadata//qui:field[@key='title']//qui:value" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$item-metadata//qui:field[@key='serial']//qui:value" />
        </xsl:otherwise>
      </xsl:choose>
    </qui:header>

    <xsl:call-template name="build-header-submain" />

    <qui:block slot="record">
      <xsl:apply-templates select="$item-metadata" mode="copy" />
      <xsl:call-template name="build-record-technical-metadata" />
    </qui:block>

  </xsl:template>

  <xsl:template name="build-header-submain">
    <xsl:if test="$item-metadata//qui:field[@key='serial']">
      <qui:header role="submain">
        <xsl:value-of select="$item-metadata//qui:field[@key='serial']//qui:value" />
      </qui:header>
    </xsl:if>
  </xsl:template>

  <xsl:template match="DocMeta" mode="metadata">
    <xsl:variable name="encoding-type">
      <xsl:value-of select="normalize-space(DocEncodingType)"/>
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

    <xsl:call-template name="build-header-metadata">
      <xsl:with-param name="encoding-type" select="$encoding-type" />
      <xsl:with-param name="item-encoding-level" select="$item-encoding-level" />
      <xsl:with-param name="item" select="." />
      <xsl:with-param name="slot">root</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-rights-statement">
    <qui:block slot="rights-statement">
      <xsl:apply-templates select="/Top/DocMeta//HEADER/FILEDESC/PUBLICATIONSTMT/AVAILABILITY"/>
    </qui:block>
  </xsl:template>

  <xsl:template name="build-related-links">
    <qui:block slot="related-links">
      <xsl:apply-templates select="//DocMeta/ItemHeader/HEADER/FILEDESC/PUBLICATIONSTMT/IDNO[@TYPE='eadid']" mode="field">
        <xsl:with-param name="name">findingaid-link</xsl:with-param>
        <xsl:with-param name="label">Collection Finding Aid</xsl:with-param>
      </xsl:apply-templates>
    </qui:block>
  </xsl:template>

  <xsl:template match="node()" mode="field">
    <xsl:param name="name" />
    <xsl:param name="label" />
    <qui:field component="{$name}">
      <qui:label><xsl:value-of select="$label" /></qui:label>
      <qui:values>
        <qui:value>
          <xsl:value-of select="." />
        </qui:value>
      </qui:values>
    </qui:field>
  </xsl:template>

  <xsl:template match="node()" mode="collection-link-value">
    <xsl:variable name="href">
      <xsl:choose>
        <xsl:when test="starts-with(., 'https://')">
          <xsl:value-of select="." />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>https://findingaids.lib.umich.edu/catalog/</xsl:text>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <qui:value>
      <qui:link href="{$href}" icon="inventory_2">
        <xsl:text>Collection Finding Aid</xsl:text>
      </qui:link>
    </qui:value>
  </xsl:template>

  <xsl:template name="get-title">
    <xsl:value-of select="normalize-space($item-metadata//qui:field[@key='title'])/qui:values" />
  </xsl:template>

  <xsl:template name="get-head-title">
    <qui:values>
      <xsl:choose>
        <xsl:when test="normalize-space($label/PageNumber) and $label/PageNumber != 'viewer.nopagenum'">
          <qui:value>
            <!-- Page no. -->
            <xsl:value-of select="key('get-lookup', 'headerutils.str.page')" />
            <xsl:value-of select="$label/PageNumber" />
            <xsl:if test="$label/PageType != 'viewer.ftr.uns'">
              <xsl:text> - </xsl:text>
              <xsl:value-of select="key('get-lookup', $label/PageType)" />  
            </xsl:if>
          </qui:value>
        </xsl:when>
        <xsl:when test="//CurrentCgi/Param[@name='seq']">
          <qui:value>
            <xsl:value-of select="key('get-lookup', 'headerutils.str.page')" />
            <xsl:text> #</xsl:text>
            <xsl:value-of select="//CurrentCgi/Param[@name='seq']" />
            <xsl:if test="$label/PageType != 'viewer.nopagenum' and $label/PageType != 'viewer.ftr.uns'">
              <xsl:text> - </xsl:text>
              <xsl:value-of select="key('get-lookup', $label/PageType)" />
            </xsl:if>
          </qui:value>
        </xsl:when>
      </xsl:choose>
      <xsl:if test="$item-metadata//qui:field[@key='articletitle']">
        <qui:value>
          <xsl:value-of select="$item-metadata//qui:field[@key='articletitle']//qui:value" />          
        </qui:value>
      </xsl:if>
      <qui:value>
        <xsl:value-of select="$item-metadata//qui:field[@key='title']//qui:value" />          
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
                <xsl:apply-templates select="/Top/DlxsGlobals/Title" />
              </qui:link>
            </qui:value>
            <xsl:apply-templates select="//DocMeta/ItemHeader/HEADER/FILEDESC/PUBLICATIONSTMT/IDNO[@TYPE='eadid']" mode="collection-link-value" />
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

        <xsl:call-template name="build-bookmarkable-link">
          <xsl:with-param name="item" select="/Top/DocMeta" />
        </xsl:call-template>

        <xsl:if test="//Param[@name='seq'] or 
          ( //Param[@name='node'] and //Param[@name='node'] != //Param[@name='idno'] )">
          <qui:field key="bookmark-item" component="input">
            <qui:label>Link to this <xsl:value-of select="key('get-lookup', 'results.str.singlepage')" /></qui:label>
            <qui:values>
              <qui:value>
                <xsl:value-of select="//ApiUrl" />
                <xsl:text>/</xsl:text>
                <xsl:value-of select="substring($collid, 1, 1)" />
                <xsl:text>/</xsl:text>
                <xsl:value-of select="$collid" />
                <xsl:text>/</xsl:text>
                <xsl:choose>
                  <xsl:when test="//Param[@name='node']">
                    <xsl:value-of select="dlxs:downcase(//Param[@name='idno'])" />  
                    <xsl:text>/</xsl:text>
                    <xsl:variable name="parts" select="str:tokenize(normalize-space(//Param[@name='node']), ':')" />
                    <xsl:if test="//Param[@name='seq']">
                      <xsl:value-of select="//Param[@name='seq']" />
                    </xsl:if>
                    <xsl:text>:</xsl:text>
                    <xsl:value-of select="$parts[last()]" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="dlxs:downcase(//Param[@name='idno'])" />  
                    <xsl:if test="//Param[@name='seq']">
                      <xsl:text>/</xsl:text>
                      <xsl:value-of select="//Param[@name='seq']" />
                    </xsl:if>
                  </xsl:otherwise>
                </xsl:choose>
              </qui:value>
            </qui:values>
          </qui:field>        
        </xsl:if>

      </qui:section>
    <!-- </qui:block> -->
    <qui:block slot="citation">
      <qui:section>
        <qui:field slot="citation" rel="full">
          <qui:values>
            <qui:value>
              <xsl:variable name="title">
                <xsl:choose>
                  <xsl:when test="$item-metadata//qui:field[@key='articletitle']">
                    <xsl:value-of select="$item-metadata//qui:field[@key='articletitle']//qui:value" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="$item-metadata//qui:field[@key='title']//qui:value" />
                  </xsl:otherwise>
                </xsl:choose>  
              </xsl:variable>
              <xsl:text>&quot;</xsl:text>
              <xsl:value-of select="normalize-space($title)" />
              <xsl:if test="substring(normalize-space($title), string-length(normalize-space($title))) != '.'">
                <xsl:text>.</xsl:text>
              </xsl:if>
              <xsl:text>&quot; </xsl:text>
              <xsl:if test="$item-metadata//qui:field[@key='articletitle']">
                <em>
                  <xsl:value-of select="$item-metadata//qui:field[@key='title']//qui:value" />
                  <xsl:text>. </xsl:text>
                </em>
              </xsl:if>
              <xsl:if test="true()">
              <xsl:text>In the digital collection </xsl:text>
              <em>
                <xsl:choose>
                  <xsl:when test="normalize-space(/Top/DlxsGlobals/Title)">
                    <xsl:value-of select="/Top/DlxsGlobals/Title" />
                  </xsl:when>
                  <xsl:when test="//TitleComplex/img">
                    <xsl:value-of select="//TitleComplex/img/@alt" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="//TitleComplex" />
                  </xsl:otherwise>
                </xsl:choose>
                <xsl:text>. </xsl:text>
              </em>
              <xsl:value-of select="//BookmarkableUrl" />
              <!-- <xsl:text>https://name.umdl.umich.edu/</xsl:text> -->
              <!-- <xsl:value-of select="substring($collid, 1, 1)" />
              <xsl:text>/</xsl:text>
              <xsl:value-of select="$collid" />
              <xsl:text>/</xsl:text> -->
              <!-- <xsl:value-of select="//Param[@name='idno']" /> -->
              <xsl:text>. </xsl:text>
              <xsl:if test="normalize-space(key('get-lookup', 'uplift.citation.repository'))">
                <xsl:value-of select="key('get-lookup', 'uplift.citation.repository')" />
                <xsl:text>, </xsl:text>
              </xsl:if>
              <xsl:text>University of Michigan Library Digital Collections. </xsl:text>
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

  <xsl:template match="Title">
    <xsl:value-of select="." />
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

  <xsl:template match="PageSelect/Option" mode="pagenum">
    <xsl:choose>
      <xsl:when test="Label/PageNumber = 'viewer.nopagenum'">
        <xsl:text>#</xsl:text>
        <xsl:value-of select="Value" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="Label/PageNumber" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
</xsl:stylesheet>