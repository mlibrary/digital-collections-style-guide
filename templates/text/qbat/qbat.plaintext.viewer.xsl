<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:tei="http://www.tei-c.org/ns/1.0" >
  <xsl:output method="xml" />

  <xsl:variable name="identifier">
    <xsl:value-of select="//Param[@name='cc']" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="//Param[@name='idno']" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="//Param[@name='seq']" />
  </xsl:variable>

  <xsl:variable name="item-encoding-level" select="//DocMeta//ENCODINGDESC/EDITORIALDECL/@N" />

  <xsl:template match="/Top">
    <!-- <xsl:value-of select="//DocSource/SourcePageData" /> -->
    <xsl:apply-templates select="//DocContent/DocSource" mode="html" />
  </xsl:template>

  <xsl:template match="DocContent" mode="basic">
    <xsl:apply-templates mode="pagetext" select="DocSource/SourcePageData"/>
    <script>
    </script>
  </xsl:template>

  <xsl:template match="DocSource" mode="html">
    <xsl:choose>
      <xsl:when test="$item-encoding-level = '1'">
        <section style="white-space: pre-line">
          <xsl:apply-templates select="tei:SourcePageData" mode="html" />
        </section>    
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="SourcePageData" mode="html" >
    <xsl:apply-templates mode="html" />
  </xsl:template>

  <xsl:template match="tei:Highlight" mode="html">
    <mark class="{@class}" id="id{@seq}" data-seq="{@seq}">
      <xsl:apply-templates />
    </mark>
  </xsl:template>

</xsl:stylesheet>