<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template match="qui:root">
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
    <xsl:apply-templates select="qui:header[@role='main']" />
    <xsl:apply-templates select="qui:block[@slot='closed-for-business']" />
  </xsl:template>

  <xsl:template match="qui:header[@role='main']">
    <div class="[ modal--header ][ flex flex-flow-row ][ flex-space-between flex-gap-1 ]">
      <h1 class="collection-heading--small">
        <xsl:apply-templates />
      </h1>
      <!-- <xsl:call-template name="build-modal-dismiss-action" /> -->
    </div>
  </xsl:template>

  <xsl:template match="qui:head/qui:link[@rel='redirect']">
    <xsl:if test="@auto-redirect = 'true'">
      <meta http-equiv="refresh" content="5;URL='{@href}'" />
    </xsl:if>
  </xsl:template>

  <xsl:template match="qui:block[@slot='closed-for-business']">
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
      <button class="[ button button--large button--secondary button--flex ][ align-left ]" data-action="back">
        <span aria-hidden="true" class="material-icons">arrow_back</span>
        <span>Back</span>
        <span class="[ hidden-for-narrow ]"> to list</span>
      </button>
      <button class="button button--large button--secondary" data-action="cancel">Cancel</button>
      <button class="button button--large button--primary" data-action="add">Add</button>
    </div>
  </xsl:template>

  <xsl:template name="build-extra-styles">
    <link rel="stylesheet" href="{$docroot}styles/modals.css" />
  </xsl:template>

</xsl:stylesheet>