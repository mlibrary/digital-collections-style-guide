<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" extension-element-prefixes="exsl str">


  <xsl:template name="get-head-title">
    <qui:values>
      <qui:value>
        <xsl:call-template name="get-title" />
      </qui:value>
      <qui:value>
        <xsl:call-template name="get-collection-title" />
      </qui:value>
    </qui:values>
  </xsl:template>

  <xsl:template name="build-breadcrumbs">
    <qui:nav role="breadcrumb">
      <qui:link href="{/Top/Home}">
        <xsl:value-of select="/Top/Banner/Text" />
      </qui:link>
      <qui:link href="{/Top//CurrentUrl}" identifier="{/Top/@identifier}">
        <xsl:call-template name="get-current-page-breadcrumb-label" />
      </qui:link>
    </qui:nav>
  </xsl:template>

</xsl:stylesheet>