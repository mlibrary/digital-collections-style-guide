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
    <xsl:variable name="view" select="/Top/DlxsGlobals/CurrentCgi/Param[@name='view']|/Top/DlxsGlobals/CurrentCgi/Param[@name='page']" />
    <qui:nav role="breadcrumb">
      <xsl:choose>
        <xsl:when test="$context-type = 'collection'">
          <qui:link href="{/Top/NavHeader/MainNav/NavItem[Name='home']/Link}">
            <xsl:text>Collection Home</xsl:text>
          </qui:link>
        </xsl:when>
        <xsl:when test="$context-type = 'list' and /Top/DlxsGlobals/CurrentCgi/Param[@name='page'] != 'bbaglist'">
          <qui:link href="/cgi/i/text/text-idx?page=bbaglist">
            <xsl:text>Bookbag</xsl:text>
          </qui:link>
        </xsl:when>
        <xsl:when test="$context-type = 'group' and /Top/NavHeader/MainNav/NavItem[Name='home']/Link">
          <qui:link href="{/Top/NavHeader/MainNav/NavItem[Name='home']/Link}">
            <xsl:text>Group Home</xsl:text>
          </qui:link>
        </xsl:when>
        <xsl:when test="$context-type = 'group' or $context-type = 'multiple'">
          <xsl:variable name="root-href">
            <xsl:choose>
              <xsl:when test="$docroot = '/'">/samples/</xsl:when>
              <xsl:when test="starts-with($api_url, 'https://quod.lib')">/lib/colllist/?byFormat=Text%20Collections</xsl:when>
              <xsl:when test="starts-with($api_url, 'https://preview.quod.lib')">/lib/colllist/?byFormat=Text%20Collections</xsl:when>
              <xsl:otherwise>/cgi/c/collsize/coll-idx?byFormat=Text%20Collections</xsl:otherwise>
            </xsl:choose>
          </xsl:variable>
          <qui:link href="{$root-href}">
            <xsl:text>Text Collections</xsl:text>
          </qui:link>
        </xsl:when>
        <xsl:otherwise>
        </xsl:otherwise>
      </xsl:choose>
      <xsl:if test="$context-type != 'list' and /Top/DlxsGlobals/CurrentCgi/Param[@name='bookbag'] = '1'">
        <qui:link href="{/Top/NavHeader/MainNav/NavItem[Name='bookbag']/Link}">
          <xsl:text>Bookbag</xsl:text>
        </qui:link>
      </xsl:if>
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
      <xsl:variable name="return-to-results-link" select="/Top/DlxsGlobals/ReturnToResultsLink" />
      <xsl:variable name="return-to-results-label">
        <xsl:choose>
          <xsl:when test="contains($return-to-results-link, 'page=browse')">
            <xsl:text>Browse Results</xsl:text>
          </xsl:when>
          <xsl:otherwise>
            <xsl:text>Search Results</xsl:text>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:variable>
      <xsl:if test="normalize-space($return-to-results-link)">
        <xsl:choose>
          <xsl:when test="$view = 'reslist' and $subview = 'detail'">
            <qui:link href="{$return-to-results-link}">Search Results</qui:link>
          </xsl:when>
          <xsl:when test="$subview = 'detail'">
            <qui:link href="{$return-to-results-link}">Item Search Results</qui:link>
          </xsl:when>
          <!-- could be otherwise, but avoid too much search history -->
          <xsl:when test="$view != 'reslist'">
            <qui:link href="{$return-to-results-link}"><xsl:value-of select="$return-to-results-label" /></qui:link>
          </xsl:when>
        </xsl:choose>
      </xsl:if>
      <xsl:call-template name="build-breadcrumbs-intermediate-links" />
      <xsl:if test="$page != 'bbaglist'">
        <qui:link href="{/Top/DlxsGlobals/CurrentUrl}">
          <xsl:call-template name="get-current-page-breadcrumb-label" />
        </qui:link>
      </xsl:if>
    </qui:nav>
  </xsl:template>

  <xsl:template name="build-breadcrumbs-intermediate-links" />

</xsl:stylesheet>