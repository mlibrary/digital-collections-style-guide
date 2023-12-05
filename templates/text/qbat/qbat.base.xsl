<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:qbat="http://dlxs.org/quombat/quombat" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <xsl:output
    method="xml"
    indent="yes"
    encoding="utf-8"
    doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd"
    doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN"
    omit-xml-declaration="yes"
    version="5.0"
    />

  <xsl:key match="/qui:root/qui:lookup/qui:item" name="get-lookup" use="@key" />

  <xsl:param name="docroot">/digital-collections-style-guide/</xsl:param>
  <xsl:param name="api_url"><xsl:value-of select="//qui:root/@api_url" /></xsl:param>
  <xsl:param name="ds_url">https://cdn.jsdelivr.net/npm</xsl:param>

  <xsl:variable name="collid" select="//qui:root/@collid" />
  <xsl:variable name="context-type" select="//qui:root/@context-type" />
  <xsl:variable name="username" select="//qui:root/@username" />
  <xsl:variable name="view" select="//qui:root/@view" />

  <xsl:template match="qui:root">
    <html lang="en" data-root="{$docroot}" data-username="{$username}" data-view="{$view}" data-template="{//qui:root/@template}" data-initialized="false" style="opacity: 0">
      <xsl:call-template name="make-data-attribute">
        <xsl:with-param name="name">c</xsl:with-param>
        <xsl:with-param name="value"><xsl:value-of select="$collid" /></xsl:with-param>
      </xsl:call-template>       
      <xsl:call-template name="make-data-attribute">
        <xsl:with-param name="name">g</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:value-of select="//qui:root/@groupid" />
        </xsl:with-param>
      </xsl:call-template>
      <xsl:call-template name="make-data-attribute">
        <xsl:with-param name="name">analytics-code-for-coll</xsl:with-param>
        <xsl:with-param name="value">
          <xsl:value-of select="//qui:root/@analytics-code-for-coll" />
        </xsl:with-param>
      </xsl:call-template>

      <xsl:if test="false() and normalize-space($collid)">
        <base href="/{substring($collid, 1, 1)}/{$collid}/" />
      </xsl:if>

      <xsl:apply-templates select="qui:head" />
      <body class="[ font-base-family ]" data-class="text" data-initialized="false" style="opacity: 0">
        <xsl:apply-templates select="build-body-data" />

        <!-- Google Tag Manager (noscript) -->
        <noscript><iframe src="https://www.googletagmanager.com/ns.html?id=GTM-MN98W2F"
        height="0" width="0" style="display:none;visibility:hidden"></iframe></noscript>
        <!-- End Google Tag Manager (noscript)-->

        <xsl:apply-templates select="//qui:skip-links" />
        <div class="border-bottom">
          <m-universal-header></m-universal-header>
          <div class="website-header-mobile">
            <xsl:apply-templates select="//qui:m-website-header" />
            <xsl:apply-templates select="//qui:m-website-header" mode="mobile-nav" />
          </div>
          <xsl:apply-templates select="//qui:sub-header" />
        </div>

        <main id="maincontent">
          <xsl:attribute name="class">
            <xsl:text>[ viewport-container ]</xsl:text>
            <xsl:call-template name="build-extra-main-class" />
          </xsl:attribute>
          <xsl:apply-templates select="//qui:main" />
        </main>

        <xsl:call-template name="build-feedback-callout" />
        <xsl:call-template name="build-footer" />
        <iframe name="bookbag-sink" id="bookbag-sink"></iframe>
        <xsl:call-template name="build-body-extra" />
      </body>
    </html>
  </xsl:template>

  <xsl:template name="build-extra-main-class" />

  <xsl:template name="build-extra-scripts" />
  <xsl:template name="build-extra-styles" />

  <xsl:template name="build-body-data" />

  <xsl:template name="build-body-extra" />

  <xsl:template match="qui:skip-links">
    <div aria-label="Skip links" class="[ skip-links ]">
      <div class="[ viewport-container ]">
        <ul>
          <xsl:for-each select="qui:link">
            <li>
              <xsl:apply-templates select="." />
            </li>
          </xsl:for-each>
        </ul>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="qui:head">
    <head>
      <meta charset="UTF-8" />
      <meta name="viewport" content="width=device-width, initial-scale=1.0" />
      <xsl:apply-templates select="qui:base" />

      <xsl:apply-templates select="xhtml:title" mode="copy" />
      <xsl:apply-templates select="xhtml:meta" mode="copy" />

      <xsl:apply-templates select="qui:link" />

      <link
        rel="stylesheet"
        href="https://fonts.googleapis.com/icon?family=Material+Icons"
      />
      <link href="{$ds_url}/@umich-lib/web@1.3.0/umich-lib.css" rel="stylesheet" />
      <link href="{$docroot}styles/styles.css" rel="stylesheet" />

      <script>
        window.mUse = [ 'm-universal-header', 'm-website-header', 'm-logo' ];
      </script>

      <script type="module" src="{$ds_url}/@umich-lib/web@1.3.0/dist/umich-lib/umich-lib.esm.js"></script>
      <script nomodule="" src="{$ds_url}/@umich-lib/web@1.3.0/dist/umich-lib/umich-lib.js"></script>

      <xsl:call-template name="build-app-script" />

      <xsl:call-template name="build-cqfill-script" />

      <!-- <link href="data:image/x-icon;base64,AAABAAEAEBAAAAAAAABoBQAAFgAAACgAAAAQAAAAIAAAAAEACAAAAAAAAAEAAAAAAAAAAAAAAAEAAAAAAAAAAAAAAOX/AD09PQA0a5EAuwD/AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAICAgACAgACAgIAAAAAAAIDAwMCAgICAwMDAgAAAAIDAwMDAgICAgMDAwMCAAACAwMDAgICAgICAwMDAgAAAgMDAwICAgICAgMDAwIAAAIBAwMCAgICAgIDAwECAAACAQEBAQICAgIBAQEBAgAAAgEBAgEBAgIBAQIBAQIAAAACAQEBAQEBAQEBAQIAAAAAAgEBAQEBAQEBAQECAAAAAAICAQEBAQEBAQECAgAAAAACBAIBAQEBAQECBAIAAAAAAAICAgICAgICAgIAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAP//AADiRwAAwAMAAIABAACAAQAAgAEAAIABAACAAQAAgAEAAMADAADAAwAAwAMAAMADAADgBwAA//8AAP//AAA=" rel="icon" type="image/x-icon" /> -->
      <link href="data:image/png;base64,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" rel="icon" type="image/png" />

      <xsl:call-template name="build-extra-scripts" />
      <xsl:call-template name="build-extra-styles" />

    </head>
  </xsl:template>

  <xsl:template name="build-app-script">
    <script src="{$docroot}dist/js/text/main.js"></script>
  </xsl:template>
  
  <xsl:template name="build-cqfill-script">
    <!-- <script src="{$ds_url}/container-query-polyfill/cqfill.iife.min.js"></script> -->
    <script src="{$ds_url}/container-query-polyfill@1/dist/container-query-polyfill.modern.js"></script>
  </xsl:template>

  <xsl:template match="qui:m-website-header">
    <xsl:variable name="root-href">
      <xsl:choose>
        <xsl:when test="$docroot = '/'">/samples/</xsl:when>
        <xsl:when test="starts-with($api_url, 'https://dcp-proto')">/samples/</xsl:when>
        <xsl:when test="starts-with($api_url, 'https://quod.lib')">/lib/colllist/?byFormat=Text%20Collections</xsl:when>
        <xsl:otherwise>/cgi/c/collsize/coll-idx?byFormat=Text%20Collections</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <m-website-header name="{@name}" to="{$root-href}" data-docroot="{$docroot}">
      <xsl:apply-templates select="qui:nav" />
    </m-website-header>
  </xsl:template>

  <xsl:template match="qui:m-website-header" mode="mobile-nav">
    <div class="mobile-nav">
      <span class="nav-btn"></span>
      <div class="submenu-container">
        <div class="primary-container">
          <ul>
            <xsl:for-each select="qui:nav/qui:link">
              <li>
                <xsl:apply-templates select="." />
              </li>
            </xsl:for-each>
          </ul>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="qui:sub-header">
    <div class="website-sub-header">
      <div class="[ viewport-container flex ][ flex-center flex-gap-0_5 ]">
        <a href="{@href}" class="[ flex flex-center flex-gap-0_5 ]">
          <span class="material-icons" aria-hidden="true">
            <xsl:value-of select="@data-badge" />
          </span>
          <span class="label">
            <xsl:value-of select="." />
          </span>
        </a>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="qui:m-website-header/qui:nav">
    <nav class="[ primary-nav ][ flex flex-center justify-end ][ gap-0_75 ]">
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
      <nav aria-label="Breadcrumb" style="flex-grow: 8">
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
            </li>
          </xsl:for-each>
        </ol>
      </nav>
      <xsl:call-template name="build-breadcrumbs-extra-nav" />
    </div>
  </xsl:template>

  <xsl:template name="build-breadcrumbs-extra-nav"></xsl:template>

  <xsl:template name="build-feedback-callout">
    <xsl:variable name="feedback-href">
      <xsl:call-template name="get-feedback-href" />
    </xsl:variable>

    <div class="[ mt-1 feedback-callout ]">
      <div class="viewport-container">
        <div class="[ pt-2 pb-2 ]">
          <div class="flex flex-flow-row gap-0_5">
            <span class="material-icons contact-icon" aria-hidden="true">email</span>
            <span>
              Do you have questions about this content? Need to report a problem?
              Please <a class="text--bold" href="{$feedback-href};to=tech">contact us</a>.
            </span>
          </div>
        </div>
      </div>
    </div>
  </xsl:template>

  <xsl:template name="build-footer">
    <xsl:variable name="feedback-href">
      <xsl:call-template name="get-feedback-href" />
    </xsl:variable>
    <footer class="[ footer ][ xx-mt-2 ]">
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
            <xsl:variable name="rights-statement-href">
              <xsl:call-template name="get-rights-statement-href" />
            </xsl:variable>
            <h2>Policies and Copyright</h2>
            <p>
              Copyright permissions may be different for each digital
              collection. Please check the
              <a href="{$rights-statement-href}">Rights and Permissions</a> section on a specific
              collection for information.
            </p>
            <p>
              <a href="https://www.lib.umich.edu/about-us/policies/takedown-policy-sensitive-information-u-m-digital-collections"
                >Takedown Policy for Sensitive Information in U-M Digital
                Collections</a
              >
            </p>
            <p>
              <a href="https://www.lib.umich.edu/about-us/policies/takedown-policy-addressing-copyright-concerns"
                >Takedown Policy for Addressing Copyright
                Concerns</a
              >
            </p>
          </section>
          <section style="display: none;">
            <h2>Contact Us</h2>
            <ul>
              <li>
                <a href="{$feedback-href};to=tech"
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
                <a href="{$feedback-href};to=content"
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
                <a href="https://www.lib.umich.edu/collections/digital-collections/about-our-digital-collections"
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

  <xsl:template match="qui:base">
    <base href="{@href}" />
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

  <xsl:template match="qui:link[@rel='quod']" priority="101">
    <a href="#" class="quod-link" target="_blank">
      <!-- <span class="material-icons" aria-hidden="true">stream</span>
      <span>QUOD</span> -->
      <img src="{$docroot}static/QUOD.svg" />
    </a>
  </xsl:template>

  <xsl:template match="qui:link">
    <xsl:param name="class" />
    <xsl:param name="attributes" />
    <a>
      <xsl:call-template name="build-href-or-identifier" />
      <xsl:if test="normalize-space($class)">
        <xsl:attribute name="class"><xsl:value-of select="$class" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="@class">
        <xsl:apply-templates select="@class" mode="copy" />
      </xsl:if>
      <xsl:if test="normalize-space($attributes)">
        <xsl:for-each select="exsl:node-set($attributes)//qui:attribute">
          <xsl:attribute name="{@name}"><xsl:value-of select="." /></xsl:attribute>
        </xsl:for-each>
      </xsl:if>
      <xsl:apply-templates select="@id" mode="copy" />
      <xsl:if test="normalize-space(@rel)">
        <xsl:attribute name="data-rel"><xsl:value-of select="@rel" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="normalize-space(@target)">
        <xsl:attribute name="data-target"><xsl:value-of select="@target" /></xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@*[starts-with(name(), 'data-')]" mode="copy" />

      <xsl:if test="@icon">
        <span class="material-icons" aria-hidden="true">
          <xsl:value-of select="@icon" />
        </span>
        <xsl:text> </xsl:text>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="qui:label"><xsl:value-of select="qui:label" /></xsl:when>
        <xsl:when test="@label"><xsl:value-of select="@label" /></xsl:when>
        <xsl:when test="@rel = 'next'">Next</xsl:when>
        <xsl:when test="@rel = 'previous'">Previous</xsl:when>
        <xsl:when test="@rel = 'next-item'">Next Item</xsl:when>
        <xsl:when test="@rel = 'previous-item'">Previous Item</xsl:when>
        <xsl:when test="@rel = 'next-section'">Next Section</xsl:when>
        <xsl:when test="@rel = 'previous-section'">Previous Section</xsl:when>
        <xsl:when test="@rel = 'back'">Search Results</xsl:when>
        <xsl:when test="@icon">
          <span>
            <xsl:apply-templates mode="copy" />
          </span>
        </xsl:when>
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

  <xsl:template match="qui:panel[.//qui:link]">
    <div class="[ border-bottom ][ pr-1 ]">
      <xsl:apply-templates />
    </div>
  </xsl:template>

  <xsl:template match="qui:panel[.//qui:link]/qui:header">
    <h3>
      <xsl:apply-templates select="." mode="copy-guts" />
    </h3>
  </xsl:template>

  <xsl:template match="qui:panel/qui:nav">
    <ul class="nav">
      <xsl:for-each select="qui:link">
        <li class="py-1">
          <xsl:if test="@data-badge='group'">
            <a class="material-icons text-black no-underline" aria-hidden="true" href="{@href}">topic</a>
          </xsl:if>
          <xsl:apply-templates select="." mode="copy" />
          <!-- <a href="{@href}" class="text-teal-400 underline">
            <xsl:apply-templates select="." mode="copy-guts" />
          </a> -->
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

  <xsl:template match="qui:panel" />

  <xsl:template match="qui:main">
    <section class="px-9">
      <pre>MAIN</pre>
    </section>
  </xsl:template>

  <xsl:template name="build-collection-heading">
    <div class="flex flex-flow-rw flex-space flex-space-between flex-align-center" style="column-gap: 3rem; row-gap: 1rem;">
      <xsl:call-template name="build-collection-heading-h1" />
      <!-- <xsl:apply-templates select="//qui:form[@id='item-search']" /> -->
    </div>
  </xsl:template>

  <xsl:template name="build-collection-heading-h1">
    <xsl:variable name="header" select="//qui:header[@role='main']" />
    <h1 class="collection-heading mb-0" style="flex-grow: 2">
      <xsl:if test="normalize-space($header/@data-badge)">
        <span class="material-icons" aria-hidden="true">
          <xsl:value-of select="$header/@data-badge" />
        </span>
      </xsl:if>
      <xsl:call-template name="build-collection-header-string">
        <xsl:with-param name="header" select="normalize-space($header)" />
      </xsl:call-template>
      <!-- <xsl:value-of select="$header" /> -->
    </h1>
  </xsl:template>

  <xsl:template name="build-collection-header-string">
    <xsl:param name="header" />
    <xsl:value-of select="$header" />
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
    <input type="text" value="{.}" id="input-{ancestor-or-self::qui:field/@key}" readonly="true" />
  </xsl:template>

  <xsl:template match="qui:field">
    <xsl:apply-templates select="." mode="build" />
  </xsl:template>

  <xsl:template match="qui:field" mode="build">
    <div data-key="{@key}" data-lookup="{@lookup}">
      <dt data-key="{@key}">
        <xsl:apply-templates select="@*[starts-with(name(), 'data-')]" mode="copy" />
        <xsl:choose>
          <xsl:when test="qui:label">
            <xsl:apply-templates select="qui:label" mode="copy-guts" />
          </xsl:when>
          <xsl:when test="@lookup">
            <xsl:value-of select="key('get-lookup', concat('uplift.header.str.', @lookup))" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="key('get-lookup', concat('uplift.header.str.', @key))" />
          </xsl:otherwise>
        </xsl:choose>
      </dt>
      <xsl:apply-templates select="qui:values" />
    </div>
  </xsl:template>

  <xsl:template match="qui:values">
    <xsl:for-each select="qui:value">
    <dd>
      <xsl:apply-templates select="." mode="copy-guts" />
    </dd>
  </xsl:for-each>

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

  <xsl:template name="build-content-copy-metadata">
    <xsl:param name="term" />
    <xsl:param name="text" />
    <xsl:param name="class" />
    <xsl:param name="key" />
    <div>
      <dt>
        <xsl:if test="$key">
          <xsl:attribute name="data-key"><xsl:value-of select="$key" /></xsl:attribute>
        </xsl:if>
        <xsl:value-of select="$term" />
      </dt>
      <dd>
        <div class="text--copyable">
          <span>
            <xsl:if test="normalize-space($class)">
              <xsl:attribute name="class"><xsl:value-of select="$class" /></xsl:attribute>
            </xsl:if>
            <xsl:value-of select="$text" />
          </span>
          <button class="button button--small" data-action="copy-text" aria-label="Copy Text">
            <span class="material-icons" aria-hidden="true">content_copy</span>
          </button>
        </div>
      </dd>
    </div>
  </xsl:template>

  <xsl:template name="get-rights-statement-href">
    <xsl:choose>
      <xsl:when test="$context-type = 'collection'">
        <xsl:text>/cgi/t/text/text-idx?cc=</xsl:text>
        <xsl:value-of select="$collid" />
        <xsl:text>;page=index#rights-permissions</xsl:text>
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>https://www.lib.umich.edu/about-us/policies/copyright-policy</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="get-feedback-href">
    <xsl:value-of select="//qui:footer/qui:link[@rel='feedback']/@href" />
  </xsl:template>

  <xsl:template name="build-hidden-portfolio-form">
    <xsl:param name="target">bookbag-sink</xsl:param>
    <form style="display: none" method="GET" action="/cgi/t/text/text-idx" id="bbaction-form" target="{$target}">
      <xsl:apply-templates select="//qui:form[@action='bbaction']/qui:hidden-input" />
      <input type="hidden" name="bbaction" value="" id="bbaction-page" />
      <xsl:if test="$collid != '*'">
        <input type="hidden" name="bbc" value="{$collid}" />
        <input type="hidden" name="c" value="{$collid}" />
        <input type="hidden" name="cc" value="{$collid}" />  
      </xsl:if>
    </form>
  </xsl:template>

  <!-- UTILITY -->
  <xsl:template name="button">
    <xsl:param name="label" />
    <xsl:param name="classes" />
    <xsl:param name="icon" />
    <xsl:param name="action" />
    <xsl:param name="href" />
    <xsl:param name="data-attributes" />
    <xsl:param name="label-classes" />
    <xsl:param name="type" />
    <button class="button button--large {$classes}">
      <xsl:if test="$action">
        <xsl:attribute name="data-action"><xsl:value-of select="$action" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="$type">
        <xsl:attribute name="type"><xsl:value-of select="$type" /></xsl:attribute>
      </xsl:if>
      <xsl:if test="$data-attributes">
        <xsl:for-each select="exsl:node-set($data-attributes)//qbat:attribute">
          <xsl:attribute name="{@name}"><xsl:value-of select="." /></xsl:attribute>
        </xsl:for-each>
      </xsl:if>
      <xsl:if test="normalize-space($icon)">
        <span class="material-icons" aria-hidden="true">
          <xsl:value-of select="$icon" />
        </span>
      </xsl:if>
      <span data-slot="label" class="{$label-classes}"><xsl:value-of select="$label" /></span>
    </button>
  </xsl:template>

  <xsl:template match="node()" mode="copy-guts">
    <!-- <xsl:message>AHOY COPY GUTS: <xsl:value-of select="local-name()" /></xsl:message> -->
    <!-- <debug><xsl:value-of select="local-name()" /></debug> -->
    <xsl:apply-templates select="*|text()" mode="copy" />
  </xsl:template>

  <xsl:template match="qui:link[@identifier != '']" mode="copy" priority="100">
    <a href="../{@identifier}/">
      <xsl:choose>
        <xsl:when test="@rel = 'next'">Next</xsl:when>
        <xsl:when test="@rel = 'previous'">Previous</xsl:when>
        <xsl:when test="@rel = 'next-item'">Next Item</xsl:when>
        <xsl:when test="@rel = 'previous-item'">Previous Item</xsl:when>
        <xsl:when test="@rel = 'back'">Search Results</xsl:when>
        <xsl:otherwise><xsl:apply-templates mode="copy" /></xsl:otherwise>
      </xsl:choose>
    </a>
  </xsl:template>

  <xsl:template match="qui:input[@type='text']">
    <xsl:apply-templates select="qui:label" />
    <input>
      <xsl:apply-templates select="@*" mode="copy" />
    </input>
  </xsl:template>

  <xsl:template match="qui:label">
    <label>
      <xsl:apply-templates select="@*|text()" mode="copy" />
    </label>
  </xsl:template>

  <xsl:template match="qui:link[normalize-space(@icon)]" mode="copy" priority="101">
    <a class="bedazzled-link">
      <span class="material-icons" aria-hidden="true">
        <xsl:value-of select="@icon" />
      </span>
      <span>
        <xsl:apply-templates mode="copy" />
      </span>
    </a>
  </xsl:template>
  
  <xsl:template match="qui:link" mode="copy" priority="99">
    <a href="{@href}">
      <xsl:apply-templates select="@class" mode="copy" />
      <xsl:apply-templates mode="copy" />
    </a>
  </xsl:template>

  <xsl:template match="qui:form[@id='item-search']">
    <form id="item-search" class="m-0" style="flex-grow: 1;" action="{@action}" method="GET">
      <!-- <style>
        #item-search * {
          font-size: 0.875rem;
        }
      </style> -->
      <div 
        class="flex flex-flow-rw flex-align-center flex-space-between border border-rounded p-half"
        style="margin: auto; padding: 4px 10px; gap: 0.5rem; border-width: 1px;">
        <xsl:apply-templates select="qui:input" />
        <button class="button button--primary button--small">Search</button>
        <xsl:if test="qui:link[@rel='advanced']">
          <a href="{qui:link[@rel='advanced']/@href}" class="text--small">
            <xsl:text>Advanced</xsl:text>
            <span class="visually-hidden">
              <xsl:text> Search</xsl:text>
            </span>
          </a>
        </xsl:if>
      </div>
      <xsl:apply-templates select="qui:hidden-input" />
    </form>
  </xsl:template>

  <xsl:template name="make-data-attribute">
    <xsl:param name="name" />
    <xsl:param name="value" />
    <xsl:if test="normalize-space($value)">
      <xsl:attribute name="data-{$name}">
        <xsl:value-of select="$value" />
      </xsl:attribute>
    </xsl:if>
  </xsl:template>

  <xsl:template match="xhtml:br" mode="copy" priority="105">
    <!-- <xsl:message>AHOY XHTML:BR</xsl:message> -->
    <br />
  </xsl:template>

  <xsl:template match="node()[namespace-uri() = 'http://www.w3.org/1999/xhtml']" mode="copy" priority="101">
    <!-- <xsl:message>AHOY COPY XHTML <xsl:value-of select="local-name()" /></xsl:message> -->
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml" data-copy="xhtml">
      <xsl:apply-templates select="*|@*|text()" mode="copy" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="node()[namespace-uri() = 'http://dlxs.org/quombat/xhtml']" mode="copy" priority="99">
    <xsl:element name="{local-name()}" namespace="http://www.w3.org/1999/xhtml" data-copy="dlxs">
      <xsl:apply-templates select="*|@*|text()" mode="copy" />
    </xsl:element>
  </xsl:template>

  <xsl:template match="text()" mode="maybe-not-copy" priority="25">
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

  <xsl:template match="br" mode="copy" priority="100">
    <!-- <xsl:message>AHOY BR</xsl:message> -->
    <br />
  </xsl:template>

  <xsl:template match="qui:ul">
    <ul>
      <xsl:if test="parent::qui:li">
        <xsl:attribute name="class">mt-0_5</xsl:attribute>
      </xsl:if>
      <xsl:apply-templates select="@class" mode="copy" />
      <xsl:apply-templates />
    </ul>
  </xsl:template>

  <xsl:template match="qui:li">
    <li>
      <xsl:attribute name="class">
        <xsl:text>mb-0_5 </xsl:text>
        <xsl:if test="@current">
          <xsl:value-of select="@current" />
        </xsl:if>
      </xsl:attribute>
      <xsl:apply-templates />
    </li>
  </xsl:template>

  <xsl:template match="xhtml:a[@target='_blank']" mode="copy" priority="101">
    <a>
      <xsl:apply-templates select="@*" mode="copy" />
      <xsl:apply-templates mode="copy" />
      <span class="sr-only"> (opens in new tab)</span>
    </a>
      <!-- <svg width="25" height="25" viewBox="0 0 24 24" style="margin-left: 0.25rem; vertical-align: text-bottom; display: inline-block; fill: currentColor;">
        <title>Open in new window</title>
        <path d="M14,3V5H17.59L7.76,14.83L9.17,16.24L19,6.41V10H21V3M19,19H5V5H12V3H5C3.89,3 3,3.9 3,5V19A2,2 0 0,0 5,21H19A2,2 0 0,0 21,19V12H19V19Z"></path>
      </svg> -->
</xsl:template>

  <xsl:template match="@*|*|text()" mode="copy">
    <!-- <xsl:message>AHOY DEFAULT COPY <xsl:value-of select="namespace-uri()" />::<xsl:value-of select="local-name()" /> :: <xsl:value-of select="namespace-uri()" /></xsl:message> -->
    <xsl:copy>
      <xsl:apply-templates select="@*|*|text()" mode="copy" />
    </xsl:copy>
  </xsl:template>

</xsl:stylesheet>