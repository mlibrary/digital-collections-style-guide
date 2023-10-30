<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="exsl str">

  <xsl:template name="build-metadata-fields-for-monograph">
    <xsl:param name="root" />

    <xsl:call-template name="build-main-title-for-monograph">
      <xsl:with-param name="root" select="$root/ItemHeader" />
    </xsl:call-template>

    <xsl:call-template name="build-contributor-list-for-monograph">
      <xsl:with-param name="key">author</xsl:with-param>
      <xsl:with-param name="values" select="($root/ItemHeader|$root)/HEADER/FILEDESC/TITLESTMT/AUTHOR" />
    </xsl:call-template>

    <xsl:call-template name="build-contributor-list-for-monograph">
      <xsl:with-param name="key">editor</xsl:with-param>
      <xsl:with-param name="values" select="($root/ItemHeader|$root)/HEADER/FILEDESC/TITLESTMT/EDITOR" />
    </xsl:call-template>

    <xsl:call-template name="build-publication-info-for-monograph">
      <xsl:with-param name="source" select="($root/ItemHeader|$root)/HEADER/FILEDESC/SOURCEDESC" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-metadata-fields-for-serialissue">
    <xsl:param name="root" />

    <xsl:choose>
      <xsl:when test="$root/ItemHeader/HEADER">
        <xsl:call-template name="build-metadata-fields-for-monograph">
          <xsl:with-param name="root" select="$root" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$root/MainHeader and $root/ItemDetails">
        <xsl:call-template name="build-metadata-fields-for-serialissue-article">
          <xsl:with-param name="root" select="$root" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$root/MainHeader">
        <xsl:call-template name="build-metadata-fields-for-serialissue-layer">
          <xsl:with-param name="root" select="$root" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$root[@NODE]">
        <xsl:call-template name="build-metadata-fields-for-serialissue-node">
          <xsl:with-param name="root" select="$root" />
        </xsl:call-template>
      </xsl:when>
      <xsl:otherwise>
        <qui:debug>FAIL</qui:debug>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-metadata-fields-for-serialissue-layer">
    <xsl:param name="root" />

    <qui:debug>AHOY</qui:debug>

    <xsl:variable name="articleCite" select="$root/ItemDetails/DIV1/BIBL"/>
    <xsl:variable name="serIssSrc" select="$root/MainHeader/HEADER/FILEDESC/SOURCEDESC"/>

    <xsl:call-template name="build-main-title-for-serialissue">
      <xsl:with-param name="article-cite" select="$articleCite" />
    </xsl:call-template>

    <xsl:call-template name="build-author-for-serialissue">
      <xsl:with-param name="article-cite" select="$articleCite" />
    </xsl:call-template>

    <xsl:call-template name="build-serial-title-for-serialissue">
      <xsl:with-param name="source" select="$root/MainHeader/HEADER/FILEDESC" />
    </xsl:call-template>

    <xsl:call-template name="build-pubinfo-for-serialissue">
      <xsl:with-param name="ser-iss-src" select="$serIssSrc"/>
      <xsl:with-param name="article-cite" select="$articleCite"/>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-metadata-fields-for-serialissue-article">
    <xsl:param name="root" />
    <xsl:variable name="articleCite" select="$root/ItemDetails/DIV1//BIBL"/>
    <xsl:variable name="serIssSrc" select="$root/MainHeader/HEADER/FILEDESC/SOURCEDESC"/>
    
    <xsl:call-template name="build-main-title-for-serialissue">
      <xsl:with-param name="article-cite" select="$articleCite" />
    </xsl:call-template>

    <xsl:call-template name="build-author-for-serialissue">
      <xsl:with-param name="article-cite" select="$articleCite" />
    </xsl:call-template>

    <xsl:call-template name="build-pubinfo-for-serialissue">
      <xsl:with-param name="ser-iss-src" select="$serIssSrc"/>
      <xsl:with-param name="article-cite" select="$articleCite"/>
    </xsl:call-template>

  </xsl:template>

  <xsl:template name="build-metadata-fields-for-serialissue-node">
    <xsl:param name="root" />

    <xsl:variable name="articleCite" select="$root/descendant-or-self::node()[@NODE]//BIBL"/>

    <qui:debug>BEH <xsl:value-of select="$root/descendant-or-self::node()/@NODE" /></qui:debug>
    
    <xsl:call-template name="build-main-title-for-serialissue">
      <xsl:with-param name="article-cite" select="$articleCite" />
    </xsl:call-template>

    <xsl:call-template name="build-author-for-serialissue">
      <xsl:with-param name="article-cite" select="$articleCite" />
    </xsl:call-template>

    <xsl:call-template name="build-pubinfo-for-serialissue">
      <!-- <xsl:with-param name="ser-iss-src" select="$root/ItemHeader/node()"/> -->
      <xsl:with-param name="article-cite" select="$articleCite"/>
    </xsl:call-template>

  </xsl:template>  

</xsl:stylesheet>