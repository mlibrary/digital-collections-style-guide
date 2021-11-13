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
    <qui:form id="collection-search" data-advanced="{$is-advanced}" data-edit-action="{//SearchLink}">
      <xsl:attribute name="data-has-query">
        <xsl:choose>
          <xsl:when test="//Facets/Value[@selected='true']">true</xsl:when>
          <xsl:when test="//SearchForm/MediaOnly[Focus='true']">true</xsl:when>
          <xsl:when test="count(//SearchForm/Q[normalize-space(Value)]) = 1 and //SearchForm/Q/Value = //SearchForm/HiddenVars/Variable[@name='c']">false</xsl:when>
          <xsl:when test="normalize-space(//SearchForm/Q/Value)">true</xsl:when>
          <xsl:otherwise>false</xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:choose>
        <xsl:when test="$is-advanced = 'true'">
          <xsl:apply-templates select="//SearchForm/Q">
            <xsl:with-param name="is-advanced" select="//SearchForm/Advanced" />
          </xsl:apply-templates>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="//SearchForm/Q[1]" />
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates select="//Facets" mode="search-form" />
    </qui:form>
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
              <xsl:when test="Value = 'none'">Relevance</xsl:when>
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

  <xsl:template match="Q">
    <xsl:param name="is-advanced" />
    <xsl:variable name="q" select="." />
    <xsl:variable name="rgn">
      <xsl:call-template name="get-selected-option">
        <xsl:with-param name="options" select="Rgn" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="ops" select="preceding::Q[1]/Op" />
    <xsl:variable name="op">
      <xsl:call-template name="get-selected-option">
        <xsl:with-param name="options" select="$ops" />
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="sel" select="Sel[@abbr=$rgn]" />

    <xsl:variable name="select">
      <xsl:call-template name="get-selected-option">
        <xsl:with-param name="options" select="Sel[@abbr=$rgn]" />
      </xsl:call-template>
    </xsl:variable>

    <qui:control slot="clause" data-name="{@name}">
      <xsl:choose>
        <xsl:when test="$is-advanced = 'true'">
          <qui:input slot="rgn" type="hidden" name="{Rgn/@name}" value="{Rgn/Option[Value=$rgn]/Value}" label="{Rgn/Option[Value=$rgn]/Label}" />
        </xsl:when>
        <xsl:otherwise>
          <!-- build the full region options to drive the basic search form -->
          <qui:input slot="rgn" name="{Rgn/@name}" type="select">
            <xsl:for-each select="Rgn/Option">
              <xsl:variable name="value" select="Value" />
              <qui:option value="{Value}">
                <xsl:if test="Value = $rgn">
                  <xsl:attribute name="selected">selected</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="Label" />
              </qui:option>
            </xsl:for-each>
          </qui:input>
        </xsl:otherwise>
      </xsl:choose>
      <qui:input slot="select" type="hidden" name="{$sel/@name}" value="{$sel/Option[Value=$select]/Value}">
        <xsl:attribute name="label">
          <xsl:apply-templates select="$sel/Option[Value=$select]/Label" />
        </xsl:attribute>
      </qui:input>
      <xsl:if test="$ops">
        <qui:input slot="op" type="hidden" name="{$ops/@name}" value="{$op}" label="{$ops/Option[Value=$op]/Label}" />
      </xsl:if>
      <qui:input slot="q" type="text" name="{@name}" value="{Value}" />
    </qui:control>
  </xsl:template>

  <xsl:template name="get-selected-option">
    <xsl:param name="options" />
    <xsl:choose>
      <xsl:when test="$options/Option[Focus='true']">
        <xsl:value-of select="$options/Option[Focus='true']/Value" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="$options/Default" />
      </xsl:otherwise>
    </xsl:choose>
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

  <xsl:template match="Facets" mode="search-form">
    <xsl:apply-templates select="//SearchForm/MediaOnly" mode="search-form" />
    <xsl:for-each select="Field">
      <xsl:variable name="abbrev" select="@abbrev" />
      <xsl:for-each select="Values/Value[@selected='true']">
        <xsl:variable name="fn" select="//Param[starts-with(@name, 'fn')][. = $abbrev]/@name" />
        <xsl:variable name="fq" select="//Param[starts-with(@name, 'fq')][. = .]/@name" />
        <qui:hidden-input type="hidden" name="{$fn}" value="{$abbrev}" data-role="facet" />
        <qui:hidden-input type="hidden" name="{$fq}" value="{.}" data-role="facet-value" data-facet-field="{$abbrev}" />
      </xsl:for-each>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="MediaOnly" mode="search-form">
    <qui:hidden-input type="hidden" name="med">
      <xsl:attribute name="value">
        <xsl:if test="Focus = 'true'">
          <xsl:text>1</xsl:text>
        </xsl:if>
      </xsl:attribute>
    </qui:hidden-input>
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