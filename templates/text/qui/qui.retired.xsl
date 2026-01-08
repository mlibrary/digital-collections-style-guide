<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="auto-redirect-setting">
    <xsl:call-template name="get-auto-redirect-setting" />
  </xsl:variable>

  <xsl:template name="build-head-block">
    <xsl:if test="//Redirect">
      <xsl:variable name="link">
        <xsl:apply-templates select="//Redirect/Link" mode="compute" />
      </xsl:variable>
      <qui:link rel="redirect" href="{$link}" auto-redirect="{$auto-redirect-setting}">
        <xsl:value-of select="//Redirect/Label" />
      </qui:link>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-canonical-link" />

  <xsl:template name="build-site-header" />

  <xsl:template name="get-title">
    <xsl:choose>
      <xsl:when test="//Redirect/RedirectType = 'move'">
        <xsl:text>Collection Moved</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>Offline</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <xsl:call-template name="get-collection-title" />
    </qui:header>

    <!-- <xsl:if test="//Redirect">
      <qui:link rel="redirect" href="{//Redirect/Link}" auto-redirect="{$auto-redirect-setting}">
\        <xsl:value-of select="//Redirect/Label" />
      </qui:link>
    </xsl:if> -->

    <qui:block slot="closed-for-business">
      <xsl:choose>
        <xsl:when test="//qui:block[@slot='closed-for-business']">
          <xsl:apply-templates select="//qui:block[@slot='closed-for-business']" mode="copy-guts" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="//Redirect/RedirectType = 'move'">
              <p>This collection has been moved.</p>
            </xsl:when>
            <xsl:otherwise>
              <p>This collection has been retired.</p>
            </xsl:otherwise>
          </xsl:choose>
          <xsl:if test="//Redirect">
            <xsl:choose>
              <xsl:when test="$auto-redirect-setting = 'true'">
                <p>
                  <xsl:text>You will be redirected to </xsl:text>
                  <xsl:apply-templates select="//Redirect" mode="print" />
                </p>
              </xsl:when>
              <xsl:otherwise>
                <p>
                  <xsl:text>For more information: </xsl:text>
                  <xsl:apply-templates select="//Redirect" mode="print" />
                </p>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </qui:block>

  </xsl:template>

  <xsl:template name="get-auto-redirect-setting">
    <xsl:choose>
      <xsl:when test="//AutoRedirect = 'true'">true</xsl:when>
      <xsl:otherwise>false</xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="Redirect" mode="print">
    <a href="{Link}">
      <xsl:choose>
        <xsl:when test="normalize-space(Label)">
          <xsl:value-of select="Label" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="Link" />
        </xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <xsl:template match="Redirect/Link" mode="compute">
    <xsl:value-of select="." />
  </xsl:template>

</xsl:stylesheet>