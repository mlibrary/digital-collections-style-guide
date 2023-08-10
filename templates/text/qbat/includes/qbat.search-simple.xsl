<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <xsl:template name="build-simple-form">
    <div class="advanced-search--containers">
      <div class="field-groups">
        <xsl:apply-templates select="$search-form/qui:fieldset[@slot='clause']" />
      </div>
    </div>
  </xsl:template>

</xsl:stylesheet>