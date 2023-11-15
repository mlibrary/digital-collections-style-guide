<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="exsl str">

  <xsl:template name="build-metadata-fields-for-monograph-extra">
    <xsl:param name="item" />

    <xsl:call-template name="build-field">
      <xsl:with-param name="key">repository</xsl:with-param>
      <xsl:with-param name="value">Bentley Historical Library, University of Michigan</xsl:with-param>
    </xsl:call-template>

  </xsl:template>

  <!-- <xsl:template name="build-pubinfo-for-monograph"></xsl:template> -->

</xsl:stylesheet>