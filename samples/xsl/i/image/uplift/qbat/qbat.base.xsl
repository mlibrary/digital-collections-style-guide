<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">
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

  <xsl:param name="use-local-identifiers">true</xsl:param>

  <xsl:param name="possible-identifiers" select="document($identifier-filename)//identifier" />

  <xsl:template match="qui:root">
    <html lang="en">
      <xsl:apply-templates select="qui:head" />
      <body class="[ font-base-family ]">
        <div class="border-bottom">
          <m-universal-header></m-universal-header>
          <xsl:apply-templates select="//qui:m-website-header" />
        </div>

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

  <xsl:template match="qui:head">
    <head>
      <xsl:apply-templates select="xhtml:title" mode="copy" />
      <xsl:apply-templates select="xhtml:meta" mode="copy" />

      <xsl:apply-templates select="qui:link" />

      <link
        rel="stylesheet"
        href="https://fonts.googleapis.com/icon?family=Material+Icons"
      />
      <link href="https://unpkg.com/@umich-lib/css@v1/dist/umich-lib.css"  rel="stylesheet"/>
      <link href="../../../../../static/styles.css" rel="stylesheet" />

      <script type="module" src="https://unpkg.com/@umich-lib/components@v1/dist/umich-lib/umich-lib.esm.js"></script>
      <script nomodule="" src="https://unpkg.com/@umich-lib/components@v1/dist/umich-lib/umich-lib.js"></script>

      <link href="data:image/x-icon;base64,AAABAAEAEBAAAAAAAABoBQAAFgAAACgAAAAQAAAAIAAAAAEACAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAOX/AD09PQA0a5EAuwD/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAICAgACAgACAgIAAAAAAAIDAwMCAgICAwMDAgAAAAIDAwMDAgICAgMDAwMCAAACAwMDAgICAgICAwMDAgAAAgMDAwICAgICAgMDAwIAAAIBAwMCAgICAgIDAwECAAACAQEBAQICAgIBAQEBAgAAAgEBAgEBAgIBAQIBAQIAAAACAQEBAQEBAQEBAQIAAAAAAgEBAQEBAQEBAQECAAAAAAICAQEBAQEBAQECAgAAAAACBAIBAQEBAQECBAIAAAAAAAICAgICAgICAgIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP//AADiRwAAwAMAAIABAACAAQAAgAEAAIABAACAAQAAgAEAAMADAADAAwAAwAMAAMADAADgBwAA//8AAP//AAA=" rel="icon" type="image/x-icon" />

      <xsl:call-template name="build-extra-scripts" />
      <xsl:call-template name="build-extra-styles" />

    </head>
  </xsl:template>

  <xsl:template match="qui:m-website-header">
    <m-website-header name="{@name}" to="/samples/">
      <xsl:apply-templates select="qui:nav" />
    </m-website-header>
  </xsl:template>

  <xsl:template match="qui:m-website-header/qui:nav">
    <nav class="[ flex flex-end ][ gap-0_5 ]">
      <xsl:apply-templates select="qui:link" />
    </nav>
  </xsl:template>

  <xsl:template match="xhtml:title/qui:values" mode="copy">
    <xsl:for-each select="qui:value">
      <xsl:value-of select="." />
      <xsl:if test="position() &lt; last()">
        <xsl:text> | </xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:text> | </xsl:text>
    <xsl:text>University of Michigan Library Digital Collections</xsl:text>
  </xsl:template>

  <xsl:template name="build-breadcrumbs">
    <div class="[ breadcrumb ]">
      <nav aria-label="Breadcrumb">
        <ol>
          <xsl:for-each select="qui:nav[@role='breadcrumb']/qui:link">
            <li>
              <xsl:apply-templates select=".">
                <xsl:with-param name="attributes">
                  <xsl:if test="position() = last()">
                    <qui:attribute name="aria-current">page</qui:attribute>
                  </xsl:if>
                </xsl:with-param>
              </xsl:apply-templates>

              <xsl:if test="false()">
              <a>
                <!-- how to pass aria attributes to generic qui:link handler? -->
                <xsl:attribute name="href">
                  <xsl:choose>
                    <xsl:when test="normalize-space(@identifier)">
                      <xsl:text>../</xsl:text>
                      <xsl:value-of select="@identifier" />
                      <xsl:text>/</xsl:text>
                    </xsl:when>
                    <xsl:otherwise><xsl:value-of select="@href" /></xsl:otherwise>
                  </xsl:choose>
                </xsl:attribute>
                <xsl:if test="position() = last()">
                  <xsl:attribute name="aria-current">page</xsl:attribute>
                </xsl:if>
                <xsl:value-of select="." />
              </a>
            </xsl:if>
            </li>
          </xsl:for-each>
        </ol>
      </nav>
      <xsl:call-template name="build-breadcrumbs-extra-nav" />
    </div>
  </xsl:template>

  <xsl:template name="build-breadcrumbs-extra-nav"></xsl:template>

  <xsl:template match="qui:block">
    <xsl:apply-templates select="." mode="copy-guts" />
  </xsl:template>

  <xsl:template match="qui:linkkkk[@identifier != '']" priority="100">
    <xsl:param name="class" />
    <xsl:param name="attributes" />
    <a href="../{@identifier}/">
      <xsl:if test="normalize-space($class)">
        <xsl:attribute name="class"><xsl:value-of select="$class" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="normalize-space($attributes)">
        <xsl:for-each select="exsl:node-set($attributes)//qui:attribute">
          <xsl:attribute name="{@name}"><xsl:value-of select="." /></xsl:attribute>
        </xsl:for-each>
      </xsl:if>
      <xsl:choose>
        <xsl:when test="@rel = 'next'">Next</xsl:when>
        <xsl:when test="@rel = 'previous'">Previous</xsl:when>
        <xsl:when test="@rel = 'back'">Search Results</xsl:when>
        <xsl:otherwise><xsl:apply-templates mode="copy" /></xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <xsl:template name="build-href-or-identifier">
    <!-- <xsl:variable name="identifier" select="@identifier" /> -->
    <xsl:variable name="identifier">
      <xsl:value-of select="@identifier" />
      <xsl:if test="normalize-space(@marker)">
        <xsl:text>__xz</xsl:text>
        <xsl:value-of select="@marker" />
      </xsl:if>
    </xsl:variable>
    <xsl:message>BUILD HREF : <xsl:value-of select="$identifier" /> : <xsl:value-of select="@marker" /></xsl:message>    
    <xsl:attribute name="href">
      <xsl:choose>
        <xsl:when test="$use-local-identifiers = 'true' and normalize-space($identifier)">
          <xsl:text>../</xsl:text>
          <xsl:value-of select="$identifier" />
          <xsl:text>/</xsl:text>
        </xsl:when>
        <xsl:otherwise><xsl:value-of select="@href" /></xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
    <xsl:attribute name="data-available">
      <xsl:choose>
        <xsl:when test="$possible-identifiers[. = $identifier]">true</xsl:when>
        <xsl:otherwise>false</xsl:otherwise>
      </xsl:choose>
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="qui:link">
    <xsl:param name="class" />
    <xsl:param name="attributes" />
    <a>
      <xsl:call-template name="build-href-or-identifier" />
      <xsl:if test="normalize-space($class)">
        <xsl:attribute name="class"><xsl:value-of select="$class" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="normalize-space($attributes)">
        <xsl:for-each select="exsl:node-set($attributes)//qui:attribute">
          <xsl:attribute name="{@name}"><xsl:value-of select="." /></xsl:attribute>
        </xsl:for-each>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="@rel = 'next'">Next</xsl:when>
        <xsl:when test="@rel = 'previous'">Previous</xsl:when>
        <xsl:when test="@rel = 'back'">Search Results</xsl:when>
        <xsl:otherwise><xsl:apply-templates mode="copy" /></xsl:otherwise>
      </xsl:choose>
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

  <xsl:template name="build-collection-heading">
    <h1 class="collection-heading">
      <xsl:value-of select="//qui:header[@role='main']" />
    </h1>
  </xsl:template>

  <!-- FIELDS -->
  <xsl:template match="qui:field[@component='catalog-link']" priority="99">
    <p>
      <a class="catalog-link" href="https://search.lib.umich.edu/catalog/Record/{qui:values/qui:value}">
        <xsl:value-of select="qui:label" />
      </a>
    </p>
  </xsl:template>

  <xsl:template match="qui:field[@component='system-link']" priority="99">
    <p>
      <a class="system-link" href="{qui:values/qui:value}">
        <xsl:value-of select="qui:label" />
      </a>
    </p>
  </xsl:template>

  <xsl:template match="qui:field[@component='input']//qui:value" mode="copy-guts" priority="99">
    <input type="text" value="{.}" />
  </xsl:template>

  <xsl:template match="qui:field">
    <dt data-key="{@key}">
      <xsl:apply-templates select="qui:label" mode="copy-guts" />
    </dt>
    <xsl:for-each select="qui:values/qui:value">
      <dd>
        <xsl:apply-templates select="." mode="copy-guts" />
      </dd>
    </xsl:for-each>
  </xsl:template>

  <xsl:template match="qui:hidden-input">
    <!-- <input type="hidden" name="{@name}" value="{@value}">
      <xsl:if test="@data-field">
        <xsl:attribute name="data-field"><xsl:value-of select="@data-field" /></xsl:attribute>
      </xsl:if>
    </input> -->
    <input type="hidden">
      <xsl:apply-templates select="@*" mode="copy" />
    </input>
  </xsl:template>

  <!-- UTILITY -->
  <xsl:template match="node()" mode="copy-guts">
    <xsl:message>AHOY COPY GUTS: <xsl:value-of select="local-name()" /></xsl:message>
    <xsl:apply-templates select="*|text()" mode="copy" />
  </xsl:template>

  <xsl:template match="qui:link[@identifier != '']" mode="copy" priority="100">
    <a href="../{@identifier}/">
      <xsl:choose>
        <xsl:when test="@rel = 'next'">Next</xsl:when>
        <xsl:when test="@rel = 'previous'">Previous</xsl:when>
        <xsl:when test="@rel = 'back'">Search Results</xsl:when>
        <xsl:otherwise><xsl:apply-templates mode="copy" /></xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <xsl:template match="qui:link" mode="copy" priority="99">
    <a href="{@href}" ><xsl:apply-templates mode="copy" /></a>
  </xsl:template>

  <xsl:template match="node()[namespace-uri() = 'http://www.w3.org/1999/xhtml']" mode="copy" priority="101">
    <xsl:message>COPY XHTML <xsl:value-of select="local-name()" /></xsl:message>
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml" data-copy="xhtml">
      <xsl:apply-templates select="*|@*|text()" mode="copy" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="node()[namespace-uri() = 'http://dlxs.org/quombat/xhtml']" mode="copy" priority="99">
    <xsl:element name="{name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="*|@*|text()" mode="copy" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="@*|*|text()" mode="copy">
    <xsl:message>COPY <xsl:value-of select="local-name()" /> :: <xsl:value-of select="namespace-uri()" /></xsl:message>
    <xsl:copy>
      <xsl:apply-templates select="@*|*|text()" mode="copy" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>