<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://dlxs.org/quombat/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui">

  <xsl:template name="build-extra-scripts">
    <script src="https://unpkg.com/mirador@latest/dist/mirador.min.js"></script>
    <script src="/samples/js/entry.js"></script>
  </xsl:template>

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <style>
      .viewer {
        width: 98vw;
        height: 80vh;
        margin: 1rem auto;
        position: relative;
        border: 0;
        display: block;
        box-sizing: border-box;
      }
    </style>
  </xsl:template>

  <xsl:template match="qui:main">

    <xsl:apply-templates select="qui:nav" />

    <xsl:call-template name="build-asset-viewer" />

    <section>
      <xsl:apply-templates select="qui:block" />
      <aside>
        <xsl:apply-templates select="qui:panel" />
      </aside>
    </section>

  </xsl:template>

  <xsl:template match="qui:main/qui:nav">
    <div>
      <nav class="breadcrumbs">
        <a href="qui:link[@rel='back']/@href">Back to search results</a>
      </nav>
      <nav class="results">
        <xsl:if test="qui:link[@rel='previous']">
          <a href="qui:link[@rel='previous']/@href">Previous</a>
        </xsl:if>
        <span>
          <xsl:value-of select="@index + 1" />
          <xsl:text> / </xsl:text>
          <xsl:value-of select="@total" />
        </span>
        <xsl:if test="qui:link[@rel='next']">
          <a href="qui:link[@rel='next']/@href">Next</a>
        </xsl:if>
      </nav>
    </div>
  </xsl:template>

  <xsl:template name="build-asset-viewer">
    <xsl:variable name="viewer" select="//qui:viewer" />
    <iframe id="viewer" class="viewer" allow="fullscreen" src="https://roger.quod.lib.umich.edu/cgi/i/image/api/embed/{$viewer/@collid}:{$viewer/@m_id}:{$viewer/@m_iid}"></iframe>
  </xsl:template>

  <xsl:template name="build-asset-viewer--inline">
    <xsl:variable name="viewer" select="//qui:viewer" />
    <div 
      id="viewer"
      class="viewer"
      data-manifest-id="{$viewer/@manifest-id}" 
      data-canvas-index="{$viewer/@canvas-index}"
      data-provider="{$viewer/@provider}"
      data-mode="{$viewer/@mode}">
    </div>
  </xsl:template>

  <xsl:template match="qui:block">
    <div>
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="qui:header[@role='main']">
    <h1><xsl:value-of select="." /></h1>
  </xsl:template>

  <xsl:template match="qui:section">
    <section class="record-container">
      <xsl:if test="@name != 'default'">
        <h2><xsl:value-of select="@name" /></h2>
      </xsl:if>
      <dl class="record">
        <xsl:apply-templates />
      </dl>
    </section>
  </xsl:template>

  <xsl:template match="qui:field">
    <dt data-key="{@name}">
      <xsl:apply-templates select="qui:label" mode="copy-guts" />
    </dt>
    <xsl:for-each select="qui:values/qui:value">
      <dd>
        <xsl:apply-templates select="." mode="copy-guts" />
      </dd>
    </xsl:for-each>
  </xsl:template>

</xsl:stylesheet>