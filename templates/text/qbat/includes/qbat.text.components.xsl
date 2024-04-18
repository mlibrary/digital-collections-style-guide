<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:qbat="http://dlxs.org/quombat/quombat" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common" xmlns:math="http://exslt.org/math" xmlns:tei="http://www.tei-c.org/ns/1.0" extension-element-prefixes="exsl math dlxs">

  <xsl:variable name="is-skip-consecutive-hi-elements" select="true()" />

  <xsl:variable name="is-target" select="//qui:block[@slot='content']/@is-target" />
  
  <!-- <xsl:variable name="highlight-count" select="//qui:block[@slot='content']/@highlight-count"/>
  <xsl:variable name="highlight-count-offset" select="//qui:block[@slot='content']/@highlight-count-offset"/> -->

  <!-- <xsl:variable name="highlights" select="//tei:TEXT//tei:Highlight" />
  <xsl:variable name="highlight-seq-last" select="//tei:TEXT//tei:Highlight[last()]/@seq" />
  <xsl:variable name="highlight-seq-first" select="//tei:TEXT//tei:Highlight[1]/@seq" /> -->

  <xsl:variable name="highlights"
    select="//node()[local-name() != 'HEADER']//tei:Highlight" />
  <xsl:variable name="highlight-seq-last" select="$highlights[last()]/@seq" />
  <xsl:variable name="highlight-seq-first" select="$highlights[1]/@seq" />

  <xsl:variable name="has-page-images" select="count(//tei:DLPSWRAP//tei:PB[@HREF]) &gt; 0" />

  <xsl:variable name="referrerhref">null</xsl:variable>

  <xsl:template match="tei:DLPSWRAP[.//tei:PB or normalize-space(.)]">
    <xsl:variable name="pb" select=".//tei:PB" />
    <xsl:variable name="idno">
      <xsl:choose>
        <xsl:when test="$pb/@ID">
          <xsl:value-of select="$pb/@ID" />
        </xsl:when>
        <xsl:when test=".//node()[@NODE]">
          <xsl:value-of select=".//node()[@NODE][1]/@NODE" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="@ID" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="$pb/@ID">
          <xsl:value-of select="$pb/@ID" />
        </xsl:when>
        <xsl:when test="@ID">
          <xsl:value-of select="@ID" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate($idno, ':', '-')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="seq">
      <xsl:choose>
        <xsl:when test="$pb/@SEQ">
          <xsl:value-of select="$pb/@SEQ" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="position()" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <article id="{$id}-{$seq}-{position()}-article" class="fullview-page" data-count="{$highlights[1]/@seq}" data-idno="{$idno}">      
      <xsl:apply-templates select="$pb" mode="build-p">
        <xsl:with-param name="base" select="$id" />
        <xsl:with-param name="idno" select="$idno" />
      </xsl:apply-templates>
      <div class="fullview-main">
        <xsl:choose>
          <xsl:when test="$pb/@HREF">
            <xsl:apply-templates select="$pb" mode="build-page-link">
              <!-- <xsl:with-param name="base" select="parent::*/@ID" /> -->
              <xsl:with-param name="base" select="$id" />
              <xsl:with-param name="idno" select="$idno" />
            </xsl:apply-templates>
          </xsl:when>
          <xsl:when test="$has-page-images">
            <div class="pb-1 fullview-blank">
              <!-- <div style="min-width: 100px; margin: 1rem">
                <div style="padding: 0.5rem"></div>
              </div> -->
            </div>
          </xsl:when>
          <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
        <div class="inner">
          <xsl:apply-templates />
        </div>
      </div>
    </article>    
  </xsl:template>

  <xsl:template match="tei:TEXT" priority="101">
    <xsl:if test="false() and count($highlights) &gt; 0">
      <div class="flex flex-row gap-0_5 flex-align-center" style="background: white; position: sticky; top: 1rem;">
        <a href="#hl{$highlight-seq-first}" class="button button--ghost">First Match</a>
        <button id="action-highlight" class="button button--ghost">
          <span class="material-icons" aria-hidden="true">visibility</span>
          <span>Turn highlights off</span>
        </button>
        <!-- <div class="flex flex-row gap_0_5 flex-align-center">
          <label for="action-highlight">
            Search highlights are visible
          </label>
          <button id="action-highlight" class="button buttonxxxghost">Turn off</button>
        </div> -->
      </div>
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>

  <!-- NOTE1 PTRs -->
  <!-- #################### -->

  <!-- cannot really guarantee whether PTR is preceding/following sibling -->
  <!-- <xsl:apply-templates select="following-sibling::text()[1]" mode="linkify" /> -->

  <xsl:template match="tei:PTR[@HREF]">
    <xsl:variable name="target" select="@TARGET" />
    <xsl:variable name="type">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$type='txt'">
        <xsl:call-template name="txtpointer" />
      </xsl:when>
      <xsl:when test="//qui:block[@slot='content']//node()[@ID=$target]">
        <a 
          class="button button--secondary button--highlight footnote-link"
          id="back{@TARGET}"
          href="#{@TARGET}">
          <xsl:choose>
            <xsl:when test="@N != '*'">
              <xsl:value-of select="@N" />
            </xsl:when>
            <xsl:otherwise>
              <span class="material-icons" aria-hidden="true">tag</span>
            </xsl:otherwise>
          </xsl:choose>
          <span class="visually-hidden">Jump to section</span>
        </a> 
      </xsl:when>
      <xsl:when test="//qui:block[@slot='notes']//node()[@ID=$target]">
        <a 
          class="button button--secondary button--highlight footnote-link"
          id="back{@TARGET}"
          href="#fn{@TARGET}">
          <xsl:choose>
            <xsl:when test="@N != '*'">
              <xsl:value-of select="@N" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="build-footnote-icon" />
            </xsl:otherwise>
          </xsl:choose>
          <span class="visually-hidden">Jump to note</span>
        </a>
      </xsl:when>
      <xsl:when test="//qui:block[@slot='notes']//tei:SKIP[@TARGET=$target][@reason='div']">
        <a href="{@HREF}" target="_top" class="button button--secondary button--highlight footnote-link">
          <xsl:choose>
            <xsl:when test="@N != '*'">
              <xsl:value-of select="@N" />
            </xsl:when>
            <xsl:otherwise>
              <span class="material-icons" aria-hidden="true">description</span>
            </xsl:otherwise>
          </xsl:choose>
          <span class="visually-hidden">Open page</span>
        </a>
      </xsl:when>
      <xsl:when test="@TYPE = 'page'">
        <a href="{@HREF}" target="_top" class="button button--secondary button--highlight footnote-link">
          <xsl:choose>
            <xsl:when test="@N != '*'">
              <xsl:value-of select="@N" />
            </xsl:when>
            <xsl:otherwise>
              <span class="material-icons" aria-hidden="true">description</span>
            </xsl:otherwise>
          </xsl:choose>
          <span class="visually-hidden">Open page</span>
        </a>
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="id" select="@TARGET" />
        <xsl:choose>
          <xsl:when test="//qui:block[@slot='notes']//node()[@ID=$id]">
            <a 
              class="button button--secondary button--highlight footnote-link"
              id="back{@TARGET}"
              href="#fn{@TARGET}">
              <xsl:choose>
                <xsl:when test="@N != '*'">
                  <xsl:value-of select="@N" />
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="build-footnote-icon" />
                </xsl:otherwise>
              </xsl:choose>
            </a>
          </xsl:when>
          <xsl:when test="//qui:block[@slot='content']//node()[@ID=$id]">
            <a 
              class="button button--secondary button--highlight footnote-link"
              id="back{@TARGET}"
              href="#{@TARGET}">
              <xsl:choose>
                <xsl:when test="@N != '*'">
                  <xsl:value-of select="@N" />
                </xsl:when>
                <xsl:otherwise>
                  <span class="material-icons" aria-hidden="true">tag</span>
                </xsl:otherwise>
              </xsl:choose>
            </a>              
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:PTR[@HREF]" mode="v1">
    <xsl:variable name="type">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$type='txt'">
        <xsl:call-template name="txtpointer" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:variable name="id" select="@TARGET" />
        <!-- <xsl:variable name="target"
          select="//qui:block[@slot='notes']//node()[@ID=$id]" /> -->
        <xsl:variable name="target">
          <xsl:choose>
            <xsl:when test="//qui:block[@slot='notes']//node()[@ID=$id]">
              <xsl:value-of select="concat('#fn', $id)" />
            </xsl:when>
            <xsl:when test="//qui:block[@slot='content']//node()[@ID=$id]">
              <xsl:value-of select="concat('#', $id)" />
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
          </xsl:choose>
        </xsl:variable>
        <xsl:if test="$target">
          <a 
            class="button button--secondary button--highlight footnote-link"
            id="back{@TARGET}"
            href="{$target}">
            <xsl:choose>
              <xsl:when test="@N != '*'">
                <xsl:value-of select="@N" />
              </xsl:when>
              <xsl:otherwise>
                <!-- <span class="material-icons" aria-hidden="true">emergency</span> -->
                <xsl:call-template name="build-footnote-icon" />
              </xsl:otherwise>
            </xsl:choose>
          </a>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="txtpointer">
    <qui:link rel="txtptr" name="{@TARGET}" href="{@HREF}">
      <xsl:value-of select="@N" />
    </qui:link>
  </xsl:template>

  <xsl:template match="tei:Q1//tei:TEXT//tei:P[tei:PB]" priority="101">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:TEXT//tei:P[tei:PB]" priority="100" mode="sketchy">
    <xsl:variable name="idno" select="ancestor-or-self::*/@NODE" />
    <xsl:variable name="id">
      <xsl:choose>
        <xsl:when test="ancestor-or-self::*/@ID">
          <xsl:value-of select="ancestor-or-self::*/@ID" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="translate($idno, ':', '-')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <article id="{$id}-{PB/@SEQ}-article" class="fullview-page" data-count="{$highlights[1]/@seq}" data-idno="{$idno}">
      <xsl:apply-templates select="tei:PB" mode="build-p">
        <xsl:with-param name="base" select="$id" />
        <xsl:with-param name="idno" select="substring-before($idno, ':')" />
      </xsl:apply-templates>
      <div class="fullview-main">
        <xsl:if test="tei:PB/@HREF">
          <xsl:apply-templates select="tei:PB" mode="build-page-link">
            <!-- <xsl:with-param name="base" select="parent::*/@ID" /> -->
            <xsl:with-param name="base" select="$id" />
            <xsl:with-param name="idno" select="substring-before($idno, ':')" />
          </xsl:apply-templates>
        </xsl:if>
        <xsl:apply-templates select="." mode="build-p" />  
      </div>
    </article>
  </xsl:template>

  <!-- #################### -->

  <xsl:template match="tei:P/tei:PB|tei:PB" mode="build-page-link">
    <xsl:param name="base" />
    <xsl:param name="idno" />
    <xsl:variable name="pNum">
      <xsl:choose>
        <xsl:when test="@DISPLAYN[string-length()&gt;=1]">
          <xsl:value-of select="@DISPLAYN" />
        </xsl:when>
        <xsl:when test="@N[string-length()&gt;=1]">
          <xsl:value-of select="@N" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="key('get-lookup','text.components.str.1')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="feature">
      <xsl:value-of select="key('get-lookup', concat('viewer.ftr.', dlxs:normAttr(@FTR)))" />
    </xsl:variable>
    <div class="pb-1 fullview-thumbnail" data-idno="{$idno}">
      <a href="{@HREF}">
      <figure>
          <img
            style="min-width: 100px"
            loading="lazy"
            src="/cgi/t/text/api/image/{$collid}:{@IDNO}:{@SEQ}/full/!250,250/0/default.jpg"
            alt="Scan of {key('get-lookup','headerutils.str.page')} {$pNum}"
          />
        <figcaption>
          <span href="{@HREF}" class="button button--ghost button--small">
            <xsl:text>View </xsl:text>
            <xsl:text> </xsl:text>
              <xsl:value-of select="key('get-lookup','headerutils.str.page')" />
            <span class="visually-hidden">              
              <xsl:text> </xsl:text>
                <xsl:value-of select="$pNum" />  
              <xsl:if test="normalize-space($feature)">
                <xsl:text> - </xsl:text>
                <xsl:value-of select="$feature" />
              </xsl:if>
            </span>
          </span>
        </figcaption>
      </figure>
      </a>
    </div>
  </xsl:template>

  <!-- <xsl:template match="tei:Q1//tei:PB" mode="build-page-link" priority="101" /> -->

  <xsl:template match="tei:PB" mode="build-page-link">
    <xsl:param name="base" />
    <xsl:param name="idno" />
    <xsl:variable name="pNum">
      <xsl:choose>
        <xsl:when test="@DISPLAYN[string-length()&gt;=1]">
          <xsl:value-of select="@DISPLAYN" />
        </xsl:when>
        <xsl:when test="@N[string-length()&gt;=1]">
          <xsl:value-of select="@N" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="key('get-lookup','text.components.str.1')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="feature">
      <xsl:value-of select="key('get-lookup', concat('viewer.ftr.', dlxs:normAttr(@FTR)))" />
    </xsl:variable>
    <div class="pb-1 fullview-thumbnail" data-idno="{$idno}">
      <a href="{@HREF}">
        <figure>
          <img
            style="min-width: 100px"
            loading="lazy"
            src="/cgi/t/text/api/image/{$collid}:{@IDNO}:{@SEQ}/full/!250,250/0/default.jpg"
            alt="Scan of {key('get-lookup','headerutils.str.page')} {$pNum}"
          />
          <figcaption>
            <span href="{@HREF}" class="button button--ghost button--small">
              <xsl:text>View </xsl:text>
              <xsl:text> </xsl:text>
              <xsl:value-of select="key('get-lookup','headerutils.str.page')" />
              <span class="visually-hidden">              
                <xsl:text> </xsl:text>
                <xsl:value-of select="$pNum" />  
                <xsl:if test="normalize-space($feature)">
                  <xsl:text> - </xsl:text>
                  <xsl:value-of select="$feature" />
                </xsl:if>
              </span>
            </span>
          </figcaption>
        </figure>
      </a>
    </div>
  </xsl:template>

  <xsl:template match="tei:P/tei:PB|tei:PB" mode="build-p">
    <xsl:param name="base" />
    <xsl:variable name="pNum">
      <xsl:choose>
        <xsl:when test="@DISPLAYN[string-length()&gt;=1]">
          <xsl:value-of select="@DISPLAYN" />
        </xsl:when>
        <xsl:when test="@N[string-length()&gt;=1]">
          <xsl:value-of select="@N" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="key('get-lookup','text.components.str.1')" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <xsl:variable name="feature">
      <xsl:value-of select="key('get-lookup', concat('viewer.ftr.', dlxs:normAttr(@FTR)))" />
    </xsl:variable>
    <xsl:variable name="heading">
      <xsl:value-of select="key('get-lookup','headerutils.str.page')" />
      <xsl:text> </xsl:text>
      <xsl:value-of select="$pNum" />  
      <xsl:if test="normalize-space($feature)">
        <xsl:text> - </xsl:text>
        <xsl:value-of
          select="$feature" />
      </xsl:if>
    </xsl:variable>
    <h3 
      class="flex align-items-center gap-0_5"
      data-heading-label="{$heading}" data-p-num="{$pNum}">
      <xsl:attribute name="data-wut">
        <xsl:choose>
          <xsl:when test="@DISPLAYN[string-length()&gt;=1]">
            <xsl:text>DISPLAYN</xsl:text>
          </xsl:when>
          <xsl:when test="@N[string-length()&gt;=1]">
            <xsl:text>N</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>AHH</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:attribute name="id">
        <xsl:choose>
          <xsl:when test="@ID">
            <xsl:value-of select="@ID" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="concat($base, '-', @SEQ)" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <span class="material-icons text-x-small" aria-hidden="true">description</span>
      <span>
        <xsl:value-of select="$heading" />
      </span>
    </h3>
  </xsl:template>

  <xsl:template match="tei:PB" />

  <!-- #################### -->
  <xsl:template match="tei:EPB" />

  <!-- turn line breaks in data into br's for html output -->
  <!-- #################### -->
  <xsl:template match="tei:LB">
    <br />
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="ReturnLink">
    <!-- link back to text/ptr from note if possible -->
    <xsl:if test="$is-target='true' and $referrerhref!='null'">
      <qui:link rel="return" name="{concat(@ID,'text')}" href="{concat($referrerhref,'#',@ID)}">
        <xsl:value-of select="key('get-lookup','text.components.str.returntotext')" />
      </qui:link>
    </xsl:if>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DIV1">
    <xsl:variable name="divtype">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE" />
      </xsl:call-template>
    </xsl:variable>

    <section name="{local-name()}" data-item-encoding-level="{$item-encoding-level}">
      <xsl:if test="@ID">
        <xsl:attribute name="id"><xsl:value-of select="@ID" /></xsl:attribute>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="$divtype='titlepage'">
          <xsl:call-template name="titlepage" />
        </xsl:when>
        <xsl:when test="$divtype='dedication'">
          <xsl:call-template name="titlepage" />
        </xsl:when>
        <xsl:when test="$divtype='toc'">
          <xsl:apply-templates />
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="tei:DIVINFO">
              <xsl:apply-templates select="tei:HEAD[1]" />
              <xsl:call-template name="printdivinfo" />
              <xsl:apply-templates
                select="*[local-name()!='DIVINFO'][local-name()!='HEAD']" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="ReturnLink" />
    </section>
  </xsl:template>

  <xsl:template match="tei:DIV2[@TYPE][normalize-space(.)]|tei:DIV3[@TYPE][normalize-space(.)]">
    <xsl:variable name="heading" select="key('get-lookup', concat('heading.', @TYPE))" />
    <xsl:variable name="id" select="@ID" />
    <div>
      <xsl:apply-templates select="@ID" />
      <xsl:if test="normalize-space($heading)">
        <div class="div-heading">
          <xsl:value-of select="$heading" />
        </div>
        <!-- <p><strong><xsl:value-of select="$heading" /></strong></p> -->
      </xsl:if>
      <xsl:apply-templates />
      <xsl:if test="//qui:block[@slot='content']//tei:PTR[@TARGET=$id]">
        <div>
          <a class="button button--secondary text-xx-small"
            href="#back{$id}">
            <span class="material-icons" aria-hidden="true">keyboard_return</span>
            <span>Return</span>
          </a>
        </div>
      </xsl:if>
    </div>
  </xsl:template>

  <!-- DIVINFO is handled elsewhere -->
  <xsl:template match="tei:DIVINFO" />

  <!-- #################### -->
  <xsl:template match="tei:TEXT|tei:FRONT|tei:BODY|tei:BACK|tei:DLPSTEXTCLASS">
    <xsl:apply-templates />
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:HEADER" />

  <!-- #################### -->
  <xsl:template name="printdivinfo">
    <xsl:for-each select="tei:DIVINFO">
      <xsl:choose>
        <xsl:when test="parent::*[starts-with(local-name(),'DIV')]/@TYPE">
          <xsl:variable name="parentDivType" select="parent::*/@TYPE" />
          <xsl:variable name="parentDivTypenorm">
            <xsl:call-template name="normAttr">
              <xsl:with-param name="attr" select="parent::*/@TYPE" />
            </xsl:call-template>
          </xsl:variable>
          <section class="infoheader mb-1 text--small">
            <div class="subtle-heading">
              <xsl:value-of select="key('get-lookup','text.components.str.2')" />
              <xsl:value-of select="$parentDivType" />
            </div>
            <dl class="record record--compact">
              <xsl:apply-templates select="tei:AUTHOR" mode="divinfoauth" />
              <xsl:apply-templates select="tei:KEYWORDS" mode="divinfokw" />
            </dl>
          </section>
         </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="titlepage">
    <div class="titlepage">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- title page templates -->
  <!-- #################### -->
  <xsl:template match="tei:TITLEPAGE">
    <xsl:apply-templates />
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DOCTITLE">
    <div class="doctitle">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:TITLEPART[@TYPE='sub']" priority="101">
    <h4 class="fullview-heading fullview-heading-2">
      <xsl:apply-templates />
    </h4>
  </xsl:template>

  <xsl:template match="tei:TITLEPART">
    <h3 class="fullview-heading fullview-heading-1">
      <xsl:apply-templates />
    </h3>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:BYLINE">
    <div class="byline">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DOCAUTHOR">
    <div class="docauthor">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DOCIMPRINT">
    <div class="docimprint">
      <xsl:for-each select="*">
        <xsl:apply-templates select="." />
        <br />
      </xsl:for-each>
    </div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:CAESURA">
    <div>
      <xsl:value-of select="key('get-lookup','text.components.str.3')" />
    </div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:ALIAS">
    <span class="alias">
      <xsl:value-of select="concat('(a.k.a ',.,' )')" />
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:FOREIGN">
    <span class="foreign">
      <xsl:value-of select="." />
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:SIC" mode="v1">
    <xsl:if test="@CORR">
      <span class="corr annotated">
        <xsl:value-of select="@CORR" />
        <xsl:text> </xsl:text>
      </span>
    </xsl:if>
    <span class="sic">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:SIC">
    <xsl:param name="has-corr" />
    <span class="sic">
      <xsl:apply-templates />
      <span class="sic--expanded">
        <xsl:text> [</xsl:text>
        <em>sic</em>
        <xsl:choose>
          <xsl:when test="@CORR">
            <span class="corr annotated">
              <xsl:value-of select="@CORR" />
            </span>
          </xsl:when>
          <xsl:when test="normalize-space($has-corr)">
            <xsl:apply-templates select="$has-corr" />
          </xsl:when>
        </xsl:choose>
        <xsl:text>]</xsl:text>  
      </span>
    </span>
  </xsl:template>

  <xsl:template match="tei:CORR">
    <span data-wut="{local-name(preceding-sibling::node()[1])}">
      <xsl:attribute name="class">
        <xsl:text>corr</xsl:text>
        <xsl:if test="local-name(preceding-sibling::node()[1]) = 'SIC'">
          <xsl:text> annotated</xsl:text>
        </xsl:if>
      </xsl:attribute>
      <xsl:text> </xsl:text>
      <xsl:apply-templates />
    </span>
    <!-- <xsl:text> </xsl:text> -->
  </xsl:template>

  <xsl:template match="tei:CHOICE">
    <span class="choice">
    <xsl:choose>
      <xsl:when test="tei:SIC">
        <xsl:apply-templates select="tei:SIC">
            <xsl:with-param name="has-corr" select="tei:CORR" />
        </xsl:apply-templates>
        <!-- <xsl:apply-templates select="tei:CORR">
          <xsl:with-param name="has-sic" select="tei:SIC" />
        </xsl:apply-templates> -->
      </xsl:when>
      <xsl:when test="tei:ABBR">
        <span class="abbr">
            <xsl:value-of select="tei:ABBR" />
          <span class="abbr--expanded annotated">
            <xsl:text> (</xsl:text>
              <xsl:value-of select="tei:EXPAN" />
            <xsl:text>)</xsl:text>  
          </span>
        </span>
      </xsl:when>
      <xsl:when test="tei:ORIG">
        <span class="orig">
            <xsl:apply-templates select="tei:ORIG" />
          <xsl:if test="false()">
          <span class="abbr--expanded annotated">
            <xsl:text> (</xsl:text>
                <xsl:apply-templates select="tei:REG" />
            <xsl:text>)</xsl:text>
          </span>
          </xsl:if>
        </span>
      </xsl:when>
    </xsl:choose>
    <xsl:text> </xsl:text>
    </span>
  </xsl:template>

  <xsl:template match="tei:ABBR">
    <span class="abbr">
      <xsl:value-of select="." />
      <xsl:if test="@EXPAN">
        <span class="abbr--expanded annotated">
          <xsl:text> (</xsl:text>
            <xsl:value-of select="@EXPAN" />
          <xsl:text>)</xsl:text>  
        </span>
      </xsl:if>
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:GAP">
    <xsl:variable name="reason-tmp">
      <span class="gap--reason annotated">
        <xsl:choose>
          <xsl:when test="@DISP">
            <xsl:value-of select="@DISP" />
          </xsl:when>
          <xsl:when test="@N">
            <xsl:value-of select="@N" />
          </xsl:when>
          <xsl:when test="@EXTENT and @REASON">
            <xsl:choose>
              <xsl:when test="number(@EXTENT) = number(@EXTENT)">
                <!-- do nothing -->
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="concat(@EXTENT, '; ')" />
              </xsl:otherwise>
            </xsl:choose>
            <xsl:value-of select="@REASON" />
          </xsl:when>
          <xsl:when test="@REASON">
            <xsl:value-of select="@REASON" />
          </xsl:when>
        </xsl:choose>
      </span>
    </xsl:variable>
    <xsl:variable name="reason" select="exsl:node-set($reason-tmp)" />
    <span class="gap">
      <xsl:choose>
        <xsl:when test="@DISP">
          <xsl:value-of select="@DISP" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>…</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="normalize-space($reason)">
        <xsl:apply-templates select="$reason" mode="copy" />
      </xsl:if>
    </span>
  </xsl:template>

  <xsl:template match="tei:GAP" mode="v1">
    <xsl:text> </xsl:text>
    <span class="gap xx-annotated">
      <xsl:choose>
        <xsl:when test="@DISP">
          <xsl:value-of select="@DISP" />
        </xsl:when>
        <xsl:when test="@N">
          <xsl:value-of select="@N" />
        </xsl:when>
        <xsl:when test="@EXTENT">
          <xsl:text>[gap: </xsl:text>
          <xsl:value-of select="@EXTENT" />
          <xsl:if test="@REASON">
            <xsl:value-of select="concat('; reason: ',@REASON)" />
          </xsl:if>
          <xsl:text>]</xsl:text>
        </xsl:when>
        <xsl:when test="@REASON = 'illegible'">
          <small>???</small>
        </xsl:when>
        <xsl:when test="@REASON">
          <small>[...]</small>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text>[gap: unclear]</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </span>
    <xsl:text> </xsl:text>
  </xsl:template>

  <xsl:template match="tei:UNCLEAR">
    <span class="unclear">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:SUPPLIED">
    <span class="supplied">
      <xsl:apply-templates />
    </span>
    <!-- <xsl:text> [</xsl:text>
    <xsl:text>] </xsl:text> -->
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:P[ancestor::FIGURE]" priority="10">
    <p>
      <xsl:apply-templates />
    </p>
  </xsl:template>

  <xsl:template match="tei:P">
    <xsl:apply-templates select="." mode="build-p" />
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:P" mode="build-p" />
  <xsl:template match="tei:P[normalize-space(.) or node()]" mode="build-p" priority="101">
    <!-- normalize type value -->
    <xsl:variable name="type">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE" />
      </xsl:call-template>
    </xsl:variable>
    <!-- *** -->
    <!-- assuming INDENT and TYPE="skipline|tei:author|tei:title|tei:subtitle" are mutually
    exclusive: -->
    <xsl:choose>
      <xsl:when test="$type='title'">
        <!-- create semantic h1 tag for article title  -->
        <h3>
          <xsl:attribute name="class">
            <xsl:value-of select="concat($type,'-semantic')" />
          </xsl:attribute>
          <xsl:call-template name="ParaAttrPassThru" />
          <xsl:apply-templates />
        </h3>
      </xsl:when>
      <xsl:when test="$type='subtitle'">
        <h4>
          <xsl:attribute name="class">
            <xsl:value-of select="concat($type,'-semantic')" />
          </xsl:attribute>
          <xsl:call-template name="ParaAttrPassThru" />
          <xsl:apply-templates />
        </h4>
      </xsl:when>
      <xsl:when test="$type='author'">
        <p class="author">
          <xsl:apply-templates />
        </p>
      </xsl:when>
      <xsl:otherwise>
        <p data-debug="otherwise">
          <xsl:attribute name="class">
            <xsl:choose>
              <xsl:when test="ancestor::qui:block[@slot='content']/@item-encoding-level != '1'"> </xsl:when>
              <xsl:otherwise>
                <xsl:text>plaintext</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:call-template name="ParaAttrPassThru" />
          <xsl:choose>
            <xsl:when test="@INDENT">
              <xsl:attribute name="style">
                <xsl:value-of select="concat('margin-left:',@INDENT,'em')" />
              </xsl:attribute>
              <xsl:apply-templates />
            </xsl:when>
            <xsl:when test="$type='skipline'">
              <br />
              <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
              <br />
              <xsl:apply-templates />
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates />
            </xsl:otherwise>
          </xsl:choose>
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="ParaAttrPassThru">
    <!-- pass through any attributes, normalized, but skip 3 common attrs -->
      <xsl:for-each select="@*[not(local-name()='INDENT' or local-name()='REND' or local-name()='TYPE')]">
        <xsl:attribute name="{translate(local-name(),'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')}">
          <xsl:choose>
            <xsl:when test="local-name()='ID'">
            <xsl:value-of select="." />
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="normAttr">
              <xsl:with-param name="attr" select="." />
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:if test="@REND">
        <xsl:attribute name="class">
        <xsl:value-of select="concat('rend-',@REND)" />
        </xsl:attribute>
      </xsl:if>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:TABLE">
    <div class="responsive-table">
      <table>
        <xsl:copy-of select="@*" />
        <xsl:if test="@ID">
          <xsl:attribute name="id"><xsl:value-of select="@ID" /></xsl:attribute>
        </xsl:if>
        <xsl:if test="not(@CLASS)">
          <!-- distinguish as source xml table (vs. an html table) -->
          <xsl:attribute name="class">
            <xsl:text>xmltable</xsl:text>
            <!-- allow for REND styles to be applied -->
            <xsl:if test="@REND!=''">
              <xsl:value-of select="concat('-rend-', @REND)" />
            </xsl:if>
          </xsl:attribute>
        </xsl:if>
        <xsl:apply-templates select="./tei:CAPTION" />
        <xsl:apply-templates select="*[not(local-name()='CAPTION')]" />
      </table>
    </div>
    <!-- table caption follows the table -->
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:CELL">
    <td>
      <xsl:if test="not(@CLASS)">
        <!-- distinguish as source xml td (vs. an html td) -->
        <xsl:attribute name="class">
          <xsl:text>xmltd</xsl:text>
          <!-- allow for REND styles to be applied -->
          <xsl:if test="@REND!=''">
            <xsl:value-of select="concat('-rend-', @REND)" />
          </xsl:if>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@COLSPAN">
        <xsl:attribute name="colspan">
          <xsl:value-of select="@COLSPAN" />
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@ROWSPAN">
        <xsl:attribute name="rowspan">
          <xsl:value-of select="@ROWSPAN" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </td>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:ROW">
    <tr>
      <xsl:if test="not(@CLASS)">
        <!-- distinguish as source xml tr (vs. an html tr) -->
        <xsl:attribute name="class">
          <xsl:text>xmltr</xsl:text>
          <!-- allow for REND styles to be applied -->
          <xsl:if test="@REND!=''">
            <xsl:value-of select="concat('-rend-', @REND)" />
          </xsl:if>
        </xsl:attribute>

      </xsl:if>
      <xsl:apply-templates />
    </tr>
  </xsl:template>

  <xsl:template match="tei:TABLE/CAPTION">
    <caption>
      <xsl:apply-templates />
    </caption>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:ITEM">
    <li>
      <xsl:if test="@ID">
        <xsl:attribute name="id">
          <xsl:value-of select="@ID" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </li>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:LIST[tei:LABEL]" priority="101">
    <xsl:apply-templates select="*[not(self::tei:ITEM) and not(self::tei:LABEL)]" />
    <dl class="record record--compcat">
      <xsl:apply-templates select="tei:LABEL" mode="dlx" />
    </dl>
  </xsl:template>

  <xsl:template match="tei:LABEL" mode="dlx">
    <xsl:variable name="self" select="." />
    <xsl:variable name="labels" select="following-sibling::tei:LABEL" />
    <div>
      <dt><xsl:apply-templates /></dt>
      <!-- <xsl:apply-templates select="following-sibling::tei:ITEM[not(preceding-sibling -->
      <xsl:apply-templates select="../tei:ITEM[
        preceding-sibling::tei:LABEL[1] = $self
      ]" mode="dl" />
    </div>
  </xsl:template>

  <xsl:template match="tei:LABEL" mode="dl">
    <dt><xsl:apply-templates /></dt>
  </xsl:template>

  <xsl:template match="tei:ITEM" mode="dl">
    <dd><xsl:apply-templates /></dd>
  </xsl:template>

  <xsl:template match="tei:LIST">
    <xsl:apply-templates select="*[not(self::tei:ITEM)] " />
    <xsl:choose>
      <xsl:when test="@TYPE='ordered' or @TYPE='numbered'">
        <ol class="list-numbered">
          <xsl:apply-templates select="@ID" />
          <xsl:apply-templates select="tei:ITEM" />
        </ol>
      </xsl:when>
      <xsl:otherwise>
        <ul>
          <xsl:apply-templates select="@ID" />
          <xsl:attribute name="class">
            <xsl:choose>
              <xsl:when test="normalize-space(@TYPE)">
                <xsl:value-of select="concat('fullview-', @TYPE)" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>list-bulleted</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <xsl:apply-templates select="tei:ITEM" />
        </ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- <xsl:template match="tei:LIST[tei:HEAD]" priority="101">
    <xsl:apply-templates select="tei:MILESTONE" />
    <xsl:apply-templates select="tei:HEAD" mode="heading">
      <xsl:with-param name="divlevel" select="9" />
      <xsl:with-param name="class">
        <xsl:value-of select="concat('fullview-heading fullview-heading-', '9') " />
      </xsl:with-param>
    </xsl:apply-templates>  
    <ul class="list-bulleted">
      <xsl:apply-templates select="tei:ITEM" />
    </ul>
  </xsl:template> -->

  <!-- #################### -->
  <xsl:template match="tei:NAME[@REG]">
    <span class="name">
      <xsl:apply-templates />
      <span class="name--reg annotated">
        <xsl:text> </xsl:text>
        <xsl:value-of select="@REG" />
      </span>
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:NOTE/tei:NOTE1|tei:NOTE/tei:NOTE2" priority="101">
    <xsl:choose>
      <xsl:when test=".//tei:P">
        <!-- nested paragraphs -->
        <xsl:apply-templates />
      </xsl:when>
      <xsl:otherwise>
        <p>
          <xsl:apply-templates />
        </p>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:NOTES/tei:SKIP" />

  <xsl:template match="tei:NOTE1|tei:NOTE2">
    <xsl:variable name="view" select="'text'" />
    <xsl:choose>
      <xsl:when test="not(@HREF)">
        <!-- no @HREF, therefore render the note content -->
        <xsl:choose>
          <xsl:when test="$view='trgt'">
            <xsl:call-template name="filterNotesInTarget" />
          </xsl:when>
          <xsl:when test="$view='text'">
            <xsl:call-template name="filterNotesInText" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="filterNotesInText" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$view='text'">
            <!-- only build anchor for text view, not target or reslist unless ... -->
            <xsl:call-template name="buildNoteAnchor" />
          </xsl:when>
          <xsl:when test="$view='trgt'">
            <xsl:variable name="targetID">
              <xsl:value-of select="/Top/DlxsGlobals/CurrentCgi/Param[@name='id']" />
            </xsl:variable>
            <xsl:choose>
              <!-- handle the case of notes within notes -->
              <xsl:when test="not(@ID=$targetID)">
                <!-- ... this is a note with an href but not the one currently targeted,
                     so build an anchor -->
                <xsl:call-template name="buildNoteAnchor" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="filterNotesInTarget" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="buildNoteAnchor">
    <a 
      class="button button--secondary button--highlight footnote-link"
      id="back{@ID}"
      href="#fn{@ID}">
        <xsl:choose>
          <xsl:when test="@N != '*'">
            <xsl:value-of select="@N" />
          </xsl:when>
          <xsl:otherwise>
            <!-- <span class="material-icons" aria-hidden="true">emergency</span> -->
            <xsl:call-template name="build-footnote-icon" />
          </xsl:otherwise>
        </xsl:choose>
      </a>
  </xsl:template>

  <xsl:template name="buildNoteAnchor-v1">
    <!--  replace NOTE1 with an anchor -->
    <span class="ptr">
      <!-- return anchor: -->
      <xsl:element name="a">
        <xsl:attribute name="name">
          <xsl:value-of select="@ID" />
        </xsl:attribute>
      </xsl:element>
      <xsl:element name="a">
        <xsl:attribute name="href">
          <xsl:value-of select="@HREF" />
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="@N">
            <xsl:value-of select="@N" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'*'" />
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="filterNotesInText">
    <xsl:variable name="id" select="@ID" />
    <xsl:variable name="target"
      select="//qui:block[@slot='notes']//node()[@ID=$id]" />
    <xsl:if test="$target">
      <a 
        class="button button--secondary button--highlight footnote-link"
        id="back{@ID}"
        href="#fn{@ID}">
        <xsl:choose>
          <xsl:when test="@N != '*'">
            <xsl:value-of select="@N" />
          </xsl:when>
          <xsl:otherwise>
            <!-- <span class="material-icons" aria-hidden="true">emergency</span> -->
            <xsl:call-template name="build-footnote-icon" />
          </xsl:otherwise>
        </xsl:choose>
      </a>
    </xsl:if>
  </xsl:template>

  <xsl:template name="filterNotesInText-v2">
    <xsl:choose>
      <xsl:when test="tei:P and @N">
        <xsl:call-template name="filterNumberedNoteWithParas" />
      </xsl:when>
      <xsl:otherwise>
        <span class="note">
          <xsl:choose>
            <xsl:when test="@N">
              <span class="note--number">
                <xsl:value-of select="@N" />
              </span>
            </xsl:when>
            <xsl:otherwise>
              <span class="note--number">
                <span class="material-icons">note</span>
              </span>
            </xsl:otherwise>
          </xsl:choose>
          <span class="note--content annotated">
            <xsl:apply-templates
              select="tei:BIBL|tei:DATE|tei:FIGURE|tei:FOREIGN|tei:GAP|tei:HEAD|tei:HI1|tei:HI2|tei:Highlight|tei:P|tei:PB|tei:Q1|tei:REF|tei:TABLE|text()" />
          </span>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="filterNotesInText--v1" mode="v1">
    <xsl:choose>
      <xsl:when test="tei:P and @N">
        <xsl:call-template name="filterNumberedNoteWithParas" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="@N">
          <span class="notenumber">
            <xsl:value-of select="concat(@N,'. ')" />
          </span>
        </xsl:if>
        <!-- it's an inline note -->
        <xsl:if test="true()">
          <xsl:if test="not(tei:P) and not(tei:TABLE)">
            <span class="inline-note-edge">[</span>
          </xsl:if>
          <xsl:apply-templates
            select="tei:BIBL|tei:DATE|tei:FIGURE|tei:FOREIGN|tei:GAP|tei:HEAD|tei:HI1|tei:HI2|tei:Highlight|tei:P|tei:PB|tei:Q1|tei:REF|tei:TABLE|text()" />
          <xsl:if test="not(tei:P) and not(tei:TABLE)">
            <span class="inline-note-edge">]</span>
          </xsl:if>
        </xsl:if>
        <!-- <xsl:choose>
          <xsl:when test="not(tei:P) and not(tei:TABLE)">
            <span class="inline-note display-inline">
              <xsl:apply-templates
              select="tei:BIBL|tei:DATE|tei:FIGURE|tei:FOREIGN|tei:GAP|tei:HEAD|tei:HI1|tei:HI2|tei:Highlight|tei:P|tei:PB|tei:Q1|tei:REF|tei:TABLE|text()" />  
            </span>
          </xsl:when>
          <xsl:otherwise>
            <div class="inline-note">
              <xsl:apply-templates
                select="tei:BIBL|tei:DATE|tei:FIGURE|tei:FOREIGN|tei:GAP|tei:HEAD|tei:HI1|tei:HI2|tei:Highlight|tei:P|tei:PB|tei:Q1|tei:REF|tei:TABLE|text()" />
            </div>    
          </xsl:otherwise>
        </xsl:choose> -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="filterNotesInTarget">
    <xsl:choose>
      <xsl:when test="P and @N">
        <xsl:call-template name="filterNumberedNoteWithParas" />
      </xsl:when>
      <xsl:otherwise>
        <!-- Only a literal N value, in case it's inline -->
        <xsl:if test="@N">
          <span class="notenumber">
            <xsl:value-of select="concat(@N,'. ')" />
          </span>
        </xsl:if>
        <xsl:apply-templates
          select="tei:BIBL|tei:CLOSER|tei:DATE|tei:FIGURE|tei:FOREIGN|tei:GAP|tei:HI1|tei:HI2|tei:Highlight|tei:NOTE2|tei:PB|tei:Q1|tei:REF|tei:TABLE|text()" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="filterNumberedNoteWithParas">
    <div>
      <xsl:for-each select="node()">
        <xsl:apply-templates select="." mode="within-number">
          <xsl:with-param name="position" select="position()" />
        </xsl:apply-templates>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="tei:P" mode="within-number">
    <xsl:param name="position" />
    <p>
    </p>
  </xsl:template>


  <xsl:template name="filterNumberedNoteWithParas-v1">
    <xsl:for-each select="node()">
      <xsl:choose>
        <xsl:when test="local-name()='P'">
          <xsl:if test="@ID">
            <xsl:element name="a">
              <xsl:attribute name="id">
                <xsl:value-of select="@ID" />
              </xsl:attribute>
            </xsl:element>
          </xsl:if>
          <xsl:choose>
            <xsl:when test="position() = 1">
              <p>
                <span class="notenumber">
                  <xsl:choose>
                    <xsl:when test="parent::tei:NOTE1/@N or parent::tei:NOTE2/@N">
                      <xsl:choose>
                        <xsl:when test="number(parent::*/@N)">
                          <xsl:value-of select="concat(parent::*/@N,'. ')" />
                        </xsl:when>
                        <xsl:otherwise>
                          <sup>
                            <xsl:value-of select="concat(parent::*/@N, ' ')" /></sup>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of
                        select="concat(substring-after(parent::tei:NOTE1/@ID,'DLPS'),'. ')" />
                    </xsl:otherwise>
                  </xsl:choose>
                </span>
                <xsl:apply-templates
                  select="tei:BIBL|tei:CLOSER|tei:DATE|tei:FIGURE|tei:FOREIGN|tei:GAP|tei:HI1|tei:HI2|tei:Highlight|tei:NOTE2|tei:PB|tei:PTR|tei:Q1|tei:REF|tei:TABLE|tei:LIST|text()" />
              </p>
            </xsl:when>
            <xsl:otherwise>
              <p>
                <xsl:apply-templates
                  select="tei:BIBL|tei:CLOSER|tei:DATE|tei:FIGURE|tei:FOREIGN|tei:GAP|tei:HI1|tei:HI2|tei:Highlight|tei:NOTE2|tei:PB|tei:PTR|tei:Q1|tei:REF|tei:TABLE|tei:LIST|text()" />
              </p>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="." />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DATE">
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template match="tei:Q1">
    <xsl:variable name="type">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE" />
      </xsl:call-template>
    </xsl:variable>
    <blockquote>
      <xsl:attribute name="class">
        <xsl:text>q1 </xsl:text>
        <xsl:if test="@TYPE">
          <xsl:value-of select="concat('q1--', $type)" />
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates />
    </blockquote>
  </xsl:template>

  <xsl:template match="tei:BIBL[not(ancestor::tei:HEADER)]">
    <xsl:if test="@ID">
      <xsl:element name="a">
        <xsl:attribute name="name"><xsl:value-of select="@ID" /></xsl:attribute>
      </xsl:element>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="parent::tei:EPIGRAPH">
        <div class="bibl">
          <xsl:apply-templates />
        </div>
      </xsl:when>
      <xsl:when test="tei:TITLE">
        <cite>
          <xsl:apply-templates select="tei:TITLE" />
        </cite>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:REF">
    <xsl:variable name="type">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE" />
      </xsl:call-template>
    </xsl:variable>
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="$type='url' and @URL">
        <span class="ref">
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="@URL" />
            </xsl:attribute>
            <!-- <xsl:attribute name="target">
              <xsl:text>_blank</xsl:text>
            </xsl:attribute> -->
            <xsl:apply-templates />
          </xsl:element>
        </span>
      </xsl:when>
      <xsl:when test="$type='audio' and @FILENAME">
        <span class="ref">
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="@SYSTEMFILEPATH" />
            </xsl:attribute>
            <!-- <xsl:attribute name="target">
              <xsl:text>_blank</xsl:text>
            </xsl:attribute> -->
            <xsl:element name="img">
              <xsl:attribute name="src">
                <xsl:value-of select="'/t/text/graphics/audio.gif'" />
              </xsl:attribute>
              <xsl:attribute name="alt">
                <xsl:value-of select="key('get-lookup','text.components.str.audio')" />
              </xsl:attribute>
            </xsl:element>
            <xsl:text>&#xa0;</xsl:text>
          </xsl:element>
          <xsl:apply-templates />
        </span>
      </xsl:when>
      <xsl:when test="@HREF">
        <span class="ref">
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="@HREF" />
            </xsl:attribute>
            <xsl:apply-templates />
          </xsl:element>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="ref">
          <xsl:apply-templates />
        </span>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:EPIGRAPH|tei:SIGNED|tei:TRAILER|tei:CLOSER|tei:PREFACE|tei:ARGUMENT|tei:DEDICAT|tei:OPENER">
    <xsl:variable name="divclass">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="local-name()" />
      </xsl:call-template>
    </xsl:variable>
    <div class="{$divclass}">
      <xsl:choose>
        <xsl:when test="@REND">
          <xsl:variable name="rendtype">
            <xsl:call-template name="makeRendVar" />
          </xsl:variable>
          <xsl:element name="span">
            <xsl:attribute name="class">
              <xsl:value-of select="concat('rend-',$rendtype)" />
            </xsl:attribute>
            <xsl:apply-templates />
          </xsl:element>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates />
        </xsl:otherwise>
      </xsl:choose>

    </div>
  </xsl:template>


  <!-- #################### -->
  <xsl:template name="BuildFigImg">
    <xsl:param name="figHref" />
    <xsl:param name="figAlt" />
    <xsl:param name="figTitle" />
    <xsl:param
      name="figClass" />

    <xsl:element name="img">
      <xsl:attribute name="loading">lazy</xsl:attribute>
      <xsl:attribute name="src">
        <xsl:value-of select="$figHref" />
      </xsl:attribute>
      <xsl:attribute name="alt">
        <xsl:value-of select="$figAlt" />
      </xsl:attribute>
      <!-- <xsl:attribute name="title">
        <xsl:value-of select="$figTitle" />
      </xsl:attribute> -->
      <xsl:if test="$figClass">
        <xsl:attribute name="class">
          <xsl:value-of select="$figClass" />
        </xsl:attribute>
      </xsl:if>
    </xsl:element>
  </xsl:template>


  <!-- #################### -->
  <xsl:template match="tei:FIGURE">
    <!-- attributes:ID,ENTITY[FIGTYPE=INLINE|tei:THUMB, HREF_1,HREF_2] -->

    <figure>
      <xsl:if test="@ID">
        <xsl:attribute name="id"><xsl:value-of select="@ID" /></xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="not(@FIGTYPE)">
          <p class="fullview-missing-image">
            <xsl:value-of select="key('get-lookup','text.components.str.6')" />
          </p>
        </xsl:when>
        <xsl:when test="@FIGTYPE='INLINE'">
          <xsl:choose>
            <xsl:when test="@HREF_1">
              <xsl:call-template name="BuildFigImg">
                <xsl:with-param name="figHref" select="@HREF_1" />
                <xsl:with-param name="figAlt" select="key('get-lookup','text.components.str.5')" />
                <xsl:with-param name="figTitle"
                  select="key('get-lookup','text.components.str.5')" />
              </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
              <!-- missing figure -->
              <p class="fullview-missing-image">
                <xsl:value-of select="key('get-lookup','text.components.str.6')" />
              </p>    
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:when test="@FIGTYPE='THUMB'">
          <xsl:choose>
            <xsl:when test="@HREF_1">
              <xsl:choose>
                <!-- is there a full image URL?-->
                <xsl:when test="@HREF_2">
                  <a href="{@HREF_2}">
                    <xsl:call-template name="BuildFigImg">
                      <xsl:with-param name="figHref" select="@HREF_1" />
                      <xsl:with-param name="figAlt" select="key('get-lookup','text.components.str.5')" />
                      <xsl:with-param name="figTitle"
                        select="key('get-lookup','text.components.str.5')" />
                    </xsl:call-template>
                  </a>
                </xsl:when>
                <xsl:otherwise>
                  <xsl:call-template name="BuildFigImg">
                    <xsl:with-param name="figHref" select="@HREF_1" />
                    <xsl:with-param name="figAlt"
                      select="key('get-lookup','text.components.str.5')" />
                    <xsl:with-param name="figTitle"
                      select="key('get-lookup','text.components.str.5')" />
                  </xsl:call-template>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>
            <xsl:when test="@HREF_2">
              <!-- no thumb url but full image url-->
              <a href="{@HREF_2}" class="button button--ghost">
                <span class="material-icons" aria-hidden="true">unfold_more</span>
                <span>
                  <xsl:value-of select="key('get-lookup','text.components.str.5')" />
                </span>
              </a>
            </xsl:when>
            <xsl:otherwise>
              <p class="fullview-missing-image">
                <xsl:value-of select="key('get-lookup','text.components.str.6')" />
              </p>    
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <p class="fullview-missing-image">
            <xsl:value-of select="key('get-lookup','text.components.str.6')" />
          </p>
        </xsl:otherwise>
      </xsl:choose>
      <figcaption>
        <xsl:if test="@FIGTYPE='THUMB' and @HREF_2">
          <p>
            <a href="{@HREF_2}" aria-hidden="true" class="button button--ghost">
              <span class="material-icons" aria-hidden="true">unfold_more</span>
              <span>View image</span>
            </a>
          </p>
        </xsl:if>
        <xsl:apply-templates select="tei:P|tei:FIGDESC|tei:HEAD" />
      </figcaption>
    </figure>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:FIGDESC">
    <xsl:apply-templates />
  </xsl:template>


  <!-- #################### -->
  <xsl:template match="tei:LG">
    <!-- attributes:  TYPE('verse''section'),ID -->
    <xsl:variable name="type">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE" />
      </xsl:call-template>
    </xsl:variable>

    <div>
      <xsl:if test="@ID">
        <xsl:attribute name="id"><xsl:value-of select="@ID" /></xsl:attribute>
      </xsl:if>
      <xsl:attribute name="class">
        <xsl:text>lg </xsl:text>
        <xsl:if test="@TYPE">
          <xsl:value-of select="concat('lg--', $type)" />
        </xsl:if>
      </xsl:attribute>
      <xsl:copy-of select="@*[local-name()!='TYPE' and local-name()!='ID']" />
      <xsl:call-template name="addRend" />
    </div>
  </xsl:template>


  <!-- #################### -->
  <xsl:template match="tei:L">
    <span>
      <xsl:if test="@ID">
        <xsl:attribute name="id"><xsl:value-of select="@ID" /></xsl:attribute>
      </xsl:if>
      <xsl:attribute name="class">
        <xsl:text>line </xsl:text>
        <xsl:if test="@REND">
          <xsl:variable name="rendtype">
            <xsl:call-template name="makeRendVar" />
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="starts-with($rendtype, 'indent')">
              <xsl:value-of select="concat(' line--', $rendtype)" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="concat(' rend-', $rendtype)" />
            </xsl:otherwise>
          </xsl:choose>
        </xsl:if>
      </xsl:attribute>
      <xsl:copy-of select="@*[not(local-name()='REND' or local-name()='ID')]" />
      <span><xsl:apply-templates /></span>
      <xsl:if test="@N">
        <span class="line--number">
          <span class="visually-hidden">Line </span>
          <xsl:value-of select="@N" />
          <xsl:text> </xsl:text>
        </span>
      </xsl:if>
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="showMilestoneLineNos">
    <xsl:param name="lineN" />
    <span class="rmarginlineno">
      <xsl:value-of select="concat(' [ ',$lineN,' ]')" />
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:NOTE1//tei:MILESTONE" priority="101" />

  <!-- <xsl:template match="tei:LIST/tei:MILESTONE" priority="101" /> -->

  <xsl:template match="tei:MILESTONE">
    <xsl:choose>
      <xsl:when test="@UNIT = 'paragraph page' and normalize-space(@N)">
        <p class="milestone--paragraph-page">
          <xsl:text>[par. p.</xsl:text>
          <xsl:value-of select="@N" />
          <xsl:text>]</xsl:text>
        </p>
      </xsl:when>
      <xsl:when test="@UNIT = 'verse'">
        <span class="milestone--verse">
          <xsl:text> [verse</xsl:text>
          <xsl:if test="normalize-space(@N)">
            <xsl:text> </xsl:text>
            <xsl:value-of select="@N" />
          </xsl:if>
          <xsl:text>] </xsl:text>
        </span>
      </xsl:when>
      <xsl:when test="@UNIT = 'paragraph page'" />
      <xsl:when test="@UNIT='typographic' and @N">
        <div class="milestone--rule">
          <span>
            <xsl:value-of select="@N" />
          </span>  
        </div>
      </xsl:when>
      <xsl:when test="@REND='asterisk'">
        <div class="milestone--rule">
          <span>
            <xsl:text>*&#xa0;*&#xa0;*</xsl:text>
          </span>  
        </div>
      </xsl:when>
      <xsl:when test="@REND='skipline'">
        <div class="milestone--rule">
          <xsl:text>&#xa0;</xsl:text>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <hr />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:MILESTONE" mode="v1">
    <div class="p-1 m-1 text-align-center">
      <xsl:choose>
        <xsl:when test="@UNIT='typographic' and @N">
          <span style="font-size: 1.5rem">
            <xsl:value-of select="@N" />
          </span>
        </xsl:when>
        <xsl:when test="@REND='asterisk'">
          <span style="white-space: nowrap; font-size: 1.5rem">
            <xsl:text>*&#xa0;*&#xa0;*</xsl:text>
          </span>
        </xsl:when>
        <xsl:when test="@UNIT = 'paragraph page'">
          <p class="text-muted">
            <xsl:text>[par. p.</xsl:text>
            <xsl:value-of select="@N" />
            <xsl:text>]</xsl:text>
          </p>
        </xsl:when>
        <xsl:when test="@REND='skipline'">
          <xsl:text>&#xa0;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <hr />
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>


  <!-- #################### -->
  <xsl:template match="tei:FIRSTL">
    <!-- could do something more with this later? -->
    <xsl:apply-templates />
  </xsl:template>


  <!-- #################### -->
  <xsl:template match="tei:HEAD">
    <xsl:variable name="divlevel" select="substring-after(local-name(..),'DIV')" />
    <xsl:choose>
      <xsl:when test="parent::tei:FIGURE">
        <xsl:element name="div">
          <xsl:attribute name="class">
            <xsl:choose>
              <xsl:when test="$divlevel=1">
                <xsl:value-of select="concat('l',$divlevel,'-head')" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>head</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <strong>
            <xsl:call-template name="addRend" />
          </strong>
          <xsl:apply-templates
            select="following-sibling::tei:PTR" />
        </xsl:element>
      </xsl:when>
      <!-- <xsl:when test="parent::tei:LIST">
        <xsl:apply-templates select="." mode="heading">
          <xsl:with-param name="divlevel" select="$divlevel" />
          <xsl:with-param name="class">
            <xsl:value-of select="concat('fullview-heading fullview-heading-', $divlevel) " />
          </xsl:with-param>
        </xsl:apply-templates>  
      </xsl:when> -->
      <xsl:when test="number($divlevel) = number($divlevel)">
        <xsl:apply-templates select="." mode="heading">
          <xsl:with-param name="divlevel" select="$divlevel" />
          <xsl:with-param name="class">
            <xsl:value-of select="concat('fullview-heading fullview-heading-', $divlevel) " />
          </xsl:with-param>
        </xsl:apply-templates>
      </xsl:when>
      <xsl:otherwise>
        <div>
          <xsl:if test="@ID">
            <xsl:apply-templates select="@ID" />
          </xsl:if>
          <!-- <xsl:if test="tei:ANCHOR">
            <xsl:attribute name="id">
              <xsl:value-of select="tei:ANCHOR" />
            </xsl:attribute>
          </xsl:if> -->
          <xsl:attribute name="class">
            <xsl:text>otherwise fullview-heading </xsl:text>
            <xsl:if test="number($divlevel)">
              <xsl:value-of select="concat('fullview-heading-', $divlevel)" />
            </xsl:if>
          </xsl:attribute>
          <xsl:call-template name="addRend" />
        </div>
        <!-- <xsl:choose>
          <xsl:when test="$divlevel='1'">
            <xsl:element name="h3">
              <xsl:call-template name="addRend" />
            </xsl:element>
          </xsl:when>
          <xsl:when test="$divlevel='2'">
            <xsl:element name="h4">
              <xsl:call-template name="addRend" />
            </xsl:element>
          </xsl:when>
          <xsl:when test="$divlevel='3'">
            <xsl:element name="h5">
              <xsl:call-template name="addRend" />
            </xsl:element>
          </xsl:when>
          <xsl:when test="$divlevel='4'">
            <xsl:element name="h6">
              <xsl:call-template name="addRend" />
            </xsl:element>
          </xsl:when>
          <xsl:when test="$divlevel='5'">
            <xsl:element name="h6">
              <xsl:call-template name="addRend" />
            </xsl:element>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates />
          </xsl:otherwise>
        </xsl:choose> -->
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="node()" mode="heading">
    <xsl:param name="divlevel" />
    <xsl:param name="class" />
    <xsl:choose>
      <xsl:when test="$divlevel = 1">
        <h3 class="{$class}">
          <xsl:apply-templates select="tei:ANCHOR" />
          <xsl:call-template name="addRend" />
        </h3>
      </xsl:when>
      <xsl:when test="$divlevel = 2">
        <h4 class="{$class}">
          <xsl:apply-templates select="tei:ANCHOR" />
          <xsl:call-template name="addRend" />
        </h4>
      </xsl:when>
      <xsl:when test="$divlevel = 3">
        <h5 class="{$class}">
          <xsl:apply-templates select="tei:ANCHOR" />
          <xsl:call-template name="addRend" />
        </h5>
      </xsl:when>
      <xsl:otherwise>
        <div class="{$class}">
          <xsl:apply-templates select="tei:ANCHOR" />
          <xsl:call-template name="addRend" />
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:ANCHOR">
    <span>
      <xsl:attribute name="id">
        <xsl:value-of select="@ID" />
      </xsl:attribute>  
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:KEYWORDS" mode="divinfokw">
    <!-- attributes: TYPE('sub')-->
    <xsl:apply-templates mode="divinfokw" />
  </xsl:template>

  <xsl:template match="tei:TERM" mode="divinfokw">
    <xsl:variable name="termtype">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="./@TYPE"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="preceedingTermType">
      <xsl:if test="preceding-sibling::tei:TERM[@TYPE]">
        <xsl:call-template name="normAttr">
          <xsl:with-param name="attr" select="preceding-sibling::tei:TERM[@TYPE]"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="followingTermType">
      <xsl:if test="preceding-sibling::tei:TERM[@TYPE]">
        <xsl:call-template name="normAttr">
          <xsl:with-param name="attr" select="following-sibling::tei:TERM[@TYPE]"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <div>
      <dt>
        <xsl:choose>
          <xsl:when test="@DATE">
            <xsl:choose>
              <xsl:when test="$preceedingTermType='genre' or $followingTermType='genre'">
                <xsl:value-of select="key('get-lookup','text.components.str.7')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="key('get-lookup','text.components.str.8')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$termtype='gender'">
            <xsl:value-of select="key('get-lookup','text.components.str.9')"/>
          </xsl:when>
          <xsl:when test="$termtype='genre'">
            <xsl:value-of select="key('get-lookup','text.components.str.10')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@TYPE"/>
          </xsl:otherwise>
        </xsl:choose>
      </dt>
      <dd>
        <xsl:value-of select="."/>
      </dd>
    </div>
  </xsl:template>

  <xsl:template match="tei:TERM[not(ancestor::tei:HEADER)]" mode="v1">
    <xsl:variable name="termtype">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="./@TYPE"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:variable name="preceedingTermType">
      <xsl:if test="preceding-sibling::tei:TERM[@TYPE]">
        <xsl:call-template name="normAttr">
          <xsl:with-param name="attr" select="preceding-sibling::tei:TERM[@TYPE]"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <xsl:variable name="followingTermType">
      <xsl:if test="preceding-sibling::tei:TERM[@TYPE]">
        <xsl:call-template name="normAttr">
          <xsl:with-param name="attr" select="following-sibling::tei:TERM[@TYPE]"/>
        </xsl:call-template>
      </xsl:if>
    </xsl:variable>
    <div class="nobreak">
      <xsl:element name="span">
        <xsl:attribute name="class">termlabel</xsl:attribute>
        <xsl:choose>
          <xsl:when test="@DATE">
            <xsl:choose>
              <xsl:when test="$preceedingTermType='genre' or $followingTermType='genre'">
                <xsl:value-of select="key('get-lookup','text.components.str.7')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="key('get-lookup','text.components.str.8')"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:when test="$termtype='gender'">
            <xsl:value-of select="key('get-lookup','text.components.str.9')"/>
          </xsl:when>
          <xsl:when test="$termtype='genre'">
            <xsl:value-of select="key('get-lookup','text.components.str.10')"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="@TYPE"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
      <xsl:element name="span">
        <xsl:value-of select="."/>
      </xsl:element>
      <!-- attributes: DATE,TYPE('publ''gender') -->
    </div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:*" mode="divinfotitle">
    <div>
      <dt>
        <xsl:value-of select="key('get-lookup','text.components.str.11')"/>
      </dt>
      <dd>
        <xsl:value-of select="."/>
      </dd>
    </div>
  </xsl:template>

  <xsl:template match="tei:*" mode="divinfopgref">
    <div>
      <dt>
        <xsl:value-of select="key('get-lookup','text.components.str.12')"/>
      </dt>
      <dd>
        <xsl:value-of select="."/>
      </dd>
    </div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:*" mode="divinfoauth">
    <div>
      <dt>
        <xsl:value-of select="key('get-lookup','text.components.str.13')"/>
      </dt>
      <dd>
        <xsl:value-of select="."/>
      </dd>
    </div>
  </xsl:template>

  <xsl:template match="@ID">
    <xsl:attribute name="id">
      <xsl:value-of select="@id" />
    </xsl:attribute>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:CAPTION">
    <div class="caption">
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:STAGE">
    <xsl:variable name="rendtype">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@REND"/>
      </xsl:call-template>
    </xsl:variable>

    <div>
      <xsl:attribute name="class">
        <xsl:text>stage </xsl:text>
        <xsl:if test="@ALIGN">
          <xsl:variable name="normAlign">
            <xsl:call-template name="normAttr">
              <xsl:with-param name="attr" select="@ALIGN"/>
            </xsl:call-template>
          </xsl:variable>
          <xsl:value-of select="concat('stage--align-', $normAlign, ' ')" />
        </xsl:if>
        <xsl:if test="$rendtype != ''">
          <xsl:value-of select="concat('rend-', $rendtype)" />
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates/>
    </div>
  </xsl:template>


  <!-- #################### -->
  <xsl:template match="tei:SP">
    <div>
      <xsl:attribute name="class">sp</xsl:attribute>
      <xsl:apply-templates/>
    </div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:SPEAKER">
    <div class="speaker">
      <xsl:call-template name="addRend"/>
    </div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="text()" mode="linkify">
    <xsl:value-of select="."/>
  </xsl:template>

  <xsl:template match="text()">
    <xsl:choose>
      <xsl:when test="false() and local-name(preceding-sibling::node()[1]) = 'PTR'" />
      <xsl:otherwise>
        <!-- <xsl:value-of select="."/> -->
        <xsl:copy></xsl:copy>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!--
       this template can be called to add additional rend styles to another
       template result by inserting span tags with a class attribute of
       rend-[val]
       -->  <!-- #################### -->
  <xsl:template name="addRend">
    <xsl:variable name="rendtype">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@REND"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:choose>
      <xsl:when test="$rendtype!=''">
        <xsl:element name="span">
          <xsl:attribute name="class">
            <xsl:value-of select="concat('rend-',$rendtype)"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:ADD" mode="replace">
    <ins data-name="{local-name(preceding-sibling::node()[1])}" data-function="replace">
      <xsl:call-template name="process-add-common" />
      <span class="material-icons" aria-hidden="true">add</span>
      <span><xsl:apply-templates/></span>    
    </ins>  
  </xsl:template>

  <xsl:template match="tei:ADD">
    <xsl:choose>
      <xsl:when test="preceding-sibling::node()[1][local-name() = 'DEL']">
        <!-- <xsl:when test="preceding-sibling::tei:DEL"> -->
        <xsl:if test="false()">
          <ins data-name="{local-name(preceding-sibling::node()[1])}" data-function="replace">
            <xsl:call-template name="process-add-common" />
            <span class="material-icons">add</span>
            <span><xsl:apply-templates/></span>    
          </ins>  
        </xsl:if>
      </xsl:when>
      <xsl:otherwise>
        <ins data-name="{local-name(preceding-sibling::node()[1])}" data-function="add">
          <xsl:call-template name="process-add-common" />
          <span><xsl:apply-templates/></span>
          <span class="material-icons" aria-hidden="true">expand_less</span>    
        </ins>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="process-add-common">
    <xsl:if test="@REND">
      <xsl:attribute name="class">
        <xsl:value-of select="concat('rend-', @REND)"/>
      </xsl:attribute>
    </xsl:if>
    <xsl:if test="@DESC">
      <xsl:attribute name="data-desc">
        <xsl:value-of select="@DESC" />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DEL" mode="v1">
    <del>
      <xsl:if test="@REND">
        <xsl:attribute name="class">
          <xsl:value-of select="concat('rend-', @REND)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@DESC">
        <xsl:attribute name="data-desc">
          <xsl:value-of select="@DESC" />
        </xsl:attribute>
      </xsl:if>
      <span class="material-icons" aria-hidden="true">remove</span>
      <span><xsl:apply-templates/></span>
    </del>
  </xsl:template>

  <xsl:template match="tei:DEL">
    <xsl:choose>
      <xsl:when test="local-name(following-sibling::node()[1]) = 'ADD'">
        <span class="edit-wrap">
          <xsl:apply-templates select="." mode="v1" />
          <xsl:apply-templates select="following-sibling::node()[1]" mode="replace" />
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates select="." mode="v1" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:SALUTE|tei:SIGNED" priority="101">
    <p class="salute indentlevel1 flex flex-flow-row flex-align-center gap-0_5">
      <svg width="2rem" height="1rem" version="1.1" xmlns="http://www.w3.org/2000/svg"><line data-stroke-dasharray="0.9" x1="0" y1="10" x2="350" y2="10"></line></svg>
      <xsl:if test="false()">
      <span>
        <span class="material-icons" aria-hidden="true">horizontal_rule</span>
        <span class="material-icons" aria-hidden="true">horizontal_rule</span>
      </span>
    </xsl:if>
      <span>
        <xsl:apply-templates />
      </span>
    </p>
  </xsl:template>

  <xsl:template match="tei:SALUTE|tei:SIGNED|tei:DATELINE">
    <p class="indentlevel1">
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="tei:P/tei:DATELINE" priority="101">
    <span class="dateline">
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:SEG" mode="v1">
    <xsl:choose>
      <xsl:when test="@ID">
        <span id="{@ID}">
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:otherwise>
      	<xsl:apply-templates/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:SEG">
    <span>
      <xsl:attribute name="class">
        <xsl:text>segment </xsl:text>
        <xsl:if test="@REND">
          <xsl:value-of select="concat('segment--', @REND)" />
        </xsl:if>
      </xsl:attribute>
      <xsl:if test="@ID">
        <xsl:attribute name="ID">
          <xsl:value-of select="@ID" />
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates />
    </span>
  </xsl:template>

  <xsl:template match="tei:TITLE">
    <em><xsl:apply-templates /></em>
  </xsl:template>

  <xsl:template match="tei:Highlight">
    <span class="inline-highlight" id="{concat('hl', @seq)}"
      data-seq="{@seq}" 
      data-first="{$highlight-seq-first}"
      data-last="{$highlight-seq-last}">
      <xsl:if test="@seq &gt; $highlight-seq-first">
        <a 
          class="hl-link button button--secondary button--highlight" 
          href="{concat('#hl', @seq - 1)}"
          aria-label="Highlight #{@seq - 1}">
          <span class="material-icons" aria-hidden="true">
            arrow_back
          </span>
        </a>
      </xsl:if>
      <mark class="{@class}">
        <xsl:value-of select="." />
      </mark>
      <xsl:if test="@seq &lt; $highlight-seq-last">
        <a 
          class="hl-link button button--secondary button--highlight" 
          href="{concat('#hl', @seq + 1)}"
          aria-label="Highlight #{@seq + 1}">
          <span class="material-icons" aria-hidden="true">
            arrow_forward
          </span>              
        </a>
      </xsl:if>
    </span>
  </xsl:template>

  <xsl:template match="tei:NOTE/node()[@ID]" mode="note">
    <xsl:variable name="id" select="@ID" />
    <!-- <xsl:variable name="ptr" select="//tei:PTR[@TARGET=$id]" /> -->
    <xsl:variable name="N">
      <xsl:choose>
        <xsl:when test="@HREF">
          <xsl:value-of select="@N" />
        </xsl:when>
        <xsl:when test="@N">
          <xsl:value-of select="@N" />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="//tei:PTR[@TARGET=$id]/@N" />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <div class="flex flex-flow-row gap-1 flex-align-center pl-1"
      id="fn{$id}">
      <div class="text-bold text-medium footnote-anchor">
        <xsl:choose>
          <xsl:when test="$N != '*'">
            <xsl:value-of select="$N" />
          </xsl:when>
          <xsl:otherwise>
            <!-- <span class="material-icons" aria-hidden="true">emergency</span> -->
            <xsl:call-template name="build-footnote-icon" />
          </xsl:otherwise>
        </xsl:choose>
      </div>
      <div class="footnote-text text-xx-small">
        <xsl:apply-templates select="." />
        <div>
          <a class="button button--secondary text-xx-small"
             href="#back{$id}">
            <span class="material-icons" aria-hidden="true">keyboard_return</span>
            <span>Back to content</span>
          </a>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="tei:HI1|tei:HI2">
    <xsl:variable name="rendtype">
      <xsl:call-template name="makeRendVar"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$rendtype='sub'">
        <sub>
            <xsl:apply-templates/>
        </sub>
      </xsl:when>
      <xsl:when test="$rendtype='sup'">
        <sup>
            <xsl:apply-templates/>
        </sup>
      </xsl:when>
      <xsl:otherwise>
        <xsl:element name="span">
          <xsl:attribute name="class">
              <xsl:value-of select="concat('rend-',$rendtype)"/>
          </xsl:attribute>
          <xsl:apply-templates/>
        </xsl:element>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:if test="$is-skip-consecutive-hi-elements and name(following-sibling::node())=name()">
      <xsl:text> </xsl:text>
    </xsl:if>
  </xsl:template>

  <xsl:template match="tei:ResultFragment">
    <xsl:if test="preceding-sibling::tei:ResultFragment">
      <hr />
    </xsl:if>
    <xsl:apply-templates />
  </xsl:template>

  <xsl:template name="build-footnote-icon">
    <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" fill="currentColor" class="bi bi-x-diamond-fill" viewBox="0 0 16 16" aria-hidden="true">
      <path d="M9.05.435c-.58-.58-1.52-.58-2.1 0L4.047 3.339 8 7.293l3.954-3.954L9.049.435zm3.61 3.611L8.708 8l3.954 3.954 2.904-2.905c.58-.58.58-1.519 0-2.098l-2.904-2.905zm-.706 8.614L8 8.708l-3.954 3.954 2.905 2.904c.58.58 1.519.58 2.098 0l2.905-2.904zm-8.614-.706L7.292 8 3.339 4.046.435 6.951c-.58.58-.58 1.519 0 2.098z"/>
    </svg>    
  </xsl:template>

  <xsl:template match="@ID">
    <xsl:attribute name="id">
      <xsl:value-of select="." />
    </xsl:attribute>
  </xsl:template>

</xsl:stylesheet>