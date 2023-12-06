<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <xsl:output method="xml" indent="yes" encoding="utf-8" doctype-system="http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd" doctype-public="-//W3C//DTD XHTML 1.0 Strict//EN" omit-xml-declaration="yes" version="5.0" />

  <xsl:param name="docroot">/digital-collections-style-guide/</xsl:param>

  <xsl:variable name="collid" select="//qui:root/@collid" />
  <xsl:variable name="username" select="//qui:root/@username" />
  <xsl:variable name="view" select="//qui:root/@view" />

  <xsl:variable name="to" select="//qui:root/@to" />

  <xsl:template match="qui:root">
    <html lang="en" data-root="{$docroot}" data-username="{$username}" data-view="{$view}" data-initialized="false" style="opacity: 0">
      <head>
        <meta charset="UTF-8" />
        <meta name="viewport" content="width=device-width, initial-scale=1.0" />
        <title>Digital Collections Contact Form</title>
        <meta name="robots" content="noindex" />

        <link rel="stylesheet" href="https://fonts.googleapis.com/icon?family=Material+Icons" />
        <link href="https://cdn.jsdelivr.net/npm/@umich-lib/web@1/umich-lib.css" rel="stylesheet" />
        <link href="{$docroot}dist/css/text/style.css" rel="stylesheet" />
        <link href="{$docroot}dist/css/feedback.css" rel="stylesheet" />

        <script>
          window.mUse = [  'm-website-header', 'm-logo' ];
        </script>

        <script type="module" src="https://cdn.jsdelivr.net/npm/@umich-lib/web@1/dist/umich-lib/umich-lib.esm.js"></script>
        <script nomodule="" src="https://cdn.jsdelivr.net/npm/@umich-lib/web@1/dist/umich-lib/umich-lib.js"></script>

        <script src="{$docroot}dist/js/image/main.js"></script>
        <script src="https://www.google.com/recaptcha/api.js?onload=onloadCallback" async="async" defer="defer"></script>

        <style>

        </style>

      </head>
      <body class="[ font-base-family ]" style="padding-top: 80px">

        <div style="width: 770px; max-width: 95%; margin: 0 auto">
          <div style="margin-left: -40px">
            <m-website-header name="Digital Collections" to="/samples/"></m-website-header>
          </div>

          <main class="[ ]" style="margin-top: 0">
            <div class="welcome-message">
              <xsl:apply-templates select="@to" mode="message" />
            </div>

            <form method="GET" action="/cgi/f/feedback/feedback" id="feedback-form">

              <xsl:call-template name="build-provide-name" />

              <xsl:call-template name="build-provide-email" />

              <!-- <xsl:call-template name="build-include-username" /> -->
              <xsl:choose>
                <xsl:when test="$username">
                  <input type="hidden" name="includeusername" value="yes" />
                </xsl:when>
                <xsl:otherwise>
                  <input type="hidden" name="includeusername" value="NA" />
                </xsl:otherwise>
              </xsl:choose>

              <div class="form--container">
                <label for="url">If you'd like tell us about a specific page, please copy and paste the URL here.</label>
                <div class="form--control">
                  <input type="text" name="url" id="url" />
                </div>
                <p class="[ hint ][ mt-0 ]">
                  We've supplied the URL of the last page you visited.
                </p>
              </div>

              <div class="form--container">
                <label for="comments">Ask a question or leave us a comment.</label>
                <div class="form--control">
                  <textarea name="comments" id="comments" required="required"></textarea>
                </div>
                <xsl:call-template name="build-required-field-label" />
              </div>

              <fieldset class="form--container">
                <legend>Status</legend>
                <p class="[ hint flex ][ mt-0 mb-0 ]">
                  <span aria-hidden="true" class="material-icons" style="margin-right: 0.25rem; color: var(--color-green-300)">check_circle</span>
                  This field is optional.
                </p>

                <xsl:variable name="status-list-tmp">
                  <qui:option value="student">U-M Student</qui:option>
                  <qui:option value="faculty">U-M Faculty</qui:option>
                  <qui:option value="alumni">U-M Alumni</qui:option>
                  <qui:option value="library-staff">U-M Library Staff</qui:option>
                  <qui:option value="staff">U-M Staff</qui:option>
                  <qui:option value="retired">Retired U-M Faculty or Staff</qui:option>
                  <qui:option value="other">Other U-M Affiliated</qui:option>
                  <qui:option value="guest">Not affiliated with U-M</qui:option>
                </xsl:variable>

                <div class="form--control">
                  <xsl:for-each select="exsl:node-set($status-list-tmp)//qui:option">
                    <div class="form--input--radio">
                      <input type="radio" value="{@value}" name="status" id="status-{position()}" />
                      <label for="status-{position()}"><xsl:value-of select="." /></label>
                    </div>
                  </xsl:for-each>
                </div>
              </fieldset>
              
              <div class="form--container" style="align-items: center">
                <div class="g-recaptcha" data-sitekey="6Ldah1EUAAAAAH7Cvi-8QDaDgRtGtW7oqA_GZ4ha"></div>
              </div>

              <div class="" style="text-align: right">
                <button class="button button--cta" type="submit">Submit</button>
              </div>

              <xsl:apply-templates select="//qui:hidden-input" />
              <input type="hidden" name="" value="1" id="session-id" />

            </form>

          </main>
        </div>

        <xsl:call-template name="build-footer" />

        <script>
          var onloadCallback = function() {
          };

          function getCookie (name) {
            let value = `; ${document.cookie}`;
            let parts = value.split(`; ${name}=`);
            if (parts.length === 2) return parts.pop().split(';').shift();
          }

          document.querySelector('#url').value = document.querySelector('input[name="return"]').value;

          let $form = document.querySelector('#feedback-form');
          $form.addEventListener('submit', function(event) {
            if ( ! $form.checkValidity() ) { return ; }
            event.preventDefault();
            let params = new URLSearchParams();
            params.append('g-recaptcha-response', document.querySelector('#g-recaptcha-response').value);
            fetch('/cgi/f/feedback/validatecaptcha', {
              method: 'POST',
              mode: 'same-origin',
              cache: 'no-cache',
              credentials: 'same-origin',
              body: params
            })
            .then(function(resp) {
              return resp.text();
            })
            .then(function(text) {
              if ( text.indexOf('SUCCESS') == -1 ) {
                alert("NOPE");
              } else {
                document.querySelector('#session-id').setAttribute('name', getCookie('DLXSsid'));
                $form.submit();
              }
            })
            .catch(function(error) {
              console.log(error);
            });

          });


        </script>

      </body>

    </html>
  </xsl:template>

  <xsl:template match="@to[. = 'content']" mode="message">
    <p>We welcome your <strong>questions and comments about this collection.</strong> 
    Thanks for taking the time to write.</p>
  </xsl:template>

  <xsl:template match="@to[. = 'tech']" mode="message">
    <p>
      Something went awry? <img alt="" aria-hidden="true" src="data:image/png;base64,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" />
    </p>
    <p>
      Please let us know any <strong>issues or questions</strong> you have using Digital Collections. 
    </p>
  </xsl:template>

  <xsl:template match="@to[. = 'dcc']" mode="message">
    <p>
      We welcome your <strong>questions and interest</strong> in Digital Collections.
      Thanks for taking the time to write.
    </p>
  </xsl:template>

  <xsl:template match="qui:hidden-input">
    <input type="hidden" name="{@name}" value="{@value}" />
  </xsl:template>

  <xsl:template name="build-include-username">
    <fieldset class="form--container">
      <legend>Do you want to include your username?</legend>
      <p class="[ help ][ mt-0 mb-0 ]">
        <xsl:text>You've authenticated to Digital Collections as </xsl:text>
        <tt><xsl:value-of select="$username" /></tt>
      </p>
      <div class="form-control mt-0">
        <div class="form--input--radio">
          <input type="radio" id="includeusername-yes" checked="checked" name="includeusername" value="yes" />
          <label for="includeusername-yes">Yes</label>
        </div>
        <div class="form--input--radio">
          <input type="radio" id="includeusername-no" name="includeusername" value="no" />
          <label for="includeusername-no">No</label>
        </div>
      </div>
    </fieldset>
  </xsl:template>

  <xsl:template name="build-provide-name">
    <div class="form--container">
      <label for="email">Your name</label>
      <div class="form--control">
        <input type="text" name="name" id="name" required="required" />
      </div>
      <xsl:call-template name="build-required-field-label" />
    </div>
  </xsl:template>

  <xsl:template name="build-provide-email">
    <div class="form--container">
      <label for="email">Your email</label>
      <div class="form--control">
        <input type="text" name="email" id="email" required="required" />
      </div>
      <xsl:call-template name="build-required-field-label" />
      <!-- <p class="[ hint ][ mt-0 ]">
        To request a reply, please provide your email address.
      </p> -->
    </div>
  </xsl:template>

  <xsl:template name="build-required-field-label">
    <p class="[ hint flex ][ mt-0 ]">
      <span aria-hidden="true" class="material-icons" style="margin-right: 0.25rem">info</span>
      This field is required.
    </p>
  </xsl:template>

  <xsl:template name="build-footer">
    <footer class="[ footer ][ mt-2 ]">
      <div class="viewport-container">
        <div class="[ footer__content ]">
          <section>
            <h2>University of Michigan Library</h2>
            <ul>
              <li>
                <a href="https://lib.umich.edu/">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" focusable="false" role="img">
                    <path d="M10 20v-6h4v6h5v-8h3L12 3 2 12h3v8z" />
                  </svg>
                  <span> U-M Library</span>
                </a>
              </li>
              <li>
                <a href="https://www.lib.umich.edu/about-us/about-library/diversity-equity-inclusion-and-accessibility/accessibility">
                  <svg xmlns="http://www.w3.org/2000/svg" height="16" viewBox="0 0 24 24" width="16" fill="currentColor" aria-hidden="true" focusable="false" role="img">
                    <path d="M0 0h24v24H0z" fill="none" />
                    <circle cx="17" cy="4.54" r="2" />
                    <path d="M14 17h-2c0 1.65-1.35 3-3 3s-3-1.35-3-3 1.35-3 3-3v-2c-2.76 0-5 2.24-5 5s2.24 5 5 5 5-2.24 5-5zm3-3.5h-1.86l1.67-3.67C17.42 8.5 16.44 7 14.96 7h-5.2c-.81 0-1.54.47-1.87 1.2L7.22 10l1.92.53L9.79 9H12l-1.83 4.1c-.6 1.33.39 2.9 1.85 2.9H17v5h2v-5.5c0-1.1-.9-2-2-2z" />
                  </svg>
                  <span>Accessibility</span>
                </a>
              </li>
              <li>
                <a href="https://www.lib.umich.edu/about-us/policies/library-privacy-statement">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" focusable="false" role="img">
                    <path d="M18 8h-1V6c0-2.76-2.24-5-5-5S7 3.24 7 6v2H6c-1.1 0-2 .9-2 2v10c0 1.1.9 2 2 2h12c1.1 0 2-.9 2-2V10c0-1.1-.9-2-2-2zm-6 9c-1.1 0-2-.9-2-2s.9-2 2-2 2 .9 2 2-.9 2-2 2zm3.1-9H8.9V6c0-1.71 1.39-3.1 3.1-3.1 1.71 0 3.1 1.39 3.1 3.1v2z" />
                  </svg>
                  <span>Library Privacy Statement</span>
                </a>
              </li>
            </ul>
          </section>

          <section>
            <h2>Digital Collections</h2>
            <ul>
              <li>
                <a href="https://quod.lib.umich.edu/">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" focusable="false" role="img">
                    <path d="M3 13h8V3H3v10zm0 8h8v-6H3v6zm10 0h8V11h-8v10zm0-18v6h8V3h-8z" />
                  </svg>
                  <span>Browse all digital collections</span>
                </a>
              </li>
              <li>
                <a href="https://www.lib.umich.edu/collections/digital-collections">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" focusable="false" role="img">
                    <path d="M12 2C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm1 15h-2v-6h2v6zm0-8h-2V7h2v2z" />
                  </svg>
                  <span>About these digital collections</span>
                </a>
              </li>
              <li>
                <a href="https://www.lib.umich.edu/about-us/our-divisions-and-departments/library-information-technology/digital-content-and">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" focusable="false" role="img">
                    <path d="M20 0H4v2h16V0zM4 24h16v-2H4v2zM20 4H4c-1.1 0-2 .9-2 2v12c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm-8 2.75c1.24 0 2.25 1.01 2.25 2.25s-1.01 2.25-2.25 2.25S9.75 10.24 9.75 9 10.76 6.75 12 6.75zM17 17H7v-1.5c0-1.67 3.33-2.5 5-2.5s5 .83 5 2.5V17z" />
                  </svg>
                  <span>About Digital Content and Collections</span>
                </a>
              </li>
              <li>
                <a href="{//qui:footer/qui:link[@rel='help']/@href}">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" focusable="false" role="img">
                    <path d="M0 0h24v24H0z" fill="none" />
                    <path d="M11 18h2v-2h-2v2zm1-16C6.48 2 2 6.48 2 12s4.48 10 10 10 10-4.48 10-10S17.52 2 12 2zm0 18c-4.41 0-8-3.59-8-8s3.59-8 8-8 8 3.59 8 8-3.59 8-8 8zm0-14c-2.21 0-4 1.79-4 4h2c0-1.1.9-2 2-2s2 .9 2 2c0 2-3 1.75-3 5h2c0-2.25 3-2.5 3-5 0-2.21-1.79-4-4-4z" />
                  </svg>

                  <span>How to use this site</span>
                </a>
              </li>
            </ul>
          </section>

          <section class="[ footer__policies ]">
            <h2>Policies and Copyright</h2>
            <p>
              Copyright permissions may be different for each digital
              collection. Please check the
              <a href="#rights-statement">Rights and Permissions</a>
              section on a specific
              collection for information.
            </p>
            <p>
              <a href="https://www.lib.umich.edu/about-us/policies/takedown-policy-sensitive-information-u-m-digital-collections">Takedown Policy for Sensitive Information in U-M Digital
                Collections</a>
            </p>
          </section>
          <section style="display: none">
            <h2>Contact Us</h2>
            <ul>
              <li>
                <a href="/cgi/f/feedback?collid={//qui:root/@collid}&amp;to=tech">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" focusable="false" role="img">
                    <path d="M22.7 19l-9.1-9.1c.9-2.3.4-5-1.5-6.9-2-2-5-2.4-7.4-1.3L9 6 6 9 1.6 4.7C.4 7.1.9 10.1 2.9 12.1c1.9 1.9 4.6 2.4 6.9 1.5l9.1 9.1c.4.4 1 .4 1.4 0l2.3-2.3c.5-.4.5-1.1.1-1.4z" />
                  </svg>
                  <span>Report problems using this collection</span>
                </a>
              </li>
              <li>
                <a href="/cgi/f/feedback?collid={//qui:root/@collid}&amp;to=content">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" focusable="false" role="img">
                    <path d="M19 2H5c-1.11 0-2 .9-2 2v14c0 1.1.89 2 2 2h4l3 3 3-3h4c1.1 0 2-.9 2-2V4c0-1.1-.9-2-2-2zm-6 16h-2v-2h2v2zm2.07-7.75l-.9.92C13.45 11.9 13 12.5 13 14h-2v-.5c0-1.1.45-2.1 1.17-2.83l1.24-1.26c.37-.36.59-.86.59-1.41 0-1.1-.9-2-2-2s-2 .9-2 2H8c0-2.21 1.79-4 4-4s4 1.79 4 4c0 .88-.36 1.68-.93 2.25z" />
                  </svg>
                  <span>Ask about this content</span>
                </a>
              </li>
              <li>
                <a href="/cgi/f/feedback?collid={//qui:root/@collid}&amp;to=dcc">
                  <svg xmlns="http://www.w3.org/2000/svg" width="16" height="16" viewBox="0 0 24 24" fill="currentColor" aria-hidden="true" focusable="false" role="img">
                    <path d="M20 4H4c-1.1 0-1.99.9-1.99 2L2 18c0 1.1.9 2 2 2h16c1.1 0 2-.9 2-2V6c0-1.1-.9-2-2-2zm0 4l-8 5-8-5V6l8 5 8-5v2z" />
                  </svg>
                  <span>Ask about our digital collections</span>
                </a>
              </li>
            </ul>
          </section>

        </div>
      </div>
      <div class="[ footer__disclaimer ]">
        <div class="viewport-container">
          <p>
            ©
            <xsl:value-of select="date:year()" />
            , Regents of the University of Michigan
          </p>
          <p>
            Built with the
            <a href="https://design-system.lib.umich.edu/">U-M Library Design System</a>
          </p>
        </div>
      </div>
    </footer>
  </xsl:template>

</xsl:stylesheet>
