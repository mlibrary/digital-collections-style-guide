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
    <xsl:apply-templates select="qui:block[@slot='blurb']" />
    <xsl:call-template name="build-select-options" />
    <xsl:call-template name="build-new-portfolio-form" />
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

  <xsl:template name="build-new-portfolio-form">
    <div class="form modal--page">
      <h2 class="section-heading">New Portfolio</h2>
      <form action="add">
        <div class="[ flex flex-flow-column ]">
          <label for="bbnn">Name</label>
          <input required="required" type="text" placeholder="New portfolio name" name="bbnn" id="bbnn" />
        </div>
        <xsl:if test="normalize-space($username)">
          <div class="[ flex flex-flow-column ]">
            <label for="bbusername">Add Owners</label>
            <textarea name="bbusername" id="bbusername" rows=" 5">
              <xsl:value-of select="$username" />
            </textarea>
            <p class="[ help ]">
            Separate values with a comma or a line break.
          </p>
          </div>
        </xsl:if>
        <xsl:choose>
          <xsl:when test="normalize-space($username)">
            <div class="[ flex flex-flow-row ]">
              <input id="bbsh" type="checkbox" name="bbsh" value="1" />
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

  <xsl:template name="build-select-options">
    <div class="[ list--select modal--page ]">
      <table aira-labelledby="list--items">
        <caption id="list--items">
          <p>Select from your list, or create a new portfolio.</p>
        </caption>
        <thead>
          <tr>
            <th><span class="visually-hidden">Select</span></th>
            <th>Title</th>
            <th style="white-space: nowrap">
              <span class="visually-hidden">Number of Items</span>
              <span aria-hidden="true">#</span>
            </th>
            <th>Owners</th>
            <th>Modified</th>
            <th>Status</th>
          </tr>
        </thead>
        <tbody>
          <tr>
            <td>
              <input name="bbid" type="radio" value="__NEW__" id="bbid-NEW" checked="checked" />
            </td>
            <td colspan="5">
              <label for="bbid-NEW" style="font-weight: bold">
                New Portfolio
              </label>
            </td>
          </tr>
          <xsl:for-each select="//qui:select[@name='bbid']/qui:option">
            <tr>
              <td>
                <input name="bbid" type="radio" value="{@value}" id="bbid-{@value}" />
              </td>
              <td>
                <label for="bbid-{@value}">
                  <xsl:value-of select="qui:field[@key='bbagname']//qui:value" />
                </label>
              </td>
              <td>
                <xsl:value-of select="qui:field[@key='itemcount']//qui:value" />
              </td>
              <td>
                <ul class="list--username">
                  <xsl:for-each select="qui:field[@key='username']//qui:value">
                    <li>
                      <xsl:value-of select="." />
                    </li>
                  </xsl:for-each>
                </ul>
              </td>
              <td>
                <xsl:value-of select="qui:field[@key='modified_display']//qui:value" />
              </td>
              <td>
                Private
              </td>
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </div>
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

  <xsl:template name="build-hidden-form">
    <form style="display: none" method="POST" action="/cgi/i/image/image-idx" id="bbaction-form">
      <xsl:apply-templates select="//qui:form[@action='bbaction']/qui:hidden-input" />
    </form>
  </xsl:template>

  <xsl:template name="build-extra-styles">
    <link rel="stylesheet" href="{$docroot}styles/modals.css" />
    <script src="{$docroot}js/image/bbname.js"></script>
  </xsl:template>

</xsl:stylesheet>