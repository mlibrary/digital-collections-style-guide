<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template name="build-extra-styles">
    <style>
      main {
        min-height: 25vh;
      }
    </style>
  </xsl:template>

  <xsl:template match="qui:root" mode="modal">
    <html lang="en" data-root="{$docroot}" data-username="{$username}">
      <xsl:apply-templates select="qui:head" />
      <body class="[ font-base-family ]">

        <main data-page="list">
          <div class="modal--overlay">
          </div>
          <div class="modal">
            <xsl:apply-templates select="//qui:main" />
          </div>
        </main>
      </body>
    </html>
  </xsl:template>

  <xsl:template name="build-cqfill-script"></xsl:template>

  <xsl:template match="qui:main">

    <div class="[ mb-2 ]">
      <xsl:call-template name="build-collection-heading">
        <xsl:with-param name="badge">
          <xsl:value-of select="@data-badge" />
        </xsl:with-param>
      </xsl:call-template>
    </div>

    <div class="[ flex flex-flow-row flex-gap-1 ]">
      <div class="main-panel full">
        <div class="text-block">
          <div class="alert-info">
            <xsl:apply-templates select="//qui:block[@slot='access-information']" />
            <xsl:apply-templates select="//qui:block[@slot='login-information']" mode="copy-guts" />
          </div>
        </div>
      </div>
    </div>

  </xsl:template>


  <!-- modal -->

  <xsl:template match="qui:main" mode="modal">
    <xsl:apply-templates select="qui:header[@role='main']" />
    <xsl:apply-templates select="qui:block[@slot='access-information']" />
    <xsl:apply-templates select="qui:block[@slot='login-information']" mode="copy-guts" />
    <xsl:call-template name="build-modal-controls" />
  </xsl:template>

  <xsl:template match="qui:header[@role='main']">
    <div class="[ modal--header ][ flex flex-flow-row ][ flex-space-between flex-gap-1 ]">
      <h1 class="collection-heading--small">
        <xsl:apply-templates />
      </h1>
      <!-- <xsl:call-template name="build-modal-dismiss-action" /> -->
    </div>
  </xsl:template>

  <xsl:template match="qui:block[@slot='access-information']">
    <xsl:apply-templates mode="copy" />
  </xsl:template>

  <xsl:template name="build-modal-dismiss-action">
    <button class="button--dismiss" data-action="cancel">
      <span class="material-icons" aria-hidden="true">close</span>
      <span class="visually-hidden"> Close Modal</span>
    </button>
  </xsl:template>

  <xsl:template name="build-modal-controls">
    <div class="modal--footer">
      <xsl:if test="//qui:block[@slot='login-information']">
        <a class="button button--ghost no-underline" href="/cgi/i/image/image-idx?page=feedback&amp;to=content">Inquire about access</a>
      </xsl:if>
      <a class="button button--primary no-underline" href="/cgi/i/image/image-idx">Go to Digital Collections</a>
    </div>
  </xsl:template>

  <xsl:template name="build-extra-styles-modal">
    <link rel="stylesheet" href="{$docroot}styles/modals.css" />
  </xsl:template>

  <xsl:template name="get-feedback-href">
    <xsl:text>/cgi/i/image/image-idx?page=feedback</xsl:text>
  </xsl:template>

</xsl:stylesheet>