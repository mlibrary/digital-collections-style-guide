<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:qui="http://dlxs.org/quombat/ui" extension-element-prefixes="exsl" >

  <xsl:template match="Top">
    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>type="text/xsl" href="../../xsl/debug.qui.xsl"</xsl:text>
    </xsl:processing-instruction>
    <qui:root>
      <!-- fills html/head-->
      <qui:head>
        <qui:title>
          <xsl:call-template name="build-head-title" />
        </qui:title>
        <xsl:call-template name="build-head-block" />
        <xsl:call-template name="build-canonical-link" />
      </qui:head>
      <qui:body>
        <xsl:call-template name="build-site-header" />
        <qui:main>
          <xsl:call-template name="build-body-main" />
        </qui:main>
        <qui:message>Message recived, La Jolla</qui:message>
      </qui:body>
    </qui:root>
  </xsl:template>

  <xsl:template name="build-site-header">
    <qui:m-website-header name="Digital Collections">
      <qui:search-form collid="{//Param[@name='cc']}" value="{//Param[@name='q1']}" />
      <qui:nav>
        <qui:link href="{//Help}">Help</qui:link>
        <qui:link href="{//OpenPortfolio/Url}">Portfolios</qui:link>
        <xsl:call-template name="build-login-link" />
      </qui:nav>
    </qui:m-website-header>
  </xsl:template>

  <xsl:template name="build-login-link">
    <qui:link href="{//LoginLink/Url}">
      <xsl:choose>
        <xsl:when test="//LoginLink/Mode = 'logout'">
          <xsl:text>Log out</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>Log in</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </qui:link>
  </xsl:template>

  <xsl:template name="build-head-block" />
  
  <xsl:template name="build-head-title">
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
      <xsl:when test="/Top/CollName = 'multiple'">
        <xsl:value-of select="normalize-space(/Top/GroupName)" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="normalize-space(/Top/CollName/Full)" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-collection-subtitle">
    <xsl:if test="normalize-space(//Subtitle)">
      <qui:collection-subtitle name="collection-subtitle">
        <xsl:value-of select="//Subtitle" />
      </qui:collection-subtitle>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-thumbnail-list">
    <xsl:if test="//Snapshot">
      <qui:thumbnail-list>
        <xsl:for-each select="//Snapshot">
          <qui:link href="{@href}">
            <xhtml:img src="{Thumbnail/@src}">
              <!-- <xsl:attribute name="alt">
                <xsl:for-each select="Record//Value">
                  <xsl:value-of select="." />
                  <xsl:if test="position() &lt; last()">
                    <xsl:text> / </xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </xsl:attribute> -->
            </xhtml:img>
            <xhtml:span>
              <xsl:for-each select="Record//Value">
                <xsl:value-of select="." />
                <xsl:if test="position() &lt; last()">
                  <xsl:text> / </xsl:text>
                </xsl:if>
              </xsl:for-each>
            </xhtml:span>
          </qui:link>
        </xsl:for-each>
      </qui:thumbnail-list>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-panel-collection-links">
    <xsl:if test="//CollectionLinks">
      <qui:panel>
        <qui:header>In this collection</qui:header>
        <qui:nav>
          <xsl:for-each select="//CollectionLinks/Link">
            <qui:link href="{@href}">
              <xsl:value-of select="normalize-space(.)" />
            </qui:link>
          </xsl:for-each>
        </qui:nav>
      </qui:panel>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-panel-related-collections">
    <xsl:if test="//Groups/Group">
      <qui:panel>
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
            <qui:link href="/cgi/i/image/image-idx?page=searchgroup;g={@GroupID}">
              <xsl:value-of select="normalize-space(.)" />
            </qui:link>
          </xsl:for-each>
        </qui:nav>
      </qui:panel>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-panel-collection-contact">
    <qui:panel>
      <qui:header>Collection Contact</qui:header>
      <qui:block-contact>
        <qui:href type="{//ContactLink/@type}"><xsl:value-of select="normalize-space(//ContactLink)" /></qui:href>
        <qui:span><xsl:value-of select="normalize-space(//ContactText)" /></qui:span>
      </qui:block-contact>
    </qui:panel>
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
              <qui:link href="/cgi/i/image/image-idx?c={//Param[@name='cc']};page=search;filter={Value}">
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

</xsl:stylesheet>
