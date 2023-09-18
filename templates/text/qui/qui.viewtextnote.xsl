<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" xmlns:qui="http://dlxs.org/quombat/ui" extension-element-prefixes="exsl date" >
  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />
  <xsl:strip-space elements="*"/>

  <xsl:variable name="title">
    <xsl:value-of select="key('get-lookup', 'header.str.viewentiretext')" />
  </xsl:variable>

  <xsl:template name="get-head-title">
    <xsl:value-of select="$title" />
  </xsl:template>

  <xsl:template name="build-head-block" />
  <xsl:template name="build-canonical-link" />

  <xsl:template name="build-site-header" />

  <xsl:template name="build-body-main">
    <qui:header role="main">
      <!-- <xsl:value-of select="$title" /> -->
      <xsl:text>Please be aware</xsl:text>
    </qui:header>

    <qui:block slot="blurb">
      <xhtml:p>
        Viewing the entire text means loading the entire &quot;volume&quot; 
        in your browser as one block of text without page breaks. 
        Some of these texts are as long as 1,000 pages
        and will take a long time to download.</xhtml:p>
      <xhtml:p>
        The quality of the OCR varies from text to text and page to page 
        (title pages can be particularly problematic).  
        The uncorrected OCR is provided as a mechanism to assist in 
        finding appropriate information, not as a substitute for the 
        page image itself.</xhtml:p>
    </qui:block>

    <qui:nav>
      <qui:link href="{/Top/ViewTextConfirmedLink}" rel="text">
        <xsl:value-of select="key('get-lookup','viewtextnote.str.1')"/>
      </qui:link>
    </qui:nav>

  </xsl:template>

</xsl:stylesheet>