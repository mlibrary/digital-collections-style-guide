<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl" xmlns:qui="http://dlxs.org/quombat/ui">
  <xsl:template name="build-body-page-history">
    <xsl:variable name="key" select="concat('navheader.str.', $page)" />
    <xsl:call-template name="build-breadcrumbs" />

    <qui:nav role="search">
      <xsl:for-each select="//SearchNav/NavItem[Tab = 'true']">
        <qui:link href="{Link}">
          <xsl:choose>
            <xsl:when test="contains($page, Name)">
              <xsl:attribute name="current">true</xsl:attribute>
            </xsl:when>  
            <xsl:when test="$page = 'booleanbbag' and Name = 'boolean'">
              <xsl:attribute name="current">true</xsl:attribute>
            </xsl:when>
            <xsl:when test="$page = 'proximitybbag' and Name = 'proximity'">
              <xsl:attribute name="current">true</xsl:attribute>
            </xsl:when>
            <xsl:when test="$page = 'bbaglist' and Name = 'simple'">
              <xsl:attribute name="current">true</xsl:attribute>
            </xsl:when>
          </xsl:choose>
          <xsl:variable name="nav-key" select="concat('navheader.str.', Name)" />
          <qui:label>
            <xsl:value-of select="key('get-lookup', $nav-key)" />
          </qui:label>
        </qui:link>
      </xsl:for-each>
    </qui:nav>
        
    <qui:header role="main">
      <xsl:text>Search Options: </xsl:text>
      <xsl:value-of select="key('get-lookup', $key)" />
    </qui:header>
    <xsl:apply-templates select="//SearchHistoryTable" />
  </xsl:template>

  <xsl:template match="SearchHistoryTable">
    <qui:block slot="history">
      <xsl:apply-templates select="Item" />
    </qui:block>
  </xsl:template>

  <xsl:template match="SearchHistoryTable/Item">
    <qui:section>
      <qui:link href="{Href}" />
      <qui:title>
        <xsl:value-of select="Query" />
      </qui:title>
      <qui:metadata>
        <qui:field key="collections">
          <qui:values>
            <qui:value>
              <xsl:value-of select="Collections" />
            </qui:value>
          </qui:values>
        </qui:field>
        <xsl:apply-templates select="Results" />
      </qui:metadata>
    </qui:section>
  </xsl:template>

  <xsl:template match="Item/Results">
    <qui:field key="results">
      <qui:values>
        <qui:value>
          <xsl:value-of select="HitCount" />
          <xsl:text> </xsl:text>
          <xsl:choose>
            <xsl:when test="HitCount = 1">match</xsl:when>
            <xsl:otherwise>matches</xsl:otherwise>
          </xsl:choose>
          <xsl:text> in </xsl:text>
          <xsl:value-of select="RecordCount" />
          <xsl:choose>
            <xsl:when test="RecordCount = 1"> item</xsl:when>
            <xsl:otherwise> items</xsl:otherwise>
          </xsl:choose>        
        </qui:value>
      </qui:values>
    </qui:field>
  </xsl:template>

  <xsl:template match="SearchHistoryTable" mode="table">
    <qui:block slot="main">
      <qui:table>
        <qui:thead>
          <qui:tr>
            <qui:th>
              <xsl:value-of select="key('get-lookup', 'searchhistory.str.10')" />
            </qui:th>
            <qui:th>
              <!-- should be searchhistory.str.12 -->
              <xsl:text>Collections</xsl:text>
            </qui:th>
            <qui:th>
              <xsl:value-of select="key('get-lookup', 'searchhistory.str.12')" />
            </qui:th>
          </qui:tr>
        </qui:thead>
        <qui:tbody>
          <xsl:apply-templates select="Item" />
        </qui:tbody>
      </qui:table>
    </qui:block>
  </xsl:template>

  <xsl:template match="SearchHistoryTable/Item" mode="table">
  <qui:tr>
    <qui:td>
      <qui:link href="{Href}">
        <xsl:value-of select="Query" />
      </qui:link>
    </qui:td>
    <qui:td>
      <xsl:value-of select="Collections" />
    </qui:td>
    <qui:td>
      <xsl:apply-templates select="Results" />
    </qui:td>
  </qui:tr>
</xsl:template>

<xsl:template match="Item/Results" mode="table">
  <xsl:value-of select="HitCount" />
  <xsl:text> </xsl:text>
  <xsl:choose>
    <xsl:when test="HitCount = 1">match</xsl:when>
    <xsl:otherwise>matches</xsl:otherwise>
  </xsl:choose>
  <xsl:text> in </xsl:text>
  <xsl:value-of select="RecordCount" />
  <xsl:choose>
    <xsl:when test="RecordCount = 1"> item</xsl:when>
    <xsl:otherwise> items</xsl:otherwise>
  </xsl:choose>
</xsl:template>

</xsl:stylesheet>