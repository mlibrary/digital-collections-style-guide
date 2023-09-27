<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  <xsl:output method="xml" />

  <xsl:variable name="identifier">
    <xsl:value-of select="//Param[@name='cc']" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="//Param[@name='idno']" />
    <xsl:text>:</xsl:text>
    <xsl:value-of select="//Param[@name='seq']" />
  </xsl:variable>

  <xsl:template match="/Top">
    <!-- <xsl:value-of select="//DocSource/SourcePageData" /> -->
    <xsl:apply-templates select="//DocContent/DocSource" mode="html" />
  </xsl:template>

  <xsl:template match="/Top" mode="html">
    <html>
      <head>
        <script type="text/javascript" src="https://cdnjs.cloudflare.com/ajax/libs/jquery/2.2.4/jquery.js"></script>
      </head>
      <body>
        <xsl:apply-templates select="//DocSource" mode="html" />
        <script>
          var $div = $("#pvdoccontent");
          var lines = $div.text().split("\n");
          $div.html(lines.join("<br />"));
        </script>
      </body>
    </html>
  </xsl:template>

  <xsl:template match="DocContent" mode="basic">
    <xsl:apply-templates mode="pagetext" select="DocSource/SourcePageData"/>
    <script>
    </script>
  </xsl:template>

  <xsl:template match="DocSource" mode="html">
    <section style="white-space: pre-line">
      <xsl:apply-templates select="SourcePageData" mode="html" />
    </section>
  </xsl:template>

  <xsl:template match="SourcePageData" mode="html" >
    <xsl:apply-templates mode="html" />
  </xsl:template>

  <xsl:template match="P">
    <p style="white-space: pre-line">
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="Highlight" mode="html">
    <mark class="{@class}" id="id{@seq}" data-seq="{@seq}">
      <xsl:apply-templates />
    </mark>
  </xsl:template>

</xsl:stylesheet>