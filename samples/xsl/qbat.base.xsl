<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui">
  <!-- <xsl:output method="html" version="1.0" encoding="utf-8" indent="yes" /> -->

  <xsl:output
    method="xml"
    indent="yes"
    encoding="utf-8"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    omit-xml-declaration="yes"
    version="5.0"
    />

  <xsl:template match="/">
    <html lang="en">
      <head>
        <title>
          <xsl:apply-templates select="//qui:head/qui:title" />
        </title>
        <xsl:apply-templates select="//qui:block[@slot='meta-social']" mode="copy-guts" />
        <link href="https://unpkg.com/@umich-lib/css@v1/dist/umich-lib.css"  rel="stylesheet"/>
        <link href="../../../../static/styles.css" rel="stylesheet" />

        <script type="module"  src="https://unpkg.com/@umich-lib/components@v1/dist/umich-lib/umich-lib.esm.js"></script>
        <script nomodule="" src="https://unpkg.com/@umich-lib/components@v1/dist/umich-lib/umich-lib.js"></script>

        <xsl:apply-templates select="//qui:head/qui:block[@slot='meta-social']" />

        <xsl:call-template name="build-extra-scripts" />
        <xsl:call-template name="build-extra-styles" />

      </head>
      <body class="[ font-base-family ]">
        <section class="border-bottom">
          <m-universal-header></m-universal-header>
          <xsl:apply-templates select="//qui:m-website-header" />
        </section>

        <main class="viewport-container">
          <xsl:apply-templates select="//qui:main" />
        </main>

        <footer style="background: var(--color-blue-400); color: var(--color-blue-100); padding: var(--space-xxxx-large); margin-top: var(--space-xx-large);">
          <p>TBD</p>
        </footer>

      </body>
    </html>
  </xsl:template>

  <xsl:template name="build-extra-scripts" />
  <xsl:template name="build-extra-styles" />

  <xsl:template match="qui:m-website-header">
    <m-website-header name="{@name}">
      <xsl:apply-templates select="qui:nav" />
    </m-website-header>
  </xsl:template>

  <xsl:template match="qui:head/qui:title">
    <xsl:for-each select="qui:values/qui:value">
      <xsl:value-of select="." />
      <xsl:if test="position() &lt; last()">
        <xsl:text> | </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text> | </xsl:text>
    <xsl:text>University of Michigan Library Digital Collections</xsl:text>
  </xsl:template>

  <xsl:template match="qui:block">
    <xsl:apply-templates select="." mode="copy-guts" />
  </xsl:template>

  <xsl:template match="qui:nav">
    <nav class="flex flex-row justify-end">
      <xsl:apply-templates select="qui:link">
        <xsl:with-param name="class">block ml-4 text-sm font-extrabold tracking-wider uppercase text-gray-umich-lib hover:underline focus:outline focus:underline</xsl:with-param>
      </xsl:apply-templates>
    </nav>
  </xsl:template>

  <xsl:template match="qui:link">
    <xsl:param name="class" />
    <a href="{@href}">
      <xsl:if test="normalize-space($class)">
        <xsl:attribute name="class"><xsl:value-of select="$class" /></xsl:attribute>
      </xsl:if>
      <xsl:value-of select="." />
    </a>
  </xsl:template>

  <xsl:template match="qui:href" mode="echo">
    <xsl:variable name="href">
      <xsl:choose>
        <xsl:when test="@type = 'mailto'">
          <xsl:text>mailto:</xsl:text>
          <xsl:value-of select="." />
        </xsl:when>
        <xsl:otherwise>
          <xsl:value-of select="." />
        </xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <a href="{$href}"><xsl:value-of select="." /></a>
  </xsl:template>

  <xsl:template match="qui:sidebar">
    <section class="px-9">
      <nav>
        <xsl:apply-templates select="qui:panel" />
      </nav>
    </section>
  </xsl:template>

  <xsl:template match="qui:panel">
    <div class="[ border-bottom ]">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="qui:panel/qui:header">
    <h3>
      <xsl:apply-templates select="." mode="copy-guts" />
    </h3>
  </xsl:template>

  <xsl:template match="qui:panel/qui:nav">
    <ul>
      <xsl:for-each select="qui:link">
        <li class="py-1">
          <a href="{@href}" class="text-teal-400 underline">
            <xsl:apply-templates select="." mode="copy-guts" />
          </a>
        </li>
      </xsl:for-each>
    </ul>
  </xsl:template>

  <xsl:template match="qui:panel/qui:block-contact">
    <p>
      <xsl:value-of select="qui:span" />
      <br />
      <xsl:text>(</xsl:text>
      <xsl:apply-templates select="qui:href" mode="echo" />
      <xsl:text>)</xsl:text>
    </p>
  </xsl:template>

  <xsl:template match="qui:main">
    <section class="px-9">
      <pre>MAIN</pre>
    </section>
  </xsl:template>

  <xsl:template match="node()" mode="copy-guts">
    <xsl:apply-templates select="*|text()" mode="copy" />
  </xsl:template>

  <xsl:template match="qui:link" mode="copy" priority="99">
    <a href="{@href}"><xsl:apply-templates mode="copy" /></a>
  </xsl:template>

  <xsl:template match="node()[namespace-uri() = 'http://www.w3.org/1999/xhtml']" mode="copy" priority="99">
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="*|@*|text()" mode="copy" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="node()[namespace-uri() = 'http://dlxs.org/quombat/xhtml']" mode="copy" priority="99">
    <xsl:element name="{name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="*|@*|text()" mode="copy" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*|*|text()" mode="copy">
    <xsl:copy>
      <xsl:apply-templates select="@*|*|text()" mode="copy" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>