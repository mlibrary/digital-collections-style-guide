<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE root [
<!ENTITY nbsp "&#160;">  
]>
<xsl:stylesheet 
  version="1.0" 
  xmlns="http://www.w3.org/1999/xhtml" 
  xmlns:xhtml="http://www.w3.org/1999/xhtml" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:dlxs="http://dlxs.org" 
  xmlns:qbat="http://dlxs.org/quombat" 
  xmlns:exsl="http://exslt.org/common" 
  xmlns:math="http://exslt.org/math"
  xmlns:date="http://exslt.org/dates-and-times" 
  extension-element-prefixes="exsl math date" 
  xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template name="get-title">
    Index
  </xsl:template>

  <xsl:template name="build-body-main">
    <xsl:choose>
      <xsl:when test="//XcollMode = 'colls'">
        <xsl:call-template name="build-body-page-overview" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="build-body-page-index" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-body-page-overview">
    <qui:header role="main">
      <xsl:call-template name="build-sub-header-badge-data" />
      <xsl:call-template name="get-collection-title" />
    </qui:header>
    <qui:panel slot="browse">
      <qui:link icon="image" href="/lib/colllist/?byFormat=Image%20Collections">Browse Image Collections</qui:link>
      <!-- <qui:link icon="book" href="/lib/colllist/?byFormat=Audio%20&amp;%20Moving%20Image%20Collections">Browse Audio &amp; Moving Image Collections</qui:link>
      <qui:link icon="book" href="/lib/colllist/?byFormat=Newspaper%20Collections%20Collections">Browse Newspaper Collections</qui:link> -->
    </qui:panel>
    <qui:block slot="information">
      <xhtml:p>
        <xhtml:strong>Image Collections</xhtml:strong> is the 
        central access point for images <!--, newspapers, and audio &amp; moving images --> provided by the 
        University of Michigan 
        <xhtml:a href="https://www.lib.umich.edu/about-us/our-divisions-and-departments/library-information-technology/digital-content-and">Digital Content and Collections</xhtml:a>.
      </xhtml:p>
      <xhtml:p>
        Some collections at this site are restricted to use by authorized users only (i.e., University faculty, staff, students, etc... ).
      </xhtml:p>
      <xhtml:p>
        Authorized users should log in for complete access. Please see the 
        <xhtml:a href="https://www.lib.umich.edu/about-us/policies/statement-appropriate-use-electronic-resources">Access and Use Policy</xhtml:a> 
        of the U-M Library.
      </xhtml:p>
    </qui:block>
  </xsl:template>  

  <xsl:template name="build-body-page-index">

  </xsl:template>

  <xsl:template name="build-sub-header" />

</xsl:stylesheet>