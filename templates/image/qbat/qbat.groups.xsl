<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template match="qui:main">
    <xsl:call-template name="build-main-index" />
  </xsl:template>

  <xsl:template name="build-main-index">
    <xsl:choose>
      <xsl:when test="//qui:hero-image">
        <xsl:apply-templates select="//qui:hero-image" />
      </xsl:when>
      <xsl:otherwise>
        <div class="[ mb-2 ]">
          <xsl:call-template name="build-collection-heading">
            <xsl:with-param name="badge">
              <xsl:value-of select="@data-badge" />
            </xsl:with-param>
          </xsl:call-template>
        </div>
      </xsl:otherwise>
    </xsl:choose>

    <div class="[ flex flex-flow-row flex-gap-1 ]">
      <div class="side-panel">
        <h2 class="visually-hidden">Options</h2>
        
        <xsl:apply-templates select="//qui:panel[@slot='browse']">
          <xsl:with-param name="classes">browse-link</xsl:with-param>
        </xsl:apply-templates>
      </div>

      <div class="main-panel">
        <!-- <xsl:apply-templates select="//qui:panel[@slot='browse']">
          <xsl:with-param name="classes">[ viewport-narrow ]</xsl:with-param>
        </xsl:apply-templates> -->
        <xsl:call-template name="build-search-form" />
        <div class="text-block">
          <xsl:apply-templates select="//qui:block[@slot='links'][@align='top']" />
          <xsl:apply-templates select="//qui:block[@slot='information']" />
        </div>
      </div>

    </div>
  </xsl:template>

  <xsl:template match="qui:panel[@slot='browse']" priority="100">
    <xsl:param name="classes" />
    <h3 class="{$classes}">Browse this collection</h3>
    <xsl:apply-templates select="qui:link[not(@rel)]" mode="browse-link">
      <xsl:with-param name="classes"><xsl:value-of select="$classes" /></xsl:with-param>
    </xsl:apply-templates>
  </xsl:template>  

  <xsl:template match="qui:link" mode="browse-link">
    <xsl:param name="classes" />
    <div class="[ link-box ][ flex flex-center ][ {$classes} ]">
      <a class="[ flex flex-start ][ gap-0_25 bedazzled-link ]" href="{@href}">
        <xsl:choose>
          <xsl:when test="@icon">
            <span class="material-icons flex-shrink-0" aria-hidden="true"><xsl:value-of select="@icon" /></span>
          </xsl:when>
          <xsl:otherwise>
            <span class="material-icons flex-shrink-0" aria-hidden="true" style="opacity: 0.5">check_box_outline_blank</span>
          </xsl:otherwise>
        </xsl:choose>
        <span><xsl:value-of select="." /></span>
      </a>
    </div>
  </xsl:template>
 
</xsl:stylesheet>