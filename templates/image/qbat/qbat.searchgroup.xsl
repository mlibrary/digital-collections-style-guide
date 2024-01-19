<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:variable name="search-form" select="//qui:form[@id='collection-search']" />

  <xsl:template name="build-search-form">
    <form id="collection-search" action="/cgi/i/image/image-idx" method="GET" autocomplete="off">
      <xsl:call-template name="build-collection-selection" />

      <h2 class="subtle-heading">Fielded Search Options</h2>
      <div class="message-callout info">
        <p>
          <xsl:apply-templates select="//qui:callout[@slot='clause']" mode="copy-guts" />
        </p>
      </div>

      <div class="advanced-search--containers">
        <div class="field-groups">
          <xsl:apply-templates select="$search-form/qui:fieldset[@slot='clause']" />
        </div>
      </div>

      <xsl:apply-templates select="$search-form/qui:fieldset[@slot='limits']" />

      <xsl:apply-templates select="$search-form/qui:hidden-input" />

      <input type="hidden" name="view" value="reslist" />
      <input type="hidden" name="type" value="boolean" />

      <xsl:call-template name="build-form-actions" />

    </form>
  </xsl:template>

  <xsl:template name="build-collection-selection">
    <h2 class="subtle-heading">Filter by Collection Options</h2>
    <div class="message-callout info">
      <p>
        <xsl:apply-templates select="//qui:callout[@slot='collids']" mode="copy-guts" />
      </p>
    </div>
    <div class="advanced-search--containers">
      <details class="panel">
        <summary class="summary--neutral">
          <span>
            <xsl:text>Select collections from the </xsl:text>
            <em>
              <xsl:value-of select="//qui:header[@role='group']" />
            </em>
            <xsl:text> group</xsl:text>
          </span>
        </summary>
        <div>
          <p style="font-size: 0.875rem">
            Select one or more collections to search.
            Follow the collection link <span class="material-icons" aria-hidden="true" style="vertical-align: bottom">link</span> to search that 
            just that collection.
          </p>
          <div class="[ flex ][ flex-gap-0_5 ]">
            <button class="button button--small button--secondary" data-action="select-all-collid">Select All</button>
            <button class="button button--small button--secondary" data-action="clear-all-collid">Clear All</button>
          </div>
          <ul>
            <xsl:for-each select="//qui:fieldset[@slot='collids']/qui:option">
              <xsl:if test="normalize-space(.)">
                <xsl:apply-templates select=".">
                  <xsl:with-param name="idx" select="position()" />
                </xsl:apply-templates>
              </xsl:if>
            </xsl:for-each>
          </ul>
          <xsl:apply-templates select="//qui:fieldset[@slot='collids']/qui:option[@type='hidden']" mode="hidden" />
        </div>
      </details>
    </div>

  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='collids']/qui:option[@type='hidden']" mode="hidden">
    <input type="hidden" name="c" value="{@collid}" />
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='collids']/qui:option[@type='hidden']" priority="100" />

  <xsl:template match="qui:fieldset[@slot='collids']/qui:option">
    <xsl:param name="idx" select="position()" />
    <li>
      <div class="[ flex ][ flex-gap-0_5 ]" style="align-items: center; padding: 0.25rem; border: 1px solid var(--color-blue-200); margin-bottom: 0.5rem">
        <input type="checkbox" name="c" value="{@value}" id="c-{$idx}">
          <xsl:if test="@checked='checked'">
            <xsl:attribute name="checked">checked</xsl:attribute>
          </xsl:if>
        </input>
        <label for="c-{$idx}" style="display: flex; gap: 0.25rem; flex-grow: 1; justify-content: space-between; align-items: center">
          <xsl:value-of select="." />
          <a href="{@data-href}" style="display: block; color: var(--color-teal-500)">
            <span class="visually-hidden">Open the <xsl:value-of select="." /> Collection</span>
            <span class="material-icons" aria-hidden="true" style="font-size: 2.5rem">link</span>
          </a>
        </label>
      </div>
    </li>
  </xsl:template>

</xsl:stylesheet>