<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:import href="str.split.function.xsl" />

  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />

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

  <xsl:template name="build-breadcrumbs">
    <qui:nav role="breadcrumb">
      <qui:link href="{/Top/Home}">
        <xsl:value-of select="/Top/Banner/Text" />
      </qui:link>
      <qui:link href="{/Top/CurrentUrl}">
        <xsl:call-template name="get-title" />
      </qui:link>
    </qui:nav>
  </xsl:template>

  <xsl:template name="get-title">Search Results</xsl:template>

  <xsl:template name="build-results-navigation">
    <!-- do we have M/N available in the PI handler? -->
    <xsl:variable name="sz" select="//Param[@name='size']" />
    <xsl:variable name="end-1" select="//Fisheye/Url[@class='active']/@name + $sz - 1" />
    <xsl:variable name="end">
      <xsl:choose>
        <xsl:when test="$end-1 &gt; //TotalResults"><xsl:value-of select="//TotalResults" /></xsl:when>
        <xsl:otherwise><xsl:value-of select="$end-1" /></xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="tmp-xml">
      <qui:nav role="results" total="{//TotalResults}" size="{$sz}" min="1" max="{count(//Fisheye/Url)}" current="{count(//Fisheye/Url[@class='active']/preceeding-sibling) + 1}" start="{//Fisheye/Url[@class='active']/@name}" end="{$end}">
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

    <xsl:if test="true() or $tmp//qui:link">
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

  <xsl:template name="build-results-list">
    <xsl:variable name="q" select="//SearchForm/Q[@name='q1']" />
    <qui:form id="collection-search">
      <qui:select name="rgn1">
        <xsl:for-each select="$q/Rgn/Option">
          <xsl:variable name="value" select="Value" />
          <xsl:if test="$q/Sel[@abbr=$value][Option/Value='all']">
            <qui:option value="{Value}"><xsl:value-of select="Label" /></qui:option>
          </xsl:if>
        </xsl:for-each>
      </qui:select>
      <qui:hidden-input name="select1" value="all" />
    </qui:form>
    <xsl:apply-templates select="//Facets" />
    <qui:block slot="results">
      <xsl:apply-templates select="//Results/Result" />
    </qui:block>
  </xsl:template>

  <xsl:template match="Results/Result">
    <qui:section>
      <qui:link rel="result" href="{Url[@name='EntryLink']}" />
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
      <xsl:for-each select="Field">
        <qui:field key="{@abbrev}">
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
        </qui:field>
      </xsl:for-each>
    </qui:filters-panel>
  </xsl:template>

  <xsl:template match="MediaInfo" mode="iiif-link">
    <xsl:variable name="collid" select="collid" />
    <xsl:variable name="m_id" select="m_id" />
    <xsl:variable name="m_iid" select="m_iid" />
    <qui:link rel="iiif" href="https://quod.lib.umich.edu/cgi/i/image/api/image/{$collid}:{$m_id}:{$m_iid}" />
  </xsl:template>

</xsl:stylesheet>