<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="exsl str">
  <xsl:variable name="add-biblscope-to-serialissue-title" select="true()" />

  <xsl:template name="build-metadata-fields-for-monograph">
    <xsl:param name="item" />

    <xsl:call-template name="build-title-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-author-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <!-- and the sequence -->
    <xsl:call-template name="build-canvas-for-monograph" />

    <xsl:call-template name="build-editor-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-pubinfo-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-metadata-fields-for-monograph-extra">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-useguidelines-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-subjects-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

  </xsl:template>

  <xsl:template  name="build-metadata-fields-for-serialissue">
    <xsl:param name="item" />

    <xsl:call-template name="build-title-for-serialissue-article">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-author-for-serialissue-article">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <!-- and the sequence -->
    <xsl:call-template name="build-canvas-for-serialissue" />

    <xsl:call-template name="build-serial-for-serialissue-article">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-pubdate-for-serialissue-article">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-pubinfo-for-serialissue-article">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-metadata-fields-for-serialissue-extra">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-useguidelines-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-subjects-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

  </xsl:template>

  <xsl:template name="build-metadata-fields-for-serialissue-extra">
  </xsl:template>

  <xsl:template name="build-metadata-fields-for-monograph-extra">
  </xsl:template>

</xsl:stylesheet>
