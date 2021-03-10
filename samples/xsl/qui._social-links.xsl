<?xml version="1.0"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://dlxs.org/quombat/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:variable name="title">
    <xsl:choose>
      <xsl:when test="$fields[@abbrev='dc_ti']">
        <!-- <xsl:value-of select="$fields[@abbrev='dc_ti']//Values" /> -->
        <xsl:for-each select="$fields[@abbrev='dc_ti']//Values/Value">
          <xsl:value-of select="." />
          <xsl:if test="position() != last()">
            <xsl:text>; </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$fields[@abbrev='dlxs_ma']">
        <!-- <xsl:value-of select="$fields[@abbrev='dlxs_ma']//Values" /> -->
        <xsl:for-each select="$fields[@abbrev='dlxs_ma']//Values/Value">
          <xsl:value-of select="." />
          <xsl:if test="position() != last()">
            <xsl:text>; </xsl:text>
          </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="fields" select="//Record[@name='special']//Field" />
  <xsl:variable name="description">
    <xsl:choose>
      <xsl:when test="$fields[@abbrev='dc_de']">
        <xsl:call-template name="get-field-values">
          <xsl:with-param name="field" select="$fields[@abbrev='dc_de']" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$fields[@abbrev='dc_su']">
        <xsl:call-template name="get-field-values">
          <xsl:with-param name="field" select="$fields[@abbrev='dc_su']" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="get-field-values">
    <xsl:param name="field" />
    <xsl:for-each select="$field//Value[normalize-space(.)]">
      <xsl:value-of select="." />
      <xsl:if test="position() &lt; last()">
        <xsl:text> / </xsl:text>
      </xsl:if>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="build-social-twitter">
    <!-- requires a description -->
    <xsl:if test="normalize-space($description)">
      <xhtml:meta name="twitter:card">
        <xsl:attribute name="content">
          <xsl:choose>
            <xsl:when test="//MediaInfo/m_entryauth = 'WORLD'">
              <xsl:text>summary_large_image</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>summary</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xhtml:meta>
      <xhtml:meta name="twitter:site" content="@umichlibrary" />
      <xhtml:meta name="twitter:url">
        <xsl:attribute name="content">
          <xsl:value-of select="/Top/ItemUrl" />
        </xsl:attribute>
      </xhtml:meta>

      <xsl:if test="normalize-space($description)">
        <xhtml:meta name="twitter:description" content="{normalize-space($description)}" />
      </xsl:if>
      <xsl:if test="normalize-space($title)">
        <meta name="twitter:title" content="{//CollName/Full}: {normalize-space($title)}" />
      </xsl:if>

      <xsl:choose>
        <xsl:when test="//MediaInfo/m_entryauth = 'WORLD'">
          <xhtml:meta name="twitter:image" content="{//MediaInfo/MediaHost}{//MediaInfo//MediaLink}" />
        </xsl:when>
        <xsl:otherwise />
      </xsl:choose>
    </xsl:if>

  </xsl:template>

  <xsl:template name="build-social-facebook">
    <xhtml:meta property="og:type" content="website" />
    <xhtml:meta property="og:site_name" content="{//CollName/Full}" />
    <xhtml:meta property="og:url">
      <xsl:attribute name="content">
        <xsl:choose>
          <xsl:when test="//Param[@name='page'] = 'index'">
            <xsl:value-of select="//Home" />
          </xsl:when>
          <xsl:when test="/Top/ItemUrl">
            <xsl:value-of select="/Top/ItemUrl" />
          </xsl:when>
        </xsl:choose>
      </xsl:attribute>
    </xhtml:meta>

    <xsl:if test="normalize-space($title)">
      <xhtml:meta property="og:title" content="{normalize-space($title)}" />
    </xsl:if>

    <xsl:choose>
      <xsl:when test="//MediaInfo/m_entryauth = 'WORLD'">
        <xhtml:meta property="og:image" content="{//MediaInfo/MediaHost}{//MediaInfo//MediaLink}" />
      </xsl:when>
      <xsl:otherwise />
    </xsl:choose>

  </xsl:template>

</xsl:stylesheet>