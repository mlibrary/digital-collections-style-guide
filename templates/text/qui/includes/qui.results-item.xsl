<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template name="build-item-metadata">
    <xsl:param name="encoding-type" />
    <xsl:param name="item-encoding-level" />
    <xsl:param name="item" select="." />
    <xsl:param name="slot">metadata</xsl:param>
    <xsl:choose>
      <xsl:when test="$encoding-type = 'monograph'">
        <xsl:call-template name="process-monograph">
          <xsl:with-param name="encoding-type" select="$encoding-type" />
          <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
          <xsl:with-param name="is-subj-search" select="$is-subj-search" />
          <xsl:with-param name="slot" select="$slot" />
          <xsl:with-param name="item" select="$item" />
        </xsl:call-template>
      </xsl:when>
      <xsl:when test="$encoding-type = 'serialissue'">
        <xsl:call-template name="process-serialissue">
          <xsl:with-param name="encoding-type" select="$encoding-type" />
          <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
          <xsl:with-param name="is-subj-search" select="$is-subj-search" />
          <xsl:with-param name="slot" select="$slot" />
          <xsl:with-param name="item" select="$item" />
        </xsl:call-template>
      </xsl:when>
      <!-- NEVER GOING TO HAPPEN -->
      <xsl:when test="$encoding-type = 'serialarticle'">
        <xsl:call-template name="process-serial-article">
          <xsl:with-param name="item-encoding-level" xml:base="$item-encoding-level" />
          <xsl:with-param name="slot" select="$slot" />
          <xsl:with-param name="item" select="$item" />
        </xsl:call-template>          
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="process-monograph">
    <xsl:param name="encoding-type" />
    <xsl:param name="item-encoding-level" />
    <xsl:param name="item" select="." />
    <xsl:param name="slot" />

    <xsl:variable name="sourcedesc" select="$item/HEADER/FILEDESC/SOURCEDESC" />
    <xsl:variable name="source-title-path" select="($sourcedesc//TITLESTMT|$sourcedesc/BIBLFULL|$sourcedesc/BIBL)"/>
    <xsl:variable name="filedesc" select="$item/HEADER/FILEDESC" />
    <xsl:variable name="mono-title-path" select="$filedesc/TITLESTMT" />
    <xsl:variable name="bibl-src" select="($sourcedesc/BIBLFULL|$sourcedesc/BIBL)"/>
    <xsl:variable name="source-pub-st-path" select="($bibl-src/PUBLICATIONSTMT|$bibl-src/IMPRINT|$bibl-src)"/>


    <xsl:variable name="main-title">
      <!-- use the 245 title if there is one -->
      <xsl:choose>
        <xsl:when test="$item/HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245']
          and
          contains($item/HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245'], '::')">
          <xsl:value-of select="normalize-space(substring-before($item/HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245'],'/'))"/>
        </xsl:when>
        <xsl:when test="$item/HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245']">
          <xsl:value-of select="$item/HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='245']"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="$item/HEADER/FILEDESC/TITLESTMT/TITLE[not(@TYPE='sort')][1]"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="main-authors">
      <xsl:choose>
        <xsl:when test="$item/HEADER/FILEDESC/TITLESTMT/AUTHOR">
          <xsl:for-each select="$item/HEADER/FILEDESC/TITLESTMT/AUTHOR">
            <xsl:value-of select="." />
            <xsl:if test="following-sibling::AUTHOR">, </xsl:if>
          </xsl:for-each>
        </xsl:when>
        <xsl:when test="$item/HEADER/FILEDESC/TITLESTMT/EDITOR">
          <xsl:for-each select="$item/HEADER/FILEDESC/TITLESTMT/EDITOR">
            <xsl:value-of select="."/>
            <xsl:if test="following-sibling::EDITOR">, </xsl:if>
          </xsl:for-each>
        </xsl:when>
      </xsl:choose>
    </xsl:variable>

    <xsl:variable name="author-count">
      <xsl:value-of select="count($item/HEADER/FILEDESC/TITLESTMT/AUTHOR)"/>
    </xsl:variable>

    <xsl:variable name="inverted-author" select="''"/>

    <xsl:variable name="sort-title">
      <xsl:value-of select="$item/HEADER/FILEDESC/TITLESTMT/TITLE[@TYPE='sort']"/>
    </xsl:variable>

    <xsl:variable name="main-date">
      <xsl:value-of select="$item/HEADER/FILEDESC/SOURCEDESC/BIBLFULL/PUBLICATIONSTMT/DATE"/>
    </xsl:variable>

    <xsl:variable name="edition-stmt">
      <xsl:value-of select="$item/HEADER/FILEDESC//EDITIONSTMT"/>
    </xsl:variable>

    <xsl:variable name="pubinfo-tmp">
      <qui:block>
        <qui:field key="pubinfo">
          <qui:label>
            <xsl:value-of select="key('get-lookup','headerutils.str.publicationinfo')"/>
          </qui:label>
          <qui:values>
            <xsl:apply-templates select="($sourcedesc/BIBLFULL/PUBLICATIONSTMT|$sourcedesc/BIBL)" mode="metadata"/>
          </qui:values>
        </qui:field>
      </qui:block>
    </xsl:variable>
    <xsl:variable name="pubinfo" select="exsl:node-set($pubinfo-tmp)" />

    <xsl:variable name="print-source-tmp">
      <qui:block>
        <xsl:if test="$include-print-source-metadata = 'yes'">
          <qui:field key="print-source">
            <qui:label>
              <xsl:value-of select="key('get-lookup','headerutils.str.printsource')"/>
            </qui:label>
            <qui:values>
              <qui:value>
                <xhtml:em><xsl:value-of select="$source-title-path/TITLE"/></xhtml:em>
              </qui:value>
              <xsl:if test="$source-title-path/TITLE[@TYPE='series']">
                <qui:value>
                  <xsl:value-of select="$source-title-path/TITLE[@TYPE='series']"/>
                </qui:value>
                <qui:value>
                  <xsl:for-each select="$source-title-path/AUTHOR">
                    <xsl:apply-templates select="."/>
                  </xsl:for-each>
                </qui:value>
              </xsl:if>
              <xsl:if test="$mono-title-path/EDITOR">
                <qui:value>
                  <xsl:for-each select="$mono-title-path/EDITOR">
                    <xsl:value-of select="concat(.,', ed.')"/>
                  </xsl:for-each>
                </qui:value>
              </xsl:if>
              <qui:value>
                <xsl:for-each select="$source-pub-st-path/PUBPLACE">
                  <xsl:value-of select="dlxs:stripEndingChars(.,'.,:;')"/>
                  <xsl:if test="position()!=last()">
                    <xsl:text>, </xsl:text>
                  </xsl:if>
                  <xsl:if test="position()=last()">
                    <xsl:text>: </xsl:text>
                  </xsl:if>
                </xsl:for-each>
                <xsl:for-each select="$source-pub-st-path/PUBLISHER">
                  <xsl:value-of select="dlxs:stripEndingChars(.,'.,:;')"/>
                  <xsl:if test="position()!=last()">
                    <xsl:text>, </xsl:text>
                  </xsl:if>
                </xsl:for-each>
              </qui:value>
              <xsl:if test="$source-title-path/BIBLSCOPE[not(@TYPE='issuetitle')]">
                <qui:value>
                  <xsl:apply-templates select="$source-title-path/BIBLSCOPE[not(@TYPE='issuetitle')]"/>
                </qui:value>
              </xsl:if>
              <xsl:if test="$source-pub-st-path/DATE">
                <qui:value part="date">
                  <xsl:value-of select="$source-pub-st-path/DATE[1]"/>
                </qui:value>
              </xsl:if>
              <xsl:if test="$source-title-path/BIBLSCOPE[@TYPE='issuetitle']">
                <qui:value>
                  <xsl:apply-templates select="$source-title-path/BIBLSCOPE[@TYPE='issuetitle']"/>
                </qui:value>                
              </xsl:if>
              <xsl:if test="$source-pub-st-path/IDNO[@TYPE='ISBN']">
                <qui:value>
                  <xsl:call-template name="docISBN">
                    <xsl:with-param name="src-bibl-path" select="$bibl-src"/>
                  </xsl:call-template>  
                </qui:value>
              </xsl:if>
              <xsl:if test="$source-title-path/following-sibling::BIBL">
                <qui:value>
                  <xsl:apply-templates select="$source-title-path/following-sibling::BIBL"/>
                </qui:value>
              </xsl:if>
            </qui:values>
          </qui:field>
        </xsl:if>          
      </qui:block>
    </xsl:variable>    
    <xsl:variable name="print-source" select="exsl:node-set($print-source-tmp)" />

    <!-- <xsl:variable name="subjectinfo-tmp">
      <qui:block>
        <xsl:if test="$is-subj-search='yes' and $item//KEYWORDS/child::TERM">
          <xsl:call-template name="build-res-item-subjects">
            <xsl:with-param name="subj-parent" select="$item"/>
          </xsl:call-template>
        </xsl:if>
      </qui:block>
    </xsl:variable>
    <xsl:variable name="subjectinfo" select="exsl:node-set($subjectinfo-tmp)" /> -->

    <qui:block slot="{$slot}">
      <qui:section>
        <qui:field key="title">
          <qui:label>Title</qui:label>
          <qui:values>
            <qui:value>
              <xsl:value-of select="$main-title" />
            </qui:value>
          </qui:values>
        </qui:field>
        <xsl:if test="normalize-space($main-authors) or normalize-space($inverted-author)">
          <qui:field key="author">
            <qui:label>Author</qui:label>
            <qui:values>
              <qui:value>
                <xsl:choose>
                  <xsl:when test="$inverted-author">
                    <xsl:value-of select="$inverted-author" />
                  </xsl:when>
                  <xsl:when test="$main-authors">
                    <xsl:value-of select="$main-authors" />
                  </xsl:when>
                </xsl:choose>    
              </qui:value>
            </qui:values>
          </qui:field>
        </xsl:if>
        <xsl:if test="false() and normalize-space($main-date)">
          <qui:field key="publication-date">
            <qui:label>Publication Date</qui:label>
            <qui:values>
              <qui:value>
                <xsl:value-of select="translate(dlxs:stripEndingChars($main-date,'.'), '][','')"/>
              </qui:value>
            </qui:values>
          </qui:field>
        </xsl:if>
        <xsl:if test="$pubinfo//qui:value">
          <xsl:apply-templates select="$pubinfo//qui:field" mode="copy" />
        </xsl:if>
        <xsl:if test="$include-useguidelines-metadata = 'yes'">
          <xsl:apply-templates select="$item/HEADER/FILEDESC/PUBLICATIONSTMT/AVAILABILITY" mode="metadata" />
        </xsl:if>
        <xsl:if test="$print-source//qui:value">
          <xsl:apply-templates select="$print-source//qui:field" mode="copy" />
        </xsl:if>
        <xsl:if test="$is-subj-search='yes' and $item//KEYWORDS/child::TERM">
          <xsl:call-template name="build-res-item-subjects">
            <xsl:with-param name="subj-parent" select="$item"/>
          </xsl:call-template>
        </xsl:if>
        <xsl:apply-templates select="$item/CollName" mode="field" />
        <xsl:if test="$include-bookmark = 'yes'">
          <qui:field key="bookmark" component="input">
            <qui:label>Link to this Item</qui:label>
            <qui:values>
              <qui:value>
                <xsl:text>https://name.umdl.umich.edu/</xsl:text>
                <xsl:value-of select="dlxs:downcase(//Param[@name='idno'])" />  
              </qui:value>
            </qui:values>
          </qui:field>
        </xsl:if>
      </qui:section>
    </qui:block>
  </xsl:template>

  <xsl:template name="process-serialissue">
    <xsl:param name="encoding-type" />
    <xsl:param name="item-encoding-level" />
    <xsl:param name="is-subj-search" select="'no'" />
    <xsl:param name="item" select="." />

    <xsl:choose>

      <!-- ********************************************************************** -->
      <!-- branch to filter SERIALISSUE, after regular search, layer 1 results -->
      <!-- ********************************************************************** -->
      <xsl:when test="not ( /Top/DlxsGlobals/CurrentCgi/Param[@name='node'] )
        and
        /Top/DlxsGlobals/CurrentCgi/Param[@name='view'] = 'reslist'
        and
        not( /Top/DlxsGlobals/CurrentCgi/Param[@name='idno'] )" >
        <xsl:call-template name="process-serialissue-for-layer1">
          <xsl:with-param name="item-encoding-level" select="$item-encoding-level"/>
          <xsl:with-param name="is-subj-search" select="$is-subj-search"/>
          <xsl:with-param name="item" select="$item" />
        </xsl:call-template>
      </xsl:when>

      <!-- ********************************************************************** -->
      <!-- branch to filter SERIALISSUE, only one article, layer2 results -->
      <!-- ********************************************************************** -->
      <xsl:when test="/Top/DlxsGlobals/CurrentCgi/Param[@name='node']
        and
        /Top/DlxsGlobals/CurrentCgi/Param[@name='view'] = 'reslist'
        and
        /Top/DlxsGlobals/CurrentCgi/Param[@name='didno'] " >
        <xsl:call-template name="process-serialissue-for-single-article">
          <xsl:with-param name="item-encoding-level" select="$item-encoding-level"/>
          <xsl:with-param name="is-subj-search" select="$is-subj-search"/>
          <xsl:with-param name="item" select="$item" />
        </xsl:call-template>
      </xsl:when>

      <!-- ********************************************************************** -->
      <!-- branch to filter SERIALISSUE, TOC view, multiple article -->
      <!-- ********************************************************************** -->
      <xsl:when test="/Top/DlxsGlobals/CurrentCgi/Param[@name='node']
        and
        /Top/DlxsGlobals/CurrentCgi/Param[@name='view'] = 'toc' " >
        <xsl:call-template name="process-serialissue-for-toc-view">
          <xsl:with-param name="item-encoding-level" select="$item-encoding-level"/>
          <xsl:with-param name="is-subj-search" select="$is-subj-search"/>
          <xsl:with-param name="item" select="$item" />
        </xsl:call-template>
      </xsl:when>

      <!-- ********************************************************************** -->
      <!-- branch to filter SERIALISSUE, result of search within this issue, multiple article -->
      <!-- ********************************************************************** -->
      <xsl:otherwise>
        <xsl:call-template name="process-serialissue-for-multiple-articles">
          <xsl:with-param name="item-encoding-level" select="$item-encoding-level"/>
          <xsl:with-param name="is-subj-search" select="$is-subj-search"/>
          <xsl:with-param name="item" select="$item" />
        </xsl:call-template>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="process-serialissue-for-layer1">
    <xsl:param name="item-encoding-level" />
    <xsl:param name="is-subj-search"/>
    <xsl:param name="item" />
    <xsl:param name="slot" />

    <xsl:variable name="ser-iss-src" select="$item/MainHeader/HEADER/FILEDESC/SOURCEDESC"/>
    <xsl:variable name="article-cite" select="$item/DIV1/Divhead/BIBL"/>

    <xsl:variable name="main-authors">
      <xsl:call-template name="define-main-authors">
        <xsl:with-param name="article-cite" select="$article-cite"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="article-title" select="$article-cite/TITLE"/>

    <qui:block slot="{$slot}">
      <qui:section>
        <qui:field key="title">
          <qui:label>Title</qui:label>
          <qui:values>
            <qui:value>
              <xsl:value-of select="$article-title" />
            </qui:value>
          </qui:values>
        </qui:field>
        <xsl:if test="normalize-space($main-authors)">
          <qui:field key="author">
            <qui:label>Author</qui:label>
            <qui:values>
              <qui:value>
                <xsl:value-of select="$main-authors" />
              </qui:value>
            </qui:values>
          </qui:field>
        </xsl:if>
        <xsl:call-template name="build-pubinfo-for-serialissue">
          <xsl:with-param name="ser-iss-src" select="$ser-iss-src"/>
          <xsl:with-param name="article-cite" select="$article-cite"/>
        </xsl:call-template>
      </qui:section>
    </qui:block>
  </xsl:template>

  <xsl:template name="process-serialissue-for-single-article">
    <xsl:param name="item-encoding-level" />
    <xsl:param name="is-subj-search"/>
    <xsl:param name="item" />
    <xsl:param name="slot" />

    <xsl:variable name="article-cite" select="$item/ItemDetails/DIV1[1]/Divhead/BIBL"/>
    <xsl:variable name="ser-iss-src" select="$item/MainHeader/HEADER/FILEDESC/SOURCEDESC"/>

    <xsl:variable name="main-authors">
      <xsl:call-template name="define-main-authors">
        <xsl:with-param name="article-cite" select="$article-cite"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:variable name="author-count">
      <xsl:call-template name="define-author-count">
        <xsl:with-param name="article-cite" select="$article-cite"/>
      </xsl:call-template>
    </xsl:variable>
    
    <xsl:variable name="article-title" select="$article-cite/TITLE[1]"/>

    <xsl:variable name="subjectinfo">
      <xsl:if test="$is-subj-search='yes' and $item//KEYWORDS/child::TERM">
        <xsl:call-template name="build-res-item-subjects">
          <xsl:with-param name="subj-parent" select="$item"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>

    <qui:debug><xsl:value-of select="name($item)" /></qui:debug>

    <qui:block slot="{$slot}">
      <qui:section>
        <qui:field key="title">
          <qui:label>Title</qui:label>
          <qui:values>
            <qui:value>
              <xsl:value-of select="$article-title" />
            </qui:value>
          </qui:values>
        </qui:field>
        <xsl:if test="normalize-space($main-authors)">
          <qui:field key="author">
            <qui:label>
              <xsl:value-of select="key('get-lookup','headerutils.str.author')"/>
              <xsl:if test="$author-count &gt; 1">
                <xsl:value-of select="key('get-lookup','headerutils.str.plural')"/>
              </xsl:if>  
            </qui:label>
            <qui:values>
              <qui:value>
                <xsl:value-of select="$main-authors" />
              </qui:value>
            </qui:values>
          </qui:field>
        </xsl:if>
        <xsl:call-template name="build-pubinfo-for-serialissue">
          <xsl:with-param name="ser-iss-src" select="$ser-iss-src"/>
          <xsl:with-param name="article-cite" select="$article-cite"/>
        </xsl:call-template>
      </qui:section>
      <xsl:copy-of select="$subjectinfo"/>
    </qui:block>
  </xsl:template>

  <xsl:template name="build-metadata">
    <xsl:param name="main-title" />
    <xsl:param name="sort-title" />
    <xsl:param name="main-authors" />
    <xsl:param name="inverted-author" />
    <xsl:param name="main-date" />
    <xsl:param name="item-encoding-level" />
    <xsl:param name="pubinfo" />
    <xsl:param name="edition-stmt" />
    <xsl:param name="subjectinfo" />
    <qui:title>
      <qui:values>
        <qui:value>
          <xsl:value-of select="$main-title" />
        </qui:value>
      </qui:values>
    </qui:title>
    <qui:block slot="metadata">
      <qui:section>
        <xsl:if test="normalize-space($main-authors) or normalize-space($inverted-author)">
          <qui:field key="author">
            <qui:label>Author</qui:label>
            <qui:values>
              <qui:value>
                <xsl:choose>
                  <xsl:when test="$inverted-author">
                    <xsl:value-of select="$inverted-author" />
                  </xsl:when>
                  <xsl:when test="$main-authors">
                    <xsl:value-of select="$main-authors" />
                  </xsl:when>
                </xsl:choose>    
              </qui:value>
            </qui:values>
          </qui:field>
        </xsl:if>
        <xsl:if test="normalize-space($main-date)">
          <qui:field key="publication-date">
            <qui:label>Publication Date</qui:label>
            <qui:values>
              <qui:value>
                <xsl:value-of select="translate(dlxs:stripEndingChars($main-date,'.'), '][','')"/>
              </qui:value>
            </qui:values>
          </qui:field>
        </xsl:if>
        <xsl:if test="normalize-space($pubinfo)">
          <qui:field key="publication-info">
            <qui:label>
              <xsl:value-of select="key('get-lookup','headerutils.str.publicationinfo')"/>
            </qui:label>
            <qui:values>
              <xsl:apply-templates select="$pubinfo" />
              <!-- <qui:value>
                <xsl:value-of select="$pubinfo" />
              </qui:value> -->
            </qui:values>
          </qui:field>
        </xsl:if>
        <xsl:copy-of select="$subjectinfo"/>
        <xsl:apply-templates select="CollName"/>
      </qui:section>
    </qui:block>
  </xsl:template>

  <xsl:template name="define-main-authors">
    <xsl:param name="article-cite" />
    <xsl:choose>
      <xsl:when test="$article-cite/AUTHORIND">
        <xsl:for-each select="$article-cite/AUTHORIND">
          <!-- may contain DESCRIPs -->
          <xsl:apply-templates select="."/>
          <xsl:if test="position()!=last()">; </xsl:if>
        </xsl:for-each>
      </xsl:when>
      <xsl:when test="$article-cite/AUTHOR and not($article-cite/AUTHORIND)">
        <xsl:for-each select="$article-cite/AUTHOR">
          <!-- may contain DESCRIPs -->
          <xsl:apply-templates select="."/>
          <xsl:if test="position()!=last()">, </xsl:if>
        </xsl:for-each>
      </xsl:when>
    </xsl:choose>    
  </xsl:template>

  <xsl:template name="define-author-count">
    <xsl:param name="article-cite" />
    <xsl:choose>
      <xsl:when test="$article-cite/AUTHORIND">
        <xsl:value-of select="count($article-cite/AUTHOR)"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="count($article-cite/AUTHOR)"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-pubinfo-for-serialissue">
    <xsl:param name="ser-iss-src" />
    <xsl:param name="article-cite" />

    <xsl:variable name="pubinfo-tmp">
      <qui:value>
        <xsl:value-of select="$ser-iss-src/descendant::TITLE[1]"/>
      </qui:value>
      <xsl:if test="$ser-iss-src/BIBL/BIBLSCOPE">
        <qui:value>
          <xsl:apply-templates select="$ser-iss-src/BIBL/BIBLSCOPE"/>
        </qui:value>
      </xsl:if>
      <xsl:if test="$ser-iss-src/descendant::DATE[1][not(@TYPE='sort')]">
        <qui:value>
          <xsl:value-of select="$ser-iss-src/descendant::DATE[1][not(@TYPE='sort')]"/>
        </qui:value>
      </xsl:if>
      <xsl:if test="$article-cite/BIBLSCOPE[@TYPE='pg']  or $article-cite/BIBLSCOPE[@TYPE='pageno'] or 
                  $article-cite/BIBLSCOPE[@TYPE='vol'] or $article-cite/BIBLSCOPE[@TYPE='iss']">
        <qui:value>
          <xsl:apply-templates select="$article-cite/BIBLSCOPE[not(@TYPE='datesort')]"/>
        </qui:value>
      </xsl:if>    
    </xsl:variable>

    <xsl:if test="normalize-space($pubinfo-tmp)">
      <qui:field>
        <qui:label>
          <xsl:value-of select="key('get-lookup','headerutils.str.publicationinfo')"/>
        </qui:label>
        <qui:values>
          <xsl:copy-of select="$pubinfo-tmp" />
        </qui:values>
      </qui:field>  
    </xsl:if>
  </xsl:template>

  <xsl:template match="DetailHref">
    <xsl:if test="not($is-bib-srch='yes') and $is-all-rgn-srch='yes'">
      <qui:link rel="detail" href="{.}">
        <xsl:attribute name="label">
          <xsl:choose>
            <xsl:when test="following-sibling::AuthRequired='true'">
              <xsl:value-of select="key('get-lookup', 'results.str.9')" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="key('get-lookup', 'results.str.10')" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </qui:link>
    </xsl:if>
  </xsl:template>

  <xsl:template match="FirstPageHref">
    <qui:link rel="result" href="{.}" label="{key('get-lookup', 'results.str.18')}" />
  </xsl:template>

  <xsl:template match="TocHref">
    <xsl:param name="item-encoding-level" />
    <qui:link rel="toc" href="{.}">
      <xsl:attribute name="label">
        <xsl:choose>
          <xsl:when test="$item-encoding-level = '1'">
            <!-- <xsl:value-of select="key('get-lookup','results.str.16')"/> -->
            <xsl:value-of select="key('get-lookup','uplift.str.contents')"/>
          </xsl:when>
          <xsl:otherwise>
            <!-- <xsl:value-of select="key('get-lookup','results.str.17')"/> -->
            <xsl:value-of select="key('get-lookup','uplift.str.contents')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
    </qui:link>
  </xsl:template>

  <xsl:template match="ThumbnailLink">
    <qui:link rel="iiif" href="{.}" />
  </xsl:template>

  <xsl:template match="Tombstone">
    <xsl:attribute name="data-tombstone">true</xsl:attribute>
  </xsl:template>

  <xsl:template match="HitSummary">
    <xsl:if test="node() and $is-bib-srch='no' and $is-all-rgn-srch='yes' and child::*">
      <qui:block slot="summary" label="{key('get-lookup','results.str.2')}">
        <xsl:choose>
          <xsl:when test="$searchtype='basic' or $searchtype='proximity'">
            <xsl:call-template name="SimpleHitSumm"/>
          </xsl:when>
          <xsl:when test="$searchtype='boolean'">
            <xsl:call-template name="BooleanHitSumm"/>
          </xsl:when>
        </xsl:choose>
      </qui:block>
    </xsl:if>
  </xsl:template>

  <xsl:template name="SimpleHitSumm">
    <xsl:value-of select="HitCount"/>
    <xsl:value-of select="key('get-lookup','results.str.3')"/>
    <xsl:apply-templates mode="HitSummPl" select="HitCount"/>
    <xsl:value-of select="key('get-lookup','results.str.4')"/>
    <xsl:if test="HitRegionsCount">
      <xsl:value-of select="HitRegionsCount"/>
      <xsl:value-of select="key('get-lookup','results.str.5')"/>
      <xsl:value-of select="AllRegionCount"/>
      <xsl:text>&#xa0;</xsl:text>
    </xsl:if>
    <xsl:value-of select="dlxs:stripEndingChars(HitRegion,'s')"/>
    <xsl:apply-templates mode="HitSummPl" select="AllRegionCount"/>
  </xsl:template>

  <xsl:template name="BooleanHitSumm">
    <xsl:choose>
      <xsl:when test="child::*">
        <xsl:value-of select="HitRegionsCount"/>
        <xsl:value-of select="key('get-lookup','results.str.6')"/>
        <xsl:value-of select="dlxs:stripEndingChars(HitRegion,'s')"/>
        
        <xsl:apply-templates mode="HitSummPl" select="HitRegionsCount"/>
        <xsl:value-of select="key('get-lookup','results.str.7')"/>
        <xsl:value-of select="AllRegionCount"/>
        <xsl:value-of select="key('get-lookup','results.str.8')"/>
        <xsl:value-of select="dlxs:stripEndingChars(HitRegion,'s')"/>
        <xsl:apply-templates mode="HitSummPl" select="AllRegionCount"/>
      </xsl:when>
    </xsl:choose>
  </xsl:template>  

  <xsl:template match="*" mode="HitSummPl">
    <xsl:choose>
      <xsl:when test=".!=1">
        <xsl:if test="name()='HitCount'">
          <xsl:value-of select="key('get-lookup','results.str.31')"/>
        </xsl:if>
        <xsl:value-of select="key('get-lookup','results.str.32')"/>
      </xsl:when>
      <xsl:otherwise/>
    </xsl:choose>
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- RESITEMSUBJECTS -->
  <!-- ********************************************************************** -->
  <xsl:template name="build-res-item-subjects">
    <xsl:param name="subj-parent"/>
    <xsl:variable name="scount" select="count($subj-parent//KEYWORDS/child::TERM)"/>
    <xsl:variable name="label">
      <xsl:value-of select="key('get-lookup','headerutils.str.subjectterms')"/>
    </xsl:variable>
    <xsl:variable name="plural">
      <xsl:if test="false() and not($scount = 1)">
        <xsl:value-of select="key('get-lookup','results.str.32')"/>
      </xsl:if>
    </xsl:variable>
    <xsl:if test="$scount &gt; 0">
      <qui:field key="subjects">
        <qui:label><xsl:value-of select="concat($label,$plural)"/></qui:label>
        <qui:values>
          <xsl:for-each select="$subj-parent//KEYWORDS/TERM[not(@TYPE) or @TYPE='subject']">
            <qui:value>
              <xsl:value-of select="." />
              <!-- <xsl:value-of select="concat('[',dlxs:stripEndingChars(.,'.,:;'),']')"/> -->
            </qui:value>
            </xsl:for-each>
        </qui:values>
      </qui:field>  
    </xsl:if>
  </xsl:template>

  <xsl:template match="IMPRINT|PUBLICATIONSTMT" mode="metadata--values">
    <xsl:for-each select="PUBPLACE">
      <qui:value><xsl:value-of select="." /></qui:value>
    </xsl:for-each>
    <xsl:for-each select="PUBLISHER">
      <qui:value><xsl:value-of select="." /></qui:value>
    </xsl:for-each>
    <!-- date? -->
  </xsl:template>

  <xsl:template match="BIBL" mode="metadata">
    <qui:value><xsl:value-of select="." /></qui:value>
  </xsl:template>

  <xsl:template match="IMPRINT|PUBLICATIONSTMT[PUBLISHER != 'unpublished']" mode="metadata">
    <qui:value>
      <xsl:for-each select="PUBPLACE">
        <xsl:value-of select="dlxs:stripEndingChars(.,'.,:;')"/>
        <xsl:if test="position()!=last()">
          <xsl:text>,&#xa0;</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:text>.&#xa0;</xsl:text>
      <xsl:for-each select="PUBLISHER">
        <xsl:value-of select="dlxs:stripEndingChars(.,'.,:;')"/>
        <xsl:if test="position()!=last()">
          <xsl:text>,&#xa0;</xsl:text>
        </xsl:if>
        <xsl:if test="position()=last()">
          <xsl:text>.&#xa0;</xsl:text>
        </xsl:if>
      </xsl:for-each>
      <xsl:apply-templates select="DATE"/>
    </qui:value>
  </xsl:template>

  <!-- ********************************************************************** -->
  <!-- BIBLSCOPE -->
  <!-- ********************************************************************** -->
  <xsl:template match="BIBLSCOPE">
    <xsl:choose>
      <xsl:when test="@TYPE='vol'">
        <xsl:value-of select="key('get-lookup','headerutils.str.volume')"/>
        <xsl:text>:&#xa0;</xsl:text>
      </xsl:when>
      <xsl:when test="@TYPE='volno'">
        <xsl:value-of select="key('get-lookup','headerutils.str.abbrevvolume')"/>
        <xsl:text>&#xa0;</xsl:text>
      </xsl:when>
      <xsl:when test="@TYPE='iss'">
        <xsl:value-of select="key('get-lookup','headerutils.str.18')"/>
        <xsl:text>:&#xa0;</xsl:text>
      </xsl:when>
      <xsl:when test="@TYPE='issno'">
        <xsl:value-of select="key('get-lookup','headerutils.str.abbrevnumber')"/>
        <xsl:text>&#xa0;</xsl:text>
      </xsl:when>
      <xsl:when test="@TYPE='pg'">
        <xsl:value-of select="concat(key('get-lookup','headerutils.str.abbrevpages'),'&#xa0;')"/>
      </xsl:when>
      <xsl:when test="@TYPE='pageno'">
        <xsl:value-of select="concat(key('get-lookup','headerutils.str.abbrevpages'),'&#xa0;')"/>
      </xsl:when>
      <xsl:when test="@TYPE='col'">
        <xsl:value-of select="concat(key('get-lookup','headerutils.str.25'),'&#xa0;')"/>
      </xsl:when>
      <xsl:when test="@TYPE='issuetitle'">
        <xsl:value-of select="concat(key('get-lookup','headerutils.str.issue.title'),'&#xa0;')"/>
      </xsl:when>
    </xsl:choose>
    <xsl:if test="@TYPE != 'ser'">
      <xsl:call-template name="stripleadingzeros">
        <xsl:with-param name="str" select="."/>
      </xsl:call-template>
      <xsl:if test="following-sibling::BIBLSCOPE[not(@TYPE='issuetitle')]">, </xsl:if>
    </xsl:if>
  </xsl:template>  

  <xsl:template match="CollName" mode="field">
    <qui:field key="collection">
      <qui:label>Collection</qui:label>
      <qui:values>
        <qui:value>
          <!-- should this be a link? -->
          <xsl:value-of select="." />
        </qui:value>
      </qui:values>
    </qui:field>
  </xsl:template>

  <xsl:template match="AVAILABILITY" mode="metadata">
    <qui:field key="useguidelines">
      <qui:label>
        <xsl:value-of select="key('get-lookup', 'headerutils.str.22')" />
      </qui:label>
      <qui:values>
        <qui:value>
          <xsl:apply-templates select="." />
        </qui:value>
      </qui:values>
    </qui:field>
  </xsl:template>

  <xsl:template match="AVAILABILITY/P">
    <xhtml:p>
      <xsl:apply-templates mode="copy-guts" />
    </xhtml:p>    
  </xsl:template>

  <xsl:template match="AVAILABILITY/P[@TYPE='license']" priority="99">
    <xsl:choose>
      <xsl:when test=".='No Copyright'">
        <xhtml:p>
          <xhtml:strong>Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xhtml:a href="https://creativecommons.org/publicdomain/mark/1.0/">No Copyright</xhtml:a>
        </xhtml:p>
      </xsl:when>
      <xsl:when test=".='No Copyright - United States'">
        <xhtml:p>
          <xhtml:strong>DPLA Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xhtml:a href="http://rightsstatements.org/vocab/NoC-US/1.0/">No Copyright - United  States</xhtml:a>
        </xhtml:p>
      </xsl:when>
      <xsl:when test=".='In Copyright'">
        <xhtml:p>
          <xhtml:strong>DPLA Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xhtml:a href="https://rightsstatements.org/page/InC/1.0/">In Copyright</xhtml:a>
        </xhtml:p>
      </xsl:when>
      <xsl:when test=".='Copyright Not Evaluated'">
        <xhtml:p>
          <xhtml:strong>DPLA Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xhtml:a href="http://rightsstatements.org/vocab/CNE/1.0/">Copyright Not Evaluated</xhtml:a>
        </xhtml:p>
      </xsl:when>
      <xsl:otherwise>
        <xhtml:p>
          <xhtml:strong>Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xsl:value-of select="."/>
        </xhtml:p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  <xsl:template match="AVAILABILITY/P[@TYPE='DPLA']" priority="99">
    <xsl:choose>
      <xsl:when test=".='No Copyright - United States'">
        <xhtml:p>
          <xhtml:strong>DPLA Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xhtml:a href="http://rightsstatements.org/vocab/NoC-US/1.0/">No Copyright - United  States</xhtml:a>
        </xhtml:p>
      </xsl:when>
      <xsl:when test=".='Copyright Not Evaluated'">
        <xhtml:p>
          <xhtml:strong>DPLA Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xhtml:a href="http://rightsstatements.org/vocab/CNE/1.0/">Copyright Not Evaluated</xhtml:a>
        </xhtml:p>
      </xsl:when>
      <xsl:otherwise>
        <xhtml:p>
          <xhtml:strong>DPLA Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xsl:value-of select="."/>
        </xhtml:p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
</xsl:stylesheet>