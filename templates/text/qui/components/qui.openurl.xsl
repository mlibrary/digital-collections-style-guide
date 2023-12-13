<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">


  <xsl:template name="build-openurl-href">
    <!-- builds the HREF part of an OpenURL link, 
         takes the HEADER as param -->
    <xsl:param name="header" />
    <xsl:text>http://worldcatlibraries.org/registry/gateway?</xsl:text>
    <xsl:call-template name="build-openurl-context-object">
      <xsl:with-param name="header" select="$header" />
    </xsl:call-template>
  </xsl:template>

  <!-- <xsl:template name="build-openurl-link">
    <xsl:param name="header" />
    <a>
      <xsl:attribute name="href">
        <xsl:call-template name="build-openurl-href">
          <xsl:with-param name="header" select="$header" />
        </xsl:call-template>
      </xsl:attribute>
      <xsl:value-of select="key('get-lookup','results.str.34')"/>
    </a>
  </xsl:template> -->

  <xsl:template name="build-openurl-context-object">
    <xsl:param name="header" />
    <xsl:param name="rfr_id" />
    <xsl:text>ctx_ver=Z39.88-2004</xsl:text>

    <xsl:if test="not($rfr_id = '')">
      <xsl:text>&amp;rfr_id=info:sid/</xsl:text><xsl:value-of select="$rfr_id" />
    </xsl:if>

    <!-- rft.aulast,  rft.aufirst -->
    <xsl:variable name="name" select="$header/FILEDESC/SOURCEDESC/BIBL/AUTHOR" />
    <xsl:if test="not($name = '')">
      <xsl:variable name="lName" select="substring-before($name, ', ')" />
      <xsl:variable name="first" select="substring-after($name,  ', ')" />

      <xsl:if test="not($first = '')">
        <xsl:text>&amp;rft.aufirst=</xsl:text><xsl:value-of select="$first" />
      </xsl:if>
      <xsl:if test="not($lName = '')">
        <xsl:text>&amp;rft.aulast=</xsl:text><xsl:value-of select="$lName" />
      </xsl:if>
    </xsl:if>

    <!-- rft.spage, rft.epage -->
    <xsl:variable name="pages" select="$header/FILEDESC/SOURCEDESC/BIBL/BIBLSCOPE[@TYPE = 'pages']" />
    <xsl:if test="not($pages = '')">
      <xsl:variable name="spage" select="substring-before($pages, '-')" />
      <xsl:variable name="epage" select="substring-after($pages,  '-')" />

      <xsl:if test="not($spage = '')">
        <xsl:text>&amp;rft.spage=</xsl:text><xsl:value-of select="$spage" />
      </xsl:if>
      <xsl:if test="not($epage = '')">
        <xsl:text>&amp;rft.epage=</xsl:text><xsl:value-of select="$epage" />
      </xsl:if>
    </xsl:if>

    <!-- rft.volume -->
    <xsl:if test="$header/FILEDESC/SOURCEDESC/BIBL/BIBLSCOPE[@TYPE = 'volume']">
      <xsl:text>&amp;rft.volume=</xsl:text><xsl:value-of select="$header/FILEDESC/SOURCEDESC/BIBL/BIBLSCOPE[@TYPE = 'volume']" />
    </xsl:if>

    <!-- rft.year -->
    <xsl:variable name="date" select="$header/FILEDESC/SOURCEDESC/BIBL/DATE" />
    <xsl:if test="$date">
      <xsl:variable name='year' select='substring($date, 1, 4 )' />

      <xsl:choose>
        <xsl:when test="not(string(number($year)) = 'NaN')">
          <xsl:text>&amp;rft.year=</xsl:text><xsl:value-of select="$year" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:variable name='len' select='string-length($date)' />
          <xsl:variable name='yr'  select='substring($date, ($len - 3), $len)' />
          <xsl:if test="not(string(number($yr)) = 'NaN')">
            <xsl:text>&amp;rft.year=</xsl:text><xsl:value-of select="$yr" />
          </xsl:if>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>

    <!-- rft.issn isbn -->
    <xsl:if test="$header/FILEDESC/PUBLICATIONSTMT/IDNO[@TYPE = 'isbn']">
      <xsl:text>&amp;rft.isbn=</xsl:text><xsl:value-of select="$header/FILEDESC/PUBLICATIONSTMT/IDNO[@TYPE = 'isbn']" />
    </xsl:if>
    <xsl:if test="$header/FILEDESC/PUBLICATIONSTMT/IDNO[@TYPE = 'issn']">
      <xsl:text>&amp;rft.issn=</xsl:text><xsl:value-of select="$header/FILEDESC/PUBLICATIONSTMT/IDNO[@TYPE = 'issn']" />
    </xsl:if>

    <xsl:variable name='genre' select="$header/PROFILEDESC/TEXTCLASS/KEYWORDS/TERM[@TYPE = 'genre']" />

    <!-- journal -->
    <!-- rft.genre, rft_val_fmt -->
    <xsl:choose>
      <xsl:when test="$genre = 'Journal Article'  or $genre = 'Newspaper Article' or 
                      $genre = 'Magazine Article' or $genre = 'Electronic Article' ">
        <xsl:text>&amp;rft.genre=article</xsl:text>
        <xsl:text>&amp;rft_val_fmt=info:ofi/fmt:kev:mtx:journal</xsl:text>

        <!-- rft.atitle -->
        <xsl:if test="$header/FILEDESC/SOURCEDESC/BIBL/TITLE[@TYPE = 'article']">
          <xsl:text>&amp;rft.atitle=</xsl:text><xsl:value-of select="$header/FILEDESC/SOURCEDESC/BIBL/TITLE[@TYPE = 'article']" />
        </xsl:if>

        <!-- rft.jtitle -->
        <xsl:if test="$header/FILEDESC/SOURCEDESC/BIBL/TITLE[@TYPE = 'serial']">
          <xsl:text>&amp;rft.jtitle=</xsl:text><xsl:value-of select="$header/FILEDESC/SOURCEDESC/BIBL/TITLE[@TYPE = 'serial']" />
        </xsl:if>
      </xsl:when>

      <!-- book -->
      <xsl:when test="$genre = 'Book Section' or $genre = 'Edited Book' or $genre = 'Book'">
        <xsl:text>&amp;rft.genre=book</xsl:text>
        <xsl:text>&amp;rft_val_fmt=info:ofi/fmt:kev:mtx:book</xsl:text>

        <!-- rft.atitle -->
        <xsl:if test="$header/FILEDESC/SOURCEDESC/BIBL/TITLE[@TYPE = 'article']">
          <xsl:text>&amp;rft.title=</xsl:text><xsl:value-of select="$header/FILEDESC/SOURCEDESC/BIBL/TITLE[@TYPE = 'article']" />
        </xsl:if>

        <!-- rft.title -->
        <xsl:if test="$header/FILEDESC/SOURCEDESC/BIBL/TITLE[@TYPE = 'serial']">
          <xsl:text>&amp;rft.title=</xsl:text><xsl:value-of select="$header/FILEDESC/SOURCEDESC/BIBL/TITLE[@TYPE = 'serial']" />
        </xsl:if>

        <!-- PUBLISHER PUBPLACE -->
        <xsl:if test="$header/FILEDESC/SOURCEDESC/BIBL/PUBLISHER">
          <!-- <xsl:text>&amp;rft.pub=</xsl:text><xsl:value-of select="$header/FILEDESC/SOURCEDESC/BIBL/PUBLISHER" />
           zotero may have issues with & in the publisher -->

          <xsl:variable name="pub" select="$header/FILEDESC/SOURCEDESC/BIBL/PUBLISHER" />
          <xsl:value-of select="translate($pub, '&amp;', ' ')" />
        </xsl:if>
        <xsl:if test="$header/FILEDESC/SOURCEDESC/BIBL/PUBPLACE">
          <xsl:text>&amp;rft.place=</xsl:text><xsl:value-of select="$header/FILEDESC/SOURCEDESC/BIBL/PUBPLACE" />
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <!-- <xsl:text>&amp;rft.genre=unknown</xsl:text> -->
        <xsl:text>&amp;rft_val_fmt=info:ofi/fmt:kev:mtx:book</xsl:text>

        <xsl:choose>
          <xsl:when test="$header/FILEDESC/SOURCEDESC/BIBL/TITLE[@TYPE = 'article']">
            <xsl:text>&amp;rft.title=</xsl:text><xsl:value-of select="$header/FILEDESC/SOURCEDESC/BIBL/TITLE[@TYPE = 'article']"/>
          </xsl:when>

          <xsl:when test="$header/FILEDESC/SOURCEDESC/BIBL/TITLE[@TYPE = 'serial']">
            <xsl:text>&amp;rft.title=</xsl:text><xsl:value-of select="$header/FILEDESC/SOURCEDESC/BIBL/TITLE[@TYPE = 'serial']"/>
          </xsl:when>
        </xsl:choose>

        <!-- PUBLISHER PUBPLACE -->
        <xsl:if test="$header/FILEDESC/SOURCEDESC/BIBL/PUBLISHER">
          <!-- <xsl:text>&amp;rft.pub=</xsl:text><xsl:value-of select="$header/FILEDESC/SOURCEDESC/BIBL/PUBLISHER" />
           zotero may have issues with & in the publisher -->

          <xsl:variable name="pub" select="$header/FILEDESC/SOURCEDESC/BIBL/PUBLISHER" />
          <xsl:value-of select="translate($pub, '&amp;', ' ')" />
        </xsl:if>
        <xsl:if test="$header/FILEDESC/SOURCEDESC/BIBL/PUBPLACE">
          <xsl:text>&amp;rft.place=</xsl:text><xsl:value-of select="$header/FILEDESC/SOURCEDESC/BIBL/PUBPLACE" />
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>  
</xsl:stylesheet>