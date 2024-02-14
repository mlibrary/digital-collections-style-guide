<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />

  <xsl:variable name="is-subj-search">yes</xsl:variable>
  <xsl:variable name="include-useguidelines-metadata">yes</xsl:variable>
  <xsl:variable name="include-print-source-metadata">yes</xsl:variable>
  <xsl:variable name="include-bookmark">yes</xsl:variable>

  <xsl:variable name="item-metadata-tmp">
    <xsl:apply-templates select="/Top/Item" mode="metadata" />
  </xsl:variable>
  <xsl:variable name="item-metadata" select="exsl:node-set($item-metadata-tmp)" />
  <xsl:variable name="idno" select="translate(//Param[@name='idno'], 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>

  <xsl:template name="build-body-main">
    <xsl:call-template name="build-contents-navigation" />
    <xsl:call-template name="build-breadcrumbs" />

    <xsl:choose>
      <xsl:when test="/Top/Item/ItemHeader/HEADER/@TYPE = 'restricted'">
        <qui:callout slot="access">
          <xsl:value-of select="key('get-lookup', 'results.str.9')" />
        </qui:callout>
      </xsl:when>
      <xsl:when test="/Top/AuthRequired = 'true'">
        <qui:callout slot="access">
          <xsl:value-of select="key('get-lookup', 'header.str.fullaccess')" />
        </qui:callout>
      </xsl:when>  
    </xsl:choose>

    <qui:header role="main">
      <xsl:value-of select="$item-metadata//qui:field[@key='title']//qui:value" />
      <!-- <xsl:text>: </xsl:text> -->
      <xsl:choose>
        <xsl:when test="$view = 'toc'">
          <!-- <xsl:value-of select="key('get-lookup', 'headerutils.str.title')" /> -->
          <!-- <xsl:text> Contents</xsl:text> -->
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
    </qui:header>
    <xsl:call-template name="build-item-header" />
    <xsl:apply-templates select="/Top/Item/HeaderToc" />
    <!-- <xsl:call-template name="build-browse-navigation" /> -->
    <qui:message>SOB</qui:message>
  </xsl:template>


  <xsl:template name="get-title">
    <xsl:text>Item Information | </xsl:text>
    <xsl:value-of select="normalize-space($item-metadata//qui:field[@key='title']/qui:values)" />
  </xsl:template>

  <xsl:template name="build-item-header">
    <qui:block slot="metadata">
      <!-- <xsl:apply-templates select="$item-metadata" mode="copy" /> -->
      <xsl:apply-templates select="/Top/Item" mode="metadata" />      
    </qui:block>
  </xsl:template>

  <xsl:template name="build-contents-navigation">
    <qui:nav role="contents">
      <xsl:choose>
        <xsl:when test="/Top/AuthRequired = 'true'"></xsl:when>
        <xsl:when test="/Top/Item/DocEncodingType = 'serialissue'"></xsl:when>
        <xsl:when test="/Top/Item/ItemHeader/HEADER/@TYPE = 'noocr'"></xsl:when>
        <xsl:when test="//ViewEntireTextLink">
          <qui:link href="{//ViewEntireTextLink}" role="view-text">
            <xsl:value-of select="key('get-lookup','header.str.viewentiretext')"/>
          </qui:link>
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
      <xsl:choose>
        <xsl:when test="/Top/BookbagResults/Item[@idno=$idno]">
          <qui:form slot="bookbag" rel="remove" href="{/Top/BookbagResults/Item[@idno=$idno]/AddRemoveUrl}" data-identifier="{$idno}">
            <qui:hidden-input name="via" value="toc" />
          </qui:form>
        </xsl:when>
        <xsl:when test="/Top/BookbagAddHref">
          <qui:form slot="bookbag" rel="add" href="{/Top/BookbagAddHref}" data-identifier="{$idno}">
            <qui:hidden-input name="via" value="toc" />
          </qui:form>
        </xsl:when>
      </xsl:choose>
    </qui:nav>
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    <xsl:value-of select="key('get-lookup', 'uplift.str.contents')" />
  </xsl:template>

  <xsl:template match="HeaderToc">
    <qui:block slot="contents">
      <qui:ul>
        <xsl:choose>
          <xsl:when test="ScopingPage">
            <xsl:apply-templates select="ScopingPage" mode="outline" />
          </xsl:when>
          <xsl:when test="DIV1">
            <xsl:apply-templates select="DIV1" mode="outline" />
          </xsl:when>
        </xsl:choose>
      </qui:ul>
    </qui:block>
  </xsl:template>

  <xsl:template match="ScopingPage" mode="outline" priority="101">
    <xsl:variable name="do-build-link">
      <xsl:choose>
        <xsl:when test="/Top/AuthRequired='true'">false</xsl:when>
        <xsl:otherwise>true</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="non-linked-div">
      <xsl:call-template name="should-div-not-be-linked" />
    </xsl:variable>
    <qui:li>
      <xsl:choose>
        <xsl:when test="$do-build-link = 'false' or $non-linked-div = 'true'">
          <xsl:apply-templates select="." mode="build-label" />
        </xsl:when>
        <xsl:otherwise>
          <qui:link href="{ViewPageLink}">
            <xsl:apply-templates select="." mode="build-label" />
          </qui:link>
        </xsl:otherwise>
      </xsl:choose>
    </qui:li>
  </xsl:template>

  <xsl:template match="Divhead" mode="outline" priority="101" />

  <xsl:template match="*" mode="outline">
    <xsl:variable name="do-build-link">
      <xsl:choose>
        <xsl:when test="/Top/AuthRequired='true'">false</xsl:when>
        <xsl:otherwise>true</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="non-linked-div">
      <xsl:call-template name="should-div-not-be-linked" />
    </xsl:variable>
    <!-- <xsl:variable name="label">
      <xsl:choose>
        <xsl:when test="Divhead/HEAD">
          <xsl:apply-templates select="Divhead/HEAD" mode="copy" />
        </xsl:when>
        <xsl:when test="Divhead/BIBL">
          <xsl:apply-templates select="Divhead" />
        </xsl:when>
        <xsl:when test="key('get-lookup',@TYPE)">
          <xsl:value-of select="key('get-lookup', @TYPE)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@TYPE" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable> -->
    <qui:li>
      <xsl:choose>
        <xsl:when test="$do-build-link = 'false' or $non-linked-div = 'true'">
          <qui:span>
            <qui:span class="article-title">
              <xsl:call-template name="build-outline-item-title" />
            </qui:span>
            <xsl:call-template name="build-outline-item-details" />
          </qui:span>
        </xsl:when>
        <xsl:otherwise>
          <qui:link href="{Link}" class="article-link">
            <qui:span class="article-title">
              <xsl:call-template name="build-outline-item-title" />
            </qui:span>
            <xsl:call-template name="build-outline-item-details" />  
          </qui:link>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="DIV2|DIV3|DIV4|DIV5|DIV6|DIV7|DIV8|DIV9|DIV10">
        <qui:ul>
          <xsl:apply-templates select="DIV2|DIV3|DIV4|DIV5|DIV6|DIV7|DIV8|DIV9|DIV10" mode="outline" />
        </qui:ul>
      </xsl:if>
    </qui:li>
  </xsl:template>

  <xsl:template match="Divhead/HEAD/NOTE1|Divhead/HEAD/NOTE2" priority="101" mode="copy" />

  <xsl:template name="build-outline-item-title">
    <xsl:choose>
      <xsl:when test="Divhead/HEAD">
        <xsl:apply-templates select="Divhead/HEAD" mode="copy" />
      </xsl:when>
      <xsl:when test="Divhead/BIBL/TITLE">
        <xsl:for-each select="Divhead/BIBL/TITLE[not(@TYPE='sort')]">
          <xsl:value-of select="." />
          <xsl:if test="position() &lt; last()">
            <xsl:text>: </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="key('get-lookup',@TYPE)">
        <xsl:value-of select="key('get-lookup', @TYPE)" />
        <xsl:if test="@N">
          <xsl:text> - </xsl:text>
          <xsl:value-of select="@N" />
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="normalize-space(@TYPE)">
            <xsl:value-of select="@TYPE" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="key('get-lookup', 'uplift.section')" />
          </xsl:otherwise>
        </xsl:choose>
        <xsl:if test="@N">
          <xsl:text> - </xsl:text>
          <xsl:value-of select="@N" />
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  
  <xsl:template name="build-outline-item-details">
    <xsl:choose>
      <xsl:when test="Divhead/BIBL/BIBLSCOPE">
        <qui:span class="article-details">
          <xsl:apply-templates select="Divhead/BIBL" mode="details" />
        </qui:span>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Divhead/BIBL" mode="details">
    <xsl:choose>
      <xsl:when test="AUTHOR">
        <xsl:apply-templates select="AUTHOR" mode="build-list" />
        <xsl:if test="BIBLSCOPE[@TYPE='pg' or @TYPE='pagno']">
          <xsl:text>; </xsl:text>
          <xsl:apply-templates select="BIBLSCOPE[@TYPE='pg' or @TYPE='pageno']" />
        </xsl:if>
      </xsl:when>
      <xsl:when test="AUTHORIND">
        <xsl:apply-templates select="AUTHORIND" mode="build-list" />
        <xsl:if test="BIBLSCOPE[@TYPE='pg' or @TYPE='pagno']">
          <xsl:text>; </xsl:text>
          <xsl:apply-templates select="BIBLSCOPE[@TYPE='pg' or @TYPE='pageno']" />
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="BIBLSCOPE[@TYPE='pg' or @TYPE='pagno']">
          <xsl:apply-templates select="BIBLSCOPE[@TYPE='pg' or @TYPE='pageno']" />
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="*" mode="build-list">
    <xsl:value-of select="." />
    <xsl:if test="position() &lt; last()">; </xsl:if>
  </xsl:template>

  <xsl:template match="Top/Item" mode="metadata">
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

    <xsl:call-template name="build-header-metadata">
      <xsl:with-param name="item" select="." />
      <xsl:with-param name="encoding-type" select="$encoding-type" />
      <xsl:with-param name="item-encoding-level" select="$item-encoding-level" />
      <xsl:with-param name="slot">root</xsl:with-param>
    </xsl:call-template>
      
  </xsl:template>  

  <xsl:template name="should-div-not-be-linked">
    <xsl:choose>
      <xsl:when test="ancestor::Item/DocEncodingType='serialarticle'">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:when test="parent::*[@STATUS='nolink']">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="ScopingPage" mode="build-label">
    <xsl:value-of select="key('get-lookup','headerutils.str.page')"/>
    <xsl:text> </xsl:text>
    <xsl:if test="PageNumber!='NA'">
      <xsl:value-of select="PageNumber"/>
    </xsl:if>
    <xsl:if test="PageNumber='NA'">
      <xsl:text>[unnumbered]</xsl:text>
    </xsl:if>
    <xsl:if test="PageType!='viewer.ftr.uns'"><xsl:text> - </xsl:text></xsl:if>
    <xsl:value-of select="key('get-lookup',PageType)"/>        
  </xsl:template>

  <xsl:template match="Divhead">
    <xsl:variable name="do-build-links">
      <xsl:choose>
        <xsl:when test="/Top/AuthRequired='true'">false</xsl:when>
        <xsl:otherwise>true</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <!-- BuildLinks is item-level, NonLinkedDiv is specific to this div -->
    <xsl:variable name="non-linked-div">
      <xsl:choose>
        <!-- disable div linking for serialarticle: served whole -->
        <xsl:when test="ancestor::Item/DocEncodingType='serialarticle'">
          <xsl:value-of select="'true'"/>
        </xsl:when>
        <xsl:when test="parent::*[@STATUS='nolink']">
          <xsl:value-of select="'true'"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="'false'"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:element name="span">
      <xsl:attribute name="class">divhead</xsl:attribute>
      <xsl:choose>
        <xsl:when test="ancestor::Item/DocEncodingType='serialissue'">
          <xsl:call-template name="SerIssueItemBrief">
            <xsl:with-param name="itemBiblNode" select="BIBL"/>
            <xsl:with-param name="itemLink" select="following-sibling::Link"/>
          </xsl:call-template>
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name="BIBLcontent">
            <xsl:choose>
              <xsl:when test="BIBL and not(/Top/Item/DocEncodingType='serialissue')">
                <xsl:for-each select="BIBL/*">
                  <xsl:apply-templates select="."/>
                  <xsl:if test="position()!=last()">
                    <xsl:text>,&#xa0;</xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </xsl:when>
              <xsl:otherwise/>
            </xsl:choose>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="$BuildLinks='false' or $NonLinkedDiv='true'">
              <!-- labels, not links  -->
              <xsl:call-template name="BuildDivHeadLinkLabel"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:element name="a">
                <xsl:attribute name="href">
                  <xsl:value-of select="following-sibling::Link"/>
                </xsl:attribute>
                <!-- handle labels for DIVs without HEADs -->
                <xsl:call-template name="BuildDivHeadLinkLabel"/>
              </xsl:element>
              <!-- append meta info such as page numbers in toc view only-->
              <!-- not desired in results details or textview, or it'll
                   muck up the breadcrumbs -->
              <xsl:if test="/Top/DlxsGlobals/CurrentCgi/Param[@name='view']='toc'">
                <xsl:if test="not($BIBLcontent='')">
                  <span class="divmeta">
                    <xsl:text>,&#xa0;</xsl:text>
                    <xsl:value-of select="$BIBLcontent"/>
                  </span>
                </xsl:if>
                <xsl:if test="HEAD/BIBL[@TYPE!='pg' or @TYPE='pp' or @TYPE='page' or @TYPE='para']">
                  <xsl:text>&#xa0;</xsl:text>
                  <span class="divmeta">
                    <xsl:apply-templates select="HEAD/BIBL[@TYPE='pg' or @TYPE='pp' or @TYPE='page' or @TYPE='para']"/>
                  </span>
                </xsl:if>
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="descendant::NOTE1 and $dlxsTemp='text'">
            <xsl:apply-templates select="descendant::NOTE1"/>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:element>
  </xsl:template>  
  
  <xsl:template match="BIBL[ancestor::Divhead]">
    <xsl:choose>
      <xsl:when test="@TYPE='para'">
        <xsl:text>[para.&#xa0;</xsl:text>
        <xsl:value-of select="concat(.,']&#xa0;')"/>
      </xsl:when>
      <xsl:when test="@TYPE='title'">
        <xsl:value-of select="."/>
      </xsl:when>
      <xsl:when test="@TYPE='chapter'">
        <xsl:value-of select="concat(., ':&#xa0;')"/>
      </xsl:when>
      <xsl:otherwise> [<xsl:value-of select="."/>] </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>