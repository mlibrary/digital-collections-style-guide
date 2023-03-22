<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="cgiNode" select="/Top/DlxsGlobals/CurrentCgi" />
  <xsl:variable name="accessitem">
    <xsl:choose>
      <xsl:when test="$cgiNode/Param[@name='entryid']">
        <xsl:text>item</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>resource</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:template name="build-head-block" />

  <xsl:template name="build-sub-header" />

  <xsl:template name="build-canonical-link" />

  <!-- <xsl:template name="build-site-header" /> -->

  <xsl:template name="get-title">Login options</xsl:template>

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <xsl:text>Login options</xsl:text>
    </qui:header>

    <qui:block slot="login-information">
      <p>Please select from the following
    links for access for this <xsl:value-of
          select="concat(' ',$accessitem)" />.</p>

      <p>University of Michigan faculty, staff, students and others who
    have UM-issued usernames should use the <a href="{/Top/ReAuthLink}">U-M Login</a>.</p>

      <p>Others may access unrestricted <a href="/?byFormat=Image+Collections">Image
    Collections</a>.</p>

      <p>
        <a class="button button--ghost no-underline" style="margin-left: 0"
          href="/cgi/i/image/image-idx?page=feedback&amp;to=content">Inquire about access</a>
      </p>

    </qui:block>

  </xsl:template>

</xsl:stylesheet>