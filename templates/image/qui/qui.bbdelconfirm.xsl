<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="count-bbidno" select="count(//Param[@name='bbidno'])" />
  <xsl:variable name="bbdbid" select="//CurrentCgi/Param[@name='bbdbid']" />

  <xsl:template name="get-head-title">
    Edit Portfolio
  </xsl:template>

  <xsl:template name="build-head-block" />
  <xsl:template name="build-canonical-link" />

  <xsl:template name="build-site-header" />

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <xsl:text>Delete this portfolio?</xsl:text>
    </qui:header>

    <qui:block slot="blurb">
      <xhtml:p>
        You are deleting 
        <xsl:value-of select="/Top//Portfolio[@id=$bbdbid]/Field[@name='bbagname']" />
      </xhtml:p>
    </qui:block>

    <qui:link rel="confirm" href="{/Top/DeletePortfolio/Url}" />
    <qui:link rel="cancel" href="{/Top//Portfolio[@id=$bbdbid]//Action[@type='open']/Url}" />

  </xsl:template>


</xsl:stylesheet>