<?xml version="1.0" encoding="UTF-8" ?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:str="http://exslt.org/strings" xmlns:exsl="http://exslt.org/common" xmlns:func="http://exslt.org/functions" xmlns:dlxs="http://dlxs.org" extension-element-prefixes="str exsl dlxs func" exclude-result-prefixes="str exsl dlxs func">
    <!-- extension functions -->
    <func:function name="dlxs:normAttr">
        <xsl:param name="attr"/>
        <!-- strip out spaces,commas,question marks -->
        <xsl:variable name="temp" select="translate($attr,' ,?','')"/>
        <func:result select="translate($temp,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
    </func:function>
    <func:function name="dlxs:capitalize">
        <xsl:param name="str"/>
        <xsl:variable name="firstChar" select="substring($str,1,1)"/>
        <xsl:variable name="therest" select="substring($str,2,string-length($str))"/>
        <func:result>
            <xsl:value-of select="concat( translate(         $firstChar,'abcdefghijklmnopqrstuvwxyz','ABCDEFGHIJKLMNOPQRSTUVWXYZ'),$therest)"/>
        </func:result>
    </func:function>
    <func:function name="dlxs:downcase">
        <xsl:param name="str"/>
        <func:result>
            <xsl:value-of select="translate($str,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
        </func:result>
    </func:function>
    <!-- Utility template for building an HTML form elements) -->
    <func:function name="dlxs:stripEndingChars">
        <xsl:param name="attr"/>
        <xsl:param name="chars"/>
        <xsl:choose>
            <xsl:when test="contains($chars,substring($attr,string-length($attr),1))">
                <func:result select="normalize-space(substring($attr,1,string-length($attr)-1))"/>
            </xsl:when>
            <xsl:otherwise>
                <func:result select="$attr"/>
            </xsl:otherwise>
        </xsl:choose>
    </func:function>
    <!-- Utility to see if string1 ends with string2  -->
    <func:function name="dlxs:ends-with">
        <xsl:param name="string1"/>
        <xsl:param name="string2"/>
        <xsl:choose>
            <xsl:when test="substring( $string1, string-length( $string1 ) - string-length( $string2 ) + 1 ) = $string2">
                <func:result>true</func:result>
            </xsl:when>
            <xsl:otherwise>
                <func:result>false</func:result>
            </xsl:otherwise>
        </xsl:choose>
    </func:function>
    <!--  General utilties -->
    <xsl:template name="stripleadingzeros">
        <xsl:param name="str"/>
        <xsl:choose>
            <xsl:when test="starts-with($str,'0')">
                <xsl:call-template name="stripleadingzeros">
                    <xsl:with-param name="str" select="substring($str,2,string-length($str)-1)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$str"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template name="normAttr">
        <xsl:param name="attr"/>
        <!-- strip out spaces,commas,question marks -->
        <xsl:variable name="temp" select="translate($attr,' ,?','')"/>
        <xsl:value-of select="translate($temp,'ABCDEFGHIJKLMNOPQRSTUVWXYZ','abcdefghijklmnopqrstuvwxyz')"/>
    </xsl:template>
</xsl:stylesheet>
