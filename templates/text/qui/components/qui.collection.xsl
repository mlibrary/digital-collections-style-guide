<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">


  <xsl:template name="get-head-title">
    <qui:values>
      <qui:value>
        <xsl:call-template name="get-title" />
      </qui:value>
      <qui:value>
        <xsl:call-template name="get-collection-title" />
      </qui:value>
    </qui:values>
  </xsl:template>

  <xsl:template name="build-breadcrumbs">
    <xsl:variable name="view" select="//Param[@name='view']|//Param[@name='page']" />
    <qui:nav role="breadcrumb">
      <xsl:choose>
        <xsl:when test="$context-type = 'collection'">
          <qui:link href="{/Top/NavHeader/MainNav/NavItem[Name='home']/Link}">
            <xsl:text>Collection Home</xsl:text>
          </qui:link>
        </xsl:when>
        <xsl:when test="$context-type = 'list'">
          <qui:link href="/cgi/i/image/image-idx?page=bbopen">
            <xsl:text>Portfolio Index</xsl:text>
          </qui:link>
        </xsl:when>
        <xsl:when test="$context-type = 'group' or $context-type = 'multiple'">
          <qui:link href="/cgi/i/image/image-idx?page=groups">
            <xsl:text>Image Collections</xsl:text>
          </qui:link>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="normalize-space(/Top/BackLink)">
        <qui:link href="{normalize-space(/Top/BackLink)}">
          <xsl:choose>
            <xsl:when test="$view = 'bbentry'">
              <xsl:text>Portfolio</xsl:text>
            </xsl:when>
            <xsl:otherwise>
              <xsl:text>Search Results</xsl:text>
            </xsl:otherwise>
          </xsl:choose>
        </qui:link>
      </xsl:if>
      <xsl:if test="$view = 'reslist' and //Param[@name='subview'] = 'detail'">
        <qui:link href="{/Top//CurrentUrl}">Search Results</qui:link>
      </xsl:if>
      <qui:link href="{/Top//CurrentUrl}">
        <xsl:call-template name="get-current-page-breadcrumb-label" />
      </qui:link>
    </qui:nav>
  </xsl:template>

</xsl:stylesheet>