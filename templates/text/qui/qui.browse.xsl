<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />

  <!-- globals -->
  <xsl:variable name="total" select="//BrowseList/TotalBrowseItems|//BrowseList/TotalTags" />
  <xsl:variable name="slice-start" select="//BrowseList/SliceStart" />
  <xsl:variable name="slice-size" select="//BrowseList/BrowseSliceSize" />
  <xsl:variable name="sz" select="number(50)" />
  <xsl:variable name="end-1">
    <xsl:choose>
      <xsl:when test="not($slice-start)">
        <xsl:value-of select="$total" />
      </xsl:when>
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
      <xsl:when test="not($slice-start)">
        <xsl:value-of select="1" />
      </xsl:when>
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
      <xsl:when test="not($slice-start)">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:when test="$slice-start = 0">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="( ( $slice-start + 1 ) div $slice-size) + 1" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="start">
    <xsl:choose>
      <xsl:when test="not($slice-start)">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:when test="$total &lt;= $sz">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$slice-start + 1 " />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="current-browse-field" select="//Param[@name='key']" />


  <xsl:template name="build-body-main">
    <xsl:call-template name="build-results-navigation" />
    <xsl:call-template name="build-breadcrumbs" />
    <qui:header role="main">
      <!-- <xsl:when test="//BookBagInfo/Field[@name='shared'] = '0'">
        <xsl:attribute name="data-status">private</xsl:attribute>
      </xsl:when> -->
      <xsl:text>Browse Collection: </xsl:text>
      <xsl:value-of select="key('get-lookup', concat('browse.str.', $current-browse-field, '.column'))" />
      <!-- <xsl:value-of select="dlxs:capitalize($current-browse-field)"/> -->
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
    <xsl:text> | Browse Collection | </xsl:text>
    <xsl:value-of select="key('get-lookup', concat('browse.str.', $current-browse-field, '.column'))" />
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    Browse Collection
  </xsl:template>

  <xsl:template name="build-browse-navigation">
    <qui:nav role="browse">
      <xsl:choose>
        <xsl:when test="//qui:panel[@slot='browse']//qui:link[@key]">
          <xsl:for-each select="//qui:panel[@slot='browse']//qui:link[@key]">
            <qui:link key="{@key}" href="{@href}">
              <qui:label>
                <xsl:value-of select="key('get-lookup', concat('uplift.str.page.', @key))" />
              </qui:label>
            </qui:link>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="//CollectionIdno">
          <qui:link key="picklist" href="/cgi/t/text/text-idx?cc={$collid};idno={//CollectionIdno}">
            <qui:label>
              <xsl:value-of select="key('get-lookup', 'uplift.picklist.str.morethanoneitem')" />
            </qui:label>
          </qui:link>
        </xsl:when>
      </xsl:choose>
      <xsl:for-each select="/Top/NavHeader/BrowseFields/Field">
        <qui:link href="{Link}" key="{Name}">
          <xsl:if test="Name = $current-browse-field">
            <xsl:attribute name="current">true</xsl:attribute>
          </xsl:if>
          <qui:label>
            <xsl:value-of select="key('get-lookup', concat('browse.str.', Name, '.column'))" />
            <!-- <xsl:value-of select="dlxs:capitalize(Name)" /> -->
          </qui:label>
        </qui:link>
      </xsl:for-each>
    </qui:nav>
  </xsl:template>

  <xsl:template name="build-browse-index">
    <xsl:variable name="default-value" select="//BrowseNav/DefaultValue" />
    <qui:form role="browse">
      <qui:label for="input-value">
        <xsl:text>Find items having </xsl:text>
        <xsl:value-of select="dlxs:capitalize(//Param[@name='key'])" />
        <br />
        <xsl:text>starting with:</xsl:text>
      </qui:label>
      <qui:input type="text" name="value" id="input-value">
        <xsl:attribute name="value">
          <xsl:choose>
            <xsl:when test="//BrowseNav//String[Value[. = $default-value]][Count &lt; 0]">
              <xsl:value-of select="$default-value" />
            </xsl:when>
            <xsl:otherwise />
          </xsl:choose>
        </xsl:attribute>
      </qui:input>
      <xsl:for-each select="//BrowseStringForm/HiddenVars/Variable[@name != 'xxkey']">
        <qui:input type="hidden" role="browse" name="{@name}" value="{.}">
        </qui:input>
      </xsl:for-each>
    </qui:form>
    <qui:nav role="index">
      <xsl:for-each select="//BrowseNav/FirstLetter">
        <xsl:variable name="first-letter" select="Value" />
        <qui:link href="{Link}">
          <xsl:if test="Value/@selected = 'true'">
            <xsl:attribute name="data-selected">true</xsl:attribute>
          </xsl:if>
          <qui:label><xsl:value-of select="Value" /></qui:label>
          <xsl:apply-templates select="//BrowseNav/String[starts-with(Value, $first-letter)][Count &gt; 0]">
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
              <xsl:text>/cgi/t/text/text-idx?page=browse;</xsl:text>
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
              <xsl:text>/cgi/t/text/text-idx?page=browse;</xsl:text>
              <xsl:text>key=</xsl:text>
              <xsl:value-of select="//Param[@name='key']" />
              <xsl:text>;value=</xsl:text>
              <xsl:value-of select="//Param[@name='value']" />
              <xsl:text>;c=</xsl:text>
              <xsl:value-of select="//Param[@name='c']" />
              <xsl:text>;start=</xsl:text>
              <xsl:value-of select="( $slice-start + 1 ) - $slice-size" />  
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
    <xsl:variable name="key" select="//Param[@name='key']" />
    <xsl:variable name="value" select="//BrowseNav/DefaultValue" />
    <qui:block slot="results" data-key="{$key}" data-value="{$value}">
      <xsl:if test="//Param[@name='xc'] = 1 or //Param[@name='view'] = 'bbreslist'">
        <xsl:attribute name="data-xc">true</xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="$total = 0">
          <xsl:call-template name="build-no-results" />
        </xsl:when>
        <xsl:when test="//BrowseList/Tag">
          <xsl:apply-templates select="//BrowseList/Tag" />
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

  <xsl:template match="BrowseList/Tag">
    <qui:tag href="{Url}" count="{Count}">
      <xsl:value-of select="Value" />
    </qui:tag>
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

    <xsl:variable name="identifier" select="translate(Idno, 'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')" />

    <qui:section identifier="{$identifier}" auth-required="{AuthRequired}" encoding-type="{$encoding-type}" encoding-level="{$item-encoding-level}">
      <xsl:apply-templates select="Tombstone" />
      <xsl:apply-templates select="DetailHref" />
      <!-- <xsl:apply-templates select="TocHref">
        <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
      </xsl:apply-templates> -->
      <qui:link rel="toc" href="{Link}">
        <xsl:attribute name="label">
          <xsl:choose>
            <xsl:when test="$item-encoding-level = '1'">
              <!-- <xsl:value-of select="key('get-lookup','results.str.16')"/> -->
              <xsl:value-of select="key('get-lookup','uplift.str.contents')"/>
            </xsl:when>
            <xsl:otherwise>
              <!-- <xsl:value-of select="key('get-lookup','results.str.17')"/>             -->
              <xsl:value-of select="key('get-lookup','uplift.str.contents')"/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </qui:link>  
      <xsl:apply-templates select="ThumbnailLink" />
      <xsl:if test="normalize-space(BookbagAddHref)">
        <qui:form slot="bookbag" rel="add" href="{BookbagAddHref}" data-identifier="{$identifier}">
        </qui:form>
      </xsl:if>
      <xsl:if test="not($encoding-type='serialissue')">
        <xsl:apply-templates select="FirstPageHref"/>
      </xsl:if>

      <xsl:call-template name="build-header-metadata">
        <xsl:with-param name="item" select="." />
        <xsl:with-param name="encoding-type" select="$encoding-type" />
        <xsl:with-param name="item-encoding-level" select="$item-encoding-level" />
      </xsl:call-template>
      
    </qui:section>

    <!-- <qui:section identifier="{Idno}">
      <qui:link rel="result" href="{Link}" />
      <xsl:apply-templates select="ThumbnailLink" mode="iiif-link" />
      <xsl:choose>
        <xsl:when test="$encoding-type = 'monograph'">
          <xsl:call-template name="process-monograph">
            <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$encoding-type = 'serialissue'">
          <xsl:call-template name="process-serialissue">
            <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$encoding-type = 'serialarticle'">
          <xsl:call-template name="process-serial-article">
            <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
          </xsl:call-template>          
        </xsl:when>
      </xsl:choose>
    </qui:section> -->
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