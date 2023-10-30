<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="exsl str">

  <xsl:template name="build-metadata-fields-for-monograph">
    <xsl:param name="root" />

    <xsl:call-template name="build-main-title-for-monograph">
      <xsl:with-param name="root" select="$root/ItemHeader" />
    </xsl:call-template>

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

  <xsl:template name="build-metadata-fields-for-serialissue">
    <xsl:param name="root" />

    <xsl:call-template name="build-metadata-fields-for-monograph">
      <xsl:with-param name="root" select="$root" />
    </xsl:call-template>

  </xsl:template>

</xsl:stylesheet>