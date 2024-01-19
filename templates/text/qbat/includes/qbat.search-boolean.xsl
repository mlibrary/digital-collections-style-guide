<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">
  <xsl:template name="build-boolean-form">
    <div class="advanced-search--containers">
      <div class="field-groups">
        <xsl:apply-templates select="$search-form/qui:fieldset[@slot='clause'][@type='boolean']" />
      </div>
    </div>
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='clause'][@type='boolean']">
    <fieldset class="[ no-border ][ fieldset--grid ]">
      <legend class="visually-hidden">Search Terms</legend>
      <div class="[ fieldset--clause--region flex flex-flow-row flex-align-center ]" style="grid-column: 1/3;">
        <xsl:apply-templates select="qui:select[@slot='region']" />
      </div>
      <div class="[ fieldset--clause--query flex flex-flow-row flex-align-top gap-1 ]">
        <p>Find:</p>
        <div>
          <div class="[ flex flex-gap-1 flex-align-center ][ parenthetical-expression ]">
            <xsl:apply-templates select="qui:input[@name='q1']" />
            <xsl:apply-templates select="qui:select[@name='op2']" />
            <xsl:apply-templates select="qui:input[@name='q2']" />
            <xsl:apply-templates select="qui:select[@name='amt2']" />
          </div>
          <div class="[ flex flex-gap-1 mt-1 flex-align-center ]">
            <xsl:apply-templates select="qui:select[@name='op3']" />
            <xsl:apply-templates select="qui:input[@name='q3']" />
            <xsl:apply-templates select="qui:select[@name='amt3']" />
          </div>  
        </div>
      </div>
      <xsl:if test="false() and @data-name != 'q1'">
        <button type="button" class="[ button button--secondary ]" data-action="reset-clause">Clear</button>
      </xsl:if>
    </fieldset>
  </xsl:template>

  <xsl:template match="qui:select[@slot='region']">
    <label class="nowrap" for="{@name}-{position()}">Search in field:</label>
    <xsl:apply-templates select="." mode="build-select" />
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='clause'][@type='boolean']" mode="v1">
    <fieldset class="[ no-border ][ fieldset--grid ]">
      <legend class="visually-hidden">Search Terms</legend>
      <div class="[ fieldset--clause--region ]">
        <xsl:apply-templates select="qui:select[@slot='region']" />
      </div>
      <div class="[ fieldset--clause--select flex flex-align-center ]">
        <!-- <xsl:apply-templates select="qui:select[@slot='select']" /> -->
        <span style="padding: 0rem 1rem; font-weight: bold;">matches the expression</span>
      </div>
      <div class="[ fieldset--clause--query ]">
        <div class="[ flex flex-gap-1 flex-align-center ][ parenthetical-expression ]">
          <xsl:apply-templates select="qui:input[@name='q1']" />
          <xsl:apply-templates select="qui:select[@name='op2']" />
          <xsl:apply-templates select="qui:input[@name='q2']" />
          <xsl:apply-templates select="qui:select[@name='amt2']" />
        </div>
        <div class="[ flex flex-gap-1 mt-1 flex-align-center ]">
          <xsl:apply-templates select="qui:select[@name='op3']" />
          <xsl:apply-templates select="qui:input[@name='q3']" />
          <xsl:apply-templates select="qui:select[@name='amt3']" />
        </div>
      </div>
      <xsl:if test="false() and @data-name != 'q1'">
        <button type="button" class="[ button button--secondary ]" data-action="reset-clause">Clear</button>
      </xsl:if>
    </fieldset>
  </xsl:template>

</xsl:stylesheet>