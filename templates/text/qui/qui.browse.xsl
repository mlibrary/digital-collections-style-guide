<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />

  <!-- globals -->
  <xsl:variable name="total" select="//BrowseList/TotalBrowseItems" />
  <xsl:variable name="slice-start" select="//BrowseList/SliceStart" />
  <xsl:variable name="slice-size" select="//BrowseList/BrowseSliceSize" />
  <xsl:variable name="sz" select="number(50)" />
  <xsl:variable name="end-1">
    <xsl:choose>
      <xsl:when test="$total &lt;= $sz">
        <xsl:value-of select="$total" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$slice-start + $sz + 1" />
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
        <xsl:value-of select="ceiling($total div $slice-size)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="current">
    <xsl:choose>
      <xsl:when test="$slice-start = 0">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="( ( $slice-start + 1 ) div $slice-size )" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="start">
    <xsl:choose>
      <xsl:when test="$total &lt;= $sz">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$slice-start + 1 + 1" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>


  <xsl:template name="build-body-main">
    <xsl:call-template name="build-results-navigation" />
    <xsl:call-template name="build-breadcrumbs" />
    <qui:header role="main">
      <!-- <xsl:when test="//BookBagInfo/Field[@name='shared'] = '0'">
        <xsl:attribute name="data-status">private</xsl:attribute>
      </xsl:when> -->
      <xsl:text>Browse Collection: </xsl:text>
      <xsl:value-of select="dlxs:capitalize(/Top/NavHeader/BrowseFields/Field/Name[@default='1'])"/>
    </qui:header>
    <!-- <xsl:call-template name="build-action-panel" /> -->
    <xsl:call-template name="build-results-list" />
    <xsl:call-template name="build-browse-index" />
    <xsl:call-template name="build-browse-navigation" />
    <!-- <xsl:call-template name="build-portfolio-form" /> -->
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
    Browse Collection
  </xsl:template>

  <xsl:template name="build-browse-navigation">
    <qui:nav role="browse">
      <xsl:for-each select="/Top/NavHeader/BrowseFields/Field">
        <qui:link href="{Link}" key="{Name}">
          <xsl:if test="Name/@default = '1'">
            <xsl:attribute name="current">true</xsl:attribute>
          </xsl:if>
          <qui:label><xsl:value-of select="dlxs:capitalize(Name)" /></qui:label>
        </qui:link>
      </xsl:for-each>
    </qui:nav>
  </xsl:template>

  <xsl:template name="build-browse-index">
    <xsl:variable name="default-value" select="//BrowseNav/DefaultValue" />
    <qui:nav role="index">
      <xsl:for-each select="//BrowseNav/FirstLetter">
        <xsl:variable name="first-letter" select="Value" />
        <qui:link href="{Link}">
          <xsl:if test="Value/@selected = 'true'">
            <xsl:attribute name="data-selected">true</xsl:attribute>
          </xsl:if>
          <qui:label><xsl:value-of select="Value" /></qui:label>
          <xsl:apply-templates select="//BrowseNav/String[starts-with(Value, $first-letter)]">
            <xsl:with-param name="default-value" select="$default-value" />
          </xsl:apply-templates>
        </qui:link>
      </xsl:for-each>
    </qui:nav>
  </xsl:template>

  <xsl:template match="BrowseNav/String">
    <xsl:param name="default-value" />
    <qui:link href="{Link}">
      <xsl:if test="Value/@selected = 'true'">
        <xsl:attribute name="data-selected">true</xsl:attribute>
      </xsl:if>
      <qui:label><xsl:value-of select="Value" /></qui:label>
    </qui:link>
  </xsl:template>

  <xsl:template name="build-results-navigation">
    <!-- do we have M/N available in the PI handler? -->
    <xsl:variable name="tmp-xml">
      <qui:nav role="results" total="{$total}" size="{$sz}" min="1" max="{$max}" current="{$current}" start="{$start}" end="{$end}" slice="{$slice-start}" is-truncated="{/Top/SearchSummary/Truncated}">
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">next</xsl:with-param>
          <xsl:with-param name="href">
            <xsl:if test="$current &lt; $max">
              <xsl:text>/cgi/t/text/text-idx?</xsl:text>
              <xsl:text>key=</xsl:text>
              <xsl:value-of select="//Param[@name='key']" />
              <xsl:text>;value=</xsl:text>
              <xsl:value-of select="//Param[@name='value']" />
              <xsl:text>;c=</xsl:text>
              <xsl:value-of select="//Param[@name='c']" />
              <xsl:text>;start=</xsl:text>
              <xsl:value-of select="$slice-start + $slice-size" />  
            </xsl:if>
          </xsl:with-param>
        </xsl:call-template>
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">previous</xsl:with-param>
          <xsl:with-param name="href">
            <xsl:if test="$current &gt; 1">
              <xsl:text>/cgi/t/text/text-idx?</xsl:text>
              <xsl:text>key=</xsl:text>
              <xsl:value-of select="//Param[@name='key']" />
              <xsl:text>;value=</xsl:text>
              <xsl:value-of select="//Param[@name='value']" />
              <xsl:text>;c=</xsl:text>
              <xsl:value-of select="//Param[@name='c']" />
              <xsl:text>;start=</xsl:text>
              <xsl:value-of select="$slice-start - $slice-size" />  
            </xsl:if>
          </xsl:with-param>
        </xsl:call-template>
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
        <qui:link rel="{$rel}" href="" disabled="disabled" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <xsl:template name="build-results-list">
    <xsl:variable name="q" select="//SearchForm/Q[@name='q1']" />
    <xsl:variable name="is-advanced" select="//SearchForm/Advanced" />
    <xsl:call-template name="build-search-form" />
    <xsl:call-template name="build-portfolio-actions" />
    <qui:block slot="results">
      <xsl:if test="//Param[@name='xc'] = 1 or //Param[@name='view'] = 'bbreslist'">
        <xsl:attribute name="data-xc">true</xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$total = 0">
          <xsl:call-template name="build-no-results" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="//BrowseList/Item" />
        </xsl:otherwise>
      </xsl:choose>
    </qui:block>
    <xsl:if test="//Callout">
      <xsl:apply-templates select="//Callout" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-portfolio-actions" />

  <xsl:template name="build-no-results">
    <pre>BOO-YAH</pre>
  </xsl:template>

  <xsl:template match="BrowseList/Item">
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

    <qui:section identifier="{Idno}">
      <qui:link rel="result" href="{Link}" />
      <xsl:apply-templates select="ThumbnailLink" mode="iiif-link" />
      <xsl:choose>
        <xsl:when test="$encoding-type = 'monograph'">
          <xsl:call-template name="process-monograph">
            <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$encoding-type = 'serialissue'">
          <xsl:call-template name="process-serial-issue">
            <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$encoding-type = 'serialarticle'">
          <xsl:call-template name="process-serial-article">
            <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
          </xsl:call-template>          
        </xsl:when>
      </xsl:choose>
    </qui:section>
  </xsl:template>

  <xsl:template name="process-monograph">
    <xsl:param name="item-encoding-level" />
    <xsl:variable name="main-title">
      <!-- use the 245 title if there is one -->
      <xsl:choose>
        <xsl:when test="ItemHeader/HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245']">
          <xsl:value-of select="ItemHeader/HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ItemHeader/HEADER/FILEDESC/TITLESTMT/TITLE"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="main-author">
      <xsl:choose>
        <xsl:when test="ItemHeader/HEADER/FILEDESC/TITLESTMT/AUTHOR">
          <xsl:value-of select="ItemHeader/HEADER/FILEDESC/TITLESTMT/AUTHOR"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="ItemHeader/HEADER/FILEDESC/TITLESTMT/EDITOR"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="inverted-author" select="''"/>

    <xsl:variable name="sort-title">
      <xsl:value-of select="ItemHeader/HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='sort']"/>
    </xsl:variable>

    <xsl:variable name="main-date">
      <xsl:value-of select="ItemHeader/HEADER/FILEDESC/SOURCEDESC/BIBLFULL/PUBLICATIONSTMT/DATE"/>
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
        <xsl:if test="$main-author or $inverted-author">
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
        </xsl:if>
      </qui:section>
    </qui:block>
  </xsl:template>

  <!-- override -->
  <xsl:template name="build-search-form-xx">
    <xsl:variable name="q" select="//SearchForm/Q[@name='q1']" />
    <qui:form id="collection-search" data-edit-action="/cgi/t/text/text-idx" role="browse">
      <xsl:attribute name="data-has-query">
        <xsl:choose>
          <xsl:when test="normalize-space(//BrowseStringForm/Value)">true</xsl:when>
          <xsl:when test="//SearchForm/MediaOnly[Focus='true']">true</xsl:when>
          <xsl:when test="//SearchForm/Range//Value[normalize-space(.)]">true</xsl:when>
          <xsl:when test="count(//SearchForm/Q[@name != 'q0'][normalize-space(Value)]) = 1 and //SearchForm/Q[@name != 'q0']/Value = //SearchForm/HiddenVars/Variable[@name='c']">false</xsl:when>
          <xsl:when test="normalize-space(//SearchForm/Q[@name != 'q0']/Value)">true</xsl:when>
          <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates select="//BrowseStringForm/Value" />
      <xsl:apply-templates select="//BrowseStringForm/HiddenVars/Variable" />
      <xsl:if test="//SearchForm/HiddenVars/Variable[@name='xc'] = '1'">
        <xsl:for-each select="//Param[@name='c']">
          <qui:hidden-input name="c" value="{.}" />
        </xsl:for-each>
      </xsl:if>
    </qui:form>
  </xsl:template>

  <xsl:template match="BrowseStringForm/Value">
    <qui:fieldset name="value-fieldset" data-name="value" slot="clause">
      <qui:input name="value" slot="query" value="{.}" data-active="true" />
    </qui:fieldset>
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
      <xsl:if test="//BbagOptionsMenu/UserIsOwner = 'true'">
        <xsl:attribute name="data-owner">true</xsl:attribute>
        <xsl:attribute name="data-status">
          <xsl:choose>
            <xsl:when test="//BookBagInfo/Field[@name='shared'] = '0'">private</xsl:when>
            <xsl:otherwise>public</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:if>
      <xsl:for-each select="//BbagOptionsMenu/HiddenVars/Variable">
        <qui:hidden-input name="{@name}" value="{.}" />
      </xsl:for-each>
      <qui:hidden-input name="backlink" value="{//BbagOptionsMenu/BackLink}" />
    </qui:form>
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

</xsl:stylesheet>