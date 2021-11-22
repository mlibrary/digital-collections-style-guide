<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

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
      <xsl:call-template name="get-collection-title" />
    </qui:header>
    <!-- <xsl:call-template name="build-action-panel" /> -->
    <xsl:call-template name="build-results-list" />
    <qui:message>BOO-YAH-HAH</qui:message>
  </xsl:template>

  <xsl:template name="get-title">
    <xsl:value-of select="//Param[@name='q1']" />
    <xsl:text> | </xsl:text>
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
      <qui:nav role="results" total="{//TotalResults}" size="{$sz}" min="1" max="{$max}" current="{$current}" start="{$start}" end="{$end}">
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
    <xsl:if test="normalize-space($href)">
      <xsl:message>NAVIGATION: <xsl:value-of select="$identifier" /></xsl:message>
      <qui:link rel="{$rel}" href="{$href}">
        <xsl:if test="normalize-space($identifier)">
          <xsl:attribute name="identifier"><xsl:value-of select="$identifier" /></xsl:attribute>
        </xsl:if>
        <xsl:if test="normalize-space($marker)">
          <xsl:attribute name="marker"><xsl:value-of select="$marker" /></xsl:attribute>
        </xsl:if>
      </qui:link>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-results-list">
    <xsl:variable name="q" select="//SearchForm/Q[@name='q1']" />
    <xsl:variable name="is-advanced" select="//SearchForm/Advanced" />
    <xsl:call-template name="build-search-form" />
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
      <xsl:choose>
        <xsl:when test="//TotalResults = 0">
          <xsl:call-template name="build-no-results" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="//Results/Result" />
        </xsl:otherwise>
      </xsl:choose>
    </qui:block>
  </xsl:template>

  <xsl:template name="build-no-results">
    <pre>BOO-YAH</pre>
  </xsl:template>

  <xsl:template match="Results/Result">
    <qui:section>
      <qui:link rel="result" href="{Url[@name='EntryLink']}" identifier="{.//EntryWindowName}" marker="{@marker}" />
      <xsl:apply-templates select="MediaInfo" mode="iiif-link" />
      <qui:title>
        <qui:values>
          <xsl:for-each select="str:split(ItemDescription, '|||')">
            <qui:value><xsl:value-of select="." /></qui:value>
          </xsl:for-each>
        </qui:values>
      </qui:title>
      <qui:block slot="metadata">
        <xsl:apply-templates select="Record[@name='result']/Section" />
      </qui:block>
    </qui:section>
  </xsl:template>

  <xsl:template match="Facets">
    <qui:filters-panel>
      <xsl:apply-templates select="//SearchForm/MediaOnly" />
      <xsl:for-each select="Field">
        <qui:filter key="{@abbrev}">
          <qui:label>
            <xsl:value-of select="Label" />
          </qui:label>
          <qui:values>
            <xsl:for-each select="Values/Value">
              <qui:value count="{@count}">
                <xsl:if test="@selected">
                  <xsl:attribute name="selected"><xsl:value-of select="@selected" /></xsl:attribute>
                </xsl:if>
                <xsl:value-of select="." />
              </qui:value>
            </xsl:for-each>
          </qui:values>
        </qui:filter>
      </xsl:for-each>
    </qui:filters-panel>
  </xsl:template>

  <xsl:template match="MediaOnly">
    <qui:filter key="med" arity="1">
      <qui:label>Has digital media?</qui:label>
      <qui:values>
        <qui:value>
          <xsl:if test="Focus = 'true'">
            <xsl:attribute name="selected">true</xsl:attribute>
          </xsl:if>
          <xsl:text>1</xsl:text>
        </qui:value>
      </qui:values>
    </qui:filter>
  </xsl:template>

  <xsl:template match="MediaInfo" mode="iiif-link">
    <xsl:variable name="collid" select="ic_collid" />
    <xsl:variable name="m_id" select="m_id" />
    <xsl:variable name="m_iid" select="m_iid" />
    <xsl:if test="normalize-space(istruct_ms) = 'P'">
      <qui:link rel="iiif" href="https://quod.lib.umich.edu/cgi/i/image/api/image/{$collid}:{$m_id}:{$m_iid}" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>