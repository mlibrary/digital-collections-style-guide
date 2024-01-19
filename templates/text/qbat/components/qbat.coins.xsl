<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:str="http://exslt.org/strings"
  xmlns:exsl="http://exslt.org/exsl"
  xmlns:qui="http://dlxs.org/quombat/ui"
  extension-element-prefixes="str exsl"
  exclude-result-prefixes="str exsl">

  <xsl:template match="qui:metadata" mode="build-coins">
    <xsl:variable name="encoding-type" select="@encoding-type" />
    <span class="Z3988">
      <xsl:attribute name="title">
        <xsl:call-template name="render-coin-attribute">
          <xsl:with-param name="include-ampersand" select="false()" />
          <xsl:with-param name="name">ctx_ver</xsl:with-param>
          <xsl:with-param name="value">Z39.88-2004</xsl:with-param>
        </xsl:call-template>

        <xsl:call-template name="render-coin-attribute">
          <xsl:with-param name="name" select="'rfr_id'"/>
          <xsl:with-param name="value" select="'info:sid/quod.umdl.umich.edu'"/>
        </xsl:call-template>

        <xsl:call-template name="render-coin-attribute">
          <xsl:with-param name="name" select="'rft.title'"/>
          <xsl:with-param name="value">
            <xsl:choose>
              <xsl:when test="$encoding-type = 'serialissue'">
                <xsl:value-of select="qui:field[@key='printsource']//qui:value[1]" />
              </xsl:when>
              <xsl:otherwise>
                <xsl:value-of select="normalize-space(qui:field[@key='title']/qui:values)" />
              </xsl:otherwise>
            </xsl:choose>
          </xsl:with-param>
        </xsl:call-template>

        <xsl:call-template name="render-coin-attribute">
          <xsl:with-param name="name" select="'rft.isbn'"/>
          <!-- Missing value for now. Won't be rendered until added. -->
        </xsl:call-template>

        <xsl:choose>
          <!-- * * * * Monograph COinS attributes * * * * -->
          <xsl:when test="$encoding-type = 'monograph'">

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft_val_fmt'"/>
              <xsl:with-param name="value" select="'info:ofi/fmt:kev:mtx:book'"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.genre'"/>
              <xsl:with-param name="value" select="'book'"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.btitle'"/>
              <xsl:with-param name="value" select="normalize-space(qui:field[@key='title']/qui:values)"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.au'"/>
              <xsl:with-param name="value">
                <xsl:for-each select="qui:field[@key='author']//qui:value">
                  <xsl:value-of select="." />
                  <xsl:if test="position() &lt; last()">, </xsl:if>
                </xsl:for-each>
              </xsl:with-param>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.date'"/>
              <xsl:with-param name="value" select="qui:field[@key='pubinfo']//qui:value[@key='pubdate']"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft_id'"/>
              <xsl:with-param name="value" select="qui:field[@key='bookmark']//qui:value"/>
            </xsl:call-template>

          </xsl:when>
          
          <!-- * * * * Generic COinS attributes * * * * -->
          <xsl:when test="$encoding-type = 'generic'">

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft_val_fmt'"/>
              <xsl:with-param name="value" select="'info:ofi/fmt:kev:mtx:dc'"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.creator'"/>
              <xsl:with-param name="value">
                <xsl:for-each select="qui:field[@key='author']//qui:value">
                  <xsl:value-of select="." />
                  <xsl:if test="position() &lt; last()">, </xsl:if>
                </xsl:for-each>
              </xsl:with-param>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.identifier'"/>
              <xsl:with-param name="value" select="qui:field[@key='bookmark']//qui:value"/>
            </xsl:call-template>

          </xsl:when>

          <!-- * * * * Journal COinS attributes * * * * -->
          <xsl:otherwise>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.jtitle'"/>
              <xsl:with-param name="value" select="normalize-space(qui:field[@key='printsource']/qui:values/qui:value[1])"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft_val_fmt'"/>
              <xsl:with-param name="value" select="'info:ofi/fmt:kev:mtx:journal'"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.genre'"/>
              <xsl:with-param name="value" select="'article'"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.atitle'"/>
              <xsl:with-param name="value" select="normalize-space(qui:field[@key='title']/qui:values)"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.au'"/>
              <xsl:with-param name="value">
                <xsl:for-each select="qui:field[@key='author']//qui:value">
                  <xsl:value-of select="." />
                  <xsl:if test="position() &lt; last()">, </xsl:if>
                </xsl:for-each>
              </xsl:with-param>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.date'"/>
              <xsl:with-param name="value" select="qui:field[@key='printsource']//qui:value[2]"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft_id'"/>
              <xsl:with-param name="value" select="qui:field[@key='bookmark']//qui:value"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft_id'"/>
              <xsl:with-param name="value" select="qui:field[@key='doi']//qui:value"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.volume'"/>
              <xsl:with-param name="value" select="qui:field[@key='volume']//qui:value"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.issue'"/>
              <xsl:with-param name="value" select="qui:field[@key='issue']//qui:value"/>
            </xsl:call-template>

            <xsl:call-template name="render-coin-attribute">
              <xsl:with-param name="name" select="'rft.issn'"/>
              <xsl:with-param name="value" select="qui:field[@key='issn']//qui:value"/>
            </xsl:call-template>

          </xsl:otherwise>
        </xsl:choose>
      </xsl:attribute>  
    </span>
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - -->
  <xsl:template name="render-coin-attribute">

    <xsl:param name="include-ampersand" select="true()"/>
    <xsl:param name="name"/>
    <xsl:param name="value"/>

    <xsl:if test="normalize-space( $value ) != ''">

      <xsl:if test="$include-ampersand">
        <xsl:text>&amp;</xsl:text>
      </xsl:if>

      <xsl:value-of select="$name"/>
      <xsl:text>=</xsl:text>
      <xsl:call-template name="get-percent-encoded-string">
        <xsl:with-param name="text" select="$value"/>
      </xsl:call-template> 

    </xsl:if>

  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - -->
  <xsl:template name="get-percent-encoded-string">

    <xsl:param name="text"/>
  
    <xsl:for-each select="str:tokenize( $text, '' )">
      <xsl:call-template name="get-percent-encoded-character">
        <xsl:with-param name="char" select="."/>
      </xsl:call-template>
    </xsl:for-each> 
    
  </xsl:template>

  <!-- - - - - - - - - - - - - - - - - - - - - - - - - -->
  <!-- 
      Using encodings from: http://ocoins.info/cobg.html

      As needed, add special (e.g., accented) characters.
  -->
  <xsl:template name="get-percent-encoded-character">
     
    <xsl:param name="char" />

    <xsl:choose>

      <xsl:when test="$char = ' '">+</xsl:when> 
      <xsl:when test="$char = '#'">%23</xsl:when> 
      <xsl:when test="$char = '%'">%25</xsl:when> 
      <xsl:when test="$char = '&amp;'">%26</xsl:when> 
      <xsl:when test="$char = '+'">%2B</xsl:when> 
      <xsl:when test="$char = '/'">%2F</xsl:when> 
      <xsl:when test="$char = '&lt;'">%3C</xsl:when> 
      <xsl:when test="$char = '='">%3D</xsl:when> 
      <xsl:when test="$char = '&gt;'">%3E</xsl:when> 
      <xsl:when test="$char = '?'">%3F</xsl:when> 
      <xsl:when test="$char = ':'">%3A</xsl:when> 
      <xsl:when test="$char = 'é'">%C3%A9</xsl:when> 
      <xsl:when test="$char = 'ü'">%C3%BC</xsl:when> 

      <xsl:otherwise>
        <xsl:value-of select="$char"/>
      </xsl:otherwise>

    </xsl:choose>
  </xsl:template>

</xsl:stylesheet>