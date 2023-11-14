<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:qui="http://dlxs.org/quombat/ui" extension-element-prefixes="exsl" >
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />
  <xsl:strip-space elements="*"/>

  <!-- globals -->
  <xsl:variable name="searchtype" select="key('get-lookup',/Top/SearchDescription/SearchTypeName)"/>
  <xsl:variable name="total">
    <xsl:choose>
      <xsl:when test="/Top/ResultsLinks/SliceNavigationLinks/TotalRecordsOrItemHits">
        <xsl:value-of select="/Top/ResultsLinks/SliceNavigationLinks/TotalRecordsOrItemHits" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count(/Top/ResList/Results/Item)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="sz" select="number(50)" />
  <xsl:variable name="end-1">
    <xsl:choose>
      <xsl:when test="$total &lt;= $sz">
        <xsl:value-of select="$total" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="//FisheyeLinks/FisheyeLink/LinkNumber[@focus='true'] + $sz - 1" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="end">
    <xsl:choose>
      <xsl:when test="$end-1 &gt; $total"><xsl:value-of select="$total" /></xsl:when>
      <xsl:otherwise><xsl:value-of select="$end-1" /></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="max">
    <xsl:choose>
      <xsl:when test="$total &lt;= $sz">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count(//FisheyeLinks/FisheyeLink)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="current">
    <xsl:choose>
      <xsl:when test="count(//FisheyeLinks/FisheyeLink) = 0">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count(//FisheyeLinks/FisheyeLink[LinkNumber[@focus='true']]//preceding-sibling::Url) + 1" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="start">
    <xsl:choose>
      <xsl:when test="$total &lt;= $sz">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="//FisheyeLinks/FisheyeLink/LinkNumber[@focus='true']" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="number-matches">
    <xsl:choose>
      <xsl:when test="$searchtype='basic' or $searchtype='proximity'">
        <xsl:value-of select="//CollTotals/HitCount" />
      </xsl:when>
      <xsl:when test="$searchtype='boolean'">
        <xsl:value-of select="//CollTotals/HitRegionCount" />
      </xsl:when>
      <xsl:when test="$searchtype='bibliographic'">
        <xsl:value-of select="//CollTotals/RecordCount" />
      </xsl:when>
    </xsl:choose>
  </xsl:variable>


  <xsl:template name="build-body-main">
    <xsl:call-template name="build-results-navigation" />
    <xsl:call-template name="build-breadcrumbs" />
    <qui:header role="main">
      <!-- <xsl:when test="//BookBagInfo/Field[@name='shared'] = '0'">
        <xsl:attribute name="data-status">private</xsl:attribute>
      </xsl:when> -->
      <xsl:text>Search Results</xsl:text>
    </qui:header>
    <!-- <xsl:call-template name="build-action-panel" /> -->
    <xsl:call-template name="build-results-list" />
    <xsl:call-template name="build-portfolio-form" />
    <qui:message>BOO-YAH-HAH</qui:message>
  </xsl:template>

  <xsl:template name="get-title">
    <xsl:if test="//Param[@name='q1']">
      <xsl:value-of select="//Param[@name='q1']" />
      <xsl:text> | </xsl:text>
    </xsl:if>
    <xsl:value-of select="$start" />
    <xsl:text>-</xsl:text>
    <xsl:value-of select="$end" />
    <xsl:text> | Search Results</xsl:text>
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    <xsl:choose>
      <xsl:when test="//Param[@name='subview'] = 'detail'">
        <xsl:choose>
          <xsl:when test="key('get-lookup', 'reslist.str.foldersearchresults')">
            <xsl:value-of select="key('get-lookup', 'reslist.str.foldersearchresults')" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Item Search Results</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Search Results</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-results-navigation">
    <!-- do we have M/N available in the PI handler? -->
    <xsl:if test="$subview = 'detail'">
      <qui:nav
        role="details"
        current="{/Top/ResultsLinks/PrevNextItemLinks/current}"
        hit-count="{/Top/SearchDescription/CollTotals/HitCount}"
        total="{/Top/SearchDescription/CollTotals/RecordCount}"
      >
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">next-item</xsl:with-param>
          <xsl:with-param name="href" select="/Top/ResultsLinks/PrevNextItemLinks/next/Href" />
        </xsl:call-template>
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">previous-item</xsl:with-param>
          <xsl:with-param name="href" select="/Top/ResultsLinks/PrevNextItemLinks/prev/Href" />
        </xsl:call-template>
      </qui:nav>
    </xsl:if> 
    <xsl:variable name="tmp-xml">
      <qui:nav 
        role="results" 
        total="{$total}" 
        size="{$sz}" 
        min="1" 
        max="{$max}" 
        current="{$current}"
        start="{$start}" 
        end="{$end}"
        subview="{$subview}"
        number-matches="{$number-matches}" 
        is-truncated="{/Top/SearchSummary/Truncated}">
        <xsl:if test="//CollTotals/RecordCount">
          <xsl:attribute name="record-count">
            <xsl:value-of select="//CollTotals/RecordCount" />
          </xsl:attribute>
          <xsl:attribute name="record-type">
            <xsl:choose>
              <xsl:when test="//CollTotals/RecordCount = 1">
                <xsl:value-of select="normalize-space(key('get-lookup', 'results.str.container'))" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="normalize-space(key('get-lookup', 'results.str.container.plural'))" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">next</xsl:with-param>
          <xsl:with-param name="href" select="/Top/ResultsLinks/SliceNavigationLinks/NextHitsLink" />
        </xsl:call-template>
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">previous</xsl:with-param>
          <xsl:with-param name="href" select="/Top/ResultsLinks/SliceNavigationLinks/PrevHitsLink" />
        </xsl:call-template>
        <xsl:if test="$subview = 'detail'">
        </xsl:if>
        <xsl:if test="//SearchDescription/RefineSearchLink">
          <qui:link rel="restart">
            <xsl:attribute name="href">
              <xsl:value-of select="/Top/NavHeader/MainNav/NavItem[Name='search']/Link" />
              <!-- <xsl:text>/cgi/t/text/text-idx?cc=</xsl:text>
              <xsl:value-of select="//Param[@name='cc']" />
              <xsl:text>;page=simple</xsl:text> -->
            </xsl:attribute>
          </qui:link>
        </xsl:if>
        <xsl:if test="normalize-space(//StartOverLink)">
          <qui:link rel="restart">
            <xsl:attribute name="href">
              <xsl:value-of select="//StartOverLink" />
              <xsl:choose>
                <xsl:when test="//Param[@name='xc'] = 1">
                  <xsl:text>;page=searchgroup</xsl:text>
                </xsl:when>
                <xsl:when test="//SearchForm/Advanced = 'true'">
                  <xsl:text>;page=search</xsl:text>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:text>;q1=</xsl:text>
                  <xsl:value-of select="$collid" />
                  <xsl:text>;view=reslist</xsl:text>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:attribute>
          </qui:link>
        </xsl:if>
      </qui:nav>
    </xsl:variable>

    <xsl:variable name="tmp" select="exsl:node-set($tmp-xml)" />

    <xsl:if test="true() or $tmp//qui:link">
      <xsl:apply-templates select="$tmp" mode="copy" />
    </xsl:if>
    <xsl:if test="//SearchDescription/RefineSearchLink">
      <qui:link rel="refine-search" href="{//SearchDescription/RefineSearchLink}" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-results-navigation-link">
    <xsl:param name="rel" />
    <xsl:param name="identifier" />
    <xsl:param name="marker" />
    <xsl:param name="href" />
    <xsl:choose>
      <xsl:when test="normalize-space($href)">
        <qui:link rel="{$rel}" href="{$href}">
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
        </qui:link>
      </xsl:when>
      <xsl:otherwise>
        <qui:link rel="{$rel}" disabled="disabled" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-results-list">
    <xsl:variable name="q" select="//SearchForm/Q[@name='q1']" />
    <xsl:variable name="is-advanced">
      <xsl:choose>
        <xsl:when test="$search-type = 'simple' 
          and ( 
            normalize-space(//SearchForm/CiteRestrictions//Default) or 
            normalize-space(//SearchForm/OtherRestrictions//Default) )">true</xsl:when>
        <xsl:when test="$search-type = 'simple'">false</xsl:when>
        <xsl:otherwise>true</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:call-template name="build-search-form" />
    <xsl:call-template name="build-portfolio-actions" />
    <xsl:apply-templates select="//Facets" />
    <xsl:apply-templates select="//GuideFrame[IncludeGuideFrame='true']/GuideFrameResults" />
    <xsl:apply-templates select="//SearchDescription" />
    <xsl:choose>
      <xsl:when test="$subview = 'detail'"></xsl:when>
      <xsl:when test="//SortSelect = 'sort.overthresold'">
        <qui:message id="sort-options">
          <xsl:value-of select="key('get-lookup', 'results.str.11')"/>
          <xsl:text> </xsl:text>
          <xsl:value-of select="key('get-lookup','results.str.12')"/>
        </qui:message>
      </xsl:when>
      <xsl:otherwise>
        <qui:form id="sort-options">
          <xsl:for-each select="//ResultsLinks/HiddenVars/Variable">
            <qui:hidden-input name="{@name}" value="{.}" />
          </xsl:for-each>
          <qui:select name="sort">
            <xsl:for-each select="//SortSelect/Option">
              <qui:option index="{@index}" value="{Value}">
                <xsl:if test="Focus = 'true'">
                  <xsl:attribute name="selected">selected</xsl:attribute>
                </xsl:if>
                <xsl:choose>
                  <xsl:when test="Value = 'none'">None</xsl:when>
                  <xsl:when test="Value = 'relevance'">Relevance</xsl:when>
                  <xsl:otherwise>
                    <xsl:value-of select="Label" />
                  </xsl:otherwise>
                </xsl:choose>
              </qui:option>
            </xsl:for-each>
          </qui:select>
        </qui:form>  
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="//ResList/Results/Item[ItemDetails]">
      <xsl:apply-templates select="//ResList/Results/Item" mode="metadata" />
    </xsl:if>
    <qui:block slot="results">
      <xsl:if test="//Param[@name='xc'] = 1 or //Param[@name='view'] = 'bbreslist'">
        <xsl:attribute name="data-xc">true</xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$total = 0">
          <xsl:call-template name="build-no-results" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="//ResList/Results/Item" />
        </xsl:otherwise>
      </xsl:choose>
    </qui:block>
    <xsl:if test="//Callout">
      <xsl:apply-templates select="//Callout" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-portfolio-actions">
    <!-- <qui:callout slot="portfolio">
      <iframe id="BBwindow" src="/cache/7/6/2/762da80dee881cd8b0c04168276a8711/bookbagitemsstring.html"></iframe>
    </qui:callout> -->
  </xsl:template>

  <xsl:template name="build-no-results">
    <pre>BOO-YAH</pre>
  </xsl:template>

  <xsl:template match="Results/Item" mode="metadata">
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
        <xsl:when test="HEADER/ENCODINGDESC/EDITORIALDECL/@N">
          <xsl:value-of select="HEADER/ENCODINGDESC/EDITORIALDECL/@N"/>
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
      <xsl:with-param name="slot">item</xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="Results/Item[ItemDetails]" priority="99">
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
        <xsl:when test="HEADER/ENCODINGDESC/EDITORIALDECL/@N">
          <xsl:value-of select="HEADER/ENCODINGDESC/EDITORIALDECL/@N"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="identifier" select="ItemIdno" />

    <xsl:variable name="item-metadata-tmp">
      <xsl:call-template name="build-header-metadata">
        <xsl:with-param name="item" select="." />
        <xsl:with-param name="encoding-type" select="$encoding-type" />
        <xsl:with-param name="item-encoding-level" select="$item-encoding-level" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="item-metadata" select="exsl:node-set($item-metadata-tmp)" />


    <xsl:call-template name="build-item-details">
      <xsl:with-param name="identifier" select="$identifier" />
      <xsl:with-param name="encoding-type" select="$encoding-type" />
      <xsl:with-param name="item-encoding-level" select="$item-encoding-level" />
      <xsl:with-param name="item-metadata" select="$item-metadata" />
      <xsl:with-param name="details" select="ItemDetails" />
      <xsl:with-param name="layout">
        <xsl:choose>
          <xsl:when test="ItemDetails/descendant::ScopingPage and not(ItemDetails/DIV1)">
            <xsl:text>nostruct</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="$display-layout"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>

  </xsl:template>

  <xsl:template match="Results/Item">
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
        <xsl:when test="HEADER/ENCODINGDESC/EDITORIALDECL/@N">
          <xsl:value-of select="HEADER/ENCODINGDESC/EDITORIALDECL/@N"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="''"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="identifier" select="translate(ItemIdno, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />

    <qui:section identifier="{ItemIdno}" auth-required="{AuthRequired}" encoding-type="{DocEncodingType}" encoding-level="{ItemEncodingLevel}">
      <xsl:apply-templates select="Tombstone" />
      <xsl:apply-templates select="DetailHref" />
      <xsl:apply-templates select="TocHref">
        <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
      </xsl:apply-templates>
      <xsl:choose>
        <xsl:when test="normalize-space(ThumbnailLink)">
          <qui:link href="{ThumbnailLink}" rel="iiif" />
        </xsl:when>
        <xsl:when test="normalize-space(ViewPageThumbnailLink)">
          <qui:link href="{ViewPageThumbnailLink}" rel="iiif" />
        </xsl:when>
        <xsl:otherwise></xsl:otherwise>
      </xsl:choose>
      <!-- <xsl:if test="normalize-space(BookbagAddHref)">
        <qui:link rel="bookmark" href="{BookbagAddHref}" label="{key('get-lookup', 'results.str.21')}" />
      </xsl:if> -->
      <xsl:if test="normalize-space(BookbagAddHref)">
        <qui:form slot="bookbag" rel="add" href="{BookbagAddHref}" data-identifier="{$identifier}">
        </qui:form>
      </xsl:if>
      <xsl:if test="not($encoding-type='serialissue')">
        <xsl:apply-templates select="FirstPageHref"/>
      </xsl:if>
      <xsl:apply-templates select="MediaInfo" mode="iiif-link" />

      <xsl:call-template name="build-header-metadata">
        <xsl:with-param name="item" select="." />
        <xsl:with-param name="encoding-type" select="$encoding-type" />
        <xsl:with-param name="item-encoding-level" select="$item-encoding-level" />
      </xsl:call-template>
      
      <xsl:apply-templates select="HitSummary" />
    </qui:section>
  </xsl:template>

  <xsl:template match="Facets">
    <qui:filters-panel>
      <xsl:apply-templates select="Threshold" />
      <xsl:apply-templates select="//SearchForm/Range" />
      <xsl:apply-templates select="//SearchForm/MediaOnly" />
      <xsl:apply-templates select="Error" />
      <xsl:for-each select="Field">
        <xsl:variable name="m" select="position()" />
        <qui:filter key="{@abbrev}" data-total="{@actual_total}">
          <qui:label>
            <xsl:value-of select="Label" />
          </qui:label>
          <qui:values>
            <xsl:for-each select="Values/Value">
              <qui:value count="{@count}">
                <xsl:if test="@selected">
                  <xsl:attribute name="selected"><xsl:value-of select="@selected" /></xsl:attribute>
                  <xsl:variable name="n" select="count(preceding-sibling::Value[@selected='true']) + 1" />
                  <xsl:attribute name="num">
                    <xsl:value-of select="concat($m, $n)" />
                  </xsl:attribute>
                </xsl:if>
                <xsl:if test="10 &lt; position()">
                  <xsl:attribute name="data-expandable-filter">true</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="." />
              </qui:value>
            </xsl:for-each>
          </qui:values>
        </qui:filter>
      </xsl:for-each>
    </qui:filters-panel>
  </xsl:template>

  <xsl:template match="SearchForm/Range">
    <xsl:variable name="check" select=".//Q/Value[normalize-space(.)]" />
    <xsl:choose>
      <xsl:when test="normalize-space($check)">
        <qui:debug>HAVE RANGE</qui:debug>
      </xsl:when>
      <xsl:otherwise>
        <qui:debug>NO RANGE</qui:debug>
        <qui:debug><xsl:value-of select="$check" /></qui:debug>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="normalize-space($check)">
      <xsl:variable name="select" select="Sel/Option/Value" />
      <qui:filter key="range-{@name}" data-type="range">
        <qui:label>
          <xsl:value-of select="Q/Rgn/Label" />
        </qui:label>
        <qui:values>
          <qui:value selected="true">
            <xsl:choose>
              <xsl:when test="$select = 'ic_range'">
                <xsl:choose>
                  <xsl:when test="Q/Value[1] = Q/Value[2]">
                    <xsl:value-of select="Q/Value[1]" />
                  </xsl:when>
                  <xsl:otherwise>
                    <xsl:text>between </xsl:text>
                    <xsl:value-of select="Q/Value[1]" />
                    <xsl:text> to </xsl:text>
                    <xsl:value-of select="Q/Value[2]" />
                  </xsl:otherwise>
                </xsl:choose>
              </xsl:when>
              <xsl:when test="$select = 'ic_before'">
                <xsl:text>before </xsl:text>
                <xsl:value-of select="Q/Value[2]" />
              </xsl:when>
              <xsl:when test="$select = 'ic_after'">
                <xsl:text>after </xsl:text>
                <xsl:value-of select="Q/Value[1]" />
              </xsl:when>
              <xsl:when test="$select = 'ic_exact_range'">
                <xsl:text> </xsl:text>
                <xsl:value-of select="Q/Value[1]" />
              </xsl:when>
              <xsl:otherwise />
            </xsl:choose>
        </qui:value>
        </qui:values>
      </qui:filter>
    </xsl:if>
  </xsl:template>

  <xsl:template match="MediaOnly">
    <qui:filter key="med" arity="1">
      <qui:label>Only include records with digital media</qui:label>
      <qui:values>
        <qui:value>
          <xsl:choose>
            <xsl:when test="//Param[@name='med'] = 1">
              <xsl:attribute name="selected">true</xsl:attribute>
            </xsl:when>
            <xsl:when test="//Param[@name='med'] or //Param[@name='q1']" />
            <xsl:when test="Focus = 'true'">
              <xsl:attribute name="selected">true</xsl:attribute>
            </xsl:when>
            <xsl:otherwise />
          </xsl:choose>
          <xsl:text>1</xsl:text>
        </qui:value>
      </qui:values>
    </qui:filter>
  </xsl:template>

  <xsl:template match="MediaInfo[AuthCheck/@allowed = 'no']" mode="iiif-link" priority="250">
    <xsl:if test="normalize-space(istruct_ms) = 'P'">
      <qui:link rel="icon" type="restricted" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="MediaInfo[Type='image']" mode="iiif-link">
    <xsl:variable name="collid" select="ic_collid" />
    <xsl:variable name="m_id" select="m_id" />
    <xsl:variable name="m_iid" select="m_iid" />
    <xsl:if test="normalize-space(istruct_ms) = 'P'">
      <qui:link rel="iiif" href="{$api_url}/tile/{$collid}:{$m_id}:{$m_iid}" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="MediaInfo[Type='audio']" mode="iiif-link" priority="100">
    <xsl:if test="normalize-space(istruct_ms) = 'P'">
      <qui:link rel="icon" type="audio" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="MediaInfo[Type='pdf']" mode="iiif-link" priority="100">
    <xsl:if test="normalize-space(istruct_ms) = 'P'">
      <qui:link rel="icon" type="pdf" />
    </xsl:if>
  </xsl:template>

   <xsl:template match="MediaInfo[istruct_mt='AUDIO:::EXTERNAL:::KALTURA:::ABLEPLAYER']"
     mode="iiif-link" priority="100">
     <xsl:if test="normalize-space(istruct_ms) = 'P'">
       <qui:link rel="icon" type="audio" />
     </xsl:if>
   </xsl:template>
     
  <xsl:template match="MediaInfo" mode="iiif-link">
    <xsl:if test="normalize-space(istruct_ms) = 'P'">
      <qui:link rel="icon" type="file" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-portfolio-form">
    <qui:form action="bbaction">
      <xsl:apply-templates select="//ResultsLinks/HiddenVars/Variable[@name='rgn']" />
      <xsl:apply-templates select="//ResultsLinks/HiddenVars/Variable[@name='q1']" />
      <xsl:apply-templates select="//ResultsLinks/HiddenVars/Variable[@name='c']" />
      <xsl:apply-templates select="//ResultsLinks/HiddenVars/Variable[@name='cc']" />
    </qui:form>
  </xsl:template>

  <xsl:template name="build-item-details">
    <xsl:param name="identifier" />
    <xsl:param name="encoding-type" />
    <xsl:param name="item-encoding-level" />
    <xsl:param name="item-metadata" />
    <xsl:param name="details" />
    <xsl:param name="layout" />

    <xsl:apply-templates select="$details/*" mode="section">
      <xsl:with-param name="identifier" select="$identifier" />
      <xsl:with-param name="item-metadata" select="$item-metadata" />
      <xsl:with-param name="item-encoding-level" select="$item-encoding-level" />
      <xsl:with-param name="encoding-type" select="$encoding-type" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="node()" mode="debug">
    <xsl:value-of select="name()" />
  </xsl:template>

  <xsl:template match="Kwic" mode="section" />

  <xsl:template match="ScopingPage" mode="section">
    <xsl:param name="identifier" />
    <xsl:param name="item-metadata" />

    <xsl:variable name="scope" select="." />

    <qui:section identifier="XYZZY-{position()}" for="{$identifier}" template-name="{$template-name}">
      <xsl:apply-templates select="ancestor::Item/TocHref">
        <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
      </xsl:apply-templates>
      <qui:link href="{ViewPageLink}" rel="result" />
      <qui:link href="{ViewPageThumbnailLink}" rel="iiif" />
      <qui:title>
        <qui:values>
          <qui:value>
            <xsl:value-of select="key('get-lookup','headerutils.str.page')"/>
            <xsl:text> </xsl:text>
            <xsl:if test="PageNumber!='NA'"><xsl:value-of select="PageNumber"/></xsl:if>
            <xsl:if test="PageNumber='NA'"><xsl:text>[unnumbered]</xsl:text></xsl:if>
            <xsl:if test="PageType!='viewer.ftr.uns'"><xsl:text> - </xsl:text></xsl:if>
            <xsl:value-of select="key('get-lookup',PageType)"/>  
          </qui:value>
        </qui:values>
      </qui:title>
      <!-- metadata -->
      <qui:metadata>
        <qui:field key="path">
          <qui:label>Path</qui:label>
          <qui:values format="ordered">
            <xsl:for-each select="ancestor::*[@TYPE]">
              <qui:value>
                <qui:link rel="{name(.)}" href="{Link}">
                  <xsl:value-of select="Divhead/HEAD" />
                </qui:link>  
              </qui:value>
            </xsl:for-each>      
          </qui:values>
        </qui:field>
        <xsl:apply-templates select="$item-metadata//qui:field" mode="copy" />
      </qui:metadata>
      <xsl:if test="false()">
      <qui:block slot="metadata">
        <qui:section>
          <!-- path -->
          <qui:field key="path">
            <qui:label>Path</qui:label>
            <qui:values format="ordered">
              <xsl:for-each select="ancestor::*[@TYPE]">
                <qui:value>
                  <qui:link rel="{name(.)}" href="{Link}">
                    <xsl:value-of select="Divhead/HEAD" />
                  </qui:link>  
                </qui:value>
              </xsl:for-each>      
            </qui:values>
          </qui:field>
          <xsl:apply-templates select="$item-metadata//qui:field" mode="copy" />
        </qui:section>
      </qui:block>
      </xsl:if>
      <xsl:for-each select="following-sibling::SummaryString[./preceding-sibling::ScopingPage[1] = $scope]">
        <qui:block slot="summary" variant="info">
          <xsl:apply-templates select="." />
        </qui:block>
      </xsl:for-each>
      <qui:block slot="matches">
        <qui:section>
          <qui:field key="matches">
            <qui:label>Matches</qui:label>
            <qui:values format="kwic">
              <xsl:for-each select="following-sibling::Kwic[./preceding-sibling::ScopingPage[1] = $scope]">
                <qui:value>
                  <xsl:apply-templates select="." />
                </qui:value>
              </xsl:for-each>
            </qui:values>
          </qui:field>z  
        </qui:section>
      </qui:block>
    </qui:section>
  </xsl:template>

  <xsl:template match="node()[Divhead/HEAD]|node()[Divhead][Kwic]" mode="section">
    <xsl:param name="identifier" />
    <xsl:param name="item-metadata" />
    <xsl:param name="encoding-type" />
    <xsl:param name="item-encoding-level" />

    <!-- we only need a qui:section if THIS is the DIV of interest -->

    <xsl:if test="not(node()[@TYPE][Divhead/HEAD])">

      <xsl:variable name="details-metadata-tmp">
        <xsl:call-template name="build-header-metadata">
          <xsl:with-param name="item" select="." />
          <xsl:with-param name="encoding-type" select="$encoding-type" />
          <xsl:with-param name="item-encoding-level" select="$item-encoding-level" />
          <xsl:with-param name="slot">item</xsl:with-param>
        </xsl:call-template>
      </xsl:variable>
      <xsl:variable name="details-metadata" select="exsl:node-set($details-metadata-tmp)" />

      <qui:section identifier="{@NODE}" for="{$identifier}" template-name="{$template-name}">
        <!-- <xsl:apply-templates select="$item/TocHref">
          <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
        </xsl:apply-templates> -->
        <xsl:apply-templates select="ancestor::Item/TocHref">
          <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
        </xsl:apply-templates>
        <xsl:apply-templates select="MediaInfo" mode="iiif-link" />
        <qui:link href="{Link}" rel="result" />
        <xsl:if test="ViewPageThumbnailLink">
          <qui:link href="{ViewPageThumbnailLink}" rel="iiif" />
        </xsl:if>
        <qui:title>
          <xsl:choose>
            <xsl:when test="$details-metadata//qui:field[@key='title']">
              <xsl:apply-templates select="$details-metadata//qui:field[@key='title']/qui:values" mode="copy" />
            </xsl:when>
            <xsl:when test="Divhead/HEAD">
              <xsl:value-of select="Divhead/HEAD" />
            </xsl:when>
            <xsl:when test="Kwic/HEAD">
              <xsl:value-of select="Kwic/HEAD" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="@TYPE" />
            </xsl:otherwise>
          </xsl:choose>
        </qui:title>
        <!-- metadata -->
        <qui:metadata>
          <qui:field key="path">
            <qui:label>Path</qui:label>
            <qui:values format="ordered">
              <xsl:for-each select="ancestor::*[@TYPE]">
                <qui:value>
                  <qui:link rel="{name(.)}" href="{Link}">
                    <xsl:value-of select="Divhead/HEAD" />
                  </qui:link>  
                </qui:value>
              </xsl:for-each>      
            </qui:values>
          </qui:field>
          <xsl:apply-templates select="$details-metadata//qui:field" mode="copy" />
        </qui:metadata>
        <xsl:if test="descendant-or-self::Kwic">
          <qui:block slot="matches">
            <qui:section>
              <qui:field key="matches">
                <qui:label>Matches</qui:label>
                <qui:values format="kwic">
                  <xsl:for-each select="descendant-or-self::Kwic|descendant-or-self::SummaryString">
                    <qui:value>
                      <xsl:apply-templates select="." />
                    </qui:value>
                  </xsl:for-each>
                </qui:values>
              </qui:field>z  
            </qui:section>
          </qui:block>  
        </xsl:if>
      </qui:section>  
    </xsl:if>

    <xsl:apply-templates select="*[starts-with(name(),'DIV')][Divhead/HEAD]" mode="section">
      <xsl:with-param name="identifier" select="$identifier" />
      <xsl:with-param name="item-metadata" select="$item-metadata" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template match="@*" mode="dlxsify">
    <xsl:copy></xsl:copy>
  </xsl:template>

  <xsl:template match="text()" mode="dlxsify">
    <xsl:copy></xsl:copy>
  </xsl:template>

  <xsl:template match="node()[name()]" mode="dlxsify" priority="99">
    <xsl:element name="dlxs:{name()}">
      <xsl:apply-templates select="@*|text()|*" mode="dlxsify" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="Callout">
    <qui:callout variant='success' slot="portfolio">
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

  <xsl:template match="SearchDescription">
    <qui:block slot="search-summary">
      <!-- <xsl:value-of select="key('get-lookup','reslist.str.yousearched')"/> -->
      <xsl:value-of select="/Top/SearchDescription/CollTotals/HitCount" />
      <xsl:text> matches </xsl:text>
      <xsl:value-of select="key('get-lookup','reslist.str.for')"/>
      <xsl:text> </xsl:text>
      <span class="naturallanguage">
        <xsl:apply-templates select="SearchInNaturalLanguage"/>
      </span>
      <xsl:if test="SearchQualifier != 'results.summary.singletextrestricted'">
        <xsl:text> in </xsl:text>
        <xsl:choose>
          <xsl:when test="SearchQualifier!=''">
            <span class="itemid">
              <xsl:value-of select="key('get-lookup',SearchQualifier)"/>
            </span>
          </xsl:when>
          <xsl:otherwise>
            <span class="collid">
              <xsl:apply-templates select="SearchCollid"/>
            </span>
          </xsl:otherwise>
        </xsl:choose>  
      </xsl:if>
      <!-- <br/>
      <xsl:value-of select="key('get-lookup','reslist.str.results')"/>
      <xsl:text> </xsl:text>
      <xsl:apply-templates select="CollTotals"/> -->
    </qui:block>
  </xsl:template>

  <xsl:template match="CollTotals">
    <xsl:choose>
      <xsl:when test="$searchtype='basic' or $searchtype='proximity'">
        <xsl:call-template name="SimpleXCHitSumm"/>
      </xsl:when>
      <xsl:when test="$searchtype='boolean'">
        <xsl:call-template name="BooleanXCHitSumm"/>
      </xsl:when>
      <xsl:when test="$searchtype='bibliographic'">
        <xsl:call-template name="BibXCHitSumm"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="SearchQualifier">
    <xsl:copy-of select="."/>
  </xsl:template>
  <xsl:template match="SearchTypeName">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="SearchInNaturalLanguage">
    <xsl:value-of select="."/>
  </xsl:template>
  <xsl:template match="SearchCollid">
    <xsl:choose>
      <xsl:when test="contains(.,'.')">
        <xsl:value-of select="key('get-lookup',.)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="."/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="SimpleXCHitSumm">
    <xsl:value-of select="HitCount"/>
    <xsl:value-of select="key('get-lookup','results.str.23')"/>
    <xsl:apply-templates mode="HitSummPl" select="HitCount"/>
    <xsl:value-of select="key('get-lookup','results.str.24')"/>
    <xsl:value-of select="RecordCount"/>
    <xsl:value-of select="key('get-lookup','results.str.25')"/>
    <xsl:apply-templates mode="HitSummPl" select="RecordCount"/>
  </xsl:template>
  
  <xsl:template name="BibXCHitSumm">
    <xsl:value-of select="RecordCount"/>
    <xsl:value-of select="key('get-lookup','results.str.26')"/>
    <xsl:value-of select="key('get-lookup','results.str.27')"/>
    <xsl:apply-templates mode="HitSummPl" select="RecordCount"/>
  </xsl:template>
   
  <xsl:template name="BooleanXCHitSumm">
    <xsl:value-of select="HitRegionCount"/>
    <xsl:value-of select="key('get-lookup','results.str.28')"/>
    <xsl:value-of select="HitRegion"/>
    <xsl:value-of select="key('get-lookup','results.str.29')"/>
    <xsl:value-of select="RecordCount"/>
    <xsl:value-of select="key('get-lookup','results.str.30')"/>
    <xsl:apply-templates mode="HitSummPl" select="RecordCount"/>
  </xsl:template>
  
  <xsl:template match="HEAD" mode="procdivhead">
    <xsl:if test="BIBL">
      <xsl:for-each select="BIBL[@TYPE!='pg' and @TYPE!='pp' and @TYPE!='page' and @TYPE!='para']">
        <xsl:apply-templates select="LB|HI1|HI2|Highlight|text()"/>
        <xsl:if test="position()!=last()">
          <xsl:text>:&#xa0;</xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
    <xsl:apply-templates select="LB|HI1|HI2|Highlight|text()[not(starts-with(normalize-space(.),' '))]"/>
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
  
  <!-- Template for handling content inside kwic tags -->
  <xsl:template match="*" mode="KwicContent">
    <xsl:choose>
      <xsl:when test="name()='Highlight'">
        <xsl:apply-templates select="."/>
      </xsl:when>
      <xsl:otherwise>        
        <xsl:apply-templates  select="child::node()" mode="KwicContent"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <!-- Special formatting for elements inside kwic tags -->
  <xsl:template match="HEAD" mode="KwicContent">
    <xsl:apply-templates select="child::node()" mode="KwicContent"/>
    <xsl:text>: </xsl:text>
  </xsl:template>
  <xsl:template match="NOTE1|NOTE2" mode="KwicContent">
    <xsl:text>[</xsl:text>
    <xsl:apply-templates select="child::node()" mode="KwicContent"/>
    <xsl:text>]</xsl:text>
  </xsl:template>
  <xsl:template match="LB" mode="KwicContent">
    <xsl:text> </xsl:text>
  </xsl:template>
  <xsl:template match="L" mode="KwicContent">
    <xsl:apply-templates select="child::node()" mode="KwicContent"/>
    <xsl:text> / </xsl:text>
  </xsl:template>
  <xsl:template match="P" mode="KwicContent">
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="child::node()" mode="KwicContent"/>
    <xsl:text> / </xsl:text>
  </xsl:template>
  <xsl:template match="DATE|CLOSER" mode="KwicContent">
    <xsl:text> </xsl:text>
    <xsl:apply-templates select="child::node()" mode="KwicContent"/>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="GuideFrameResults">
    <xsl:if test="Coll">
      <qui:panel slot="guide-frame">
        <xsl:apply-templates select="Coll" />        
      </qui:panel>
    </xsl:if>
  </xsl:template>

  <xsl:template match="GuideFrameResults/Coll">
    <qui:section>
      <xsl:if test="FocusColl = 'true'">
        <xsl:attribute name="selected">selected</xsl:attribute>
      </xsl:if>
      <xsl:attribute name="icon">
        <xsl:choose>
          <xsl:when test="CollName = 'results.allselectedcolls'">
            <xsl:text>topic</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>filter_frames</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="data-hit-count">
        <xsl:value-of select="CollTotals/HitCount" />
      </xsl:attribute>
      <qui:header>
        <xsl:choose>
          <xsl:when test="CollName = 'results.allselectedcolls'">
            <xsl:value-of select="key('get-lookup', CollName)" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="CollName" />
          </xsl:otherwise>
        </xsl:choose>    
      </qui:header>
      <qui:link rel="results">
        <xsl:attribute name="href">
          <xsl:choose>
            <xsl:when test="FocusColl = 'true'">
              <xsl:value-of select="//CurrentUrl" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="CollResultsHref" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </qui:link>
      <xsl:if test="normalize-space(CollHomeHref)">
        <qui:link rel="home" href="{CollHomeHref}" />
      </xsl:if>
      <qui:block slot="summary">
        <xsl:apply-templates select="CollTotals" />
      </qui:block>
    </qui:section>
  </xsl:template>

  <xsl:template match="SummaryString">
    <xsl:variable name="key">
      <xsl:text>results.str.3</xsl:text>
      <xsl:if test="HitCount != 1">
        <xsl:text>p</xsl:text>
      </xsl:if>
    </xsl:variable>
    <span>
      <xsl:value-of select="HitCount" />
      <xsl:value-of select="key('get-lookup',$key)"/>
      <xsl:text> of </xsl:text>
      <xsl:apply-templates select="HitTerm" />
    </span>
  </xsl:template>

  <xsl:template match="HitTerm">
    <xsl:text>"</xsl:text>
    <xsl:value-of select="." />
    <xsl:text>"</xsl:text>
  </xsl:template>
  
</xsl:stylesheet>