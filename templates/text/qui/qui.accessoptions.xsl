<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template name="build-head-block">
  </xsl:template>

  <xsl:template name="build-sub-header" />

  <xsl:template name="build-canonical-link" />

  <!-- <xsl:template name="build-site-header" /> -->

  <xsl:template name="get-title">
    Access
  </xsl:template>

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <xsl:call-template name="get-collection-title" />
    </qui:header>

    <qui:block slot="access-information">
      <xsl:choose>
        <xsl:when test="//qui:block[@slot='access-information']">
          <xsl:apply-templates select="//qui:block[@slot='access-information']" mode="copy-guts" />
        </xsl:when>
        <xsl:otherwise>
          <p>Sorry, you are not permitted access to this collection.</p>
          <p>Access for this collection is restricted to authorized users only.</p>
          <p>Authorized users should log in for complete access. Please see the <a href="https://www.lib.umich.edu/about-us/policies/statement-appropriate-use-electronic-resources">Access and Use Policy</a>
           of the U-M Library.</p>
        </xsl:otherwise>
      </xsl:choose>
    </qui:block>

    <xsl:if test="//NoAccess = 'false' and //SupportedAuthSystems[System = 'um']">
      <qui:block slot="login-information">
        <p>
          <xsl:text>University of Michigan staff, students, and others with U-M login privileges may </xsl:text>
          <a href="{/Top/ReAuthLink}">log in</a> for access.
        </p>
      </qui:block>
    </xsl:if>

  </xsl:template>

</xsl:stylesheet>