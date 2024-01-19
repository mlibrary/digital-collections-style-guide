<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="exsl str">
  <xsl:variable name="add-biblscope-to-serialissue-title" select="true()" />

  <xsl:template match="*" mode="qui:monograph">
    <xsl:apply-templates select="." mode="qui:monograph-title" />
    <xsl:apply-templates select="." mode="qui:monograph-author" />

    <xsl:call-template name="build-canvas-for-monograph" />

    <xsl:apply-templates select="." mode="qui:monograph-editor" />
    <xsl:apply-templates select="." mode="qui:monograph-pubinfo" />
    <xsl:apply-templates select="." mode="qui:monograph-useguidelines" />
    <xsl:apply-templates select="." mode="qui:monograph-subjects" />
  </xsl:template>

  <xsl:template match="*" mode="qui:serialissue">
    <xsl:apply-templates select="." mode="qui:serialissue-article-title" />
    <xsl:apply-templates select="." mode="qui:serialissue-article-author" />

    <xsl:call-template name="build-canvas-for-monograph" />

    <xsl:apply-templates select="." mode="qui:serialissue-article-serial" />
    <xsl:apply-templates select="." mode="qui:serialissue-article-pubdate" />
    <xsl:apply-templates select="." mode="qui:serialissue-article-pubinfo" />

    <xsl:if test="$add-notesstmt">
      <xsl:apply-templates select="ItemHeader/HEADER/FILEDESC/SOURCEDESC//NOTESSTMT" mode="process-notes" />
    </xsl:if>

    <xsl:apply-templates select="." mode="qui:monograph-useguidelines" />
    <xsl:apply-templates select="." mode="qui:monograph-subjects" />
  </xsl:template>

</xsl:stylesheet>
