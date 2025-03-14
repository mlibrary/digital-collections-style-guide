<?xml version="1.0" encoding="utf-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui"
  xmlns:qbat="http://dlxs.org/quombat/quombat" xmlns:xhtml="http://www.w3.org/1999/xhtml"
>

  <xsl:variable name="show-ocr-warning-alert" select="false()" />

  <xsl:template name="build-ocr-warning-alert">
    <xsl:if test="$show-ocr-warning-alert">
      <div class="message-callout info pt-0_5" style="margin-bottom: 1rem; padding-top: 0.5rem;">
        <span class="material-icons" aria-hidden="true">info</span>
        <div>
          <p class="mt-0"><strong>Disclaimer</strong></p>
          <p class="mb-0_5">Computer generated plain text may have errors.
            <a href="/cgi/t/text/text-idx?cc={//Param[@name='cc']};page=help/about-ocr-errors" target="_blank">Read more about this.</a></p>
        </div>
      </div>
    </xsl:if>
  </xsl:template>

</xsl:stylesheet>