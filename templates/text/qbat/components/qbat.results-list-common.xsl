<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:qui="http://dlxs.org/quombat/ui" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:exsl="http://exslt.org/common" extension-element-prefixes="exsl">
  
  <xsl:template name="build-results-item-badge">
    <xsl:choose>
      <xsl:when test="qui:link[@rel='iiif']">
        <img loading="lazy" class="[ results-list__image ]" src="{qui:link[@rel='iiif']/@href}" aria-hidden="true" alt="" />
      </xsl:when>
      <xsl:otherwise>
        <div class="[ results-list__blank ]" aria-hidden="true">
          <xsl:attribute name="data-type">
            <xsl:choose>
              <xsl:when test="qui:link[@rel='icon']/@type='audio'">
                <span>volume_up</span>
              </xsl:when>
              <xsl:when test="qui:link[@rel='icon']/@type='doc'">
                <span>description</span>
              </xsl:when>
              <xsl:when test="qui:link[@rel='icon']/@type='pdf'">
                <span>description</span>
              </xsl:when>
              <xsl:when test="qui:link[@rel='icon']/@type='restricted'">
                <span>lock</span>
              </xsl:when>
              <xsl:otherwise>blank</xsl:otherwise>
            </xsl:choose>
          </xsl:attribute>
        </div>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

  <xsl:template name="build-tombstone-notification">
    <xsl:if test="qui:metadata/@data-tombstone='true'">
      <m-callout icon="info" variant="info">
        <p class="mb-0">
          <xsl:value-of select="key('get-lookup', 'tombstone.str.8')" />
        </p>
        <xsl:if test="qui:link[@rel='tombstone']">
          <ul class="list-unstyled mt-0_5">
            <xsl:for-each select="qui:link[@rel='tombstone']">
              <li>
                <a href="{@href}" class="bedazzled-link" target="_blank">
                  <xsl:apply-templates select="." mode="copy-guts" />
                  <span class="visually-hidden">
                    <xsl:text> for </xsl:text>
                    <xsl:value-of select="normalize-space(qui:metadata/qui:field[@key='title']//qui:value)" />
                  </span>
                  <span class="visually-hidden"> (opens in new tab)</span>
                </a>      
              </li>
            </xsl:for-each>
          </ul>
        </xsl:if>
      </m-callout>
    </xsl:if>
  </xsl:template>
</xsl:stylesheet>