<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template name="get-title">
    Index
  </xsl:template>

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <xsl:call-template name="get-collection-title" />
    </qui:header>

    <xsl:call-template name="build-search-form" />

    <xsl:if test="//HeroImage/@identifier">
      <qui:hero-image identifier="{//HeroImage/@identifier}" />
    </xsl:if>

    <qui:panel>
      <xhtml:ul>
        <xhtml:li>
          <xhtml:a href="{//BrowseImages/Url}">Browse Images</xhtml:a>
        </xhtml:li>
        <xsl:if test="//BrowseRecords/Url">
          <xhtml:li>
            <xhtml:a href="{//BrowseRecords/Url}">Browse Records</xhtml:a>
          </xhtml:li>
        </xsl:if>
      </xhtml:ul>
    </qui:panel>
  </xsl:template>

  <xsl:template name="build-search-form-XXX">
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
  </xsl:template>

  <xsl:template match="Facets" mode="search-form">
    <xsl:for-each select="Field">
      <xsl:variable name="abbrev" select="@abbrev" />
      <xsl:for-each select="Values/Value[@selected='true']">
        <qui:hidden-input type="hidden" name="fn{position()}" value="{$abbrev}" data-role="facet" />
        <qui:hidden-input type="hidden" name="fq{position()}" value="{.}" data-role="facet-value" data-facet-field="{$abbrev}" />
      </xsl:for-each>
    </xsl:for-each>
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


</xsl:stylesheet>
