<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template match="qui:root">

    <xsl:apply-templates select="//qui:main" />

  </xsl:template>

  <xsl:template match="qui:main">

    <xsl:call-template name="build-filters-panel" />

  </xsl:template>

</xsl:stylesheet>