<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE root [
<!ENTITY nbsp "&#160;">  
]>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="search-form" select="//SearchForm" />

  <xsl:template name="get-title">
    Index
  </xsl:template>

  <xsl:template name="build-head-block">
    <qui:base href="/{substring($collid, 1, 1)}/{$collid}/" />
  </xsl:template>

  <xsl:template name="build-body-main">
    <xsl:choose>
      <xsl:when test="//XcollMode = 'colls'">
        <xsl:call-template name="build-body-page-overview" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="build-body-page-index" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-body-page-overview">
    <qui:header role="main">
      <xsl:call-template name="build-sub-header-badge-data" />
      <xsl:call-template name="get-collection-title" />
    </qui:header>
    <qui:panel slot="browse">
      <qui:link icon="book" href="/lib/colllist/?byFormat=Text%20Collections">Browse Digital Collections</qui:link>
    </qui:panel>
    <qui:block slot="information">
      <xhtml:p>
        <xhtml:strong>Digital Text Collections</xhtml:strong> is the 
        central access point for electronic books and journals provided by the 
        University of Michigan 
        <xhtml:a href="https://www.lib.umich.edu/about-us/our-divisions-and-departments/library-information-technology/digital-content-and">Digital Content and Collections</xhtml:a>.
      </xhtml:p>
      <xhtml:p>
        Some collections at this site are restricted to use by authorized users only (i.e., University faculty, staff, students, etc... ).
      </xhtml:p>
      <xhtml:p>
        Authorized users should log in for complete access. Please see the 
        <xhtml:a href="https://www.lib.umich.edu/about-us/policies/statement-appropriate-use-electronic-resources">Access and Use Policy</xhtml:a> 
        of the U-M Library.
      </xhtml:p>
      <xsl:if test="false()">
        <xhtml:div class="alert-info">
          <xsl:value-of select="//NumberOfCollections" />
          <xsl:text> collections serving </xsl:text>
          <xsl:value-of select="//NumberOfTexts" />
          <xsl:text> texts</xsl:text>
        </xhtml:div>
        </xsl:if>
    </qui:block>
  </xsl:template>

  <xsl:template name="build-body-page-index">
    <qui:header role="main">
      <xsl:call-template name="build-sub-header-badge-data" />
      <xsl:call-template name="get-collection-title" />
    </qui:header>

    <xsl:apply-templates select="/Top//BannerImage" />

    <xsl:apply-templates select="/Top//Content" />
    
    <xsl:apply-templates select="//qui:block[@slot='links']" mode="copy" />
    <xsl:apply-templates select="//qui:block[@slot='copyright']|//qui:block[@slot='useguidelines']" mode="copy" />
    <xsl:apply-templates select="//qui:block[@slot='contentwarning']" mode="copy" />

    <xsl:call-template name="build-panel-custom" />
    <xsl:call-template name="build-panel-browse-links" />
    <xsl:call-template name="build-search-form" />
    <xsl:call-template name="build-panel-related-collections" />
  </xsl:template>

  <xsl:template name="build-panel-custom">
    <qui:panel slot="custom">
      <qui:header>Links</qui:header>
      <qui:nav>
        <xsl:call-template name="build-nav-link">
          <xsl:with-param name="slug">about</xsl:with-param>
        </xsl:call-template>
      </qui:nav>
    </qui:panel>
    <xsl:apply-templates select="//qui:panel[@slot='custom']" mode="copy" />
  </xsl:template>

  <xsl:template name="build-nav-link">
    <xsl:param name="slug" />
    <xsl:variable name="nav-item" select="//MainNav/NavItem[Name=$slug]" />
    <xsl:variable name="key" select="concat('navheader.str.', $slug)" />
    <xsl:if test="$nav-item">
      <qui:link href="{$nav-item/Link}" data-key="{$key}"><xsl:value-of select="key('get-lookup',$key)" /></qui:link>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-panel-browse-links">
    <qui:panel class="callout" slot="browse">
      <qui:nav>
        <xsl:apply-templates select="//qui:panel[@slot='browse'][@weight=0]//qui:link" mode="copy" />
        <xsl:if test="normalize-space(//CollectionIdno)">
          <xsl:choose>
            <xsl:when test="//CollectionIdno/@home-link = 'no'"></xsl:when>
            <xsl:otherwise>
              <qui:link href="/cgi/t/text/text-idx?c={$collid};idno={//CollectionIdno}" icon="newspaper">
                <xsl:text>Browse by </xsl:text>
                <xsl:value-of select="key('get-lookup', 'uplift.picklist.str.morethanoneitem')" />
              </qui:link>  
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
        <xsl:for-each select="//BrowseFields/Field">
          <qui:link href="{Link}" data-rel="browse-items" icon="layers">
            <xsl:text>Browse by </xsl:text>
            <xsl:value-of select="key('get-lookup', concat('browse.str.', Name, '.column'))" />
          </qui:link>
        </xsl:for-each>
      <!-- <qui:link href="/cgi/i/image/image-idx?c={$collid};view=reslist;q1={$collid};med=1" rel="browse-images" data-count="{//Stats/Images}" /> -->
        <xsl:apply-templates select="//qui:panel[@slot='browse'][not(@weight)]//qui:link" mode="copy" />
        <xsl:apply-templates select="/Top/Panels/div[@data-slot='browse']" mode="links" />
      </qui:nav>
    </qui:panel>
    <xsl:apply-templates select="/Top/Panels/div[@data-slot='custom']" mode="links" />
  </xsl:template>

  <xsl:template name="get-current-page-breadcrumb-label">
    <xsl:call-template name="get-title" />
  </xsl:template>

  <xsl:template match="Content[.//div[@data-slot]]" priority="100">
    <qui:debug>WHY</qui:debug>
    <qui:block slot="information">
      <xsl:apply-templates select="./div[@data-slot='overview']|./div[@data-slot='information']" mode="copy" />
    </qui:block>
    <qui:block slot="contents">
      <xsl:choose>
        <xsl:when test="//CollCheckboxList/Coll">
          <qui:label>Publications</qui:label>
          <xsl:apply-templates select="//CollCheckboxList/Coll" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="./div[@data-slot='contents']" mode="copy-guts" />
        </xsl:otherwise>
      </xsl:choose>
    </qui:block>
    <qui:block slot="contentwarning">
      <xsl:apply-templates select="./div[@data-slot='contentwarning']" mode="copy-guts" />
    </qui:block>
    <qui:block slot="access">
      <xsl:apply-templates select="./div[@data-slot='access']" mode="copy-guts" />
    </qui:block>
    <qui:block slot="useguidelines">
      <xsl:apply-templates select="./div[@data-slot='useguidelines']" mode="copy" />
    </qui:block>
    <qui:block slot="more-information">
      <xsl:apply-templates select="./div[@data-slot='more-information']" mode="copy" />
    </qui:block>
    <qui:block slot="download">
      <xsl:apply-templates select="./div[@data-slot='download']" mode="copy" />
    </qui:block>
  </xsl:template>

  <xsl:template match="Content">
    <qui:block slot="information">
      <xsl:apply-templates mode="copy" />
    </qui:block>
  </xsl:template>

  <xsl:template match="Option">
    <xsl:param name="default" />
    <qui:option value="{Value}">
      <xsl:if test="Focus = 'true' or Value = $default">
        <xsl:attribute name="selected">true</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="Label" />
    </qui:option>
  </xsl:template>

  <xsl:template match="BannerImage[normalize-space(.)]">
    <qui:hero-image src="{.}" />
  </xsl:template>

  <xsl:template match="BannerImage">
    <qui:debug>BOOGER</qui:debug>
  </xsl:template>

  <xsl:template match="div[@data-slot='contents'][Content]" mode="copy-guts" priority="101">
    <!-- we are doing a nested thing -->
    <xsl:for-each select="Content/section">
      <xhtml:figure href="browse#{@id}" id="fig-{@id}">
        <xhtml:img src="{img/@src}" alt="{img/@alt}" />
        <xhtml:figcaption>
          <xhtml:h3 id="{@id}">
            <xsl:value-of select="div[@data-slot='overview']/h2" />
          </xhtml:h3>
        </xhtml:figcaption>
      </xhtml:figure>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="div[@data-slot='browse']" mode="links">
    <xsl:for-each select=".//a">
      <qui:link href="{@href}">
        <xsl:apply-templates select="@rel" mode="build-icon" />
        <xsl:apply-templates mode="copy" />
      </qui:link>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="div[@data-slot='custom']" mode="links">
    <qui:panel slot="custom">
      <qui:header><xsl:value-of select="h3" /></qui:header>
      <qui:nav>
        <xsl:for-each select="nav/a">
          <qui:link href="{@href}">
            <xsl:apply-templates select="@rel" mode="build-icon" />
            <xsl:apply-templates mode="copy" />
          </qui:link>
        </xsl:for-each>
      </qui:nav>
    </qui:panel>
  </xsl:template>

  <xsl:template match="div[@data-slot='useguidelines']" mode="copy" priority="101">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:choose>
        <xsl:when test="@key">
          <xsl:variable name="key" select="@key" />
          <xsl:apply-templates select="//RightsStatement[@key=$key]" mode="copy-guts" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates mode="copy" />
        </xsl:otherwise>
      </xsl:choose>
      </xsl:copy>
  </xsl:template>

  <xsl:template match="@rel" mode="build-icon">
    <xsl:attribute name="icon">
      <xsl:choose>
        <xsl:when test=". = 'findingaid'">
          <xsl:text>inventory_2</xsl:text>
        </xsl:when>
        <xsl:when test=". = 'findingaid'">
          <xsl:text>inventory_2</xsl:text>
        </xsl:when>
        <xsl:when test="normalize-space(.)">
          <xsl:value-of select="." />
        </xsl:when>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="CollCheckboxList/Coll" priority="101" />
  <xsl:template match="CollCheckboxList/Coll">
    <xhtml:figure href="{Href}">
      <xhtml:figcaption>
        <xhtml:h3 id="coll-{Id}">
          <xsl:value-of select="Name" />
        </xhtml:h3>
      </xhtml:figcaption>
    </xhtml:figure>
  </xsl:template>

  <xsl:template name="build-panel-related-collections">
    <xsl:if test="//Groups/Group">
      <qui:panel slot="related-collections">
        <qui:header>Related Collections</qui:header>
        <qui:block slot="help">
          <xsl:text>Search this collection with other related collections in </xsl:text>
          <xsl:choose>
            <xsl:when test="count(//Groups/Group) = 1">
              <xsl:text> this group</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text> these groups</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </qui:block>
        <qui:nav>
          <xsl:for-each select="//Groups/Group">
            <qui:link href="/cgi/t/text/text-idx?page=simple;xc=1;g={@GroupID}" data-badge="group">
              <xsl:value-of select="normalize-space(.)" />
            </qui:link>
          </xsl:for-each>
        </qui:nav>
      </qui:panel>
    </xsl:if>
  </xsl:template>  
</xsl:stylesheet>
