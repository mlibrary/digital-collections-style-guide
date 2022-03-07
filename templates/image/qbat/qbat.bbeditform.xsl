<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template match="qui:root">
    <html lang="en" data-root="{$docroot}" data-username="{$username}">
      <xsl:apply-templates select="qui:head" />
      <body class="[ font-base-family ]">

        <main data-page="form">
          <div class="modal--overlay"></div>
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
    <xsl:apply-templates select="qui:block[@slot='blurb']" />
    <xsl:call-template name="build-edit-portfolio-form" />
    <xsl:call-template name="build-modal-controls" />
    <xsl:call-template name="build-hidden-form" />
  </xsl:template>

  <xsl:template match="qui:header[@role='main']">
    <div class="[ modal--header ][ flex flex-flow-row ][ flex-space-between flex-gap-1 ]">
      <h1 class="collection-heading--small">
        <xsl:apply-templates />
      </h1>
      <xsl:call-template name="build-modal-dismiss-action" />
    </div>
  </xsl:template>

  <xsl:template match="qui:block[@slot='blurb']">
    <blockquote>
      <xsl:apply-templates mode="copy" />
    </blockquote>
  </xsl:template>

  <xsl:template name="build-modal-dismiss-action">
    <button class="button--dismiss" data-action="cancel">
      <span class="material-icons" aria-hidden="true">close</span>
      <span class="visually-hidden"> Close Modal</span>
    </button>
  </xsl:template>

  <xsl:template name="build-edit-portfolio-form">
    <div class="form modal--page">
      <form action="update">
        <div class="[ flex flex-flow-column ]">
          <label for="bbnn">Name</label>
          <input required="required" type="text" name="bbnn" id="bbnn" value="{//qui:input[@name='bbnn']/@value}" />
        </div>
        <xsl:if test="normalize-space($username)">
          <xsl:variable name="username">
            <xsl:for-each select="//qui:textarea[@name='newowners']/qui:value">
              <xsl:value-of select="concat(., '&#xd;')" />
            </xsl:for-each>
          </xsl:variable>
          <div class="[ flex flex-flow-column ]">
            <label for="newowners">Manage Owners</label>
            <textarea name="newowners" id="newowners" rows="5"><xsl:value-of select="$username" /></textarea>
            <p class="[ help ]">
            Separate values with a comma or a line break.
          </p>
          </div>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="normalize-space($username)">
            <div class="[ flex flex-flow-row ]">
              <input type="hidden" name="status" value="{//qui:input[@name='status']/@value}" />
              <input id="bbsh" type="checkbox" name="newstatus" value="1" />
              <label for="bbsh">
                Publically Viewable
              </label>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <input type="hidden" name="bbsh" value="0" />
          </xsl:otherwise>
        </xsl:choose>
      </form>
    </div>
  </xsl:template>

  <xsl:template name="build-modal-controls">
    <div class="modal--footer">
      <button class="button button--large button--secondary" data-action="cancel">Cancel</button>
      <button class="button button--large button--primary" data-action="update">Save Changes</button>
    </div>
  </xsl:template>

  <xsl:template name="build-hidden-form">
    <form style="display: none" method="POST" action="/cgi/i/image/image-idx" id="bbaction-form">
      <xsl:apply-templates select="//qui:form[@action='bbaction']/qui:hidden-input" />
    </form>
  </xsl:template>

  <xsl:template name="build-extra-styles">
    <link rel="stylesheet" href="{$docroot}styles/modals.css" />
    <script src="{$docroot}dist/js/image/bbeditform.js"></script>
  </xsl:template>

</xsl:stylesheet>