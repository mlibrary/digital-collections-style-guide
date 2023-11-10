<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:qui="http://dlxs.org/quombat/ui" extension-element-prefixes="exsl" >
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />

  <!-- <xsl:variable name="collid" select="normalize-space((//Param[@name='cc']|//Param[@name='c'])[1])" /> -->
  <xsl:variable name="collid">
    <xsl:choose>
      <xsl:when test="//Param[@name='xc'] = 1">
        <xsl:text>*</xsl:text>
      </xsl:when>
      <xsl:when test="//Param[@name='cc']">
        <xsl:value-of select="//Param[@name='cc']" />
      </xsl:when>
      <xsl:when test="count(//Param[@name='c']) = 1">
        <xsl:value-of select="//Param[@name='cc']" />
      </xsl:when>
      <xsl:otherwise>*</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:key match="/Top/DlxsGlobals/LangMap//Lookup/Item" name="get-lookup" use="@key"/>
  
  <xsl:param name="docroot">/digital-collections-style-guide</xsl:param>
  <xsl:param name="api_url"><xsl:value-of select="//DlxsGlobals/ApiUrl" /></xsl:param>

  <xsl:param name="view">
    <xsl:call-template name="get-view" />
  </xsl:param>

  <xsl:param name="context-type">
    <xsl:choose>
      <xsl:when test="contains(//Param[@name='page'], 'bbag')">
        <xsl:text>list</xsl:text>
      </xsl:when>
      <xsl:when test="//Param[@name='bookbag'] = '1'">
        <xsl:text>list</xsl:text>
      </xsl:when>
      <xsl:when test="//Param[@name='xc'] = 1">
        <xsl:choose>
          <xsl:when test="//Param[@name='g']">
            <xsl:text>group</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>multiple</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="//Para[@name='cc']">
        <xsl:text>collection</xsl:text>
      </xsl:when>
      <xsl:when test="count(//Param[@name='c']) = 1">
        <xsl:text>collection</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>root</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:param>

  <xsl:template match="/">
    <xsl:apply-templates select="/Top" />
    <!-- <qui:root>
      <qui:debug>ONE</qui:debug>
      <xsl:apply-templates 
        select="document('')//xsl:template[@name='ACK']">
        <xsl:with-param name="root" select="/Top" />
      </xsl:apply-templates>
    </qui:root> -->
  </xsl:template>
  
  <xsl:template match="Top">
    <!-- <xsl:processing-instruction name="xml-stylesheet">
      <xsl:value-of select="concat('type=&quot;text/xsl&quot; href=&quot;', $docroot, '/templates/debug.qui.xsl&quot;')" />
    </xsl:processing-instruction> -->
    <qui:root template="{$template-name}" view="{$view}" collid="{$collid}" username="{//AuthenticatedUsername}" context-type="{$context-type}" api_url="{$api_url}">
      <xsl:if test="//BbagOptionsMenu/UserIsOwner = 'true'">
        <xsl:attribute name="user-is-owner">true</xsl:attribute>
      </xsl:if>
      <xsl:attribute name="context-type"><xsl:value-of select="$context-type" /></xsl:attribute>
      <xsl:if test="normalize-space(//CollGroupMembership)">
        <xsl:attribute name="groupid">
          <xsl:value-of select="//CollGroupMembership" />
        </xsl:attribute>
      </xsl:if>

      <xsl:apply-templates 
        select="document('')//xsl:template[@name='ACK']">
        <xsl:with-param name="root" select="/Top" />
      </xsl:apply-templates>

      <!-- fills html/head-->
      <qui:head>
        <xhtml:title>
          <xsl:call-template name="get-head-title" />
        </xhtml:title>
        <xsl:call-template name="build-head-block" />
        <xsl:call-template name="build-canonical-link" />
        <qui:link rel="self" href="{//CurrentUrl}" />
      </qui:head>
      <qui:body>
        <xsl:call-template name="build-skip-links" />
        <xsl:call-template name="build-site-header" />
        <xsl:call-template name="build-sub-header" />
        <qui:main>
          <xsl:call-template name="build-body-main" />
          <xsl:call-template name="build-item-search-form" />
        </qui:main>
        <qui:message>Message recived, La Jolla</qui:message>
        <qui:footer>
          <qui:link rel="help" href="{normalize-space(//Help)}" />
          <qui:link rel="collection-home" href="{//Home}" />
          <qui:link rel="feedback" href="{//FeedbackUrl}" />
        </qui:footer>
        <qui:block slot="langmap">
          <xsl:apply-templates select="/Top/Langmap//Lookup/Item" mode="build-lookup" />
          <!-- <xsl:apply-templates select="//Lookup[@id='text.components']" mode="build-lookup" />
          <xsl:apply-templates select="//Lookup[@id='headerutils']" mode="build-lookup" />
          <xsl:apply-templates select="//Lookup[@id='viewer']" mode="build-lookup" />
          <xsl:apply-templates select="//Lookup[@id='uplift']" mode="build-lookup" /> -->
        </qui:block>    
      </qui:body>
    </qui:root>
  </xsl:template>

  <xsl:template name="build-skip-links">
    <qui:skip-links>
      <qui:link href="#maincontent">Skip to main content</qui:link>
      <xsl:call-template name="build-page-skip-links" />
    </qui:skip-links>
  </xsl:template>

  <xsl:template name="build-page-skip-links" />

  <xsl:template name="build-site-header">
    <qui:m-website-header name="Digital Collections">
      <qui:search-form collid="{$collid}" value="{//Param[@name='q1']}" />
      <qui:nav>
        <qui:link rel="feedback" icon="email" href="{//FeedbackUrl}">Contact Us</qui:link>
        <qui:link rel="help" icon="help" href="{//NavHeader/MainNav/NavItem[Name='help']/Link}">Help</qui:link>
        <xsl:if test="//NavItem[Name='browse']/Tab='true'">
          <qui:link rel="browse" icon="list" href="{//NavItem[Name='browse']/Link}">Browse</qui:link>
        </xsl:if>
        <qui:link rel="search" icon="search" href="{//NavItem[Name='search']/Link}">Search</qui:link>
        <xsl:if test="//NavItem/Name='bookbag'">
          <qui:link rel="portfolios" icon="bookmark" href="{//NavItem[Name='bookbag']/Link}">Bookbag</qui:link>
        </xsl:if>
        <!-- <xsl:call-template name="build-login-link" /> -->
        <qui:link rel="quod" />
      </qui:nav>
    </qui:m-website-header>
  </xsl:template>

  <xsl:template name="build-sub-header">
    <xsl:if test="$page != 'home'">
      <qui:debug>WTF: <xsl:value-of select="$page" /></qui:debug>
      <qui:sub-header>
        <xsl:attribute name="href">
          <xsl:call-template name="get-context-link" />
        </xsl:attribute>
        <xsl:call-template name="build-sub-header-badge-data" />
        <xsl:call-template name="get-context-title" />
      </qui:sub-header>  
    </xsl:if>
    <xsl:if test="$page = 'home'">
      <qui:debug>INDEX</qui:debug>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-sub-header-badge-data">
    <xsl:attribute name="data-badge">
      <xsl:value-of select="key('get-lookup', concat($context-type, '-badge'))" />
    </xsl:attribute>
    <xsl:attribute name="data-context-type">
      <xsl:value-of select="$context-type" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template name="build-login-link">
    <qui:link href="{//LoginLink/Url}" id="action-login">
      <xsl:choose>
        <xsl:when test="//LoginLink/Mode = 'logout'">
          <xsl:attribute name="data-logged-in">true</xsl:attribute>
          <xsl:attribute name="icon">logout</xsl:attribute>
          <xsl:text>Log out</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="data-logged-in">false</xsl:attribute>
          <xsl:attribute name="icon">login</xsl:attribute>
          <xsl:text>Log in</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </qui:link>
  </xsl:template>

  <xsl:template name="build-head-block" />
  
  <xsl:template name="get-head-title">
    <qui:values>
      <qui:value>
        <xsl:call-template name="get-collection-title" />
      </qui:value>
    </qui:values>
  </xsl:template>

  
  <xsl:template name="build-body-main" />

  <xsl:template name="build-canonical-link">
    <xsl:variable name="link">
      <xsl:call-template name="get-canonical-link" />
    </xsl:variable>
    <xsl:if test="normalize-space($link)">
      <qui:link rel="canonical" href="{$link}" />
    </xsl:if>
  </xsl:template>

  <xsl:template name="get-canonical-link" />

  <xsl:template name="get-collection-title">
    <xsl:choose>
      <xsl:when test="$context-type = 'list'">
        <xsl:text>Bookbag</xsl:text>
      </xsl:when>
      <xsl:when test="/Top/BookBagInfo/Field[@name='bbagname']">
        <xsl:value-of select="normalize-space(/Top/BookBagInfo/Field[@name='bbagname'])" />
      </xsl:when>
      <xsl:when test="//Param[@name='xc'] = 1 and normalize-space(/Top/GroupName)">
        <xsl:value-of select="normalize-space(/Top/GroupName)" />
      </xsl:when>
      <xsl:when test="/Top/CollName = 'multiple'">
        Text Collections
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="contains(/Top/DlxsGlobals/Title,'.str')">
            <xsl:value-of select="key('get-lookup',/Top/DlxsGlobals/Title)"/>
          </xsl:when>
          <xsl:when test="not(/Top/DlxsGlobals/TitleComplex/img)">
            <xsl:value-of select="/Top/DlxsGlobals/TitleComplex" />
          </xsl:when>
          <xsl:when test="/Top/DlxsGlobals/TitleComplex/img/@alt">
            <xsl:value-of select="/Top/DlxsGlobals/TitleComplex/img/@alt" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="/Top/DlxsGlobals/Title"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-context-title">
    <xsl:call-template name="get-collection-title" />
  </xsl:template>

  <xsl:template name="get-context-link">
    <xsl:choose>
      <xsl:when test="$context-type = 'collection'">
        <xsl:value-of select="/Top/NavHeader/MainNav/NavItem[Name='home']/Link" />
      </xsl:when>
      <xsl:when test="$context-type = 'list' and //Param[@name='bbdbid']">
        <xsl:value-of select="/Top/Home" />
      </xsl:when>
      <xsl:when test="$context-type = 'list'">
        <xsl:text>/cgi/t/text/text-idx?page=bbaglist</xsl:text>
      </xsl:when>
      <xsl:when test="$context-type = 'group'">
        <xsl:value-of select="/Top/Home" />
      </xsl:when>
      <xsl:when test="$context-type = 'multiple'">
        <xsl:value-of select="/Top/Home" />
      </xsl:when>
      <xsl:otherwise></xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-collection-subtitle">
    <xsl:if test="normalize-space(//Subtitle)">
      <qui:collection-subtitle name="collection-subtitle">
        <xsl:value-of select="//Subtitle" />
      </qui:collection-subtitle>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-panel-browse-filters">
    <qui:panel>
      <xsl:comment>see: https://curiosity.lib.harvard.edu/american-currency</xsl:comment>
      <qui:header>Limit your search</qui:header>
      <qui:nav>
        <xsl:for-each select="//SearchForm//Rgn/Option">
          <xsl:choose>
            <xsl:when test="Value = 'ic_all'"></xsl:when>
            <xsl:otherwise>
              <qui:link href="/cgi/i/image/image-idx?cc={$collid};page=search;filter={Value}">
                <xsl:value-of select="Label" />
              </qui:link>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
      </qui:nav>
    </qui:panel>
  </xsl:template>

  <xsl:template match="HiddenVars/Variable">
    <qui:hidden-input name="{@name}" value="{.}" />
  </xsl:template>

  <xsl:template match="Section">
    <qui:section name="{@name}" slug="{@class}">
      <xsl:apply-templates select="Field" />
    </qui:section>
  </xsl:template>

  <xsl:template match="Field[@abbrev='dc_ri']" priority="100" />
  <xsl:template match="Field[@abbrev='dlxs_ri']" priority="100" />

  <xsl:template match="Field">
    <qui:field key="{@abbrev}">
      <xsl:apply-templates select="@*[starts-with(name(), 'data-')]" mode="copy" />
      <qui:label>
        <xsl:value-of select="Label" />
      </qui:label>
      <qui:values>
        <xsl:for-each select="Values/Value">
          <qui:value>
            <xsl:apply-templates select="." />
          </qui:value>
        </xsl:for-each>
      </qui:values>
    </qui:field>
  </xsl:template>

  <xsl:template match="Field" mode="system-link">
    <xsl:param name="label" />
    <xsl:param name="component">system-link</xsl:param>
    <qui:field key="{@abbrev}" component="{$component}">
      <qui:label>
        <xsl:value-of select="$label" />
      </qui:label>
      <qui:values>
        <xsl:for-each select="Values/Value">
          <qui:value>
            <xsl:apply-templates select="." />
          </qui:value>
        </xsl:for-each>
      </qui:values>
    </qui:field>
  </xsl:template>

  <xsl:template match="Value[@link][Value]" priority="100">
    <qui:link href="{@link}" data-message="ack">
      <xsl:value-of select="Value" />
    </qui:link>
    <xsl:for-each select="Url">
      <qui:link href="{.}"><xsl:value-of select="." /></qui:link>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="Value[@link]">
    <qui:link href="{@link}">
      <xsl:value-of select="." />
    </qui:link>
  </xsl:template>

  <xsl:template match="Value">
    <xsl:apply-templates select="." mode="copy-guts" />
  </xsl:template>

  <xsl:template match="Value/Highlight" mode="copy" priority="100">
    <xhtml:span class="{@class}" data-result-seq="{@seq}">
      <xsl:value-of select="." />
    </xhtml:span>
  </xsl:template>

  <xsl:template match="*" mode="copy-guts">
    <xsl:apply-templates select="*|text()" mode="copy" />
  </xsl:template>

  <xsl:template match="node()[name()][namespace-uri() = '']" mode="copy" priority="99">
    <xsl:element name="xhtml:{name()}">
      <xsl:apply-templates select="*|@*|text()" mode="copy" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="text()" mode="copy">
    <xsl:value-of select="normalize-space(.)" />
  </xsl:template>

  <xsl:template match="@*|*|text()" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|text()" mode="copy" />
    </xsl:copy>
  </xsl:template>

  <xsl:template name="get-view">
    <xsl:value-of select="//Param[@name='view']|//Param[@name='page']" />
  </xsl:template>

  <xsl:template name="build-item-search-form">
    <xsl:if test="//IncludeItemSearch = 'true'">
      <qui:form id="item-search" action="{/Top/DlxsGlobals/ScriptName[@application='text']}">
        <qui:hidden-input name="type" value="simple" />
        <qui:hidden-input name="rgn" value="full text" />
        <xsl:apply-templates select="//SearchForm/HiddenVars" />
        <qui:input name="q1" value="{//Param[@name='q1']}" type="text" style="width: auto; flex-grow: 1;">
          <qui:label>
            <xsl:choose>
              <xsl:when test="/Top/Item/DocEncodingType='serialissue'">
                <xsl:value-of select="key('get-lookup','header.str.searchthisissue')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="key('get-lookup','header.str.searchthistext')"/>
              </xsl:otherwise>
            </xsl:choose>
          </qui:label>
        </qui:input>
        <qui:link href="{/Top/SimpleSearchWithinLink}" rel="advanced" />
      </qui:form>
    </xsl:if>
  </xsl:template>

  <!-- highlighting -->
  <xsl:template match="Highlight">
    
    <!-- special treatment for text view but not pageviewer text view -->
    <xsl:choose>
      <xsl:when test="/Top/DlxsGlobals/CurrentCgi/Param[@name='view']='text'
                      and not(/Top/DlxsGlobals/CurrentCgi/Param[@name='page']='root')">
        <xsl:apply-templates select="." mode="text"/>
      </xsl:when>
      
      <xsl:otherwise>
        
        <xsl:choose>
          <xsl:when test="$show-text-hilight='yes'
                          or /Top/DlxsGlobals/CurrentCgi/Param[@name='page']='root'">
            <xsl:element name="span">
              <xsl:copy-of select="@class"/>
              <xsl:value-of select="."/>
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="."/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Lookup" mode="build-lookup">
    <qui:lookup id="{@id}">
      <xsl:apply-templates select="Item" mode="build-lookup" />
    </qui:lookup>
  </xsl:template>

  <xsl:template match="Item" mode="build-lookup">
    <qui:item key="{@key}"><xsl:value-of select="." /></qui:item>
  </xsl:template>

  <xsl:template match="xsl:template[@name='ACK']" name="ACK" priority="101">
    <qui:debug>ACK</qui:debug>
    <xsl:if test="true()">
      <message>TRUE</message>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>
