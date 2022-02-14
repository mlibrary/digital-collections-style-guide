<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <xsl:template name="build-search-form">
    <xsl:apply-templates select="//qui:form[@id='collection-search']" />
  </xsl:template>

  <xsl:template match="qui:form[@id='collection-search']">
    <xsl:variable name="form" select="." />
    <form id="collection-search" action="/cgi/i/image/image-idx" method="GET">
      <div class="search">
        <xsl:choose>
          <xsl:when test="$form/@data-advanced = 'true'">
            <xsl:call-template name="build-advanced-search-toolbar" />
          </xsl:when>
          <xsl:otherwise>
            <xsl:call-template name="build-basic-search-input" />
          </xsl:otherwise>
        </xsl:choose>
        <div class="advanced-link"><a href="/cgi/i/image/image-idx?c={$collid};page=search">Advanced Search</a></div>
      </div>
      <xsl:call-template name="build-search-hidden-fields">
        <xsl:with-param name="form" select="$form" />
      </xsl:call-template>
      <xsl:call-template name="build-search-additional-fields" />
    </form>
  </xsl:template>

  <xsl:template name="build-basic-search-input">
    <xsl:variable name="form" select="." />
    <fieldset class="[ search-container ][ input-group right ] [ no-border ]">
      <legend class="visually-hidden">Search</legend>

      <div class="[ flex ]">
        <label for="search-select" class="visually-hidden"
          >Select a search filter:</label
        >
        <select name="rgn1" id="search-select" class="[ dropdown dropdown--neutral select ] [ bold no-border ]">
          <xsl:for-each select="$form/qui:control/qui:input[@slot='rgn']/qui:option">
            <option value="{@value}">
              <xsl:if test="@selected = 'selected'">
                <xsl:attribute name="selected">selected</xsl:attribute>
              </xsl:if>
              <xsl:value-of select="." />
            </option>
          </xsl:for-each>
        </select>

        <label for="search-collection" class="visually-hidden">
          <span>Search</span>
        </label>

        <xsl:variable name="q1" select="$form/qui:control/qui:input[@name='q1']/@value" />
        <input
          id="search-collection"
          type="search"
          name="q1"
          placeholder=""
          data-value="{$q1}">
          <xsl:attribute name="value">
            <xsl:choose>
              <xsl:when test="$q1 = $collid">
                <xsl:text>*</xsl:text>
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="$q1" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </input>
        <div class="flex">
          <button
            class="[ button button--cta ]"
            type="submit"
            aria-label="Search"
          >
            <svg
              xmlns="http://www.w3.org/2000/svg"
              width="24px"
              height="24px"
              viewBox="0 0 24 24"
              aria-hidden="true"
              focusable="false"
              role="img"
            >
              <path
                d="M15.5 14h-.79l-.28-.27C15.41 12.59 16 11.11 16 9.5 16 5.91 13.09 3 9.5 3S3 5.91 3 9.5 5.91 16 9.5 16c1.61 0 3.09-.59 4.23-1.57l.27.28v.79l5 4.99L20.49 19l-4.99-5zm-6 0C7.01 14 5 11.99 5 9.5S7.01 5 9.5 5 14 7.01 14 9.5 11.99 14 9.5 14z"
              ></path>
            </svg>
          </button>
        </div>
      </div>
    </fieldset>
  </xsl:template>
  
  <xsl:template name="build-advanced-search-toolbar">
    <xsl:variable name="form" select="." />
    <div class="[ search-container search-results__edit ]">
      <a href="{@data-edit-action}">Edit Search</a>
    </div>
  </xsl:template>

  <xsl:template name="build-search-hidden-fields">
    <xsl:param name="form" />
    <xsl:if test="$form/@data-advanced='true'">
      <xsl:for-each select="$form/qui:control">
        <xsl:if test="normalize-space(qui:input[@slot='q']/@value)">
          <xsl:apply-templates select="qui:input" mode="hidden" />
        </xsl:if>
      </xsl:for-each>
      <input type="hidden" name="from" value="reslist" />
    </xsl:if>
    <xsl:apply-templates select="$form/qui:hidden-input" />
    <input type="hidden" name="type" value="boolean" />
    <input type="hidden" name="view" value="reslist" />
    <input type="hidden" name="c" value="{//qui:root/@collid}" />
  </xsl:template>

  <xsl:template name="build-search-additional-fields" />

  <xsl:template match="qui:input" mode="hidden">
    <input type="hidden" name="{@name}" value="{@value}" />
  </xsl:template>

</xsl:stylesheet>