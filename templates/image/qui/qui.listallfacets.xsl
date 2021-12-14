<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">

  <xsl:output method="xml" version="1.0" encoding="utf-8" indent="yes" />

  <xsl:template match="Top">
    <xsl:processing-instruction name="xml-stylesheet">
      <xsl:text>type="text/xsl" href="../../../xsl/i/image/debug.qui.xsl"</xsl:text>
    </xsl:processing-instruction>
    <qui:root view="{//Param[@name='view']|//Param[@name='page']}" collid="{$collid}">
      <!-- fills html/head-->
      <qui:body>
        <qui:main>
          <xsl:call-template name="build-body-main" />
        </qui:main>
      </qui:body>
    </qui:root>
  </xsl:template>

  <xsl:template name="build-body-main">
    <xsl:apply-templates select="//Facets" />
  </xsl:template>

</xsl:stylesheet>