<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template name="build-head-block">
  </xsl:template>

  <xsl:template name="build-sub-header" />

  <xsl:template name="build-canonical-link" />

  <!-- <xsl:template name="build-site-header" /> -->

  <xsl:template name="get-title">
    Access Failure
  </xsl:template>

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <xsl:value-of select="key('get-lookup', 'tombstone.str.7')" />
    </qui:header>

    <qui:block slot="blurb">
      <p>
        <xsl:value-of select="key('get-lookup', 'tombstone.str.8')" />
      </p>
    </qui:block>

  </xsl:template>

</xsl:stylesheet>