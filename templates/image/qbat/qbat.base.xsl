<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <xsl:output
    method="xml"
    indent="yes"
    encoding="utf-8"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    omit-xml-declaration="yes"
    version="5.0"
    />

  <xsl:param name="docroot">/digital-collections-style-guide/</xsl:param>

  <xsl:variable name="collid" select="//qui:root/@collid" />

  <xsl:template match="qui:root">
    <html lang="en" data-root="{$docroot}">
      <xsl:apply-templates select="qui:head" />
      <body class="[ font-base-family ]">
        <div class="border-bottom">
          <m-universal-header></m-universal-header>
          <xsl:apply-templates select="//qui:m-website-header" />
        </div>

        <main>
          <xsl:attribute name="class">
            <xsl:text>[ viewport-container ]</xsl:text>
            <xsl:call-template name="build-extra-main-class" />
          </xsl:attribute>
          <xsl:apply-templates select="//qui:main" />
        </main>

        <xsl:call-template name="build-footer" />
      </body>
    </html>
  </xsl:template>

  <xsl:template name="build-extra-main-class" />

  <xsl:template name="build-extra-scripts" />
  <xsl:template name="build-extra-styles" />

  <xsl:template match="qui:head">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <xsl:apply-templates select="xhtml:title" mode="copy" />
      <xsl:apply-templates select="xhtml:meta" mode="copy" />

      <xsl:apply-templates select="qui:link" />

      <link
        rel="stylesheet"
        href="https://fonts.googleapis.com/icon?family=Material+Icons"
      />
      <link href="https://unpkg.com/@umich-lib/web@1/umich-lib.css" rel="stylesheet" />
      <link href="{$docroot}styles/styles.css" rel="stylesheet" />

      <script type="module" src="https://unpkg.com/@umich-lib/web@1/dist/umich-lib/umich-lib.esm.js"></script>
      <script nomodule="" src="https://unpkg.com/@umich-lib/web@1/dist/umich-lib/umich-lib.js"></script>
      <script src="https://unpkg.com/container-query-polyfill/cqfill.iife.min.js"></script>

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
    <xsl:param name="classes" />
    <div class="[ breadcrumb ][ {$classes} ]">
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

  <xsl:template name="build-footer">
    <footer class="[ footer ][ mt-2 ]">
      <div class="viewport-container">
        <div class="[ footer__content ]">
          <section>
            <h2>University of Michigan Library</h2>
            <ul>
              <li>
                <a href="https://lib.umich.edu/">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    aria-hidden="true"
                    focusable="false"
                    role="img"
                  >
                    <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z" />
                  </svg>
                  <span> U-M Library</span></a
                >
              </li>
              <li>
                <a href="https://www.lib.umich.edu/about-us/about-library/diversity-equity-inclusion-and-accessibility/accessibility">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    height="16"
                    viewBox="0 0 24 24"
                    width="16"
                    fill="currentColor"
                    aria-hidden="true"
                    focusable="false"
                    role="img"
                  >
                    <path d="M0 0h24v24H0z" fill="none" />
                    <circle cx="17" cy="4.54" r="2" />
                    <path
                      d="M14 17h-2c0 1.65-1.35 3-3 3s-3-1.35-3-3 1.35-3 3-3v-2c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5zm3-3.5h-1.86l1.67-3.67C17.42 8.5 16.44 7 14.96 7h-5.2c-.81 0-1.54.47-1.87 1.2L7.22 10l1.92.53L9.79 9H12l-1.83 4.1c-.6 1.33.39 2.9 1.85 2.9H17v5h2v-5.5c0-1.1-.9-2-2-2z"
                    />
                  </svg>
                  <span>Accessibility</span></a
                >
              </li>
              <li>
                <a href="https://www.lib.umich.edu/about-us/policies/library-privacy-statement"
                  ><svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    aria-hidden="true"
                    focusable="false"
                    role="img"
                  >
                    <path
                      d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z"
                    />
                  </svg>
                  <span>Library Privacy Statement</span></a
                >
              </li>
            </ul>
          </section>

          <section>
            <h2>Digital Collections</h2>
            <ul>
              <li>
                <a href="https://quod.lib.umich.edu/"
                  ><svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    aria-hidden="true"
                    focusable="false"
                    role="img"
                  >
                    <path
                      d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z"
                    />
                  </svg>
                  <span>Browse all digital collections</span></a
                >
              </li>
              <li>
                <a href="https://www.lib.umich.edu/collections/digital-collections"
                  ><svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    aria-hidden="true"
                    focusable="false"
                    role="img"
                  >
                    <path
                      d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z"
                    />
                  </svg>
                  <span>About these digital collections</span></a
                >
              </li>
              <li>
                <a href="https://www.lib.umich.edu/about-us/our-divisions-and-departments/library-information-technology/digital-content-and"
                  ><svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    aria-hidden="true"
                    focusable="false"
                    role="img"
                  >
                    <path
                      d="M20 0H4v2h16V0zM4 24h16v-2H4v2zM20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm-8 2.75c1.24 0 2.25 1.01 2.25 2.25s-1.01 2.25-2.25 2.25S9.75 10.24 9.75 9 10.76 6.75 12 6.75zM17 17H7v-1.5c0-1.67 3.33-2.5 5-2.5s5 .83 5 2.5V17z"
                    />
                  </svg>
                  <span>About Digital Content and Collections</span>
                </a>
              </li>
              <li>
                <a href="{//qui:footer/qui:link[@rel='help']/@href}">
                  <svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    aria-hidden="true"
                    focusable="false"
                    role="img"
                  >
                    <path d="M0 0h24v24H0z" fill="none" />
                    <path
                      d="M11 18h2v-2h-2v2zm1-16C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm0-14c-2.21 0-4 1.79-4 4h2c0-1.1.9-2 2-2s2 .9 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5 0-2.21-1.79-4-4-4z"
                    />
                  </svg>

                  <span>How to use this site</span></a
                >
              </li>
            </ul>
          </section>

          <section class="[ footer__policies ]">
            <h2>Policies and Copyright</h2>
            <p>
              Copyright permissions may be different for each digital
              collection. Please check the
              <a href="#rights-statement">Rights and Permissions</a> section on a specific
              collection for information.
            </p>
            <p>
              <a href="https://www.lib.umich.edu/about-us/policies/takedown-policy-sensitive-information-u-m-digital-collections"
                >Takedown Policy for Sensitive Information in U-M Digital
                Collections</a
              >
            </p>
          </section>
          <section>
            <h2>Contact Us</h2>
            <ul>
              <li>
                <a href="/cgi/f/feedback?collid={//qui:root/@collid}&amp;to=tech"
                  ><svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    aria-hidden="true"
                    focusable="false"
                    role="img"
                  >
                    <path
                      d="M22.7 19l-9.1-9.1c.9-2.3.4-5-1.5-6.9-2-2-5-2.4-7.4-1.3L9 6 6 9 1.6 4.7C.4 7.1.9 10.1 2.9 12.1c1.9 1.9 4.6 2.4 6.9 1.5l9.1 9.1c.4.4 1 .4 1.4 0l2.3-2.3c.5-.4.5-1.1.1-1.4z"
                    />
                  </svg>
                  <span>Report problems using this collection</span></a
                >
              </li>
              <li>
                <a href="/cgi/f/feedback?collid={//qui:root/@collid}&amp;to=content"
                  ><svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    aria-hidden="true"
                    focusable="false"
                    role="img"
                  >
                    <path
                      d="M19 2H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h4l3 3 3-3h4c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-6 16h-2v-2h2v2zm2.07-7.75l-.9.92C13.45 11.9 13 12.5 13 14h-2v-.5c0-1.1.45-2.1 1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41 0-1.1-.9-2-2-2s-2 .9-2 2H8c0-2.21 1.79-4 4-4s4 1.79 4 4c0 .88-.36 1.68-.93 2.25z"
                    />
                  </svg>
                  <span>Ask about this content</span></a
                >
              </li>
              <li>
                <a href="/cgi/f/feedback?collid={//qui:root/@collid}&amp;to=dcc"
                  ><svg
                    xmlns="http://www.w3.org/2000/svg"
                    width="16"
                    height="16"
                    viewBox="0 0 24 24"
                    fill="currentColor"
                    aria-hidden="true"
                    focusable="false"
                    role="img"
                  >
                    <path
                      d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z"
                    />
                  </svg>
                  <span>Ask about our digital collections</span></a
                >
              </li>
            </ul>
          </section>
                    
        </div>
      </div>
      <div class="[ footer__disclaimer ]">
        <div class="viewport-container">
          <p>© <xsl:value-of select="date:year()" />, Regents of the University of Michigan</p>
          <p>
            Built with the
            <a href="https://design-system.lib.umich.edu/"
              >U-M Library Design System</a
            >
          </p>
        </div>
      </div>
    </footer>
  </xsl:template>

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
    <xsl:attribute name="href">
      <xsl:value-of select="@href" />
    </xsl:attribute>
  </xsl:template>

  <xsl:template match="qui:head/qui:link">
    <link rel="{@rel}" href="{@href}" />
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
      <xsl:apply-templates select="@id" mode="copy" />
      <xsl:apply-templates select="@*[starts-with(name(), 'data-')]" mode="copy" />

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
    <div class="[ border-bottom ][ pr-1 ]">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="qui:panel/qui:header">
    <h3>
      <xsl:apply-templates select="." mode="copy-guts" />
    </h3>
  </xsl:template>

  <xsl:template match="qui:panel/qui:nav">
    <ul class="nav">
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
    <div>
      <dt data-key="{@key}">
        <xsl:apply-templates select="qui:label" mode="copy-guts" />
      </dt>
      <xsl:for-each select="qui:values/qui:value">
        <dd>
          <xsl:apply-templates select="." mode="copy-guts" />
        </dd>
      </xsl:for-each>
    </div>
  </xsl:template>

  <xsl:template match="qui:hidden-input[@name='debug']" priority="100" />

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
    <!-- <xsl:message>AHOY COPY GUTS: <xsl:value-of select="local-name()" /></xsl:message> -->
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
    <!-- <xsl:message>COPY XHTML <xsl:value-of select="local-name()" /></xsl:message> -->
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml" data-copy="xhtml">
      <xsl:apply-templates select="*|@*|text()" mode="copy" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="node()[namespace-uri() = 'http://dlxs.org/quombat/xhtml']" mode="copy" priority="99">
    <xsl:element name="{name()}" namespace="http://www.w3.org/1999/xhtml">
      <xsl:apply-templates select="*|@*|text()" mode="copy" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="text()" mode="copy" priority="25">
    <xsl:if test="normalize-space(.)">
      <xsl:variable name="x" select="substring(normalize-space(.), 1, 1)" />
      <xsl:if test="position() &gt; 1">
        <xsl:choose>
          <xsl:when test="$x = '.' or $x = ';' or $x = ':' or $x = ')'">
          </xsl:when>
          <xsl:otherwise><xsl:text> </xsl:text></xsl:otherwise>
        </xsl:choose>
      </xsl:if>
      <xsl:value-of select="normalize-space(.)" />
      <xsl:if test="position() &lt; last()">
        <xsl:text> </xsl:text>
      </xsl:if>
    </xsl:if>
  </xsl:template>

  <xsl:template match="@*|*|text()" mode="copy">
    <!-- <xsl:message>COPY <xsl:value-of select="local-name()" /> :: <xsl:value-of select="namespace-uri()" /></xsl:message> -->
    <xsl:copy>
      <xsl:apply-templates select="@*|*|text()" mode="copy" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>