<?xml version="1.0" encoding="UTF-8" ?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:output
    method="xml"
    indent="yes"
    encoding="utf-8"
    omit-xml-declaration="yes"
    version="5.0"
    />
  <xsl:strip-space elements="*"/>

  <!-- assume that namespace="" is xhtml -->
  <!-- <xsl:template match="node()[name()][namespace-uri() = '']" priority="99">
    <xsl:element name="{local-name()}" namespace="http://dlxs.org/quombat/xhtml">
      <xsl:apply-templates select="@*" />
      <xsl:attribute name="data-tag"><xsl:value-of select="local-name()" /></xsl:attribute>
      <xsl:apply-templates select="*|text()" />
    </xsl:element>
  </xsl:template> -->

  <!-- and capture xhtml itself -->
  <!-- <xsl:template match="node()[name()][namespace-uri() = 'http://www.w3.org/1999/xhtml']" priority="99">
    <xsl:element name="{local-name()}" namespace="http://dlxs.org/quombat/xhtml">
      <xsl:apply-templates select="@*" />
      <xsl:attribute name="data-tag"><xsl:value-of select="local-name()" /></xsl:attribute>
      <xsl:apply-templates select="*|text()" />
    </xsl:element>
  </xsl:template> -->

  <xsl:template match="qui:root" priority="99">
    <html>
      <head>
        <link rel="icon" href="data:image/svg+xml,&lt;svg xmlns='http://www.w3.org/2000/svg' width='1em' height='1em'>&lt;text y='.9em'>🎃&lt;/text>&lt;/svg>" />

        <style>

          ul {
            padding: 0 1.5rem;
          }

          li {
            list-style-type: none;
          }

          li.element {
            color: #999;
          }

          li.text {
            color: #000;
          }

          .attribute-value {
            color: #666;
          }
        </style>
      </head>
      <body>
        <ul>
          <xsl:apply-templates select="." mode="xhtml" />
        </ul>
      </body>
    </html>

  </xsl:template>

  <xsl:template name="generate-opening-tag">
    <xsl:param name="node" />
    <xsl:text>&lt;</xsl:text>
    <xsl:value-of select="name($node)" />
    <xsl:if test="$node/@*">
      <xsl:text> </xsl:text>
      <xsl:for-each select="$node/@*">
        <xsl:value-of select="name()" />
        <xsl:text>=&quot;</xsl:text>
        <span class="attribute-value"><xsl:value-of select="." /></span>
        <xsl:text>&quot;</xsl:text>
        <xsl:if test="position() &lt; last()">
          <xsl:text> </xsl:text>
        </xsl:if>
      </xsl:for-each>
    </xsl:if>
    <xsl:choose>
      <xsl:when test="normalize-space($node)">
        <xsl:text>&gt;</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text> /&gt;</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template match="@*" mode="xhtml">
    <xsl:value-of select="name()" />
    <xsl:text>=&quot;</xsl:text>
    <span class="attribute-value"><xsl:value-of select="." /></span>
    <xsl:text>&quot;</xsl:text>
  </xsl:template>

  <xsl:template match="node()[name()]" mode="xhtml">
    <li class="element">
      <xsl:text>&lt;</xsl:text>
      <xsl:value-of select="name()" />
      <xsl:for-each select="@*">
        <xsl:text> </xsl:text>
        <xsl:apply-templates select="." mode="xhtml" />
      </xsl:for-each>
      <xsl:choose>
        <xsl:when test="* or normalize-space(.)">
          <xsl:text>&gt;</xsl:text>
        </xsl:when>
        <xsl:otherwise>
          <xsl:text> /&gt;</xsl:text>
        </xsl:otherwise>
      </xsl:choose>
    </li>
    <xsl:if test="*|text()">
      <li>
        <ul>
          <xsl:apply-templates select="*|text()" mode="xhtml" />
        </ul>
      </li>
      <li class="element">
        <xsl:value-of select="concat('&lt;/', name(), '&gt;')" />
      </li>
    </xsl:if>
  </xsl:template>

  <xsl:template match="*" mode="xhtml">
    <xsl:if test="normalize-space(.)">
      <li class="text"><xsl:value-of select="." /></li>
    </xsl:if>
  </xsl:template>

  <!-- <xsl:template match="@*|*">
    <xsl:copy>
      <xsl:apply-templates select="@*" />
      <xsl:apply-templates select="*|text()" />
    </xsl:copy>
  </xsl:template> -->
  
</xsl:stylesheet>
