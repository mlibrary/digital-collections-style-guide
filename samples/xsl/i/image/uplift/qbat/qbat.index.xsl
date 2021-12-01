<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <style>
      .hero--banner {
        width: 100%;
        height: 400px;
        background-position: 0px center;
        background-repeat: no-repeat;
        background-size: cover;
        background-color: #666;
        background-image: var(--background-src);
        position: relative;
      }

      .hero--banner .collection-title {
        position: absolute;
        height: 100%;
        width: 100%;
        top: 0;
        bottom: 0;
        left: 0;
        right: 0;
        padding: 2rem;
        display: flex;
        flex-direction: row;
        align-items: flex-end;
        background: linear-gradient(0deg, #00000088 30%, #ffffff44 100%);
      }
  
      .hero--banner .collection-heading {
        display: block;
        color: white;
        text-shadow: 0 2px 3px rgba(0, 0, 0, 0.3);
      }
      
    </style>
  </xsl:template>

  <xsl:template match="qui:main">
    <xsl:choose>
      <xsl:when test="//qui:hero-image">
        <xsl:apply-templates select="//qui:hero-image" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:call-template name="build-collection-heading" />
      </xsl:otherwise>
    </xsl:choose>

    <div class="message-callout">
      <p>
        This collection index re-design is still under construction.
      </p>
    </div>

    <xsl:call-template name="build-search-form" />

    <xsl:apply-templates select="qui:panel" mode="copy-guts" />

  </xsl:template>

  <xsl:template match="qui:hero-image">
    <div class="hero">
      <div class="hero--banner" style="--background-src: url(https://quod.lib.umich.edu/cgi/i/image/api/image/{@identifier}/full/1000,/0/default.jpg)">
        <div class="collection-title">
          <xsl:call-template name="build-collection-heading" />
        </div>
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>