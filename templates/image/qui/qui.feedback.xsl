<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qbat="http://dlxs.org/quombat" xmlns:exsl="http://exslt.org/common" xmlns:qui="http://dlxs.org/quombat/ui" extension-element-prefixes="exsl">

  <xsl:variable name="collid">
    <xsl:choose>
      <xsl:when test="//Param[@name='cc']">
        <xsl:value-of select="//Param[@name='cc']" />
      </xsl:when>
      <xsl:when test="count(//Param[@name='c']) = 1">
        <xsl:value-of select="//Param[@name='cc']" />
      </xsl:when>
      <xsl:otherwise>*</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:variable name="to">
    <xsl:choose>
      <xsl:when test="normalize-space(/Top/DlxsGlobals/CurrentCgi/Param[@name='to'])">
        <xsl:value-of select="/Top/DlxsGlobals/CurrentCgi/Param[@name='to']" />
      </xsl:when>
      <xsl:otherwise>content</xsl:otherwise>
    </xsl:choose>
  </xsl:variable>

  <xsl:param name="docroot">/digital-collections-style-guide</xsl:param>

  <xsl:template match="Top">
    <qui:root view="feedback" collid="{$collid}" username="{//AuthenticatedUsername}" to="{normalize-space($to)}" sid="{/Top/DlxsGlobals/Sid}">
      <qui:form>
        <qui:hidden-input name="id">
          <xsl:attribute name="value">
            <xsl:value-of select="/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']" />
            <xsl:apply-templates select="/Top/DlxsGlobals/CurrentCgi/Param[@name='entryid']" mode="hidden-value" />
            <xsl:apply-templates select="/Top/DlxsGlobals/CurrentCgi/Param[@name='viewid']" mode="hidden-value" />
          </xsl:attribute>
        </qui:hidden-input>
        <qui:hidden-input name="return" value="{/Top/DlxsGlobals/FeedbackReturnUrl}" />
        <qui:hidden-input name="m" value="{/Top/DlxsGlobals/CurrentCgi/Param[@name='cc']}" />
        <!-- <qui:hidden-input name="to" value="{$to}" /> -->
      </qui:form>

      <qui:footer>
        <qui:link rel="feedback" select="{CurrentUrl}" />
      </qui:footer>

    </qui:root>
  </xsl:template>

  <xsl:template match="Param" mode="hidden-value">
    <xsl:if test="normalize-space(.)">
      <xsl:value-of select="concat('::', .)" />
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>