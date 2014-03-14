<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xs="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://opendata.cz/xslt/functions#"
    exclude-result-prefixes="xs f"
    version="2.0">
    
    <xsl:variable name="authority_kinds_nm" select="'http://purl.org/procurement/public-contracts-authority-kinds#'"/>
    <xsl:variable name="contract_kinds_nm" select="'http://purl.org/procurement/public-contracts-kinds#'"/>
    <xsl:variable name="authority_activities_nm" select="'http://purl.org/procurement/public-contracts-activities#'"/>
    
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
</xsl:stylesheet>