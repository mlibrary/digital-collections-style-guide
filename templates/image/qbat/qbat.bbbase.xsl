<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:date="http://exslt.org/dates-and-times" extension-element-prefixes="exsl date">

  <xsl:variable name="labels-tmp">
    <dlxs:labels>
      <dlxs:field key="itemcount">Number of items</dlxs:field>
      <dlxs:field key="username">Owner</dlxs:field>
      <dlxs:field key="modified_display">Last Modified</dlxs:field>
      <dlxs:field key="bbdel">Delete</dlxs:field>
      <dlxs:field key="bbeditform">Edit</dlxs:field>
      <dlxs:field key="bbexportprep">Export</dlxs:field>
    </dlxs:labels>
  </xsl:variable>
  <xsl:variable name="labels" select="exsl:node-set($labels-tmp)" />

</xsl:stylesheet>