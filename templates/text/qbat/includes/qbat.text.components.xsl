<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:qbat="http://dlxs.org/quombat/quombat" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org" xmlns:exsl="http://exslt.org/common" xmlns:math="http://exslt.org/math" xmlns:tei="http://www.tei-c.org/ns/1.0" extension-element-prefixes="exsl math">

  <xsl:key match="qui:lookup" name="get-lookup" use="@key"/>

  <xsl:variable name="is-target" select="//qui:block[@slot='content']/@is-target" />
  
  <!-- <xsl:variable name="highlight-count" select="//qui:block[@slot='content']/@highlight-count"/>
  <xsl:variable name="highlight-count-offset" select="//qui:block[@slot='content']/@highlight-count-offset"/> -->

  <xsl:variable name="highlights" select="//tei:TEXT//tei:Highlight" />

  <xsl:variable name="highlight-seq-last" select="//tei:TEXT//tei:Highlight[last()]/@seq"/>
  <xsl:variable name="highlight-seq-first" select="//tei:TEXT//tei:Highlight[1]/@seq"/>


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
  <xsl:template match="tei:PTR[@HREF]">
    <xsl:variable name="type">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$type='txt'">
        <xsl:call-template name="txtpointer"/>
      </xsl:when>
      <xsl:otherwise>
        <qui:link rel="ptr" name="{@TARGET}" href="{@HREF}">
          <xsl:value-of select="concat('[', @N, ']')"/>
        </qui:link>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="txtpointer">
    <qui:link rel="txtptr" name="{@TARGET}" href="{@HREF}">
      <xsl:value-of select="@N"/>
    </qui:link>
  </xsl:template>

  <xsl:template match="tei:P[tei:PB]" priority="100">
    <article id="{parent::*/@ID}-{PB/@SEQ}" class="fullview-page" data-count="{$highlights[1]/@seq}">
      <xsl:apply-templates select="tei:PB" mode="build-p" />
      <xsl:apply-templates select="." mode="build-p" />
    </article>
  </xsl:template>

    <!-- #################### -->
  <xsl:template match="tei:P/tei:PB" mode="build-p">
    <xsl:variable name="pNum">
      <xsl:choose>
        <xsl:when test="@DISPLAYN[string-length()&gt;=1]">
          <xsl:value-of select="@DISPLAYN"/>
        </xsl:when>
        <xsl:when test="@N[string-length()&gt;=1]">
          <xsl:value-of select="@N"/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="key('get-lookup','text.components.str.1')"/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <h3>
      <xsl:if test="@ID">
        <xsl:attribute name="id">
          <xsl:value-of select="@ID"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@HREF">
          <a href="{@HREF}">
            <xsl:value-of select="concat(key('get-lookup','headerutils.str.page'), ' ', $pNum)"/>
          </a>
        </xsl:when>
        <xsl:otherwise>
          <span>
            <xsl:value-of select="key('get-lookup','headerutils.str.page')"/>
            <xsl:text> </xsl:text>
            <xsl:value-of select="$pNum"/>  
          </span>
        </xsl:otherwise>
      </xsl:choose>
    </h3>
  </xsl:template>

  <xsl:template match="tei:PB" />

  <!-- #################### -->
  <xsl:template match="tei:EPB"/>

  <!-- turn line breaks in data into br's for html output -->
  <!-- #################### -->
  <xsl:template match="tei:LB">
    <qui:br/>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="ReturnLink">
    <!-- link back to text/ptr from note if possible -->
    <xsl:if test="$is-target='true' and $referrerhref!='null'">
      <qui:link rel="return" name="{concat(@ID,'text')}" href="{concat($referrerhref,'#',@ID)}">
        <xsl:value-of select="key('get-lookup','text.components.str.returntotext')"/>
      </qui:link>
    </xsl:if>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DIV1">
    <xsl:variable name="divtype">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE"/>
      </xsl:call-template>
    </xsl:variable>

    <section name="{local-name()}">
      <xsl:if test="@ID">
        <xsl:attribute name="id"><xsl:value-of select="@ID"/></xsl:attribute>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="$divtype='titlepage'">
          <xsl:call-template name="titlepage"/>
        </xsl:when>
        <xsl:when test="$divtype='dedication'">
          <xsl:call-template name="titlepage"/>
        </xsl:when>
        <xsl:when test="$divtype='toc'">
          <xsl:apply-templates/>
        </xsl:when>
        <xsl:otherwise>
          <xsl:choose>
            <xsl:when test="tei:DIVINFO">
              <xsl:apply-templates select="tei:HEAD[1]"/>
              <xsl:call-template name="printdivinfo"/>
              <xsl:apply-templates select="*[local-name()!='DIVINFO'][local-name()!='HEAD']"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:call-template name="ReturnLink"/>
    </section>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:TEXT|tei:FRONT|tei:BODY|tei:BACK|tei:DLPSTEXTCLASS">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:HEADER"/>

  <!-- #################### -->
  <xsl:template name="printdivinfo">
    <xsl:for-each select="tei:DIVINFO">
      <xsl:choose>
        <xsl:when test="parent::*[starts-with(local-name(),'DIV')]/@TYPE">
          <xsl:variable name="parentDivType" select="parent::*/@TYPE"/>
          <xsl:variable name="parentDivTypenorm">
            <xsl:call-template name="normAttr">
              <xsl:with-param name="attr" select="parent::*/@TYPE"/>
            </xsl:call-template>
          </xsl:variable>
          <qui:section slot="infoheader">
            <qui:field>
              <qui:label>
                <xsl:value-of select="key('get-lookup','text.components.str.2')"/>
                <xsl:value-of select="$parentDivType"/>
              </qui:label>
              <xsl:apply-templates select="tei:AUTHOR" mode="divinfoauth"/>
              <xsl:apply-templates select="tei:KEYWORDS" mode="divinfokw"/>
            </qui:field>
          </qui:section>
        </xsl:when>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="titlepage">
    <qui:div class="titlepage">
      <xsl:apply-templates/>
    </qui:div>
  </xsl:template>

  <!-- title page templates -->
  <!-- #################### -->
  <xsl:template match="tei:TITLEPAGE">
    <xsl:apply-templates/>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DOCTITLE">
    <qui:div class="doctitle">
      <xsl:apply-templates/>
    </qui:div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:TITLEPART">
    <xsl:apply-templates/>
    <xsl:if test="position()!=last()">
      <xsl:text>:&#xa0;</xsl:text>
    </xsl:if>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:BYLINE">
    <qui:div class="byline">
      <xsl:apply-templates/>
    </qui:div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DOCAUTHOR">
    <qui:div class="docauthor">
      <xsl:apply-templates/>
    </qui:div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DOCIMPRINT">
    <qui:div class="docimprint">
      <xsl:for-each select="*">
        <xsl:apply-templates select="."/>
        <br/>
      </xsl:for-each>
    </qui:div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:CAESURA">
    <qui:div>
      <xsl:value-of select="key('get-lookup','text.components.str.3')"/>
    </qui:div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:ALIAS">
    <span class="alias">
      <xsl:value-of select="concat('(a.k.a ',.,' )')"/>
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:FOREIGN">
    <span class="foreign">
      <xsl:value-of select="."/>
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:SIC">
    <span class="sic">
      <xsl:if test="@CORR">
        <xsl:value-of select="@CORR"/>
        <xsl:text>&#xa0;</xsl:text>
      </xsl:if>
      <xsl:text>[&#xa0;</xsl:text>
      <xsl:value-of select="."/>
      <xsl:text>&#xa0;]</xsl:text>
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:GAP">
    <span class="gap">
      <xsl:text>&#xa0;[&#xa0;</xsl:text>
      <xsl:value-of select="concat(&apos;gap: &apos;,@EXTENT)"/>
      <xsl:if test="@REASON">
        <xsl:value-of select="concat(&apos;;reason: &apos;,@REASON)"/>
      </xsl:if>
      <xsl:text>&#xa0;]&#xa0;</xsl:text>
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:P[ancestor::FIGURE]" priority="10">
    <p>
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <xsl:template match="tei:P">
    <xsl:apply-templates select="." mode="build-p" />
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:P" mode="build-p">
    <!-- normalize type value -->
    <xsl:variable name="type">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE"/>
      </xsl:call-template>
    </xsl:variable>
    <!-- *** -->
    <!-- assuming INDENT and TYPE="skipline|tei:author|tei:title|tei:subtitle" are mutually exclusive: -->
    <xsl:choose>
    <xsl:when test="$type='title'">
	<!-- create semantic h1 tag for article title  -->
      <h3>
        <xsl:attribute name="class">
          <xsl:value-of select="concat($type,'-semantic')"/>
        </xsl:attribute>
        <xsl:call-template name="ParaAttrPassThru"/>
        <xsl:apply-templates/>
      </h3>
    </xsl:when>
    <xsl:when test="$type='subtitle'">
      <h4>
        <xsl:attribute name="class">
          <xsl:value-of select="concat($type,'-semantic')"/>
        </xsl:attribute>
        <xsl:call-template name="ParaAttrPassThru"/>
        <xsl:apply-templates/>
      </h4>
    </xsl:when>
    <xsl:when test="$type='author'">
      <qui:field slot="author">
        <qui:values>
          <qui:value>
            <xsl:apply-templates/>
          </qui:value>
        </qui:values>
      </qui:field>
    </xsl:when>
    <xsl:otherwise>
      <p class="plaintext">
        <xsl:call-template name="ParaAttrPassThru"/>
        <xsl:choose>
          <xsl:when test="@INDENT">
            <xsl:attribute name="style">
              <xsl:value-of select="concat('margin-left:',@INDENT,'em')"/>
            </xsl:attribute>
            <xsl:apply-templates/>
          </xsl:when>
          <xsl:when test="$type='skipline'">
            <br/>
            <xsl:text disable-output-escaping="yes">&amp;nbsp;</xsl:text>
            <br/>
            <xsl:apply-templates/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates/>
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
              <xsl:value-of select="."/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:call-template name="normAttr">
                <xsl:with-param name="attr" select="."/>
              </xsl:call-template>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:attribute>
      </xsl:for-each>
      <xsl:if test="@REND">
        <xsl:attribute name="class">
          <xsl:value-of select="concat('rend-',@REND)"/>
        </xsl:attribute>
      </xsl:if>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:TABLE">
    <table>
      <xsl:copy-of select="@*"/>
      <xsl:if test="@ID">
        <xsl:attribute name="id"><xsl:value-of select="@ID"/></xsl:attribute>
      </xsl:if>
      <xsl:if test="not(@CLASS)">
        <!-- distinguish as source xml table (vs. an html table) -->
        <xsl:attribute name="class">
          <xsl:text>xmltable</xsl:text>
          <!-- allow for REND styles to be applied -->
          <xsl:if test="@REND!=''">
            <xsl:value-of select="concat('-rend-', @REND)"/>
          </xsl:if>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="./tei:CAPTION"/>
      <xsl:apply-templates select="*[not(local-name()='CAPTION')]"/>
    </table>
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
            <xsl:value-of select="concat('-rend-', @REND)"/>
          </xsl:if>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@COLSPAN">
        <xsl:attribute name="colspan">
          <xsl:value-of select="@COLSPAN"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:if test="@ROWSPAN">
        <xsl:attribute name="rowspan">
          <xsl:value-of select="@ROWSPAN"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
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
            <xsl:value-of select="concat('-rend-', @REND)"/>
          </xsl:if>
        </xsl:attribute>

      </xsl:if>
      <xsl:apply-templates/>
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
          <xsl:value-of select="@ID"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:apply-templates/>
    </li>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:LIST">
    <xsl:choose>
      <xsl:when test="@TYPE='ordered' or @TYPE='numbered'">
        <ol>
          <xsl:apply-templates select="@ID" />
          <xsl:apply-templates/>
        </ol>
      </xsl:when>
      <xsl:otherwise>
        <ul>
          <xsl:apply-templates select="@ID" />
          <xsl:if test="@TYPE">
            <xsl:attribute name="class">
              <xsl:value-of select="@TYPE"/>
            </xsl:attribute>
          </xsl:if>
          <xsl:apply-templates/>
        </ul>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:NOTE1|tei:NOTE2">
    <xsl:variable name="view">
      <xsl:value-of select="/Top/DlxsGlobals/CurrentCgi/Param[@name='view']"/>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="not(@HREF)">
        <!-- no @HREF, therefore render the note content -->
        <xsl:choose>
          <xsl:when test="$view='trgt'">
            <xsl:call-template name="filterNotesInTarget"/>
          </xsl:when>
          <xsl:when test="$view='text'">
            <xsl:call-template name="filterNotesInText"/>
          </xsl:when>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="$view='text'">
            <!-- only build anchor for text view, not target or reslist unless ... -->
            <xsl:call-template name="buildNoteAnchor"/>
          </xsl:when>
          <xsl:when test="$view='trgt'">
            <xsl:variable name="targetID">
              <xsl:value-of select="/Top/DlxsGlobals/CurrentCgi/Param[@name='id']"/>
            </xsl:variable>
            <xsl:choose>
              <!-- handle the case of notes within notes -->
              <xsl:when test="not(@ID=$targetID)">
                <!-- ... this is a note with an href but not the one currently targeted,
                     so build an anchor -->
                <xsl:call-template name="buildNoteAnchor"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:call-template name="filterNotesInTarget"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="buildNoteAnchor">
    <!--  replace NOTE1 with an anchor -->
    <span class="ptr">
      <!-- return anchor: -->
      <xsl:element name="a">
        <xsl:attribute name="name">
          <xsl:value-of select="@ID"/>
        </xsl:attribute>
      </xsl:element>
      <xsl:element name="a">
        <xsl:attribute name="href">
          <xsl:value-of select="@HREF"/>
        </xsl:attribute>
        <xsl:choose>
          <xsl:when test="@N">
            <xsl:value-of select="@N"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'*'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:element>
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="filterNotesInText">
    <xsl:choose>
      <xsl:when test="tei:P and @N">
        <xsl:call-template name="filterNumberedNoteWithParas"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:if test="@N">
          <span class="notenumber">
            <xsl:value-of select="concat(@N,'. ')"/>
          </span>
        </xsl:if>
        <!-- it's an inline note -->
        <xsl:if test="not(tei:P) and not(tei:TABLE)">
          <xsl:text>[</xsl:text>
        </xsl:if>
        <xsl:apply-templates select="tei:BIBL|tei:DATE|tei:FIGURE|tei:FOREIGN|tei:GAP|tei:HEAD|tei:HI1|tei:HI2|tei:Highlight|tei:P|tei:PB|tei:Q1|tei:REF|tei:TABLE|text()"/>
        <xsl:if test="not(tei:P) and not(tei:TABLE)">
          <xsl:text>]</xsl:text>
        </xsl:if>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="filterNotesInTarget">
    <xsl:choose>
      <xsl:when test="P and @N">
        <xsl:call-template name="filterNumberedNoteWithParas"/>
      </xsl:when>
      <xsl:otherwise>
        <!-- Only a literal N value, in case it's inline -->
        <xsl:if test="@N">
          <span class="notenumber">
            <xsl:value-of select="concat(@N,'. ')"/>
          </span>
        </xsl:if>
        <xsl:apply-templates select="tei:BIBL|tei:CLOSER|tei:DATE|tei:FIGURE|tei:FOREIGN|tei:GAP|tei:HI1|tei:HI2|tei:Highlight|tei:NOTE2|tei:PB|tei:Q1|tei:REF|tei:TABLE|text()"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="filterNumberedNoteWithParas">
    <xsl:for-each select="node()">
      <xsl:choose>
        <xsl:when test="local-name()='P'">
          <xsl:if test="@ID">
            <xsl:element name="a">
              <xsl:attribute name="id">
                <xsl:value-of select="@ID"/>
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
                          <xsl:value-of select="concat(parent::*/@N,'. ')"/>
                        </xsl:when>
                        <xsl:otherwise>
                          <sup><xsl:value-of select="concat(parent::*/@N, ' ')"/></sup>
                        </xsl:otherwise>
                      </xsl:choose>
                    </xsl:when>
                    <xsl:otherwise>
                      <xsl:value-of select="concat(substring-after(parent::tei:NOTE1/@ID,'DLPS'),'. ')"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </span>
                <xsl:apply-templates select="tei:BIBL|tei:CLOSER|tei:DATE|tei:FIGURE|tei:FOREIGN|tei:GAP|tei:HI1|tei:HI2|tei:Highlight|tei:NOTE2|tei:PB|tei:PTR|tei:Q1|tei:REF|tei:TABLE|tei:LIST|text()"/>
              </p>
            </xsl:when>
            <xsl:otherwise>
              <p>
                <xsl:apply-templates select="tei:BIBL|tei:CLOSER|tei:DATE|tei:FIGURE|tei:FOREIGN|tei:GAP|tei:HI1|tei:HI2|tei:Highlight|tei:NOTE2|tei:PB|tei:PTR|tei:Q1|tei:REF|tei:TABLE|tei:LIST|text()"/>
              </p>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates select="."/>
        </xsl:otherwise>
      </xsl:choose>
    </xsl:for-each>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DATE">
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:Q1">
    <xsl:variable name="type">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:element name="div">
      <xsl:choose>
        <xsl:when test="@TYPE">
          <xsl:attribute name="class">
            <xsl:value-of select="concat('q1-',$type)"/>
          </xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <xsl:attribute name="class">q1</xsl:attribute>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <xsl:template match="tei:BIBL[not(ancestor::tei:HEADER)]">
    <xsl:if test="@ID">
      <xsl:element name="a">
        <xsl:attribute name="name"><xsl:value-of select="@ID"/></xsl:attribute>
      </xsl:element>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="parent::tei:EPIGRAPH">
        <div class="bibl">
          <xsl:apply-templates/>
        </div>
      </xsl:when>
      <xsl:when test="tei:TITLE">
        <cite>
          <xsl:apply-templates select="tei:TITLE" />
        </cite>
      </xsl:when>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="tei:REF">
    <xsl:variable name="type">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE"/>
      </xsl:call-template>
    </xsl:variable>
    <xsl:choose>
      <xsl:when test="$type='url' and @URL">
        <span class="ref">
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="@URL"/>
            </xsl:attribute>
            <xsl:attribute name="target">
              <xsl:text>_blank</xsl:text>
            </xsl:attribute>
            <xsl:apply-templates/>
          </xsl:element>
        </span>
      </xsl:when>
      <xsl:when test="$type='audio' and @FILENAME">
        <span class="ref">
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="@SYSTEMFILEPATH"/>
            </xsl:attribute>
            <xsl:attribute name="target">
              <xsl:text>_blank</xsl:text>
            </xsl:attribute>
            <xsl:element name="img">
              <xsl:attribute name="src">
                <xsl:value-of select="'/t/text/graphics/audio.gif'"/>
              </xsl:attribute>
              <xsl:attribute name="alt">
                <xsl:value-of select="key('get-lookup','text.components.str.audio')"/>
              </xsl:attribute>
            </xsl:element>
            <xsl:text>&#xa0;</xsl:text>
          </xsl:element>
          <xsl:apply-templates/>
        </span>
      </xsl:when>
      <xsl:when test="@HREF">
        <span class="ref">
          <xsl:element name="a">
            <xsl:attribute name="href">
              <xsl:value-of select="@HREF"/>
            </xsl:attribute>
            <xsl:apply-templates/>
          </xsl:element>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span class="ref">
          <xsl:apply-templates/>
        </span>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>
  
  <!-- #################### -->
  <xsl:template match="tei:EPIGRAPH|tei:SIGNED|tei:TRAILER|tei:CLOSER|tei:PREFACE|tei:ARGUMENT|tei:DEDICAT|tei:OPENER">
    <xsl:variable name="divclass">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="local-name()"/>
      </xsl:call-template>
    </xsl:variable>
    <div class="{$divclass}">
      <xsl:choose>
        <xsl:when test="@REND">
          <xsl:variable name="rendtype">
            <xsl:call-template name="makeRendVar"/>
          </xsl:variable>
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

    </div>
  </xsl:template>


  <!-- #################### -->
  <xsl:template name="BuildFigImg">
    <xsl:param name="figHref"/>
    <xsl:param name="figAlt"/>
    <xsl:param name="figTitle"/>
    <xsl:param name="figClass"/>

    <xsl:element name="img">
      <xsl:attribute name="src">
        <xsl:value-of select="$figHref"/>
      </xsl:attribute>
      <xsl:attribute name="alt">
        <xsl:value-of select="$figAlt"/>
      </xsl:attribute>
      <xsl:attribute name="title">
        <xsl:value-of select="$figTitle"/>
      </xsl:attribute>
      <xsl:if test="$figClass">
        <xsl:attribute name="class">
          <xsl:value-of select="$figClass"/>
        </xsl:attribute>
      </xsl:if>
    </xsl:element>
  </xsl:template>


  <!-- #################### -->
  <xsl:template match="tei:FIGURE">
    <!-- attributes:ID,ENTITY[FIGTYPE=INLINE|tei:THUMB, HREF_1,HREF_2] -->

    <xsl:if test="@ID">
      <xsl:element name="a">
        <xsl:attribute name="name">
          <xsl:value-of select="@ID"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>

    <div class="figure">
      <xsl:choose>
        <xsl:when test="not(@FIGTYPE)">
          <xsl:value-of select="key('get-lookup','text.components.str.6')"/>
          <xsl:apply-templates/>
        </xsl:when>

        <xsl:otherwise>
          <!-- inline image -->

          <xsl:choose>
            <xsl:when test="@FIGTYPE='INLINE'">
              <xsl:choose>
                <xsl:when test="@HREF_1">
                  <xsl:call-template name="BuildFigImg">
                    <xsl:with-param name="figHref" select="@HREF_1"/>
                    <xsl:with-param name="figAlt" select="key('get-lookup','text.components.str.5')"/>
                    <xsl:with-param name="figTitle" select="key('get-lookup','text.components.str.5')"/>
                  </xsl:call-template>
                </xsl:when>
                <xsl:otherwise>
                  <!-- [missing figure] -->
                  <xsl:value-of select="key('get-lookup','text.components.str.6')"/>
                </xsl:otherwise>
              </xsl:choose>

              <xsl:apply-templates select="tei:P|tei:FIGDESC|tei:HEAD"/>
            </xsl:when>

            <!-- thumb image links to full size image-->

            <xsl:when test="@FIGTYPE='THUMB'">
              <xsl:choose>
                <!-- if there is a thumb URL -->
                <xsl:when test="@HREF_1">
                  <xsl:choose>
                    <!-- and if there is a full image URL -->
                    <xsl:when test="@HREF_2">
                      <xsl:element name="a">
                        <xsl:attribute name="href">
                          <xsl:value-of select="@HREF_2"/>
                        </xsl:attribute>
                        <xsl:call-template name="BuildFigImg">
                          <xsl:with-param name="figHref" select="@HREF_1"/>
                          <xsl:with-param name="figAlt" select="key('get-lookup','text.components.str.clickenlarge')"/>
                          <xsl:with-param name="figTitle" select="key('get-lookup','text.components.str.clickenlarge')"/>
                          <xsl:with-param name="figClass" select="'thumbfigure'"/>
                        </xsl:call-template>
                      </xsl:element>
                      <br/>
                      <!-- second link on an image of some text saying "click to enlarge image" -->
                      <xsl:element name="a">
                        <xsl:attribute name="href">
                          <xsl:value-of select="@HREF_2"/>
                        </xsl:attribute>
                        <img src="/t/text/graphics/enlarge.gif" border="0" alt="click to enlarge image"/>
                      </xsl:element>

                      <xsl:apply-templates select="tei:P|tei:FIGDESC|tei:HEAD"/>
                    </xsl:when>

                    <!-- else no URL to full sized image, just the thumbnail -->
                    <xsl:otherwise>
                      <xsl:call-template name="BuildFigImg">
                        <xsl:with-param name="figHref" select="@HREF_1"/>
                        <xsl:with-param name="figAlt" select="key('get-lookup','text.components.str.5')"/>
                        <xsl:with-param name="figTitle" select="key('get-lookup','text.components.str.5')"/>
                      </xsl:call-template>

                      <xsl:apply-templates select="tei:P|tei:FIGDESC|tei:HEAD"/>
                    </xsl:otherwise>
                  </xsl:choose>
                </xsl:when>

                <!-- no thumb URL but do have a URL to full image so text link to full -->
                <xsl:when test="@HREF_2">
                  <xsl:element name="a">
                    <xsl:attribute name="href">
                      <xsl:value-of select="@HREF_2"/>
                    </xsl:attribute>
                    <!-- [figure] -->
                    <xsl:value-of select="key('get-lookup','text.components.str.5')"/>
                  </xsl:element>

                  <xsl:apply-templates select="tei:P|tei:FIGDESC|tei:HEAD"/>
                </xsl:when>

                <!-- no thumb or full image URLs: [missing figure] -->
                <xsl:otherwise>
                  <xsl:value-of select="key('get-lookup','text.components.str.6')"/>
                  <xsl:apply-templates/>
                </xsl:otherwise>
              </xsl:choose>
            </xsl:when>

            <xsl:otherwise>
              <!-- missing figure -->
              <xsl:value-of select="key('get-lookup','text.components.str.6')"/>
              <xsl:apply-templates/>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
    </div>
  </xsl:template>


  <!-- #################### -->
  <xsl:template match="tei:FIGDESC">
    <div class="caption">
      <xsl:value-of select="."/>
    </div>
  </xsl:template>


  <!-- #################### -->
  <xsl:template match="tei:LG">
    <!-- attributes:  TYPE('verse''section'),ID -->
    <xsl:variable name="type">
      <xsl:call-template name="normAttr">
        <xsl:with-param name="attr" select="@TYPE"/>
      </xsl:call-template>
    </xsl:variable>

    <xsl:if test="@ID">
      <xsl:element name="a">
        <xsl:attribute name="name"><xsl:value-of select="@ID"/></xsl:attribute>
      </xsl:element>
    </xsl:if>
    <xsl:text>&#x0a;</xsl:text>
    <xsl:element name="div">
      <xsl:attribute name="class">
        <xsl:choose>
          <xsl:when test="@TYPE">
            <xsl:value-of select="concat('lg-',$type)"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>lg</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:copy-of select="@*[local-name()!='TYPE']"/>
      <xsl:call-template name="addRend"/>
    </xsl:element>
  </xsl:template>


  <!-- #################### -->
  <xsl:template match="tei:L">
    <xsl:if test="@ID">
      <xsl:element name="a">
        <xsl:attribute name="name">
          <xsl:value-of select="@ID"/>
        </xsl:attribute>
      </xsl:element>
    </xsl:if>
    <xsl:element name="div">
      <xsl:choose>
        <xsl:when test="not(@REND)">
          <xsl:attribute name="class">line</xsl:attribute>
        </xsl:when>
        <xsl:otherwise>
          <!-- assuming a rend type of "indent" or "indentx" where x is a digit 1 to 6 -->
          <!-- HI1 can accommodate othere rend types -->
          <xsl:variable name="rendtype">
            <xsl:call-template name="makeRendVar"/>
          </xsl:variable>
          <xsl:choose>
            <xsl:when test="starts-with($rendtype, 'indent')">
              <xsl:attribute name="class">
                <xsl:value-of select="concat('line', $rendtype)"/>
              </xsl:attribute>
            </xsl:when>
            <xsl:otherwise>
              <xsl:attribute name="class">
                <xsl:value-of select="concat('rend-', $rendtype)"/>
              </xsl:attribute>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:copy-of select="@*[not(local-name()='REND')]"/>
      <xsl:apply-templates/>
    </xsl:element>
    <xsl:text>&#x0a;</xsl:text>
  </xsl:template>

  <!-- #################### -->
  <xsl:template name="showMilestoneLineNos">
    <xsl:param name="lineN"/>
    <span class="rmarginlineno">
      <xsl:value-of select="concat(' [ ',$lineN,' ]')"/>
    </span>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:MILESTONE">
    <xsl:choose>
      <xsl:when test="@UNIT='typographic' and @N">
        <div class="milestone-typo">
          <xsl:value-of select="@N"/>
        </div>
      </xsl:when>
      <xsl:otherwise>
        <div style="text-align:center;padding-top:1em;padding-bottom:1em;">
          <xsl:choose>
            <xsl:when test="@REND='asterisk'">
              <xsl:text>*&#xa0;*&#xa0;*</xsl:text>
            </xsl:when>
            <xsl:when test="@REND='skipline'">
              <xsl:text>&#xa0;</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <hr style="margin-right:40%;margin-left:40%;"/>
            </xsl:otherwise>
          </xsl:choose>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>


  <!-- #################### -->
  <xsl:template match="tei:FIRSTL">
    <!-- could do something more with this later? -->
    <xsl:apply-templates/>
  </xsl:template>




  <!-- #################### -->
  <xsl:template match="tei:HEAD">
    <xsl:variable name="divlevel" select="substring-after(local-name(..),'DIV')"/>
    <xsl:choose>
      <xsl:when test="parent::tei:FIGURE">
        <br/>
        <xsl:element name="div">
          <xsl:attribute name="class">
            <xsl:choose>
              <xsl:when test="$divlevel=1">
                <xsl:value-of select="concat('l',$divlevel,'-head')"/>
              </xsl:when>
              <xsl:otherwise>
                <xsl:text>head</xsl:text>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
          <strong>
            <xsl:call-template name="addRend"/>
          </strong>
          <xsl:apply-templates select="following-sibling::tei:PTR"/>
        </xsl:element>
      </xsl:when>
      <xsl:otherwise>
	<xsl:choose>
	  <xsl:when test="$divlevel='1'">
	    <xsl:element name="h2">
	      <xsl:call-template name="addRend"/>
	    </xsl:element>
	  </xsl:when>
	  <xsl:when test="$divlevel='2'">
	    <xsl:element name="h3">
	      <xsl:call-template name="addRend"/>
	    </xsl:element>
	  </xsl:when>
	  <xsl:when test="$divlevel='3'">
	    <xsl:element name="h4">
	      <xsl:call-template name="addRend"/>
	    </xsl:element>
	  </xsl:when>
	  <xsl:when test="$divlevel='4'">
	    <xsl:element name="h5">
	      <xsl:call-template name="addRend"/>
	    </xsl:element>
	  </xsl:when>
	  <xsl:when test="$divlevel='5'">
	    <xsl:element name="h6">
	      <xsl:call-template name="addRend"/>
	    </xsl:element>
	  </xsl:when>
	  <xsl:otherwise>
            <xsl:apply-templates/>
          </xsl:otherwise>
	</xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:KEYWORDS" mode="divinfokw">
    <!-- attributes: TYPE('sub')-->
    <xsl:apply-templates/>
  </xsl:template>

  <xsl:template match="tei:TERM[not(ancestor::tei:HEADER)]">
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
    <qui:field>
      <qui:label>
        <xsl:value-of select="key('get-lookup','text.components.str.11')"/>
      </qui:label>
      <qui:values>
        <qui:value>
          <xsl:value-of select="."/>
        </qui:value>
      </qui:values>
    </qui:field>
  </xsl:template>

  <xsl:template match="tei:*" mode="divinfopgref">
    <qui:field>
      <qui:label>
        <xsl:value-of select="key('get-lookup','text.components.str.12')"/>
      </qui:label>
      <qui:values>
        <qui:value>
          <xsl:value-of select="."/>
        </qui:value>
      </qui:values>
    </qui:field>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:*" mode="divinfoauth">
    <qui:field>
      <qui:label>
        <xsl:value-of select="key('get-lookup','text.components.str.13')"/>
      </qui:label>
      <qui:values>
        <qui:value>
          <xsl:value-of select="."/>
        </qui:value>
      </qui:values>
    </qui:field>
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

    <xsl:element name="div">
      <xsl:attribute name="class">stage</xsl:attribute>
      <xsl:if test="@ALIGN">
        <xsl:variable name="normAlign">
          <xsl:call-template name="normAttr">
            <xsl:with-param name="attr" select="@ALIGN"/>
          </xsl:call-template>
        </xsl:variable>
        <xsl:choose>
          <xsl:when test="contains($normAlign,'c')">
            <xsl:attribute name="style">padding-left:20px;padding-right:20px</xsl:attribute>
          </xsl:when>
          <xsl:when test="contains($normAlign,'r')">
            <xsl:attribute name="align">right</xsl:attribute>
          </xsl:when>
          <xsl:when test="contains($normAlign,'l')">
            <xsl:attribute name="align">left</xsl:attribute>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
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
    </xsl:element>
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
  <xsl:template match="text()">
    <xsl:value-of select="."/>
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
  <xsl:template match="tei:ADD">
    <xsl:element name="span">
      <xsl:attribute name="class">add</xsl:attribute>
      <xsl:attribute name="title">
        <xsl:choose>
          <xsl:when test="@DESC">
            <xsl:value-of select="@DESC"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="key('get-lookup','text.components.str.addition')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DEL">
    <xsl:element name="span">
      <xsl:if test="@REND">
        <xsl:attribute name="class">
          <xsl:value-of select="concat('rend-', @REND)"/>
        </xsl:attribute>
      </xsl:if>
      <xsl:attribute name="title">
        <xsl:choose>
          <xsl:when test="@DESC">
            <xsl:value-of select="@DESC"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="key('get-lookup','text.components.str.deletion')"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>
      <xsl:apply-templates/>
    </xsl:element>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:SALUTE|tei:SIGNED|tei:DATELINE">
    <p class="indentlevel1">
      <xsl:apply-templates/>
    </p>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:SEG">
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

</xsl:stylesheet>