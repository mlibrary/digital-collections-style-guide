<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <xsl:template name="build-proximity-form">
    <div class="advanced-search--containers">
      <div class="field-groups">
        <xsl:apply-templates select="$search-form/qui:fieldset[@slot='clause'][@type='proximity']" />
      </div>
    </div>
  </xsl:template>

  <xsl:template match="qui:fieldset[@slot='clause'][@type='proximity']">
    <fieldset class="[ no-border ][ fieldset--grid ]">
      <legend class="visually-hidden">Search Terms</legend>
      <div class="[ fieldset--clause--region flex flex-flow-row flex-align-center ]" style="grid-column: 1/3;">
        <xsl:apply-templates select="qui:select[@slot='region']" />
      </div>
      <div class="[ fieldset--clause--query flex flex-flow-row flex-align-top gap-1 mt-1 ]">
        <p>Find:</p>
        <div class="flex-grow-1">
          <div class="[ flex flex-gap-1 flex-align-center ][ parenthetical-expression ]">
            <div class="flex-grow-1">
              <div class="[ flex flex-flow-row flex-gap-1 ][ flex-grow-1 ]">
                <xsl:apply-templates select="qui:input[@name='q1']" />
                <xsl:apply-templates select="qui:select[@name='op2']" />  
              </div>
              <div class="[ flex flex-flow-row flex-gap-1 ][ mt-1 flex-grow-1 ][ proximity-clause ]">
                <xsl:apply-templates select="qui:input[@name='q2']" />
                <span>within</span>
                <xsl:apply-templates select="qui:select[@name='amt2']" />  
              </div>
            </div>
          </div>
          <div class="[ flex flex-gap-1 mt-1 flex-align-center ][ proximity-clause ]">
            <xsl:apply-templates select="qui:select[@name='op3']" />
            <xsl:apply-templates select="qui:input[@name='q3']" />
            <span>within</span>
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

  <xsl:template match="qui:select[starts-with(@name, 'amt')]/qui:option" priority="101">
    <option value="{@value}">
      <xsl:value-of select="." />
      <xsl:text> characters</xsl:text>
    </option>
  </xsl:template>

</xsl:stylesheet>