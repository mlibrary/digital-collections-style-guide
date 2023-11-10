<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="exsl str">

  <xsl:key match="Lookup/Item" name="get-lookup" use="@key"/>
  <xsl:key match="RightsStatements/RightsStatement" name="get-statement" use="@key"/>

  <!-- ################## -->
  <xsl:variable name="template-name" select="/Top/DlxsGlobals/TemplateName"/>

  <!-- ################## -->
  <xsl:variable name="cachedir-path" select="/Top/DlxsGlobals/CacheDirPath"/>

  <!-- ################## -->
  <xsl:variable name="bib-regions">
    <xsl:for-each select="/Top/DlxsGlobals/BibSearchRegionNames/Name">
      <xsl:value-of select="dlxs:normAttr(.)"/>
      <xsl:if test="not(position()=last())">&#xA0;</xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <!-- ################## -->
  <xsl:variable name="all-regions">
    <xsl:for-each select="/Top/DlxsGlobals/AllSearchRegionNames/Name">
      <xsl:value-of select="dlxs:normAttr(.)"/>
      <xsl:if test="not(position()=last())"> &#xA0; </xsl:if>
    </xsl:for-each>
  </xsl:variable>

  <!-- ################## -->
  <xsl:variable name="xc-mode" select="/Top/DlxsGlobals/XcollMode"/>

  <!-- ################## -->
  <xsl:variable name="search-rgn">
    <xsl:choose>
      <xsl:when test="$template-name='text'">
        <xsl:choose>
          <xsl:when test="contains(/Top/ReturnToResultsLink,'rgn=')">
            <xsl:choose>
              <xsl:when test="contains(/Top/ReturnToResultsLink,'subtype=bib')">null</xsl:when>
              <xsl:otherwise>
                <xsl:variable name="return-url-seg" select="substring-after(/Top/ReturnToResultsLink,'rgn=')"/>
                <xsl:value-of select="normalize-space(translate(substring-before($return-url-seg,';'),'%20;',''))"/>
              </xsl:otherwise>
            </xsl:choose>
          </xsl:when>
          <xsl:otherwise>null</xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:when test="$template-name='reslist'">
        <xsl:value-of select="/Top/DlxsGlobals/CurrentCgi/Param[@name='rgn']"/>
      </xsl:when>
    </xsl:choose>
  </xsl:variable>

  <!-- ################## -->
  <xsl:variable name="is-bib-srch">
    <xsl:choose>
      <xsl:when test="key('get-lookup', /Top/SearchDescription/SearchTypeName)='bibliographic'">
        <xsl:text>yes</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:choose>
          <xsl:when test="contains($bib-regions, dlxs:normAttr($search-rgn))">
            <xsl:text>yes</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>no</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- ################## -->
  <xsl:variable name="is-all-rgn-srch">
    <xsl:choose>
      <xsl:when test="contains($all-regions, dlxs:normAttr($search-rgn))">
        <xsl:text>yes</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>no</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- ################## -->
  <xsl:variable name="show-text-hilight">
    <xsl:choose>
      <xsl:when test="$is-all-rgn-srch='no'">no</xsl:when>
      <xsl:when test="$is-bib-srch='yes'">no</xsl:when>
      <xsl:otherwise>yes</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- ################## -->
  <xsl:variable name="is-target">
    <xsl:choose>
      <xsl:when test="/Top/DlxsGlobals/CurrentCgi/Param[@name='view']='trgt'">
        <xsl:text>true</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>false</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- ################## -->
  <xsl:variable name="referrer-href">
    <xsl:choose>
      <xsl:when test="/Top/DlxsGlobals/child::ReferrerHref and /Top/DlxsGlobals/ReferrerHref!=/Top/DlxsGlobals/CurrentUrl">
        <xsl:value-of select="/Top/DlxsGlobals/ReferrerHref"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'null'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <!-- On the priciple that we don't highlight bib regions and
      because not all HEADER elements display, count accordingly and
      make an offset value for building jump links in the Highlight
      template.  Thses are here because they are declared in text.xsl
      but referenced in text.components.xsl however text components
      is also referenced in header.xsl -->
  <xsl:variable name="hl-count" select="count(//Highlight[not(ancestor::HEADER)])"/>
  <xsl:variable name="hl-count-offset" select="(count(//Highlight) - $hl-count)"/>

  <!-- ################## -->
  <xsl:variable name="highlighting-on">
    <xsl:choose>
      <xsl:when test="(/Top/DlxsGlobals/CurrentCgi/Param[@name='q1'] or /Top/DlxsGlobals/CurrentCgi/Param[@name='q2'] or /Top/DlxsGlobals/CurrentCgi/Param[@name='q3']) and $hl-count!='0'">
        <xsl:choose>
          <xsl:when test="not(/Top/DlxsGlobals/CurrentCgi/Param[@name='hi']) or /Top/DlxsGlobals/CurrentCgi/Param[@name='hi']!='0'">
            <xsl:value-of select="'on'"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="'off'"/>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'null'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="go-str">
    <xsl:value-of select="key('get-lookup','text.str.gostr')"/>
  </xsl:variable>

  <!-- ################## -->
  <xsl:variable name="hdr-style">
    <xsl:choose>
      <xsl:when test="/Top/DlxsGlobals/XcollMode='colls'">
        <xsl:value-of select="'xchdrcolor'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'hdrcolor'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="page">
    <xsl:choose>
      <xsl:when test="normalize-space(//Param[@name='page'])">
        <xsl:value-of select="//Param[@name='page']" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="//Param[@name='view']" />
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="subview" select="//Param[@name='subview']" />

  <xsl:variable name="search-type" select="key('get-lookup', /Top/SearchDescription/SearchTypeName)" />

  <xsl:variable name="cgiNode" select="/Top/DlxsGlobals/CurrentCgi"/>
  <xsl:variable name="subject-match-str">
    <xsl:value-of select="key('get-lookup','results.str.33')"/>
  </xsl:variable>
  <xsl:variable name="is-subj-search">
    <xsl:choose>
      <xsl:when
        test="$cgiNode/Param[
        @name = 'rgn'  or
        @name = 'rgn1' or
        @name = 'rgn2' or
        @name = 'rgn3'
        ] = $subject-match-str">
        <xsl:value-of select="'yes'"/>
      </xsl:when>
      <xsl:otherwise>
        <xsl:value-of select="'no'"/>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:variable>
  <xsl:variable name="include-useguidelines-metadata">no</xsl:variable>
  <xsl:variable name="include-print-source-metadata">no</xsl:variable>
  <xsl:variable name="include-bookmark">no</xsl:variable>
  <xsl:variable name="display-layout" select="normalize-space(//Top/ResList/Results/DisplayLayout)"/>
  <xsl:variable name="display-type" select="normalize-space(//Top/ResList/Results/DisplayType)"/>
  <xsl:variable name="BuildLinks">
    <xsl:choose>
      <xsl:when test="/Top/AuthRequired='true'">false</xsl:when>
      <xsl:otherwise>true</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

</xsl:stylesheet>
