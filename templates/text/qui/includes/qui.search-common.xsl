<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template name="build-advanced-search-form">
    <xsl:variable name="key" select="concat('navheader.str.', $page)" />
    <xsl:call-template name="build-breadcrumbs" />
    <qui:header role="main">
      <xsl:text>Advanced Search: </xsl:text>
      <xsl:value-of select="key('get-lookup', $key)" />
    </qui:header>

    <qui:nav role="search">
      <xsl:for-each select="//SearchNav/NavItem[Tab = 'true']">
        <qui:link href="{Link}">
          <xsl:if test="$page = Name">
            <xsl:attribute name="current">true</xsl:attribute>
          </xsl:if>
          <xsl:variable name="nav-key" select="concat('navheader.str.', Name)" />
          <qui:label>
            <xsl:value-of select="key('get-lookup', $nav-key)" />
          </qui:label>
        </qui:link>
      </xsl:for-each>
    </qui:nav>

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
    
    <qui:form id="collection-search">

      <xsl:choose>
        <xsl:when test="$page = 'simple'">
          <xsl:call-template name="build-simple-form" />
        </xsl:when>
        <xsl:when test="$page = 'boolean'">
          <xsl:call-template name="build-boolean-form" />
        </xsl:when>
        <xsl:when test="$page = 'proximity'">
          <xsl:call-template name="build-proxmity-form" />
        </xsl:when>
        <xsl:when test="$page = 'bib'">
          <xsl:call-template name="build-bib-form" />
        </xsl:when>
        <xsl:when test="$page = 'wwstart' or $page = 'wwfull'">
          <xsl:call-template name="build-ww-form" />
        </xsl:when>          
      </xsl:choose>

      <xsl:apply-templates select="$search-form/CiteRestrictions" />
      <xsl:apply-templates select="$search-form/OtherRestrictions/*[normalize-space(.)]" />
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
      <qui:select name="{$rgn/Name}" slot="region">
        <xsl:apply-templates select="$rgn/Option">
          <xsl:with-param name="default" select="$rgn/Default" />
        </xsl:apply-templates>
      </qui:select>
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

</xsl:stylesheet>