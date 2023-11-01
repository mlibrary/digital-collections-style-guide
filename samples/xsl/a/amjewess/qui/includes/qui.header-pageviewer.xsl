<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" version="1.0" extension-element-prefixes="exsl str">

  <xsl:template name="build-metadata-fields-for-serialissue-extra">
    <xsl:param name="item" />

    <xsl:apply-templates select="$item/ItemHeader/HEADER/FILEDESC/SOURCEDESC//NOTESSTMT" mode="process-notesstmt" />

  </xsl:template>

</xsl:stylesheet>