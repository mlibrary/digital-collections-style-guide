<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">
  <xsl:variable name="searchtype" select="/Top/SearchType"/>
  <xsl:variable name="xcoll-mode" select="/Top/DlxsGlobals/XcollMode" />

  <xsl:template name="build-advanced-search">
    <xsl:variable name="key" select="concat('navheader.str.', $page)" />
    <xsl:call-template name="build-breadcrumbs" />
    <qui:header role="main">
      <xsl:text>Advanced Search: </xsl:text>
      <xsl:value-of select="key('get-lookup', $key)" />
    </qui:header>
    <xsl:call-template name="build-advanced-search-form" />
  </xsl:template>

  <xsl:template name="build-advanced-search-form">
    <xsl:variable name="key" select="concat('navheader.str.', $page)" />

    <qui:nav role="search">
      <xsl:for-each select="//SearchNav/NavItem[Tab = 'true']">
        <qui:link href="{Link}">
          <xsl:choose>
            <xsl:when test="contains($page, Name)">
              <xsl:attribute name="current">true</xsl:attribute>
            </xsl:when>  
            <xsl:when test="$page = 'booleanbbag' and Name = 'boolean'">
              <xsl:attribute name="current">true</xsl:attribute>
            </xsl:when>
            <xsl:when test="$page = 'proximitybbag' and Name = 'proximity'">
              <xsl:attribute name="current">true</xsl:attribute>
            </xsl:when>
            <xsl:when test="$page = 'bbaglist' and Name = 'simple'">
              <xsl:attribute name="current">true</xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <xsl:variable name="nav-key" select="concat('navheader.str.', Name)" />
          <qui:label>
            <xsl:value-of select="key('get-lookup', $nav-key)" />
          </qui:label>
        </qui:link>
      </xsl:for-each>
    </qui:nav>

    <xsl:apply-templates select="/Top/SearchRestriction/ItemHeader[HEADER]" />


    <xsl:if test="$xcoll-mode = 'group'">
      <qui:callout slot="collids">
        <xsl:text>You can search all the collections in this group, or use the list of collections to restrict your search to a subset.</xsl:text>
      </qui:callout>
    </xsl:if>

    <qui:callout slot="clause">
      <div>
        <p>
          <xsl:value-of select="key('get-lookup','searchforms.str.1')"/>
        </p>
        <p>
          <xsl:value-of select="key('get-lookup','searchforms.str.2')"/>
        </p>  
      </div>
    </qui:callout>
    
    <qui:form id="collection-search" data-searchtype="{$searchtype}">

      <qui:hidden-input name="type">
        <xsl:attribute name="value">
          <xsl:choose>
            <xsl:when test="contains($searchtype, 'bbag')">
              <xsl:value-of select="substring-after($searchtype, 'bbag')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="$searchtype" />
            </xsl:otherwise>  
          </xsl:choose>  
        </xsl:attribute>
      </qui:hidden-input>

      <xsl:if test="contains($searchtype, 'bbag')">
        <!-- <qui:hidden-input name="rgn" value="full text" /> -->
        <qui:hidden-input name="bookbag" value="1" />
      </xsl:if>

      <xsl:choose>
        <xsl:when test="contains($searchtype, 'simple')">
          <xsl:call-template name="build-simple-form" />
        </xsl:when>
        <xsl:when test="contains($searchtype, 'boolean')">
          <xsl:call-template name="build-boolean-form" />
        </xsl:when>
        <xsl:when test="contains($searchtype, 'proximity')">
          <xsl:call-template name="build-proxmity-form" />
        </xsl:when>
        <xsl:when test="contains($searchtype, 'bib')">
          <xsl:call-template name="build-bib-form" />
        </xsl:when>
        <xsl:when test="$page = 'wwstart' or $page = 'wwfull'">
          <xsl:call-template name="build-ww-form" />
        </xsl:when>          
      </xsl:choose>

      <xsl:apply-templates select="$search-form/CiteRestrictions" />
      <xsl:apply-templates select="$search-form/OtherRestrictions/*[normalize-space(.)]" />
      <xsl:for-each select="//SearchForm/HiddenVars/Variable">
        <qui:hidden-input name="{@name}" value="{.}" />
      </xsl:for-each>
      <xsl:call-template name="build-collection-select" />      
    </qui:form>     
  </xsl:template>

  <xsl:template name="build-clause">
    <xsl:param name="name" />
    <xsl:param name="q" />
    <xsl:param name="op" />
    <xsl:param name="rgn" />
    <qui:fieldset id="{$q/Name}-fieldset" data-name="{$q/Name}" slot="clause">
      <qui:input name="{$q/Name}" slot="query" value="{$q/Default}">
        <xsl:attribute name="data-active">
          <xsl:choose>
            <xsl:when test="Qlist[@active = 'TRUE']">false</xsl:when>
            <xsl:otherwise>true</xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </qui:input>
      <xsl:if test="contains($searchtype, 'bbag')">
        <qui:select name="rgn" slot="region">
          <qui:option value="full text" selected="selected">Full Text</qui:option>
        </qui:select>
      </xsl:if>
      <xsl:if test="not(contains($searchtype, 'bbag'))">
        <qui:select name="{$rgn/Name}" slot="region">
          <xsl:apply-templates select="$rgn/Option">
            <xsl:with-param name="default" select="$rgn/Default" />
          </xsl:apply-templates>
        </qui:select>
      </xsl:if>
      <xsl:if test="$op">
        <xsl:apply-templates select="$op" mode="build-op" />
      </xsl:if>
    </qui:fieldset>
  </xsl:template>

  <xsl:template name="build-op" mode="build-op" match="*">
    <xsl:param name="index">1</xsl:param>
    <qui:select name="{Name}" label="Boolean operator {$index}" slot="op">
      <xsl:apply-templates select="Option">
        <xsl:with-param name="default" select="Default" />
      </xsl:apply-templates>
    </qui:select>
  </xsl:template>

  <xsl:template match="CiteRestrictions">
    <qui:fieldset slot="restriction-cite">
      <qui:legend><xsl:value-of select="key('get-lookup','searchforms.str.16')" /></qui:legend>
      <xsl:for-each select="Cite">
        <xsl:variable name="default" select="Restrict/Default" />
        <qui:fieldset slot="clause" id="{Input/Name}-fieldset">
          <qui:input name="{Input/Name}" value="{Input/Default}" slot="query" />
          <qui:select name="{Restrict/Name}" slot="region">
            <xsl:apply-templates select="Restrict/Option">
              <xsl:with-param name="default" select="$default" />
            </xsl:apply-templates>
          </qui:select>
        </qui:fieldset>  
      </xsl:for-each>  
    </qui:fieldset>
  </xsl:template>

  <xsl:template match="GenreSelect">
    <qui:fieldset id="genre-fieldset" slot="restriction">
      <qui:legend><xsl:value-of select="key('get-lookup','searchforms.str.19')" /></qui:legend>
      <qui:select name="{GenreSelect/Name}">
        <xsl:apply-templates select="GenreSelect/Option">
          <xsl:with-param name="default" select="GenreSelect/Default" />
        </xsl:apply-templates>
      </qui:select>
    </qui:fieldset>
  </xsl:template>

  <xsl:template match="GenderSelect">
    <qui:fieldset id="genre-fieldset" slot="restriction">
      <qui:legend><xsl:value-of select="key('get-lookup','searchforms.str.20')" /></qui:legend>
      <qui:select name="{GenderSelect/Name}">
        <xsl:apply-templates select="GenderSelect/Option">
          <xsl:with-param name="default" select="GenderSelect/Default" />
        </xsl:apply-templates>
      </qui:select>
    </qui:fieldset>
  </xsl:template>

  <xsl:template match="PeriodSelect">
    <qui:fieldset id="genre-fieldset" slot="restriction">
      <qui:legend><xsl:value-of select="key('get-lookup','searchforms.str.21')" /></qui:legend>
      <qui:select name="{PeriodSelect/Name}">
        <xsl:apply-templates select="PeriodSelect/Option">
          <xsl:with-param name="default" select="PeriodSelect/Default" />
        </xsl:apply-templates>
      </qui:select>
    </qui:fieldset>
  </xsl:template>

  <xsl:template match="PubBetweenSelect">
    <qui:fieldset id="pub-between-fieldset" slot="restriction" class="range">
      <qui:legend><xsl:value-of select="key('get-lookup','searchforms.str.22')" /></qui:legend>
      <qui:select name="{FromSelect/Name}" label="Start Date">
        <xsl:apply-templates select="FromSelect/Option">
          <xsl:with-param name="default" select="FromSelect/Default" />
        </xsl:apply-templates>
      </qui:select>
      <qui:select name="{ToSelect/Name}" label="End Date">
        <xsl:apply-templates select="ToSelect/Option">
          <xsl:with-param name="default" select="ToSelect/Default" />
        </xsl:apply-templates>
      </qui:select>
    </qui:fieldset>
  </xsl:template>

  <xsl:template match="SearchRestriction/ItemHeader">
    <qui:callout slot="restriction">
      <qui:header>
        <xsl:value-of select="key('get-lookup','search.str.6')"/>
      </qui:header>
      <xsl:call-template name="build-item-metadata">
        <xsl:with-param name="item" select="." />
        <xsl:with-param name="encoding-type" select="/Top/SearchRestriction/DocEncodingType" />
      </xsl:call-template>
    </qui:callout>
  </xsl:template>

  <xsl:template name="build-collection-select">
    <xsl:if test="$xcoll-mode = 'group'">
      <qui:fieldset slot="collids">
        <xsl:for-each select="/Top/CollCheckboxList/Coll">
          <xsl:apply-templates select="." />
        </xsl:for-each>
      </qui:fieldset>
    </xsl:if>
  </xsl:template>

  <xsl:template match="Coll">
    <qui:option value="{Id}" data-href="{Href}">
      <xsl:if test="Checked = '1'">
        <xsl:attribute name="checked">checked</xsl:attribute>
      </xsl:if>
      <xsl:if test="@collid = 'DC'">
        <xsl:attribute name="type">hidden</xsl:attribute>
      </xsl:if>
      <xsl:value-of select="Name" />
    </qui:option>
  </xsl:template>

</xsl:stylesheet>