<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="exsl str">

  <xsl:template match="*" mode="qui:monograph">
    <xsl:apply-templates select="." mode="qui:monograph-title" />
    <xsl:apply-templates select="." mode="qui:monograph-author" />
    <xsl:apply-templates select="." mode="qui:monograph-editor" />
    <xsl:apply-templates select="." mode="qui:monograph-pubinfo" />
    <xsl:apply-templates select="." mode="qui:monograph-useguidelines" />
    <xsl:apply-templates select="." mode="qui:monograph-subjects" />
  </xsl:template>

  <xsl:template match="*" mode="qui:serialissue">
    <xsl:apply-templates select="." mode="qui:monograph" />
  </xsl:template>

</xsl:stylesheet>