<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="exsl str">
  <xsl:variable name="add-biblscope-to-serialissue-title" select="true()" />

  <xsl:template name="build-metadata-fields-for-monograph">
    <xsl:param name="root" />
    <xsl:variable name="src" select="$root/ItemHeader/HEADER/FILEDESC/SOURCEDESC" />

    <xsl:call-template name="build-main-title-for-monograph">
      <xsl:with-param name="root" select="$root/ItemHeader" />
    </xsl:call-template>

    <!-- and the sequence -->
    <xsl:call-template name="build-canvas-for-monograph" />

    <xsl:call-template name="build-contributor-list-for-monograph">
      <xsl:with-param name="key">author</xsl:with-param>
      <xsl:with-param name="values" select="$root/ItemHeader/HEADER/FILEDESC/TITLESTMT/AUTHOR" />
    </xsl:call-template>

    <xsl:call-template name="build-contributor-list-for-monograph">
      <xsl:with-param name="key">editor</xsl:with-param>
      <xsl:with-param name="values" select="$root/ItemHeader/HEADER/FILEDESC/TITLESTMT/EDITOR" />
    </xsl:call-template>

    <xsl:call-template name="build-publication-info-for-monograph">
      <xsl:with-param name="source" select="$root/ItemHeader/HEADER/FILEDESC/SOURCEDESC" />
    </xsl:call-template>

    <xsl:call-template name="build-useguidelines-for-monograph">
      <xsl:with-param name="root" select="$root" />
    </xsl:call-template>

    <xsl:call-template name="build-subjects-for-monograph">
      <xsl:with-param name="root" select="$root" />
    </xsl:call-template>

  </xsl:template>

  <xsl:template  name="build-metadata-fields-for-serialissue">
    <xsl:param name="root" />
    <xsl:variable name="articleCite" select="$root/ItemDivhead/DIV1/BIBL"/>
    <xsl:variable name="serIssSrc" select="$root/ItemHeader/HEADER/FILEDESC/SOURCEDESC"/>

    <xsl:call-template name="build-main-title-for-serialissue">
      <xsl:with-param name="article-cite" select="$articleCite" />
    </xsl:call-template>

    <xsl:call-template name="build-author-for-serialissue">
      <xsl:with-param name="article-cite" select="$articleCite" />
    </xsl:call-template>

    <!-- and the sequence -->
    <xsl:call-template name="build-canvas-for-serialissue" />

    <xsl:call-template name="build-serial-title-for-serialissue">
      <xsl:with-param name="source" select="$root/ItemHeader/HEADER/FILEDESC" />
    </xsl:call-template>

    <xsl:call-template name="build-pubinfo-for-serialissue">
      <xsl:with-param name="ser-iss-src" select="$serIssSrc"/>
      <xsl:with-param name="article-cite" select="$articleCite"/>
    </xsl:call-template>

    <xsl:call-template name="build-useguidelines-for-monograph">
      <xsl:with-param name="root" select="$root" />
    </xsl:call-template>

    <xsl:call-template name="build-subjects-for-monograph">
      <xsl:with-param name="root" select="$root" />
    </xsl:call-template>

  </xsl:template>

</xsl:stylesheet>