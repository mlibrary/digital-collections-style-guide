<?xml version="1.0"?>
<xsl:stylesheet xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:dlxs="http://dlxs.org" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:exsl="http://exslt.org/common" xmlns:str="http://exslt.org/strings" xmlns:date="http://exslt.org/dates-and-times" version="1.0" extension-element-prefixes="exsl str date">
  <xsl:template name="marc-to-iana">
      <xsl:param name="marcCode"/>
      <xsl:variable name="code" select="normalize-space($marcCode)"/>
      
      <xsl:choose>
          <xsl:when test="$code = ''">en</xsl:when>
          <xsl:when test="contains($code, '|')">mul</xsl:when>
          <xsl:when test="$code = 'eng'">en</xsl:when>
          <xsl:when test="$code = 'fre' or $code = 'fra'">fr</xsl:when>
          <xsl:when test="$code = 'ger' or $code = 'deu'">de</xsl:when>
          <xsl:when test="$code = 'spa'">es</xsl:when>
          <xsl:when test="$code = 'ita' or $code = 'ital'">it</xsl:when>
          <xsl:when test="$code = 'jpn'">ja</xsl:when>
          <xsl:when test="$code = 'chi' or $code = 'zho'">zh</xsl:when>
          <xsl:when test="$code = 'rus'">ru</xsl:when>
          <xsl:when test="$code = 'lat'">la</xsl:when>
          <xsl:when test="$code = 'gre' or $code = 'ell' or $code = 'grk'">el</xsl:when>
          <xsl:when test="$code = 'und'">und</xsl:when>
          <xsl:when test="$code = 'mul'">mul</xsl:when>
          <xsl:when test="$code = 'scc'">sr</xsl:when>
          <xsl:when test="$code = 'scr'">hr</xsl:when>
          <xsl:when test="$code = 'fill' or $code = 'phi'">fil</xsl:when>
          <xsl:when test="$code = 'por'">pt</xsl:when>
          <xsl:when test="$code = 'ara'">ar</xsl:when>
          <xsl:when test="$code = 'bik'">bcl</xsl:when>
          <xsl:when test="$code = 'arm'">hy</xsl:when>
          <xsl:when test="$code = 'bik'">bcl</xsl:when>
          <xsl:when test="$code = 'bul'">bg</xsl:when>
          <xsl:when test="$code = 'bur'">my</xsl:when>
          <xsl:when test="$code = 'cat'">ca</xsl:when>
          <xsl:when test="$code = 'cha'">ch</xsl:when>
          <xsl:when test="$code = 'cze'">cs</xsl:when>
          <xsl:when test="$code = 'dan'">da</xsl:when>
          <xsl:when test="$code = 'dut'">nl</xsl:when>
          <xsl:when test="$code = 'ger'">de</xsl:when>
          <xsl:when test="$code = 'grk'">el</xsl:when>
          <xsl:when test="$code = 'heb'">he</xsl:when>
          <xsl:when test="$code = 'hun'">hu</xsl:when>
          <xsl:when test="$code = 'ind'">id</xsl:when>
          <xsl:when test="$code = 'jpn'">ja</xsl:when>
          <xsl:when test="$code = 'lao'">lo</xsl:when>
          <xsl:when test="$code = 'may'">ms</xsl:when>
          <xsl:when test="$code = 'nor'">no</xsl:when>
          <xsl:when test="$code = 'per'">fa</xsl:when>
          <xsl:when test="$code = 'pol'">pl</xsl:when>
          <xsl:when test="$code = 'que'">qu</xsl:when>
          <xsl:when test="$code = 'rum'">ro</xsl:when>
          <xsl:when test="$code = 'san'">sa</xsl:when>
          <xsl:when test="$code = 'scc'">sr</xsl:when>
          <xsl:when test="$code = 'scr'">hr</xsl:when>
          <xsl:when test="$code = 'swe'">sv</xsl:when>
          <xsl:when test="$code = 'tel'">te</xsl:when>
          <xsl:when test="$code = 'tgl'">tl</xsl:when>
          <xsl:when test="$code = 'tha'">th</xsl:when>
          <xsl:when test="$code = 'urd'">ur</xsl:when>
          <xsl:when test="$code = 'vie'">vi</xsl:when>
          <xsl:when test="$code = 'wel'">cy</xsl:when>
          <xsl:when test="$code = 'yid'">ji</xsl:when>          
          <xsl:when test="$code = 'l' or $code = 'lat' or $code = 'latin'">la</xsl:when>
          <!-- mul?? -->
          <xsl:otherwise>
              <xsl:value-of select="$code"/>
          </xsl:otherwise>
      </xsl:choose>
  </xsl:template>
</xsl:stylesheet>