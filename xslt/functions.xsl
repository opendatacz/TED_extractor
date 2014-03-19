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
    <xsl:variable name="cpv_nm" select="'http://purl.org/weso/cpv/2008/'"/>
    <xsl:variable name="procedure_type_nm" select="'http://purl.org/procurement/public-contracts-procedure-types#'"/>
    
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
    <xsl:function name="f:getContractKind" as="xs:string">
        <xsl:param name="kind" as="xs:string"/>
        <xsl:choose>
            <xsl:when test="matches($kind,'SERVICES')">
                <xsl:sequence select="concat($contract_kinds_nm,'Services')"/>
            </xsl:when>
            <xsl:when test="matches($kind,'WORKS')">
                <xsl:sequence select="concat($contract_kinds_nm,'Works')"/>
            </xsl:when>
            <xsl:when test="matches($kind,'SUPPLIES')">
                <xsl:sequence select="concat($contract_kinds_nm,'Supplies')"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <!-- get authority kind resource uri -->
    <xsl:function name="f:getAuthorityKind" as="xs:string">
        <xsl:param name="kind" as="xs:string" />       
        <xsl:choose>
            <xsl:when test="matches($kind,'MINISTRY')">
                <xsl:sequence select="concat($authority_kinds_nm, 'NationalAuthority')" />
            </xsl:when>
            <xsl:when test="matches($kind,'NATIONAL_AGENCY')">
                <xsl:sequence select="concat($authority_kinds_nm, 'NationalAgency')" />
            </xsl:when>
            <xsl:when test="matches($kind,'REGIONAL_AUTHORITY')">
                <xsl:sequence select="concat($authority_kinds_nm, 'LocalAuthority')" />
            </xsl:when>
            <xsl:when test="matches($kind,'REGIONAL_AGENCY')">
                <xsl:sequence select="concat($authority_kinds_nm, 'LocalAgency')" />
            </xsl:when>
            <xsl:when test="matches($kind,'BODY_PUBLIC')">
                <xsl:sequence select="concat($authority_kinds_nm, 'PublicBody')" />
            </xsl:when>
            <xsl:when test="matches($kind,'EU_INSTITUTION')">
                <xsl:sequence select="concat($authority_kinds_nm, 'InternationalOrganization')" />
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <!-- get authority kind resource uri -->
    <xsl:function name="f:getAuthorityActivity" as="xs:string">
        <xsl:param name="activity" as="xs:string" />       
        <xsl:choose>
            <xsl:when test="matches($activity,'GENERAL_PUBLIC_SERVICES')">
                <xsl:sequence select="concat($authority_activities_nm, 'GeneralServices')" />
            </xsl:when>
            <xsl:when test="matches($activity,'SOCIAL_PROTECTION')">
                <xsl:sequence select="concat($authority_activities_nm, 'SocialProtection')" />
            </xsl:when>
            <xsl:when test="matches($activity,'EDUCATION')">
                <xsl:sequence select="concat($authority_activities_nm, 'Educational')" />
            </xsl:when>
            <xsl:when test="matches($activity,'HEALTH')">
                <xsl:sequence select="concat($authority_activities_nm, 'Health')" />
            </xsl:when>
            <xsl:when test="matches($activity,'ENVIRONMENT')">
                <xsl:sequence select="concat($authority_activities_nm, 'Environment')" />
            </xsl:when>
            <xsl:when test="matches($activity,'PUBLIC_ORDER_AND_SAFETY')">
                <xsl:sequence select="concat($authority_activities_nm, 'Safety')" />
            </xsl:when>
            <xsl:when test="matches($activity,'HOUSING_AND_COMMUNITY_AMENITIES')">
                <xsl:sequence select="concat($authority_activities_nm, 'Housing')" />
            </xsl:when>
            <xsl:when test="matches($activity,'DEFENCE')">
                <xsl:sequence select="concat($authority_activities_nm, 'Defence')" />
            </xsl:when>
            <xsl:when test="matches($activity,'ECONOMIC_AND_FINANCIAL_AFFAIRS')">
                <xsl:sequence select="concat($authority_activities_nm, 'EconomicAffairs')" />
            </xsl:when>
            <xsl:when test="matches($activity,'RECREATION_CULTURE_AND_RELIGION')">
                <xsl:sequence select="concat($authority_activities_nm, 'Cultural')" />
            </xsl:when>
        </xsl:choose>
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
        <xsl:param name="durationValue" as="xs:integer"/>
        <xsl:param name="unitChar" as="xs:string"/>
        <xsl:sequence select="xs:duration(concat('P', $durationValue, $unitChar))"/>
    </xsl:function>
    
    <xsl:function name="f:getDate" as="xs:date">
        <xsl:param name="year" as="xs:integer"/>
        <xsl:param name="month" as="xs:integer"/>
        <xsl:param name="day" as="xs:integer"/>
        <xsl:sequence select="xs:date(concat($year, '-', format-number($month, '00'), '-', format-number($day, '00')))"/>
    </xsl:function>
    
    <xsl:function name="f:getDateTime" as="xs:dateTime">
        <xsl:param name="year" as="xs:integer"/>
        <xsl:param name="month" as="xs:integer"/>
        <xsl:param name="day" as="xs:integer"/>
        <xsl:param name="hoursMinutes" as="xs:string?"/>
        <xsl:variable name="date" select="f:getDate($year, $month, $day)"/>
        <xsl:variable name="time">
            <xsl:choose>
                <xsl:when test="$hoursMinutes">
                    <xsl:value-of select="concat($hoursMinutes, ':00')"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'00:00:00'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:sequence select="xs:dateTime(concat($date, 'T', $time))"/>
    </xsl:function>
    
    <xsl:function name="f:getProcedureType" as="xs:string">
        <xsl:param name="procedureTypeElementName" as="xs:string"/>       
        <xsl:choose>
            <xsl:when test="matches($procedureTypeElementName,'OPEN')">
                <xsl:sequence select="concat($procedure_type_nm, 'Open')" />
            </xsl:when>
            <xsl:when test="matches($procedureTypeElementName,'ACCELERATED_RESTRICTED')">
                <xsl:sequence select="concat($procedure_type_nm, 'AcceleratedRestricted')" />
            </xsl:when>
            <xsl:when test="matches($procedureTypeElementName,'RESTRICTED')">
                <xsl:sequence select="concat($procedure_type_nm, 'Restricted')" />
            </xsl:when>
            <xsl:when test="matches($procedureTypeElementName,'ACCELERATED_NEGOTIATED')">
                <xsl:sequence select="concat($procedure_type_nm, 'AcceleratedNegotiated')" />
            </xsl:when>
            <xsl:when test="matches($procedureTypeElementName,'NEGOTIATED_WITH_COMPETITION')">
                <xsl:sequence select="concat($procedure_type_nm, 'NegotiatedWithCompetition')" />
            </xsl:when>
            <xsl:when test="matches($procedureTypeElementName,'NEGOTIATED_WITHOUT_COMPETITION')">
                <xsl:sequence select="concat($procedure_type_nm, 'NegotiatedWithoutCompetition')" />
            </xsl:when>
            <xsl:when test="matches($procedureTypeElementName,'NEGOTIATED')">
                <xsl:sequence select="concat($procedure_type_nm, 'Negotiated')" />
            </xsl:when>
            <xsl:when test="matches($procedureTypeElementName,'COMPETITIVE_DIALOGUE')">
                <xsl:sequence select="concat($procedure_type_nm, 'CompetitiveDialogue')" />
            </xsl:when>
            <xsl:when test="matches($procedureTypeElementName,'AWARD_WITHOUT_PRIOR_PUBLICATION')">
                <xsl:sequence select="concat($procedure_type_nm, 'AwardWithoutPriorPublication')" />
            </xsl:when>
        </xsl:choose>
    </xsl:function>
</xsl:stylesheet>