<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://opendata.cz/xslt/functions#" 
    xmlns:uuid="http://www.uuid.org"
    version="2.0">
    
    <xsl:import href="uuid.xsl"/>
    
    <!-- Namespaces -->
    <xsl:variable name="pc_nm">http://purl.org/procurement/public-contracts#</xsl:variable>
    <xsl:variable name="pcAuthorityKinds">http://purl.org/procurement/public-contracts-authority-kinds#</xsl:variable>
    <xsl:variable name="pcContractKinds">http://purl.org/procurement/public-contracts-kinds#</xsl:variable>
    <xsl:variable name="pcProcedureTypes">http://purl.org/procurement/public-contracts-procedure-types#</xsl:variable>
    <xsl:variable name="pcAwardCriteria">http://purl.org/procurement/public-contracts-criteria#</xsl:variable>
    <xsl:variable name="pcActivities">http://purl.org/procurement/public-contracts-activities#</xsl:variable>
    <xsl:variable name="lod_nm">http://linked.opendata.cz/resource/</xsl:variable>
    <xsl:variable name="ted_nm" select="concat($lod_nm, 'ted.europa.eu/')"/>
    
    <!-- Functions -->
    <xsl:function name="f:getAuthorityKind" as="xsd:anyURI">
        <xsl:param name="code" as="xsd:string"/>
        <xsl:variable name="localname">
            <xsl:choose>
                <xsl:when test="$code = ('1', 'N')">NationalAuthority</xsl:when>
                <xsl:when test="$code = ('3', 'R')">LocalAuthority</xsl:when>
                <xsl:when test="$code = '5'">InternationalOrganization</xsl:when>
                <xsl:when test="$code = '6'">PublicBody</xsl:when>
                <xsl:when test="$code = '8'">Other</xsl:when> <!-- Not in scheme! -->
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($pcAuthorityKinds, $localname)"/>
    </xsl:function>
    
    <xsl:function name="f:getClassInstanceURI" as="xsd:anyURI">
        <xsl:param name="class" as="xsd:string"/>
        <xsl:param name="key" as="xsd:string"/>
        <xsl:value-of select="concat($ted_nm, f:slugify($class), '/', $key)"/>
    </xsl:function>
    
    <xsl:function name="f:getClassInstanceURI" as="xsd:anyURI">
        <xsl:param name="class" as="xsd:string"/>
        <xsl:value-of select="f:getClassInstanceURI($class, uuid:get-uuid())"/>
    </xsl:function>
    
    <xsl:function name="f:getContractKind" as="xsd:anyURI">
        <xsl:param name="code" as="xsd:string"/>
        <xsl:variable name="lowercasedCode" select="lower-case($code)"/>
        <xsl:variable name="localname">
            <xsl:choose>
                <xsl:when test="$lowercasedCode = ('1', 'W')">Works</xsl:when>
                <xsl:when test="$lowercasedCode = '2'">Supplies</xsl:when>
                <xsl:when test="$lowercasedCode = '4'">Services</xsl:when>
                <!--
                <xsl:when test="$lowercasedCode = 'S'">
                    Services or Supplies
                    <xsl:value-of select="concat($pc_contract_kinds, 'Services')"/>
                </xsl:when>
                -->
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($pcContractKinds, $localname)"/>
    </xsl:function>
    
    <xsl:function name="f:getMainActivity" as="xsd:anyURI">
        <xsl:param name="code" as="xsd:string"/>
        <xsl:variable name="localname">
            <xsl:choose>
                <xsl:when test="$code = 'A'">Housing</xsl:when>
                <xsl:when test="$code = 'B'">SocialProtection</xsl:when>
                <xsl:when test="$code = 'C'">Cultural</xsl:when>
                <xsl:when test="$code = 'D'">Defence</xsl:when>
                <xsl:when test="$code = 'E'">Environment</xsl:when>
                <xsl:when test="$code = 'F'">EconomicAffairs</xsl:when>
                <xsl:when test="$code = 'G'">ProductionTransportDistributionGasAndHeat</xsl:when> <!-- "Production, transport and distribution of gas and heat" Not in the scheme! -->
                <xsl:when test="$code = 'H'">Health</xsl:when>
                <xsl:when test="$code = 'I'">AirportRelated</xsl:when> <!-- "Airport-related activities" Not in the scheme! -->
                <xsl:when test="$code = 'J'">ExporationExtractionGasAndOil</xsl:when> <!-- "Exploration and extraction of gas and oil" Not in the scheme! -->
                <xsl:when test="$code = 'K'">PortRelated</xsl:when> <!-- "Port-related activities" Not in the scheme! -->
                <xsl:when test="$code = 'L'">Educational</xsl:when>
                <xsl:when test="$code = 'M'">ExplorationExtractionCoalAndSolidFuels</xsl:when> <!-- "Exploration and extraction of coal and other solid fuels" Not in the scheme! -->
                <xsl:when test="$code = 'N'">Electricity</xsl:when> <!-- "Electricity" Not in the scheme! -->
                <xsl:when test="$code = 'O'">Other</xsl:when> <!-- "Other" Not in the scheme! -->
                <xsl:when test="$code = 'P'">PostalServices</xsl:when> <!-- "Postal services" Not in the scheme! -->
                <xsl:when test="$code = 'R'">RailwayServices</xsl:when> <!-- "Railway services" Not in the scheme! -->
                <xsl:when test="$code = 'S'">GeneralServices</xsl:when>
                <xsl:when test="$code = 'T'">TransportServices</xsl:when> <!-- "Urban railway, tramway, trolleybus or bus services" Not in the scheme! -->
                <xsl:when test="$code = 'U'">Safety</xsl:when>
                <xsl:when test="$code = 'W'">Water</xsl:when> <!-- "Water" Not in the scheme! -->
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($pcActivities, $localname)"/>
    </xsl:function>
    
    <xsl:function name="f:getNoticeType" as="xsd:anyURI?">
        <xsl:param name="code" as="xsd:string"/>
        <xsl:variable name="localname">
            <xsl:choose>
                <xsl:when test="$code = '3'">ContractNotice</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test="$localname">
            <xsl:value-of select="concat($pc_nm, $localname)"/>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="f:getProcedureType" as="xsd:anyURI">
        <xsl:param name="code" as="xsd:string"/>
        <xsl:variable name="localname">
            <xsl:choose>
                <xsl:when test="$code = '1'">Open</xsl:when>
                <xsl:when test="$code = '2'">Restricted</xsl:when>
                <xsl:when test="$code = '3'">AcceleratedRestricted</xsl:when>
                <xsl:when test="$code = '4'">Negotiated</xsl:when>
                <xsl:when test="$code = '6'">AcceleratedNegotiated</xsl:when>
                <xsl:when test="$code = '9'">NotApplicable</xsl:when> <!-- Not in the scheme! -->
                <xsl:when test="$code = 'C'">CompetitiveDialogue</xsl:when> <!-- Not in the scheme! -->
                <xsl:when test="$code = ('D', 'R')">DesignContest</xsl:when> <!-- Not in the scheme! -->
                <xsl:when test="$code = 'I'">CallForExpressionsOfInterest</xsl:when> <!-- Not in the scheme! -->
                <xsl:when test="$code = 'N'">NotSpecified</xsl:when> <!-- Not in the scheme! -->
                <xsl:when test="$code = 'Q'">QualificationSystem</xsl:when> <!-- Not in the scheme! -->
                <xsl:when test="$code = 'T'">NegotiatedWithoutCompetition</xsl:when>
                <xsl:when test="$code = 'V'">AwardWithoutPriorPublication</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($pcProcedureTypes, $localname)"/>
    </xsl:function>
    
    <xsl:function name="f:parseDateTime" as="xsd:string">
        <xsl:param name="dateTimeString" as="xsd:string"/>
        <xsl:analyze-string select="$dateTimeString" regex="^(\d{{4}})(\d{{2}})(\d{{2}})\s?(\d{{2}}:\d{{2}})?$">
            <xsl:matching-substring>
                <xsl:choose>
                    <xsl:when test="regex-group(4)">
                        <xsl:value-of select="concat(regex-group(1),
                            '-',
                            regex-group(2),
                            '-',
                            regex-group(3),
                            'T',
                            regex-group(4),
                            ':00')"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat(regex-group(1),
                            '-',
                            regex-group(2),
                            '-',
                            regex-group(3))"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:matching-substring>
            <xsl:non-matching-substring>
                <xsl:message terminate="yes"><xsl:value-of select="$dateTimeString"/></xsl:message>
            </xsl:non-matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="f:slugify" as="xsd:string">
        <xsl:param name="text" as="xsd:string"/>
        <xsl:value-of select="encode-for-uri(replace(lower-case($text), '\s', '-'))"/>
    </xsl:function>
    
</xsl:stylesheet>