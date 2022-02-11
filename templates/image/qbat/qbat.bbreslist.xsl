<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:dlxs="http://dlxs.org" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <link rel="stylesheet" href="{$docroot}styles/image/reslist.css" />
    <script src="{$docroot}js/image/base.js"></script>
    <script src="{$docroot}js/image/bbreslist.js"></script>
  </xsl:template>

  <xsl:template name="build-search-form" />

  <xsl:template name="build-filters-panel">
    <xsl:if test="//qui:link[@target='portfolio']">
      <xsl:if test="//qui:link[@target='portfolio'][@rel='bbeditform']">
        <h3 class="[ mt-2 ]">Portfolio Management</h3>
        <div class="[ side_panel__box ]">
            <div class="[ button_group ]">
              <xsl:call-template name="button">
                <xsl:with-param name="rel" select="'bbeditform'" />
              </xsl:call-template>
              <xsl:call-template name="button">
                <xsl:with-param name="rel" select="'bbdel'" />
              </xsl:call-template>
            </div>
          </div>
      </xsl:if>
      <h3 class="[ mt-2 ]">Portfolio Actions</h3>
      <div class="[ side_panel__box ]">
        <div class="[ button_group ]">
          <xsl:call-template name="button">
            <xsl:with-param name="rel" select="'bbexportprep'" />
          </xsl:call-template>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="button">
    <xsl:param name="rel" />
    <xsl:variable name="link" select="//qui:link[@target='portfolio'][@rel=$rel]" />
    <button class="[ button button--large button--secondary ]" data-action="{$rel}" data-href="{$link/@href}">
      <xsl:value-of select="$labels//dlxs:field[@key=$rel]" />
    </button>
  </xsl:template>

</xsl:stylesheet>