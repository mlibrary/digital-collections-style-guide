<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="exsl str">
  <xsl:variable name="add-biblscope-to-serialissue-title" select="false()" />

  <xsl:template name="build-header-metadata">
    <xsl:param name="encoding-type" />
    <xsl:param name="item-encoding-level" />
    <xsl:param name="item" />
    <xsl:param name="slot">item</xsl:param>
    
    <qui:metadata slot="{$slot}"
      item-encoding-level="{$item-encoding-level}"
      encoding-type="{$encoding-type}"
      root="{name($item)}">

      <xsl:choose>
        <xsl:when test="$encoding-type = 'monograph'">
          <xsl:call-template name="build-metadata-fields-for-monograph">
            <xsl:with-param name="item" select="$item" />
          </xsl:call-template>
        </xsl:when>
        <xsl:when test="$encoding-type = 'serialissue'">
          <xsl:call-template name="build-metadata-fields-for-serialissue">
            <xsl:with-param name="item" select="$item" />
          </xsl:call-template>
        </xsl:when>
      </xsl:choose>

      <xsl:apply-templates select="$item//CollName" mode="field" />

      <xsl:if test="$include-bookmark = 'yes'">
        <qui:field key="bookmark" component="input">
          <qui:label>Link to this Item</qui:label>
          <qui:values>
            <qui:value>
              <xsl:text>https://name.umdl.umich.edu/</xsl:text>
              <xsl:choose>
                <xsl:when test="//Param[@name='node']">
                  <xsl:value-of select="//Param[@name='node']" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:value-of select="dlxs:downcase(//Param[@name='idno'])" />  
                </xsl:otherwise>
              </xsl:choose>
            </qui:value>
          </qui:values>
        </qui:field>
      </xsl:if>

    </qui:metadata>

  </xsl:template>

  <!-- core templates, maybe -->
  <!-- MONOGRAPH -->
  <xsl:template name="build-title-for-monograph">
    <xsl:param name="item" />
    <xsl:variable name="titlestmt" select="($item/ItemHeader|$item)/HEADER/FILEDESC/TITLESTMT" />
    <xsl:apply-templates select="$titlestmt" mode="process-title" />
  </xsl:template>

  <xsl:template name="build-author-for-monograph">
    <xsl:param name="item" />
    <xsl:variable name="titlestmt" select="($item/ItemHeader|$item)/HEADER/FILEDESC/TITLESTMT" />
    <xsl:apply-templates select="$titlestmt" mode="process-author" />
  </xsl:template>

  <xsl:template name="build-editor-for-monograph">
    <xsl:param name="item" />
    <xsl:variable name="titlestmt" select="($item/ItemHeader|$item)/HEADER/FILEDESC/TITLESTMT" />
    <xsl:apply-templates select="$titlestmt" mode="process-editor" />
  </xsl:template>

  <xsl:template name="build-pubinfo-for-monograph">
    <xsl:param name="item" />
    <xsl:apply-templates select="($item/ItemHeader|$item)/HEADER/FILEDESC/SOURCEDESC" mode="process-pubinfo" />
  </xsl:template>

  <!-- SERIAL ISSUE : ISSUE -->

  <xsl:template name="build-title-for-serialissue-issue">
    <xsl:param name="item" />
    <!-- <xsl:variable name="bibl" select="$item/ItemDetails/DIV1/BIBL" /> -->
    <xsl:variable name="bibl" select="$item/DIV1//BIBL" />
    <xsl:apply-templates select="$bibl" mode="process-title">
      <xsl:with-param name="add-biblscope" select="false()" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="build-author-for-serialissue-issue">
    <xsl:param name="item" />
    <xsl:variable name="bibl" select="$item/DIV1//BIBL" />
    <xsl:apply-templates select="$bibl" mode="process-author" />
  </xsl:template>

  <xsl:template name="build-serial-for-serialissue-issue">
    <xsl:param name="item" />
    <xsl:apply-templates select="$item/MainHeader/HEADER/FILEDESC" mode="process-title">
      <xsl:with-param name="key">serial</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="build-pubinfo-for-serialissue-issue">
    <xsl:param name="item" />
    <xsl:call-template name="process-pubinfo-for-serialissue">
      <xsl:with-param name="bibl" select="$item/DIV1//BIBL" />
      <xsl:with-param name="header" select="$item/MainHeader/HEADER" />
    </xsl:call-template>
  </xsl:template>

  <!-- SERIAL ISSUE : ARTICLE -->

  <xsl:template name="build-title-for-serialissue-article">
    <xsl:param name="item" />
    <!-- <xsl:variable name="bibl" select="$item/ItemDetails/DIV1/BIBL" /> -->
    <xsl:variable name="bibl" select="($item/ItemDetails|$item/ItemDivhead)/DIV1//BIBL" />
    <xsl:apply-templates select="$bibl" mode="process-title">
      <xsl:with-param name="add-biblscope" select="false()" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="build-author-for-serialissue-article">
    <xsl:param name="item" />
    <xsl:variable name="bibl" select="($item/ItemDetails|$item/ItemDivhead)/DIV1//BIBL" />
    <xsl:apply-templates select="$bibl" mode="process-author" />
  </xsl:template>

  <xsl:template name="build-serial-for-serialissue-article">
    <xsl:param name="item" />
    <xsl:apply-templates select="($item/MainHeader|$item/ItemHeader)/HEADER/FILEDESC" mode="process-title">
      <xsl:with-param name="key">serial</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="build-pubdate-for-serialissue-article">
    <xsl:param name="item" />
    <xsl:variable name="bibl" select="($item/ItemDetails|$item/ItemDivhead)/DIV1//BIBL" />
    <xsl:apply-templates select="$bibl" mode="process-pubdate" />
  </xsl:template>

  <xsl:template name="build-pubinfo-for-serialissue-article">
    <xsl:param name="item" />
    <xsl:call-template name="process-pubinfo-for-serialissue">
      <xsl:with-param name="bibl" select="$item/ItemDetails/DIV1//BIBL" />
      <xsl:with-param name="header" select="$item/MainHeader/HEADER" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-title-for-serialissue-node">
    <xsl:param name="item" />
    <!-- <xsl:variable name="bibl" select="$item/ItemDetails/DIV1/BIBL" /> -->
    <xsl:variable name="bibl" select="$item/descendant-or-self::node()[@NODE]//BIBL" />
    <xsl:apply-templates select="$bibl" mode="process-title">
      <xsl:with-param name="add-biblscope" select="false()" />
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="build-author-for-serialissue-node">
    <xsl:param name="item" />
    <xsl:variable name="bibl" select="$item/descendant-or-self::node()[@NODE]//BIBL" />
    <xsl:apply-templates select="$bibl" mode="process-author" />
  </xsl:template>

  <xsl:template name="build-serial-for-serialissue-node">
    <xsl:param name="item" />
    <xsl:apply-templates select="$item/MainHeader/HEADER/FILEDESC" mode="process-title">
      <xsl:with-param name="key">serial</xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>

  <xsl:template name="build-pubinfo-for-serialissue-node">
    <xsl:param name="item" />
    <xsl:call-template name="process-pubinfo-for-serialissue">
      <xsl:with-param name="header" select="$item/ancestor-or-self::Item/MainHeader/HEADER" />
      <xsl:with-param name="bibl" select="$item/descendant-or-self::node()//BIBL" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-useguidelines-for-monograph">
    <xsl:param name="item" />
    <xsl:apply-templates select="($item/ItemHeader|$item)/HEADER/FILEDESC/PUBLICATIONSTMT/AVAILABILITY" mode="metadata" />
  </xsl:template>

  <xsl:template name="build-useguidelines-for-serialissue">
    <xsl:param name="item" />
    <xsl:apply-templates select="$item//HEADER/FILEDESC/PUBLICATIONSTMT/AVAILABILITY" mode="metadata" />
  </xsl:template>

  <xsl:template name="build-subjects-for-monograph">
    <xsl:param name="item" />
    <xsl:if test="$item//KEYWORDS/child::TERM">
      <xsl:call-template name="build-res-item-subjects">
        <xsl:with-param name="subj-parent" select="$item"/>
      </xsl:call-template>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-subjects-for-serialarticle">
    <xsl:param name="item" />
    <xsl:call-template name="build-subjects-for-monograph">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-canvas-for-monograph">
    <xsl:param name="item" />
    <xsl:call-template name="build-canvas-for-serialissue">
      <xsl:with-param name="item" select="$item" />
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-canvas-for-serialissue">
    <xsl:param name="item" />
    <xsl:if test="normalize-space(/Top/DocContent/DocSource/SourceUrl)">
      <xsl:call-template name="build-field">
        <xsl:with-param name="key">canvas</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:choose>
            <xsl:when test="normalize-space($label/PageNumber) and $label/PageNumber != 'viewer.nopagenum'">
              <qui:span data-key="canvas-label">
                <xsl:value-of select="key('get-lookup', 'headerutils.str.page')" />
                <xsl:value-of select="$label/PageNumber" />
                <xsl:if test="$label/PageType != 'viewer.ftr.uns'">
                  <xsl:text> - </xsl:text>
                  <xsl:value-of select="key('get-lookup', $label/PageType)" />
                </xsl:if>  
              </qui:span>
            </xsl:when>
            <xsl:when test="normalize-space($seq)">
              <qui:span data-key="canvas-label">
                <xsl:value-of select="key('get-lookup', 'headerutils.str.page')" />
                <xsl:text> #</xsl:text>
                <xsl:value-of select="//CurrentCgi/Param[@name='seq']" />
                <xsl:if test="$label/PageType != 'viewer.ftr.uns'">
                  <xsl:text> - </xsl:text>
                  <xsl:value-of select="key('get-lookup', $label/PageType)" />
                </xsl:if>
              </qui:span>  
            </xsl:when>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>
    </xsl:if>    
  </xsl:template>

  <!-- processing-->
  <xsl:template name="build-field">
    <xsl:param name="key" />
    <xsl:param name="label" />
    <xsl:param name="value" />
    <xsl:variable name="value-type" select="exsl:object-type($value)" />
    <xsl:variable name="lookup-key">
      <xsl:choose>
        <xsl:when test="contains($key, '.')">
          <xsl:value-of select="$key" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="concat('uplift.header.str.', $key)" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:if test="normalize-space($value)">
      <qui:field key="{$key}">
        <xsl:if test="key('get-lookup', $lookup-key)
                      or normalize-space($label)">
          <qui:label>
            <xsl:choose>
              <xsl:when test="normalize-space($label)">
                <xsl:value-of select="$label" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="key('get-lookup', $lookup-key)" />
              </xsl:otherwise>
            </xsl:choose>
          </qui:label>              
        </xsl:if>
        <qui:values debug="{$value-type}">
          <xsl:choose>
            <xsl:when test="$value-type = 'node-set'">
              <xsl:apply-templates select="$value" mode="build-field-value" />
            </xsl:when>
            <xsl:when test="$value-type = 'RTF'">
              <xsl:apply-templates select="exsl:node-set($value)" mode="build-field-value" />
            </xsl:when>
            <xsl:otherwise>
              <qui:value><xsl:value-of select="$value" /></qui:value>
            </xsl:otherwise>
          </xsl:choose>
        </qui:values>
      </qui:field>  
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:value" mode="build-field-value">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="node()" mode="build-field-value">
    <qui:value name="{name()}">
      <xsl:apply-templates select="." mode="copy-field-value" />
    </qui:value>
  </xsl:template>

  <xsl:template match="*[name()='Value']" mode="copy-field-value" priority="101">
    <xsl:value-of select="." />
  </xsl:template>

  <xsl:template match="qui:span" mode="copy-field-value">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </xsl:copy>
  </xsl:template>

  <xsl:template match="text()" mode="copy-field-value" priority="0.5">
    <xsl:copy>
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:attribute name="debug">wtf</xsl:attribute>
      <xsl:apply-templates mode="copy" />
    </xsl:copy>
  </xsl:template>

  <!-- <xsl:template name="build-main-title-for-monograph">
    <xsl:param name="item" />
    <xsl:call-template name="build-field">
      <xsl:with-param name="key">title</xsl:with-param>
      <xsl:with-param name="value">
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
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template> -->

  <xsl:template match="TITLESTMT" mode="process-title">
    <xsl:call-template name="build-field">
      <xsl:with-param name="key">title</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:choose>
          <xsl:when test="TITLE[@TYPE='245']
            and
            contains(TITLE[@TYPE='245'], '::')">
            <xsl:value-of select="normalize-space(substring-before(TITLE[@TYPE='245'],'::'))"/>
          </xsl:when>
          <xsl:when test="TITLE[@TYPE='245']">
            <xsl:value-of select="TITLE[@TYPE='245']"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="TITLE[not(@TYPE='sort')][1]"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template name="build-contributor-list-for-monograph">
    <xsl:param name="key"/>
    <xsl:param name="values" />
    <xsl:if test="normalize-space($values)">
      <xsl:call-template name="build-field">
        <xsl:with-param name="key" select="$key" />
        <xsl:with-param name="value">
          <xsl:for-each select="$values">
            <xsl:value-of select="."/>
            <xsl:if test="position() &lt; last()">, </xsl:if>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>  
    </xsl:if>
  </xsl:template>

  <xsl:template match="TITLESTMT" mode="process-author">
    <xsl:if test="normalize-space(AUTHOR) or normalize-space(AUTHORIND)">
      <xsl:call-template name="build-field">
        <xsl:with-param name="key">author</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:choose>
            <xsl:when test="AUTHORIND">
              <xsl:for-each select="AUTHORIND">
                <xsl:value-of select="."/>
                <xsl:if test="position() &lt; last()">, </xsl:if>    
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="AUTHOR">
              <xsl:for-each select="AUTHOR">
                <xsl:value-of select="."/>
                <xsl:if test="position() &lt; last()">, </xsl:if>    
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>    
    </xsl:if>  
  </xsl:template>

  <xsl:template match="TITLESTMT" mode="process-editor">
    <xsl:if test="normalize-space(EDITOR) or normalize-space(EDITORIND)">
      <xsl:call-template name="build-field">
        <xsl:with-param name="key">editor</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:choose>
            <xsl:when test="EDITORIND">
              <xsl:for-each select="EDITORIND">
                <xsl:value-of select="."/>
                <xsl:if test="position() &lt; last()">, </xsl:if>    
              </xsl:for-each>
            </xsl:when>
            <xsl:when test="EDITOR">
              <xsl:for-each select="EDITOR">
                <xsl:value-of select="."/>
                <xsl:if test="position() &lt; last()">, </xsl:if>    
              </xsl:for-each>
            </xsl:when>
          </xsl:choose>
        </xsl:with-param>
      </xsl:call-template>    
    </xsl:if>  
  </xsl:template>

  <!-- <xsl:template name="build-publication-info-for-monograph">
    <xsl:param name="source" />
    <xsl:variable name="bibl-source" select="($source/BIBLFULL|$source/BIBL)" />
    <xsl:variable name="pubstatement-source" select="($bibl-source/PUBLICATIONSTMT|$bibl-source/IMPRINT)" />
    <xsl:call-template name="build-field">
      <xsl:with-param name="key">publicationinfo</xsl:with-param>
      <xsl:with-param name="value">
        <qui:value>
          <xsl:value-of select="$pubstatement-source/PUBPLACE" />
          <xsl:text>: </xsl:text>
          <xsl:value-of select="$pubstatement-source/PUBLISHER" />
        </qui:value>
        <xsl:apply-templates select="$pubstatement-source/SERIES[1]" mode="metadata-value" />
        <xsl:apply-templates select="$pubstatement-source/DATE[not(@TYPE='sort')][1]" mode="metadata-value" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template> -->

  <xsl:template match="SOURCEDESC" mode="process-pubinfo">
    <xsl:variable name="bibl-source" select="(BIBLFULL|BIBL)" />
    <xsl:variable name="pubstatement-source" select="($bibl-source/PUBLICATIONSTMT|$bibl-source/IMPRINT)" />
    <xsl:call-template name="build-field">
      <xsl:with-param name="key">pubinfo</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:variable name="pubplace" select="normalize-space($pubstatement-source/PUBPLACE)" />
        <xsl:variable name="publisher" select="normalize-space($pubstatement-source/PUBLISHER)" />
        <xsl:choose>
          <xsl:when test="$pubplace and $publisher">
            <qui:value>
              <xsl:value-of select="$pubplace" />
              <xsl:text>: </xsl:text>
              <xsl:value-of select="$publisher" />
            </qui:value>
          </xsl:when>
          <xsl:when test="$pubplace">
            <qui:value>
              <xsl:value-of select="$pubplace" />
            </qui:value>
          </xsl:when>
          <xsl:when test="$publisher">
            <qui:value>
              <xsl:value-of select="$publisher" />
            </qui:value>
          </xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
        <xsl:apply-templates select="$pubstatement-source/SERIES[1]" mode="metadata-value" />
        <xsl:apply-templates select="$pubstatement-source/DATE[not(@TYPE='sort')][1]" mode="metadata-value" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="FILEDESC|SOURCEDESC" mode="process-title">
    <xsl:param name="key">title</xsl:param>
    <xsl:call-template name="build-field">
      <xsl:with-param name="key" select="$key" />
      <xsl:with-param name="value">
        <xsl:choose>
          <xsl:when test="TITLESTMT/TITLE[@TYPE='245']">
            <xsl:apply-templates select="TITLESTMT/TITLE[@TYPE='245']" mode="build-list" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="TITLESTMT/TITLE[not(@TYPE='sort')][1]" mode="build-list" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>  
  </xsl:template>

  <xsl:template match="BIBL" mode="process-title">
    <xsl:param name="add-biblscope" select="true()" />
    <xsl:call-template name="build-field">
      <xsl:with-param name="key">title</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:value-of select="TITLE[1]" />
        <xsl:if test="$add-biblscope and BIBLSCOPE">
          <xsl:text> [</xsl:text>
          <xsl:apply-templates select="$article-cite/BIBLSCOPE"/>
          <xsl:text>]</xsl:text>
        </xsl:if>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="BIBL" mode="process-author">
    <xsl:call-template name="build-field">
      <xsl:with-param name="key">author</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:choose>
          <xsl:when test="AUTHORIND">
            <xsl:for-each select="AUTHORIND">
              <Value><xsl:value-of select="." /></Value>
            </xsl:for-each>
          </xsl:when>
          <xsl:when test="AUTHOR">
            <xsl:for-each select="AUTHOR">
              <Value><xsl:value-of select="." /></Value>
            </xsl:for-each>
          </xsl:when>
        </xsl:choose>
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="BIBL" mode="process-pubdate">
    <xsl:call-template name="build-field">
      <xsl:with-param name="key">pubdate</xsl:with-param>
      <xsl:with-param name="value">
        <xsl:value-of select="BIBLSCOPE[@TYPE='mo']" />
        <xsl:text> </xsl:text>
        <xsl:value-of select="BIBLSCOPE[@TYPE='year']" />
      </xsl:with-param>
    </xsl:call-template>
  </xsl:template>

  <xsl:template match="NOTESSTMT" mode="process-notesstmt">
    <xsl:if test="normalize-space(NOTE)">
      <xsl:call-template name="build-field">
        <xsl:with-param name="key">note</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:for-each select="NOTE">
            <Value><xsl:value-of select="." /></Value>
          </xsl:for-each>
        </xsl:with-param>
      </xsl:call-template>  
    </xsl:if>
  </xsl:template>
  
  <xsl:template name="process-pubinfo-for-serialissue">
    <xsl:param name="bibl" />
    <xsl:param name="header" />

    <xsl:variable name="article-cite" select="$bibl" />

    <xsl:variable name="pubinfo-tmp">
      <xsl:if test="$header">
        <xsl:variable name="ser-iss-src" select="$header/FILEDESC/SOURCEDESC" />
        <xsl:if test="$ser-iss-src and $ser-iss-src/descendant::TITLE[1]">
          <qui:value>
            <xsl:value-of select="$ser-iss-src/descendant::TITLE[1]"/>
          </qui:value>
        </xsl:if>
        <xsl:if test="$ser-iss-src and $ser-iss-src/BIBL/BIBLSCOPE">
          <qui:value>
            <xsl:apply-templates select="$ser-iss-src/BIBL/BIBLSCOPE"/>
          </qui:value>
        </xsl:if>
        <xsl:if test="$ser-iss-src and $ser-iss-src/descendant::DATE[1][not(@TYPE='sort')]">
          <qui:value>
            <xsl:value-of select="$ser-iss-src/descendant::DATE[1][not(@TYPE='sort')]"/>
          </qui:value>
        </xsl:if>
      </xsl:if>
      <xsl:if test="$article-cite/BIBLSCOPE[@TYPE='pg']  or $article-cite/BIBLSCOPE[@TYPE='pageno'] or 
                  $article-cite/BIBLSCOPE[@TYPE='vol'] or $article-cite/BIBLSCOPE[@TYPE='iss']">
        <qui:value>
          <xsl:apply-templates select="$article-cite/BIBLSCOPE[not(@TYPE='datesort')]"/>
        </qui:value>
      </xsl:if>    
    </xsl:variable>

    <xsl:if test="normalize-space($pubinfo-tmp)">
      <qui:field key="printsource">
        <qui:label>
          <xsl:value-of select="key('get-lookup','uplift.header.str.printsource')"/>
        </qui:label>
        <qui:values>
          <xsl:copy-of select="$pubinfo-tmp" />
        </qui:values>
      </qui:field>  
    </xsl:if>
  </xsl:template>

  <!-- TEI -->
  <xsl:template match="DetailHref">
    <qui:debug key="not-is-bib-srch"><xsl:value-of select="not($is-bib-srch='yes')" /></qui:debug>
    <qui:debug key="is-alla-rgn-srch"><xsl:value-of select="$is-all-rgn-srch" /></qui:debug>
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
    <xsl:if test="$is-bib-srch='no' and $is-all-rgn-srch='yes'">
      <xsl:choose>
        <xsl:when test="node() and child::*">
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
        </xsl:when>
        <xsl:otherwise>
          <qui:block slot="summary" label="{key('get-lookup','results.str.2')}">
            <span>View matches in item</span>
          </qui:block>    
        </xsl:otherwise>
      </xsl:choose>
    </xsl:if>
  </xsl:template>

  <xsl:template match="HitSummary" mode="v1">
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
    <xsl:if test="node()">
      <qui:debug>WTF</qui:debug>
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

  <!-- ********************************************************************** -->
  <!-- BIBLSCOPE -->
  <!-- ********************************************************************** -->
  <xsl:template match="BIBLSCOPE">
    <xsl:choose>
      <xsl:when test="@TYPE='vol'">
        <xsl:value-of select="key('get-lookup','headerutils.str.volume')"/>
        <xsl:text>: </xsl:text>
      </xsl:when>
      <xsl:when test="@TYPE='volno'">
        <xsl:value-of select="key('get-lookup','headerutils.str.abbrevvolume')"/>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="@TYPE='iss'">
        <xsl:value-of select="key('get-lookup','headerutils.str.18')"/>
        <xsl:text>: </xsl:text>
      </xsl:when>
      <xsl:when test="@TYPE='issno'">
        <xsl:value-of select="key('get-lookup','headerutils.str.abbrevnumber')"/>
        <xsl:text> </xsl:text>
      </xsl:when>
      <xsl:when test="@TYPE='pg'">
        <xsl:value-of select="concat(key('get-lookup','headerutils.str.abbrevpages'),' ')"/>
      </xsl:when>
      <xsl:when test="@TYPE='pageno'">
        <xsl:value-of select="concat(key('get-lookup','headerutils.str.abbrevpages'),' ')"/>
      </xsl:when>
      <xsl:when test="@TYPE='col'">
        <xsl:value-of select="concat(key('get-lookup','headerutils.str.25'),' ')"/>
      </xsl:when>
      <xsl:when test="@TYPE='issuetitle'">
        <xsl:value-of select="concat(key('get-lookup','headerutils.str.issue.title'),' ')"/>
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

  <xsl:template match="node()" mode="metadata-value">
    <xsl:if test="normalize-space(.)">
      <Value><xsl:value-of select="." /></Value>
    </xsl:if>
  </xsl:template>

  <xsl:template match="AVAILABILITY/P">
    <xhtml:p>
      <xsl:apply-templates mode="copy-guts" />
    </xhtml:p>    
  </xsl:template>

  <xsl:template match="AVAILABILITY/P[contains(., 'The University of Michigan Library provides access')]" priority="99">
    <xsl:choose>
      <xsl:when test="contains(., 'believed to be in the public domain')">
        <xsl:apply-templates select="key('get-statement', 'u-m-research-access-believed')" mode="copy-guts" />
      </xsl:when>
      <xsl:when test="contains(., 'may be under copyright')">
        <xsl:apply-templates select="key('get-statement', 'u-m-research-access-copyright')" mode="copy-guts" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="key('get-statement', 'u-m-research-access-pd')" mode="copy-guts" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="AVAILABILITY/P[@TYPE='license']" priority="99">
    <xsl:choose>
      <xsl:when test=".='No Copyright'">
        <xsl:apply-templates select="//RightsStatement[@key='dpla-no-copyright']" mode="copy-guts" />
        <!-- <xhtml:p>
          <xhtml:strong>Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xhtml:a href="https://creativecommons.org/publicdomain/mark/1.0/">No Copyright</xhtml:a>
        </xhtml:p> -->
      </xsl:when>
      <xsl:when test=".='No Copyright - United States'">
        <xsl:apply-templates select="//RightsStatement[@key='dpla-no-copyright-us']" mode="copy-guts" />
        <!-- <xhtml:p>
          <xhtml:strong>DPLA Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xhtml:a href="http://rightsstatements.org/vocab/NoC-US/1.0/">No Copyright - United  States</xhtml:a>
        </xhtml:p> -->
      </xsl:when>
      <xsl:when test=".='In Copyright'">
        <xsl:apply-templates select="//RightsStatement[@key='dpla-in-copyright']" mode="copy-guts" />
        <!-- <xhtml:p>
          <xhtml:strong>DPLA Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xhtml:a href="https://rightsstatements.org/page/InC/1.0/">In Copyright</xhtml:a>
        </xhtml:p> -->
      </xsl:when>
      <xsl:when test=".='Copyright Not Evaluated'">
        <xsl:apply-templates select="//RightsStatement[@key='dpla-copyright-not-evaluated']" mode="copy-guts" />
        <!-- <xhtml:p>
          <xhtml:strong>DPLA Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xhtml:a href="http://rightsstatements.org/vocab/CNE/1.0/">Copyright Not Evaluated</xhtml:a>
        </xhtml:p> -->
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
        <xsl:apply-templates select="//RightsStatement[@key='dpla-no-copyright-us']" mode="copy-guts" />
        <!-- <xhtml:p>
          <xhtml:strong>DPLA Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xhtml:a href="http://rightsstatements.org/vocab/NoC-US/1.0/">No Copyright - United  States</xhtml:a>
        </xhtml:p> -->
      </xsl:when>
      <xsl:when test=".='Copyright Not Evaluated'">
        <xsl:apply-templates select="//RightsStatement[@key='dpla-copyright-not-evaluated']" mode="copy-guts" />
        <!-- <xhtml:p>
          <xhtml:strong>DPLA Rights Statement:</xhtml:strong>
          <xsl:text> </xsl:text>
          <xhtml:a href="http://rightsstatements.org/vocab/CNE/1.0/">Copyright Not Evaluated</xhtml:a>
        </xhtml:p> -->
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