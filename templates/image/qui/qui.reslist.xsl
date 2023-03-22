<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml"  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />

  <!-- globals -->
  <xsl:variable name="total" select="//TotalResults" />
  <xsl:variable name="sz" select="//Param[@name='size']" />
  <xsl:variable name="end-1">
    <xsl:choose>
      <xsl:when test="$total &lt;= $sz">
        <xsl:value-of select="$total" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="//Fisheye/Url[@class='active']/@name + $sz - 1" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="end">
    <xsl:choose>
      <xsl:when test="$end-1 &gt; //TotalResults"><xsl:value-of select="//TotalResults" /></xsl:when>
      <xsl:otherwise><xsl:value-of select="$end-1" /></xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="max">
    <xsl:choose>
      <xsl:when test="$total &lt;= $sz">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count(//Fisheye/Url)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="current">
    <xsl:choose>
      <xsl:when test="count(//Fisheye/Url) = 0">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count(//Fisheye/Url[@class='active']//preceding-sibling::Url) + 1" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="start">
    <xsl:choose>
      <xsl:when test="$total &lt;= $sz">
        <xsl:value-of select="1" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="//Fisheye/Url[@class='active']/@name" />
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
    Search Results
  </xsl:template>

  <xsl:template name="build-results-navigation">
    <!-- do we have M/N available in the PI handler? -->
    <xsl:variable name="tmp-xml">
      <qui:nav role="results" total="{//TotalResults}" size="{$sz}" min="1" max="{$max}" current="{$current}" start="{$start}" end="{$end}" is-truncated="{/Top/SearchSummary/Truncated}">
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">next</xsl:with-param>
          <xsl:with-param name="identifier" select="/Top/Next/@identifier" />
          <xsl:with-param name="marker" select="/Top/Next/@marker" />
          <xsl:with-param name="href" select="/Top/Next/Url" />
        </xsl:call-template>
        <xsl:call-template name="build-results-navigation-link">
          <xsl:with-param name="rel">previous</xsl:with-param>
          <xsl:with-param name="identifier" select="/Top/Prev/@identifier" />
          <xsl:with-param name="marker" select="/Top/Prev/@marker" />
          <xsl:with-param name="href" select="/Top/Prev/Url" />
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
    <xsl:apply-templates select="//Facets" />
    <qui:form id="sort-options">
      <xsl:for-each select="//SortOptionsMenu/HiddenVars/Variable">
        <qui:hidden-input name="{@name}" value="{.}" />
      </xsl:for-each>
      <qui:select name="sort">
        <xsl:for-each select="//SortOptionsMenu/Option">
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
    <qui:block slot="results">
      <xsl:if test="//Param[@name='xc'] = 1 or //Param[@name='view'] = 'bbreslist'">
        <xsl:attribute name="data-xc">true</xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="//TotalResults = 0">
          <xsl:call-template name="build-no-results" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="//Results/Result" />
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

  <xsl:template match="Results/Result">
    <qui:section identifier="{EntryId}">
      <qui:link rel="result" href="{Url[@name='EntryLink']}" identifier="{.//EntryWindowName}" marker="{@marker}" />
      <xsl:apply-templates select="MediaInfo" mode="iiif-link" />
      <qui:title>
        <qui:values>
          <xsl:for-each select="str:split(ItemDescription, '|||')">
            <qui:value><xsl:value-of select="." /></qui:value>
          </xsl:for-each>
        </qui:values>
      </qui:title>
      <qui:collection collid="{CollName/@collid}">
        <qui:title><xsl:value-of select="CollName/Full" /></qui:title>
      </qui:collection>
      <qui:block slot="metadata">
        <xsl:apply-templates select="Record[@name='result']/Section" />
      </qui:block>
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