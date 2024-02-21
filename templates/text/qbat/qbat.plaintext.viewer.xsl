<xsl:stylesheet 
  version="1.0" 
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
  xmlns:tei="http://www.tei-c.org/ns/1.0"
  xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:variable name="identifier">
    <xsl:value-of select="//tiParam[@name='cc']" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="//Param[@name='idno']" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="//Param[@name='seq']" />
  </xsl:variable>

  <xsl:variable name="item-encoding-level" select="//DocMeta//ENCODINGDESC/EDITORIALDECL/@N" />

  <xsl:template match="/Top">
    <!-- <xsl:value-of select="//DocSource/SourcePageData" /> -->
    <xsl:apply-templates select="//DocContent/DocSource/tei:SourcePageData//tei:ResultFragment" mode="html" />
    <xsl:apply-templates select="//qui:block[@slot='notes']/tei:NOTES" />
  </xsl:template>

  <xsl:template match="DocContent" mode="basic">
    <xsl:apply-templates mode="pagetext" select="DocSource/SourcePageData"/>
    <script>
    </script>
  </xsl:template>

  <xsl:template match="DocSource" mode="htmlxx">
    <html lang="en" data-item-encoding-level="{$item-encoding-level}">
      <head>
        <title>W?</title>
      </head>
      <body>
        <p>Urhg.</p>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="tei:ResultFragment" mode="html">
    <xsl:choose>
      <xsl:when test="normalize-space(.) = ''"></xsl:when>
      <xsl:when test="$item-encoding-level = '1'">
        <xsl:if test="preceding-sibling::tei:ResultFragment">
          <hr />
        </xsl:if>    
        <section style="white-space: pre-line">
          <xsl:apply-templates />
        </section>    
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="preceding-sibling::tei:ResultFragment">
          <hr />
        </xsl:if>
        <article data-item-encoding-level="{$item-encoding-level}">
        <xsl:apply-templates />
        </article>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:Highlight">
    <mark class="{@class}" id="id{@seq}" data-seq="{@seq}">
      <xsl:apply-templates />
    </mark>
  </xsl:template>

  <xsl:template match="tei:DLPSWRAP[normalize-space(.)]" priority="101">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:DLPSWRAP" priority="10" />

  <xsl:template match="tei:NOTES[normalize-space(.)]">
    <section class="[ records ]">
      <h2 id="notes" class="subtle-heading">Notes</h2>
      <ul class="list-unstyled">
        <xsl:for-each select="tei:NOTE">
          <li class="mb-2 p-1 border-bottom" data-id="{node()/@ID}">
            <xsl:apply-templates select="*" mode="note" />
          </li>
        </xsl:for-each>
      </ul>
    </section>
  </xsl:template>

</xsl:stylesheet>