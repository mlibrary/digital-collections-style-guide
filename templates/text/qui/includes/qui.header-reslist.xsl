<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="exsl str">

  <xsl:template name="build-metadata-fields-for-monograph">
    <xsl:param name="item" />

    <xsl:call-template name="build-title-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-author-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-editor-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-pubinfo-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-metadata-fields-for-serialissue">
    <xsl:param name="item" />

    <xsl:choose>
      <xsl:when test="$item/ItemHeader/HEADER">
        <xsl:call-template name="build-metadata-fields-for-monograph">
          <xsl:with-param name="item" select="$item" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$item/MainHeader and $item/ItemDetails">
        <xsl:call-template name="build-metadata-fields-for-serialissue-article">
          <xsl:with-param name="item" select="$item" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$item/MainHeader">
        <xsl:call-template name="build-metadata-fields-for-serialissue-issue">
          <xsl:with-param name="item" select="$item" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$item[@NODE]">
        <xsl:call-template name="build-metadata-fields-for-serialissue-node">
          <xsl:with-param name="item" select="$item" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <qui:debug>FAIL</qui:debug>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-metadata-fields-for-serialissue-issue">
    <xsl:param name="item" />

    <xsl:call-template name="build-title-for-serialissue-issue">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-author-for-serialissue-issue">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-serial-for-serialissue-issue">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-pubinfo-for-serialissue-issue">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-metadata-fields-for-serialissue-article">
    <xsl:param name="item" />
    <xsl:variable name="articleCite" select="$item/ItemDetails/DIV1//BIBL"/>
    <xsl:variable name="serIssSrc" select="$item/MainHeader/HEADER/FILEDESC/SOURCEDESC"/>

    <xsl:call-template name="build-title-for-serialissue-article">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-author-for-serialissue-article">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-serial-for-serialissue-article">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-pubinfo-for-serialissue-article">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

  </xsl:template>

  <xsl:template name="build-metadata-fields-for-serialissue-node">
    <xsl:param name="item" />

    <xsl:call-template name="build-title-for-serialissue-node">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-author-for-serialissue-node">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

    <xsl:call-template name="build-pubinfo-for-serialissue-node">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>

  </xsl:template>

    
</xsl:stylesheet>