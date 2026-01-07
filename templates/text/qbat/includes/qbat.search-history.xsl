<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <!-- <xsl:template name="build-extra-styles">
    <xsl:comment>DUBIOUS EXCEPTIONS</xsl:comment>
    <link rel="stylesheet" href="{$docroot}styles/text/index.css" />
    <link rel="stylesheet" href="{$docroot}styles/text/tabs.css" />
    <link rel="stylesheet" href="{$docroot}styles/text/reslist.css" />

    <style>
    </style>
  </xsl:template> -->

  <xsl:template name="build-search-history">
    <div class="[ mb-2 ]">
      <xsl:call-template name="build-breadcrumbs" />
      <xsl:call-template name="build-collection-heading" />

      <xsl:call-template name="build-advanced-search-form-tabs" />
    </div>
    <div class="[ flex flex-flow-rw ][ flex-gap-1 ]">
      <div class="side-panel"></div>
      <div class="main-panel" id="search-history">
        <!-- <xsl:choose>
          <xsl:when test="not(//qui:block[@slot='history']/qui:section)">
            <div class="message-callout">
              <p>You have no search history.</p>
            </div>
          </xsl:when>
          <xsl:otherwise>
            <xsl:apply-templates select="//qui:block[@slot='history']/qui:section" mode="result" />
          </xsl:otherwise>
        </xsl:choose> -->
      </div>  
    </div>
  </xsl:template>

  <xsl:template match="qui:section" mode="result">
    <section class="[ results-list--small ]">
      <div class="results-card">
        <div class="[ results-list__blank ]" aria-hidden="true" data-type="history">
        </div>
        <div class="results-list__content flex flex-flow-column flex-grow-1">
          <h3>
            <a class="results-link" href="{qui:link/@href}">
              <xsl:value-of select="qui:title" />
            </a>
          </h3>
          <dl class="[ results ]">
            <div>
              <dt>Collections</dt>
              <dd>
                <xsl:value-of select=".//qui:field[@key='collections']/qui:values" />
              </dd>
            </div>
            <div>
              <dt>Total Results</dt>
              <dd>
                <xsl:value-of select=".//qui:field[@key='results']/qui:values" />
              </dd>
            </div>
          </dl>
        </div>
      </div>
    </section>
  </xsl:template>

  <xsl:template match="qui:table">
    <table class="responsive-table">
      <xsl:apply-templates />
    </table>
  </xsl:template>

  <xsl:template match="qui:th">
    <th><xsl:apply-templates /></th>
  </xsl:template>

  <xsl:template match="qui:tr">
    <tr><xsl:apply-templates /></tr>
  </xsl:template>

  <xsl:template match="qui:td">
    <td><xsl:apply-templates /></td>
  </xsl:template>

  <xsl:template match="qui:thead">
    <thead><xsl:apply-templates /></thead>
  </xsl:template>

  <xsl:template match="qui:tbody">
    <tbody><xsl:apply-templates /></tbody>
  </xsl:template>

</xsl:stylesheet>