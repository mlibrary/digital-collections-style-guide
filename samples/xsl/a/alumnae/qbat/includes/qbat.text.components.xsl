<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui"
  xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org"
  xmlns:exsl="http://exslt.org/common" 
  xmlns:tei="http://www.tei-c.org/ns/1.0" extension-element-prefixes="exsl">

  <xsl:preserve-space elements="tei:CHOICE" />

  <xsl:template match="tei:CHOICE">
    <xsl:text> </xsl:text>
    <xsl:choose>
      <xsl:when test="tei:SIC">
        <span class="sic">
          <xsl:apply-templates select="tei:SIC" />
          <span class="text-muted">
            <xsl:text> [</xsl:text>
            <xsl:value-of select="tei:CORR" />
            <xsl:text>]</xsl:text>
          </span>
        </span>
      </xsl:when>
      <xsl:when test="tei:ABBR">
        <span class="abbr">
          <xsl:apply-templates select="tei:ABBR" />
          <span class="text-muted">
            <xsl:text> [</xsl:text>
            <xsl:value-of select="tei:EXPAN" />
            <xsl:text>]</xsl:text>
          </span>
        </span>
      </xsl:when>
      <xsl:otherwise>
        <xsl:apply-templates />
      </xsl:otherwise>
    </xsl:choose>
    <xsl:text> </xsl:text>
  </xsl:template>

  <!-- <xsl:template match="tei:GAP">
    <span class="gap">
      <xsl:text>&#xa0;[&#xa0;</xsl:text>
      <xsl:value-of select="concat(&apos;gap: &apos;,@EXTENT)" />
      <xsl:text>unclear&#xa0;]&#xa0;</xsl:text>
    </span>
  </xsl:template> -->

  <!-- #################### -->
  <xsl:template match="tei:DIV2[@N='B3']//tei:LABEL">
    <li class="mb-0_5 flex flex-flow-row gap-0_5">
    <xsl:choose>
      <xsl:when test="@TYPE">
        <span>
          <span class="material-icons" aria-hidden="true">check_box</span>
          <span class="visually-hidden">checked</span>
        </span>
        <!-- <xsl:text> [ x ] </xsl:text> -->
        <span>
          <xsl:apply-templates />
        </span>
      </xsl:when>
      <xsl:otherwise>
        <span>
          <span class="material-icons" aria-hidden="true">check_box_outline_blank</span>
          <span class="visually-hidden">unchecked</span>
        </span>
        <!-- <xsl:text> [&#xA0;&#xA0;&#xA0;] </xsl:text> -->
        <span>
          <xsl:apply-templates />
        </span>
      </xsl:otherwise>
    </xsl:choose>
    </li>
  </xsl:template>

  <xsl:template match="tei:DIV2[@N='B3']//tei:ITEM" />

  <xsl:template match="tei:DIV2[@N='B2']//tei:LABEL">
    <xsl:variable name="this" select="." />
    <!-- <strong>
      <xsl:apply-templates />
      <xsl:text>:</xsl:text>
    </strong> -->
    <div>
      <dt>
        <xsl:apply-templates />
      </dt>
      <xsl:for-each select="following-sibling::tei:ITEM[preceding-sibling::tei:LABEL[1] = $this]">
        <dd>
          <xsl:value-of select="." />
        </dd>
      </xsl:for-each>
    </div>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:ITEM" priority="101" />
  <xsl:template match="tei:ITEM">
    <li class="mb-0_5 flex flex-flow-row gap-0_5">
      <xsl:apply-templates />
    </li>
  </xsl:template>

  <!-- #################### -->
  <xsl:template match="tei:DIV2[@N='B3']//tei:LIST">
    <ul>
      <xsl:apply-templates />
    </ul>
  </xsl:template>

  <xsl:template match="tei:LIST[tei:LABEL]">
    <dl class="record">
      <xsl:apply-templates />
    </dl>
  </xsl:template>
  
  <xsl:template match="tei:DIV1//NAME">
    <xsl:text> </xsl:text>
    <xsl:apply-templates />
  </xsl:template>

</xsl:stylesheet>