<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">
  <xsl:template name="build-ww-form">
    <div class="[ mb-2 ]">
      <xsl:call-template name="build-breadcrumbs" />
      <xsl:call-template name="build-collection-heading" />

      <xsl:if test="//qui:nav[@role='search']">
        <nav aria-label="Search Options" class="horizontal-navigation-container mb-2">
          <ul class="horizontal-navigation-list">
            <xsl:for-each select="//qui:nav[@role='search']/qui:link">
              <li>
                <a href="{@href}">
                  <xsl:if test="@current = 'true'">
                    <xsl:attribute name="aria-current">page</xsl:attribute>
                  </xsl:if>
                  <xsl:value-of select="qui:label" />
                </a>
              </li>
            </xsl:for-each>
          </ul>
        </nav>
      </xsl:if>
    </div>
    <div class="advanced-search--form">
      <xsl:apply-templates select="//qui:form[@id='ww-selection']" />
      <xsl:apply-templates select="//qui:form[@id='ww-search']" />
      
      <h2 class="subtle-heading">Quick Word Index</h2>
      <div class="advanced-search--containers">
        <div class="field-groups">
          <div class="message-callout info mb-0" style="background: white">
            <xsl:apply-templates select="//qui:block[@slot='quickindex-help']" />
          </div>
          <xsl:apply-templates select="//qui:nav[@slot='quickindex']" />
        </div>
      </div>

    </div>
  </xsl:template>

  <xsl:template match="qui:nav[@slot='quickindex']">
    <nav>
      <ul class="[ flex flex-gap-0_5 flex-flow-rw ]" style="justify-content: start;">
        <xsl:for-each select="qui:link">
          <li>
            <!-- <xsl:apply-templates select="." /> -->
            <a class="button button--secondary" href="{@href}">
              <xsl:value-of select="." />
            </a>
          </li>
        </xsl:for-each>
      </ul>
    </nav>
  </xsl:template>

  <xsl:template match="qui:form">
    <xsl:apply-templates select="." mode="header" />
    <div class="advanced-search--containers">
      <div class="field-groups">
        <form method="GET" action="/cgi/t/text/ww2-idx">
          <xsl:apply-templates select="qui:hidden-input" />
          <xsl:apply-templates select="qui:fieldset" />
          <xsl:apply-templates select="." mode="button" />
        </form>
      </div>
    </div>
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='ww-selection']">
    <fieldset class="[ no-border ]">
      <legend class="visually-hidden">Select Terms</legend>
      <div class="message-callout info" style="background: white">
        <div>
          <xsl:apply-templates select="//qui:block[@slot='selection-help']" />
        </div>
      </div>
      <div class="[ flex flex-align-center flex-gap-0_5 ]">
        <button class="button button--ghost button--small" name="up.x" value="1" type="submit">
          <span class="material-icons" aria-hidden="true">chevron_left</span>
          <span>Previous Page</span>          
        </button>
        <button class="button button--ghost button--small" name="down.x" value="1" type="submit">
          <span>Next Page</span>          
          <span class="material-icons" aria-hidden="true">chevron_right</span>
        </button>
      </div>
      <table class="table ww-terms">
        <thead>
          <tr>
            <th scope="col">Term</th>
            <th scope="col">Occurrences</th>
          </tr>
        </thead>
        <tbody>
          <xsl:for-each select="qui:table/qui:tbody/qui:tr">
            <tr class="{@class}">
              <xsl:apply-templates select="qui:td" />
            </tr>
          </xsl:for-each>
        </tbody>
      </table>
    </fieldset>
  </xsl:template>

  <xsl:template match="qui:td">
    <td><xsl:apply-templates/></td>
  </xsl:template>

  <xsl:template match="qui:input[@type='checkbox']">
    <label class="flex flex-align-center flex-gap-0_5">
      <input type="checkbox" value="{@value}" name="q1">
        <xsl:if test="@checked = 'checked'">
          <xsl:attribute name="checked">checked</xsl:attribute>
        </xsl:if>
      </input>
      <span><xsl:value-of select="@label" /></span>
    </label>
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='ww-form']">
    <fieldset class="[ no-border ]">
      <legend><xsl:value-of select="qui:legend" /></legend>
      <div class="message-callout info" style="background: white">
        <xsl:apply-templates select="qui:block[@slot='help']" />
      </div>
      <div class="[ flex flex-align-center flex-gap-0_5 ]">
        <label for="q1">
          <xsl:value-of select="qui:input/@label" />
        </label>
        <input type="text" name="q1" id="q1" value="" />
      </div>
    </fieldset>    
  </xsl:template>

  <xsl:template match="qui:form[@id='ww-search']" mode="header" priority="100">
    <h2 class="subtle-heading">Search Word Index</h2>
  </xsl:template>

  <xsl:template match="qui:form[@id='ww-selection']" mode="header" priority="100">
    <h2 class="subtle-heading">Browse Word Index</h2>
  </xsl:template>

  <xsl:template match="qui:form[@id='ww-search']" mode="button" priority="100">
    <div style="padding: 0.5rem 1rem">
      <button class="button button--primary" value="Show Word Index">Show Word Index</button>
    </div>
  </xsl:template>

  <xsl:template match="qui:form[@id='ww-selection']" mode="button" priority="100">
    <div style="padding: 0.5rem 1rem">
      <button class="button button--primary" name="simplesearch" value="Search for selected terms">Search for Selected Items</button>
    </div>
  </xsl:template>

</xsl:stylesheet>