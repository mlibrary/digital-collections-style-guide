<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="exsl str">

  <xsl:template match="*" mode="qui:monograph">
    <xsl:apply-templates select="." mode="qui:monograph-title" />
    <xsl:apply-templates select="." mode="qui:monograph-author" />
    <xsl:apply-templates select="." mode="qui:monograph-pubinfo" />
  </xsl:template>

  <xsl:template match="*[ItemHeader/HEADER|HEADER]" mode="qui:serialissue">
    <xsl:apply-templates select="." mode="qui:monograph" />
  </xsl:template>

  <xsl:template match="*[MainHeader][ItemDetails]" mode="qui:serialissue">
    <qui:debug>serialissue-article</qui:debug>
    <xsl:apply-templates select="." mode="qui:serialissue-article-title" />
    <xsl:apply-templates select="." mode="qui:serialissue-article-author" />
    <xsl:apply-templates select="." mode="qui:serialissue-article-serial" />
    <xsl:apply-templates select="." mode="qui:serialissue-article-pubinfo" />
  </xsl:template>

  <xsl:template match="*[MainHeader]" mode="qui:serialissue">
    <qui:debug>serialissue-issue</qui:debug>
    <xsl:apply-templates select="." mode="qui:serialissue-issue-title" />
    <xsl:apply-templates select="." mode="qui:serialissue-issue-author" />
    <xsl:apply-templates select="." mode="qui:serialissue-issue-serial" />
    <xsl:apply-templates select="." mode="qui:serialissue-issue-pubinfo" />
  </xsl:template>

  <xsl:template match="*[ItemHeader/node()[@NODE]]" mode="qui:serialissue">
    <qui:debug>serialissue-node</qui:debug>
    <xsl:apply-templates select="." mode="qui:serialissue-node-title" />
    <xsl:apply-templates select="." mode="qui:serialissue-node-author" />
    <xsl:apply-templates select="." mode="qui:serialissue-node-serial" />
    <xsl:apply-templates select="." mode="qui:serialissue-node-pubinfo" />
  </xsl:template>

  <xsl:template match="*[@NODE]" mode="qui:serialissue">
    <qui:debug>serialissue-node</qui:debug>
    <xsl:apply-templates select="." mode="qui:serialissue-node-title" />
    <xsl:apply-templates select="." mode="qui:serialissue-node-author" />
    <xsl:apply-templates select="." mode="qui:serialissue-node-serial" />
    <xsl:apply-templates select="." mode="qui:serialissue-node-pubinfo" />
  </xsl:template>
    
</xsl:stylesheet>