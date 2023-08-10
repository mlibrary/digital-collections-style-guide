<?xml version="1.0" encoding="UTF-8" ?>
<!DOCTYPE root [
<!ENTITY nbsp "&#160;">  
]>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">
  <xsl:template name="build-ww-form">

    <xsl:variable name="key" select="concat('navheader.str.', $page)" />
    <xsl:call-template name="build-breadcrumbs" />
    <qui:header role="main">
      <xsl:text>Advanced Search: </xsl:text>
      <xsl:value-of select="key('get-lookup', $key)" />
    </qui:header>

    <qui:nav role="search">
      <xsl:for-each select="//SearchNav/NavItem[Tab = 'true']">
        <qui:link href="{Link}">
          <xsl:if test="starts-with(Name, 'ww')">
            <xsl:attribute name="current">true</xsl:attribute>
          </xsl:if>
          <xsl:variable name="nav-key" select="concat('navheader.str.', Name)" />
          <qui:label>
            <xsl:value-of select="key('get-lookup', $nav-key)" />
          </qui:label>
        </qui:link>
      </xsl:for-each>
    </qui:nav>

    <xsl:apply-templates select="$search-form/WordWheelList[WWListItem]"/>
    <xsl:apply-templates select="$search-form/WordWheelQuickLinks"/>

    <qui:form id="ww-search">
      <qui:fieldset id="ww-fieldset" slot="ww-form">
        <!-- <qui:legend>
          <xsl:value-of select="key('get-lookup','ww.str.search')"/>
          <xsl:text> </xsl:text>
          <xsl:if test="/Top/DlxsGlobals/CurrentCgi/Param[@name='realm']">
            <xsl:value-of select="key('get-lookup','ww.str.new')"/>
            <xsl:text> </xsl:text>
          </xsl:if>
          <xsl:value-of select="key('get-lookup','ww.str.wordindex')"/>
        </qui:legend> -->
        <qui:block slot="help">
          <xsl:value-of select="key('get-lookup','ww.str.lookfor')"/>
        </qui:block>
        <qui:input name="{$search-form/Q1/Name}" slot="query" label="{key('get-lookup','ww.str.findword')}" />
      </qui:fieldset>
      <qui:hidden-input name="page" value="wwfull" />
      <qui:hidden-input name="realm" value="full text" />
      <xsl:apply-templates select="$search-form/HiddenVars" />
    </qui:form>

  </xsl:template>

  <xsl:template match="WordWheelList">
    <qui:form id="ww-selection">
      <qui:block slot="selection-help">
        <p>
          <xsl:value-of select="key('get-lookup','ww.str.usecheckboxes')"/>
        </p>
        <!-- <p>
          <xsl:value-of select="key('get-lookup','ww.str.moveupdown')"/>
        </p> -->
        <p>
          <xsl:value-of select="key('get-lookup','ww.str.clicksearchbutton')"/>
          <xsl:text> </xsl:text>
          <strong>
            <xsl:value-of select="key('get-lookup','ww.str.any')"/>
          </strong>
          <xsl:text> </xsl:text>
          <xsl:value-of select="key('get-lookup','ww.str.oftheterms')"/>
        </p>
      </qui:block>
      <qui:hidden-input name="page" value="wwfull" />
      <qui:hidden-input name="top" value="{WWListItem[1]/Term}" />
      <qui:hidden-input name="bottom" value="{WWListItem[last()]/Term}" />
      <xsl:apply-templates select="../HiddenVars" />
      <qui:fieldset id="ww-selection-fieldset" slot="ww-selection">
        <qui:table>
          <qui:tbody>
            <xsl:for-each select="WWListItem">
              <qui:tr>
                <xsl:attribute name="class">  
                  <xsl:if test="@bestmatch = '1'">bestmatch</xsl:if>
                  <xsl:if test="@bestmatch = '0'">fuzzymatch</xsl:if>
                </xsl:attribute>
                <qui:td>
                  <qui:input type="checkbox" value="{Term}" label="{Term}">
                    <xsl:if test="Checked = 1">
                      <xsl:attribute name="checked">checked</xsl:attribute>
                    </xsl:if>
                  </qui:input>
                </qui:td>
                <qui:td>
                  <xsl:value-of select="Occur" />
                </qui:td>
              </qui:tr>
            </xsl:for-each>
          </qui:tbody>
        </qui:table>
      </qui:fieldset>  
    </qui:form>
  </xsl:template>

  <xsl:template match="WordWheelQuickLinks">
    <qui:block slot="quickindex-help">
      <p>
        <xsl:value-of select="key('get-lookup','ww.str.quickindex')"/>
        <xsl:text> </xsl:text>
        <xsl:value-of select="key('get-lookup','ww.str.selectcharacter')"/>  
      </p>
    </qui:block>
    <qui:nav slot="quickindex">
      <xsl:for-each select="QuickLinkPair">
        <qui:link href="{Link}">
          <xsl:choose>
            <xsl:when test="contains(Char,'_KEY')">
              <xsl:value-of select="key('kval-expand',Char)"/>
            </xsl:when>
            <xsl:otherwise>
              <xsl:value-of select="Char"/>
            </xsl:otherwise>
          </xsl:choose>
        </qui:link>
      </xsl:for-each>
    </qui:nav>
  </xsl:template>

</xsl:stylesheet>