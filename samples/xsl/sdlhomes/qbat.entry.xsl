<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">

  <xsl:template match="qui:block[@slot='actions']" mode="extra">
    <xsl:variable name="record_no" select="//Record[@name='special']//Field[@abbrev='dlxs_catalog']" />
    <xsl:variable name="barcode" select="//Record//Field[@abbrev='wcl1ic_bc']/Values/Value" />
    <!-- <a class="button" href="http://mirlyn.lib.umich.edu/Record/{$record_no}/Request?barcode={$barcode}">Request This</a> -->
    <sl-button href="http://mirlyn.lib.umich.edu/Record/{$record_no}/Request?barcode={$barcode}">Request This</sl-button>
  </xsl:template>

  <!-- <xsl:template name="build-extra-holdings-links">
    <xsl:param name="dlxs_catalog" />
    <xsl:variable name="barcode" select="//Record//Field[@abbrev='wcl1ic_bc']/Values/Value" />
    <qui:field key="request_this" component="system-link">
      <qui:label>
        <xsl:text>Request This</xsl:text>
      </qui:label>
      <qui:values>
        <xsl:for-each select="Values/Value">
          <qui:value>
            <xsl:text>https://mirlyn.lib.umich.edu/Record/</xsl:text>
            <xsl:value-of select="$dlxs_catalog" />
            <xsl:text>/Request?barcode=</xsl:text>
            <xsl:value-of select="$barcode" />
          </qui:value>
        </xsl:for-each>
      </qui:values>
    </qui:field>

  </xsl:template> -->

</xsl:stylesheet>