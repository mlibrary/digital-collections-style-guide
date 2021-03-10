<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://dlxs.org/quombat/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <!-- <xsl:import href="social.wireframe.xsl" /> -->

  <xsl:template match="Top">
    <qui:root>
      <!-- fills html/head-->
      <qui:head>
        <qui:title>
          <xsl:value-of select="//CollName/Brief" />
        </qui:title>
        <qui:block slot="meta-social">
          <xsl:call-template name="build-social-twitter" />
          <xsl:call-template name="build-social-facebook" />
        </qui:block>
      </qui:head>
      <qui:m-website-header name="Digital Collections">
        <qui:nav>
          <qui:link href="{//Help}">Help</qui:link>
          <qui:link href="{//OpenPortfolio/Url}">Portfolios</qui:link>
          <xsl:call-template name="build-login-link" />
        </qui:nav>
      </qui:m-website-header>
      <qui:collection-header>
        <xsl:if test="//BannerImage">
          <xsl:attribute name="src">
            <xsl:value-of select="//BannerImage" />
          </xsl:attribute>
        </xsl:if>
        <xsl:call-template name="get-collection-title" />
        <xsl:call-template name="get-collection-subtitle" />
        <qui:nav slot="browse">
          <xsl:comment>browse records?</xsl:comment>
          <xsl:if test="normalize-space(//BrowseRecords)">
            <qui:link href="{//BrowseRecords/Url}">Browse the collection records</qui:link>
          </xsl:if>
          <qui:link href="{//BrowseImages/Url}">Browse the collection images</qui:link>
        </qui:nav>
        <qui:search-form />
      </qui:collection-header>
      <qui:main>
        <qui:block slot="introduction">
          <xsl:apply-templates select="//CollDescr" mode="copy-guts" />
        </qui:block>
        <xsl:call-template name="build-thumbnail-list" /> 
        <qui:block slot="description">
          <xsl:apply-templates select="//InsertTextInfo//div[@class='instructiontxt']" mode="copy-guts" />
        </qui:block>
        <qui:block slot="copyright-information">
          <xsl:apply-templates select="//InsertTextInfo//div[@id='useguidelines']" mode="copy-guts" />
        </qui:block>
      </qui:main>
      <qui:sidebar>
        <xsl:call-template name="build-panel-collection-links" />
        <xsl:call-template name="build-panel-browse-filters" />
        <xsl:call-template name="build-panel-related-collections" />
        <xsl:call-template name="build-panel-collection-contact" />
      </qui:sidebar>
      <qui:message>Message recived, La Jolla</qui:message>
    </qui:root>
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

  <xsl:template name="get-collection-title">
    <qui:collection-title>
      <xsl:choose>
        <xsl:when test="/Top/CollName = 'multiple'">
          <xsl:value-of select="normalize-space(/Top/GroupName)" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="normalize-space(/Top/CollName/Full)" />
        </xsl:otherwise>
      </xsl:choose>
    </qui:collection-title>
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

  <xsl:template match="*" mode="copy-guts">
    <xsl:apply-templates select="*|text()" mode="copy" />
  </xsl:template>

  <xsl:template match="node()[name()]" mode="copy" priority="99">
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
