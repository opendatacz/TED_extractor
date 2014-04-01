<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://opendata.cz/xslt/functions#"
    xmlns:uuid="http://www.uuid.org" 
    exclude-result-prefixes="xs f uuid"
    version="2.0">
    
    <xsl:import href="uuid.xsl"/>
    
    <xsl:variable name="authority_kinds_nm" select="'http://purl.org/procurement/public-contracts-authority-kinds#'"/>
    <xsl:variable name="contract_kinds_nm" select="'http://purl.org/procurement/public-contracts-kinds#'"/>
    <xsl:variable name="authority_activities_nm" select="'http://purl.org/procurement/public-contracts-activities#'"/>
    <xsl:variable name="nuts_nm" select="'http://ec.europa.eu/eurostat/ramon/rdfdata/nuts2008/'"/>
    <xsl:variable name="cpv_nm" select="'http://linked.opendata.cz/resource/cpv-2008/concept/'"/>
    <xsl:variable name="procedure_type_nm" select="'http://purl.org/procurement/public-contracts-procedure-types#'"/>
    
    <!-- get UUID -->
    <xsl:function name="f:getUuid">
        <xsl:sequence select="uuid:get-uuid()"/>
    </xsl:function>
    
    <!-- get business entity id -->
    <xsl:function name="f:getBusinessEntityId" as="xs:string">
        <xsl:param name="countryCode" as="xs:string"/>
        <xsl:param name="identificationNumber" as="xs:string?"/>
        <xsl:choose>
            <xsl:when test="$identificationNumber">
                <xsl:sequence select="concat($countryCode, $identificationNumber)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="uuid:get-uuid()"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    
    <!-- get contract kind resource uri -->
    <xsl:function name="f:getContractKind" as="xs:string?">
        <xsl:param name="kind" as="xs:string"/>
        <xsl:variable name="localname">
            <xsl:choose>
                <xsl:when test="matches($kind, 'SERVICES')">Services</xsl:when>
                <xsl:when test="matches($kind, 'WORKS')">Works</xsl:when>
                <xsl:when test="matches($kind, 'SUPPLIES')">Supplies</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="not($localname = '')">
            <xsl:value-of select="concat($contract_kinds_nm, $localname)"/>
        </xsl:if>
    </xsl:function>
    
    <!-- get authority kind resource uri -->
    <xsl:function name="f:getAuthorityKind" as="xs:string?">
        <xsl:param name="kind" as="xs:string" />
        <xsl:variable name="localname">
            <xsl:choose>
                <xsl:when test="matches($kind,'MINISTRY')">NationalAuthority</xsl:when>
                <xsl:when test="matches($kind,'NATIONAL_AGENCY')">NationalAgency</xsl:when>
                <xsl:when test="matches($kind,'REGIONAL_AUTHORITY')">LocalAuthority</xsl:when>
                <xsl:when test="matches($kind,'REGIONAL_AGENCY')">LocalAgency</xsl:when>
                <xsl:when test="matches($kind,'BODY_PUBLIC')">PublicBody</xsl:when>
                <xsl:when test="matches($kind,'EU_INSTITUTION')">InternationalOrganization</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="not($localname = '')">
            <xsl:value-of select="concat($authority_kinds_nm, $localname)"/>
        </xsl:if>
    </xsl:function>
    
    <!-- get authority kind resource uri -->
    <xsl:function name="f:getAuthorityActivity" as="xs:string?">
        <xsl:param name="activity" as="xs:string" />
        <xsl:variable name="localname">        
            <xsl:choose>
                <xsl:when test="matches($activity,'GENERAL_PUBLIC_SERVICES')">GeneralServices</xsl:when>
                <xsl:when test="matches($activity,'SOCIAL_PROTECTION')">SocialProtection</xsl:when>
                <xsl:when test="matches($activity,'EDUCATION')">Educational</xsl:when>
                <xsl:when test="matches($activity,'HEALTH')">Health</xsl:when>
                <xsl:when test="matches($activity,'ENVIRONMENT')">Environment</xsl:when>
                <xsl:when test="matches($activity,'PUBLIC_ORDER_AND_SAFETY')">Safety</xsl:when>
                <xsl:when test="matches($activity,'HOUSING_AND_COMMUNITY_AMENITIES')">Housing</xsl:when>
                <xsl:when test="matches($activity,'DEFENCE')">Defence</xsl:when>
                <xsl:when test="matches($activity,'ECONOMIC_AND_FINANCIAL_AFFAIRS')">EconomicAffairs</xsl:when>
                <xsl:when test="matches($activity,'RECREATION_CULTURE_AND_RELIGION')">Cultural</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="not($localname = '')">
            <xsl:value-of select="concat($authority_activities_nm, $localname)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="f:getNutsUri" as="xs:string">
        <xsl:param name="nuts" as="xs:string"/>
        <xsl:sequence select="concat($nuts_nm, $nuts)"/>
    </xsl:function>
    
    <xsl:function name="f:getCpvUri" as="xs:string">
        <xsl:param name="cpvCode" as="xs:string"/>
        <xsl:sequence select="concat($cpv_nm, $cpvCode)"/>
    </xsl:function>
    
    <xsl:function name="f:getDuration" as="xs:duration">
        <xsl:param name="durationValue" as="xs:string"/>
        <xsl:param name="unitChar" as="xs:string"/>
        <xsl:variable name="parsedDuration" select="f:parseDuration($durationValue)"/>
        <xsl:if test="$parsedDuration">
            <xsl:value-of select="xs:duration(concat('P', $parsedDuration, $unitChar))"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="f:getDate" as="xs:date">
        <xsl:param name="year" as="xs:integer"/>
        <xsl:param name="month" as="xs:integer"/>
        <xsl:param name="day" as="xs:integer"/>
        <xsl:value-of select="xs:date(concat($year, '-', format-number($month, '00'), '-', format-number($day, '00')))"/>
    </xsl:function>
    
    <xsl:function name="f:getDate" as="xs:gYearMonth">
        <xsl:param name="year" as="xs:integer"/>
        <xsl:param name="month" as="xs:integer"/>
        <xsl:value-of select="xs:gYearMonth(concat($year, '-', format-number($month, '00')))"/>
    </xsl:function>
    
    <xsl:function name="f:getDateTime" as="xs:dateTime">
        <xsl:param name="year" as="xs:integer"/>
        <xsl:param name="month" as="xs:integer"/>
        <xsl:param name="day" as="xs:integer"/>
        <xsl:param name="hoursMinutes" as="xs:string?"/>
        <xsl:variable name="date" select="f:getDate($year, $month, $day)"/>
        <xsl:variable name="time" select="f:getTime($hoursMinutes)"/>
        <xsl:sequence select="xs:dateTime(concat($date, 'T', $time))"/>
    </xsl:function>
    
    <xsl:function name="f:getProcedureType" as="xs:string?">
        <xsl:param name="procedureTypeElementName" as="xs:string"/>    
        <xsl:variable name="localname">
            <xsl:choose>
                <xsl:when test="matches($procedureTypeElementName,'OPEN')">Open</xsl:when>
                <xsl:when test="matches($procedureTypeElementName,'ACCELERATED_RESTRICTED')">AcceleratedRestricted</xsl:when>
                <xsl:when test="matches($procedureTypeElementName,'RESTRICTED')">Restricted</xsl:when>
                <xsl:when test="matches($procedureTypeElementName,'ACCELERATED_NEGOTIATED')">AcceleratedNegotiated</xsl:when>
                <xsl:when test="matches($procedureTypeElementName,'NEGOTIATED_WITH_COMPETITION')">NegotiatedWithCompetition</xsl:when>
                <xsl:when test="matches($procedureTypeElementName,'NEGOTIATED_WITHOUT_COMPETITION')">NegotiatedWithoutCompetition</xsl:when>
                <xsl:when test="matches($procedureTypeElementName,'NEGOTIATED')">Negotiated</xsl:when>
                <xsl:when test="matches($procedureTypeElementName,'COMPETITIVE_DIALOGUE')">CompetitiveDialogue</xsl:when>
                <xsl:when test="matches($procedureTypeElementName,'AWARD_WITHOUT_PRIOR_PUBLICATION')">AwardWithoutPriorPublication</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="not($localname = '')">
            <xsl:value-of select="concat($procedure_type_nm, $localname)" />
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="f:getTime" as="xs:time">
        <xsl:param name="hoursMinutes" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="$hoursMinutes">
                <xsl:analyze-string select="$hoursMinutes" regex="^(\d+):(\d+)$">
                    <xsl:matching-substring>
                        <xsl:value-of select="concat(format-number(xs:integer(regex-group(1)), '00'), ':', format-number(xs:integer(regex-group(2)), '00'), ':', '00')"/>
                    </xsl:matching-substring>
                    <xsl:non-matching-substring>
                        <xsl:value-of select="'00:00:00'"/>
                    </xsl:non-matching-substring>
                </xsl:analyze-string>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="'00:00:00'"/>
            </xsl:otherwise>
        </xsl:choose>      
    </xsl:function>
    
    <xsl:function name="f:parseDuration" as="xs:integer">
        <xsl:param name="durationValue" as="xs:string"/>
        <xsl:variable name="normalizedDuration" select="replace($durationValue, '\s', '')"/>
        <xsl:choose>
            <xsl:when test="matches($normalizedDuration, '^\d+$')">
                <xsl:value-of select="$normalizedDuration"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:analyze-string select="$durationValue" regex="^(\d+)">
                   <xsl:matching-substring>
                       <xsl:value-of select="regex-group(1)"/>
                   </xsl:matching-substring>
                </xsl:analyze-string>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>