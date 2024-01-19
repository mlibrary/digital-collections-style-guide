<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template name="build-filters-panel">
    <xsl:param name="margin-top">mt-2</xsl:param>

    <xsl:variable name="filters" select="//qui:filters-panel" />

    <xsl:variable name="selected-filters" select="$filters//qui:filter[not(@arity)]//qui:value[@selected='true']" />
    <xsl:if test="$search-form/@data-has-query = 'true'">
      <section class="[ filters__selected ]">
        <xsl:if test="$selected-filters">
          <h3 class="[ mt-2 ]">Current Filters</h3>
          <xsl:for-each select="$selected-filters">
            <xsl:variable name="filter" select="ancestor-or-self::qui:filter" />
            <xsl:variable name="key" select="$filter/@key" />
            <div class="[ flex filter-item ][ gap-0_5 ]">
              <input type="checkbox" id="x-{$key}-{position()}" name="{$key}" value="{.}" data-action="facet" data-num="{@num}" autocomplete="off" checked="checked">
                <xsl:apply-templates select="$filter/@data-type" mode="copy" />
                <xsl:apply-templates select="$filter/@data-key" mode="copy" />
              </input>
              <label for="x-{$key}-{position()}">
                <xsl:choose>
                  <xsl:when test="$filter/@arity = '1'">
                    <span>
                      <xsl:value-of select="$filter/qui:label" />
                    </span>
                  </xsl:when>
                  <xsl:otherwise>
                    <span class="separator">
                      <xsl:value-of select="$filter/qui:label" />
                    </span>
                    <span>
                      <xsl:value-of select="." />
                    </span>
                  </xsl:otherwise>
                </xsl:choose>
              </label>
            </div>
          </xsl:for-each>
        </xsl:if>

        <!-- <a>
          <xsl:if test="not($selected-filters)">
            <xsl:attribute name="class">mt-2 block</xsl:attribute>
          </xsl:if>
          <xsl:attribute name="href">
            <xsl:value-of select="//qui:link[@rel='restart']/@href" />
          </xsl:attribute>
          <xsl:text>Clear Search</xsl:text>
        </a> -->
        <button data-action="go" data-href="{//qui:link[@rel='restart']/@href}">
          <xsl:attribute name="class">
            <xsl:text>[ button button--secondary flex ][ flex-center ]</xsl:text>
            <xsl:if test="not($selected-filters)">
              <xsl:text>[ mt-2 block ]</xsl:text>
            </xsl:if>
          </xsl:attribute>
          <span class="material-icons" aria-hidden="true">clear</span>
          <xsl:text>Clear Search</xsl:text>
        </button>
      </section>
    </xsl:if>

    <xsl:if test="$filters//qui:filter or $filters//qui:callout">
      <h3>
        <xsl:attribute name="class"><xsl:value-of select="$margin-top" /></xsl:attribute>
        <xsl:text>Filters</xsl:text>
      </h3>
      <div class="[ side-panel__box ]">
        <xsl:apply-templates select="$filters/@*[starts-with(name(), 'data-')]" mode="copy" />
        <xsl:for-each select="$filters//qui:filter">
          <xsl:choose>
            <xsl:when test="@arity = 1">
              <xsl:call-template name="build-single-filter-option" />
            </xsl:when>
            <xsl:otherwise>
              <xsl:if test="qui:values/qui:value[not(@selected)]">
                <xsl:call-template name="build-filter-panel" />
              </xsl:if>
            </xsl:otherwise>
          </xsl:choose>
        </xsl:for-each>
        <xsl:apply-templates select="$filters/qui:callout" />
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-single-filter-option">
    <xsl:variable name="key" select="@key" />
    <xsl:variable name="value" select="qui:values/qui:value" />
    <xsl:if test="true() or not($value/@selected = 'true')">
      <div class="panel" style="padding: 1rem 0">
        <div class="[ flex flex-align-center ][ gap-0_5 ]">
          <input type="checkbox" id="{ $key }-1" name="{$key}" data-key="{$key}" value="{ normalize-space($value) }" data-action="facet" autocomplete="off" style="margin-top: 4px">
            <xsl:if test="$value/@selected = 'true'">
              <xsl:attribute name="checked">checked</xsl:attribute>
            </xsl:if>
            <xsl:apply-templates select="@data-type" mode="copy" />
          </input>
          <label for="{ $key }-1">
            <xsl:value-of select="qui:label" />
          </label>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

  <xsl:template name="build-filter-panel">
    <xsl:variable name="key" select="@key" />
    <xsl:variable name="total" select="@data-total" />
    <xsl:variable name="open">
      <xsl:choose>
        <xsl:when test="qui:values/qui:value[@selected='true']">true</xsl:when>
        <xsl:when test="count(//qui:filter[@data-total]) = 1">true</xsl:when>
        <xsl:when test="$view = 'index' and position() &gt; 2">false</xsl:when>
        <xsl:otherwise>true</xsl:otherwise>
      </xsl:choose>
    </xsl:variable>
    <details class="panel" data-list-expanded="false" data-key="{@key}" data-position="{position()}">
      <xsl:if test="$open = 'true'">
        <xsl:attribute name="open">open</xsl:attribute>
      </xsl:if>
      <summary>
        <xsl:value-of select="qui:label" />
      </summary>
      <div class="filter-item--list">
        <xsl:call-template name="build-filter-item--value-list">
          <xsl:with-param name="key" select="$key" />
        </xsl:call-template>
      </div>
      <xsl:if test="$total &gt; 10">
        <p>
          <button class="[ button filter__button ]" data-action="expand-filter-list">
            <span data-expanded="true">
              <xsl:text>Show fewer </xsl:text>
            </span>
            <span data-expanded="false">
              <xsl:text>Show all </xsl:text>
              <xsl:value-of select="$total" />
              <xsl:text></xsl:text>
            </span>
            <xsl:text> </xsl:text>
            <xsl:value-of select="qui:label" />
            <xsl:text> filters</xsl:text>
          </button>
        </p>
      </xsl:if>
    </details>
  </xsl:template>

  <xsl:template name="build-filter-item--value-list">
    <xsl:param name="key" />
    <xsl:for-each select="qui:values/qui:value[not(@selected)]">
      <xsl:call-template name="build-filter-item--value">
        <xsl:with-param name="key" select="$key" />
      </xsl:call-template>
    </xsl:for-each>
  </xsl:template>

  <xsl:template name="build-filter-item--value">
    <xsl:param name="key" />
    <div class="[ flex filter-item ][ gap-0_5 ]">
      <xsl:apply-templates select="@data-expandable-filter" mode="copy" />
      <input type="checkbox" id="{ $key }-{ position() }" name="{$key}" value="{ . }" data-action="facet" autocomplete="off" style="margin-top: 4px">
        <xsl:if test="@selected = 'true'">
          <xsl:attribute name="checked">checked</xsl:attribute>
        </xsl:if>
      </input>
      <label for="{ $key }-{ position() }">
        <xsl:value-of select="." />
        <xsl:text></xsl:text>
        <span class="filters__count">
          <xsl:text> (</xsl:text>
          <xsl:value-of select="@count" />
          <xsl:text>)</xsl:text>
        </span>
      </label>
    </div>
  </xsl:template>

  <xsl:template match="qui:callout[@variant='warning']" priority="100">
    <m-callout subtle="subtle" icon="warning" variant="{@variant}" style="margin-top: 1rem; margin-bottom: 0">
      <xsl:apply-templates mode="copy" />
    </m-callout>
  </xsl:template>


</xsl:stylesheet>