<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template name="get-title">
    Index
  </xsl:template>

  <xsl:template name="build-subheader" />

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <xsl:call-template name="build-sub-header-badge-data" />
      <xsl:call-template name="get-collection-title" />
    </qui:header>

    <xsl:call-template name="build-search-form" />

    <xsl:apply-templates select="//qui:block[@slot='information']" mode="copy" />
    <xsl:apply-templates select="//qui:block[@slot='links']" mode="copy" />
    <xsl:apply-templates select="//qui:block[@slot='copyright']" mode="copy" />

    <xsl:if test="//HeroImage/@identifier">
      <qui:hero-image identifier="{//HeroImage/@identifier}" />
    </xsl:if>

    <xsl:call-template name="build-panel-custom" />
    <xsl:call-template name="build-panel-browse-links" />
    <!-- <xsl:call-template name="build-panel-collection-links" /> -->
    <xsl:call-template name="build-panel-filters" />
    <xsl:call-template name="build-panel-related-collections" />
    <xsl:call-template name="build-panel-access-restrictions" />

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

  <xsl:template name="build-panel-custom">
    <xsl:apply-templates select="//qui:panel[@slot='custom']" mode="copy" />
  </xsl:template>

  <xsl:template name="build-panel-browse-links">
    <qui:panel class="callout" slot="browse">
      <qui:link href="/cgi/i/image/image-idx?c={$collid};view=reslist;q1={$collid}" rel="browse-items" data-count="{//Stats/Items}" />
      <qui:link href="/cgi/i/image/image-idx?c={$collid};view=reslist;q1={$collid};med=1" rel="browse-images" data-count="{//Stats/Images}" />
    </qui:panel>
  </xsl:template>

  <xsl:template name="build-panel-filters">
    <xsl:apply-templates select="//Facets" />
  </xsl:template>

  <xsl:template name="build-panel-collection-links">
    <xsl:if test="//CollectionLinks">
      <qui:panel class="callout">
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
            <qui:link href="/cgi/i/image/image-idx?page=searchgroup;g={@GroupID}" data-badge="group">
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

  <xsl:template name="build-panel-access-restrictions">
    <xsl:variable name="status" select="normalize-space(/Top/AccessRestrictions/Status)" />
    <qui:panel slot="access-restrictions">
      <qui:header>
        <xsl:value-of select="key('gui-txt', 'access')" />
      </qui:header>
      <qui:block xmlns="http://www.w3.org/1999/xhtml">
        <xsl:choose>
          <xsl:when test="$status = 'access1'">
            <p>Access to this collection is restricted to authorized users.</p>
          </xsl:when>
          <xsl:when test="$status = 'public'">
            <xsl:variable name="num_authorized" select="/Top/AccessRestrictions/Authorized" />
            <xsl:variable name="num_public" select="/Top/AccessRestrictions/Public" />
            <xsl:variable name="num_restricted" select="/Top/AccessRestrictions/Restricted" />
            <xsl:choose>
              <xsl:when test="$num_public = 0">
                <p>There are no openly available images.</p>
              </xsl:when>
              <xsl:when test="$num_public > 0">
                <p>
                  <a href="{$num_public/@href}">
                    <xsl:value-of select="$num_public" />
                    images/descriptions
                  </a>
                  are openly available.
                </p>
              </xsl:when>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="$num_authorized = 0">
                <!-- NOP -->
              </xsl:when>
              <xsl:when test="$num_authorized > 0">
                <p>
                  <a href="{$num_authorized/@href}" class="number">
                    <xsl:value-of select="$num_authorized" />
                    images
                  </a>
                  are available with authorization;
            descriptions are openly available.
                </p>
                <xsl:if test="/Top/LoginLink/Mode = 'login'">
                  <p>
                    People affiliated with the University of Michigan can
                    <strong>
                      <a href="{//LoginLink/Url}">log in</a>
                    </strong>
                    to view them.
                  </p>
                </xsl:if>
              </xsl:when>
            </xsl:choose>
            <xsl:choose>
              <xsl:when test="$num_restricted = 0">
                <!-- NOP -->
              </xsl:when>
              <xsl:when test="$num_restricted > 0">
                <p>
                  <a href="{$num_restricted/@href}" class="number">
                    <xsl:value-of select="$num_restricted" />
                    images
                  </a>
                  are restricted; descriptions are openly available.
                </p>
              </xsl:when>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$status = 'authorized'">
            <p>You are an authorized user of this collection.</p>
          </xsl:when>
          <xsl:when test="$status = 'access4'">
            <p>Access restricted.</p>
          </xsl:when>
          <xsl:otherwise />
        </xsl:choose>
      </qui:block>
    </qui:panel>
  </xsl:template>


</xsl:stylesheet>
