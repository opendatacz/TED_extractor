<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:f="http://opendata.cz/xslt/functions#" 
    
    xmlns:uuid="java:java.util.UUID"
    exclude-result-prefixes="xsd f uuid"
    version="2.0">
  
    <!-- NAMESPACES -->
    <xsl:variable name="authority_kinds_nm" select="'http://purl.org/procurement/public-contracts-authority-kinds#'"/>
    <xsl:variable name="contract_kinds_nm" select="'http://purl.org/procurement/public-contracts-kinds#'"/>
    <xsl:variable name="authority_activities_nm" select="'http://purl.org/procurement/public-contracts-activities#'"/>
    <xsl:variable name="procedure_type_nm" select="'http://purl.org/procurement/public-contracts-procedure-types#'"/>
    <xsl:variable name="pc_nm" select="'http://purl.org/procurement/public-contracts#'"/>
    <xsl:variable name="nuts_nm" select="'http://ec.europa.eu/eurostat/ramon/rdfdata/nuts2008/'"/>
    <xsl:variable name="cpv_nm" select="'http://linked.opendata.cz/resource/cpv-2008/concept/'"/>
    <xsl:variable name="award_criteria_nmpcAwardCriteria" select="'http://purl.org/procurement/public-contracts-criteria#'"/>
    <xsl:variable name="lod_nm" select="'http://linked.opendata.cz/resource/'"/>
    <xsl:variable name="ted_nm" select="concat($lod_nm, 'ted.europa.eu/')"/>
    

    <!-- FUNCTIONS -->
    
    <!-- get UUID -->
    <xsl:function name="f:getUuid">
        <xsl:sequence select="uuid:randomUUID()"/>
    </xsl:function>
    
    <!-- format decimal number -->
    
    <xsl:function name="f:formatDecimal" as="xsd:decimal">
        <xsl:param name="number" as="xsd:string"/>
        <xsl:value-of select="xsd:decimal(translate(replace($number, '\s', ''), ',', '.'))"/>
    </xsl:function> 
    
    
    <!-- get authority kind resource uri -->
    <xsl:function name="f:getAuthorityKind" as="xsd:string?">
        <xsl:param name="kind" as="xsd:string"/>
        <xsl:param name="code" as="xsd:string"/>
        <xsl:variable name="localname">
            <xsl:choose>
            <!-- TED-to-RDF -->
                <xsl:when test="(string-length($kind) &gt; 0) and (string-length($code) = 0)">
                    <xsl:choose>
                        <xsl:when test="matches($kind,'MINISTRY')">NationalAuthority</xsl:when>
                        <xsl:when test="matches($kind,'NATIONAL_AGENCY')">NationalAgency</xsl:when>
                        <xsl:when test="matches($kind,'REGIONAL_AUTHORITY')">LocalAuthority</xsl:when>
                        <xsl:when test="matches($kind,'REGIONAL_AGENCY')">LocalAgency</xsl:when>
                        <xsl:when test="matches($kind,'BODY_PUBLIC')">PublicBody</xsl:when>
                        <xsl:when test="matches($kind,'EU_INSTITUTION')">InternationalOrganization</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <!-- META-XML-to-RDF -->
                <xsl:when test="(string-length($kind) = 0) and (string-length($code) &gt; 0)">
                    <xsl:choose>
                        <xsl:when test="$code = ('1', 'N')">NationalAuthority</xsl:when>
                        <xsl:when test="$code = '2'">NationalAuthority</xsl:when>
                        <xsl:when test="$code = ('3', 'R')">LocalAuthority</xsl:when>
                        <xsl:when test="$code = '4'">PublicBody</xsl:when>
                        <xsl:when test="$code = '5'">InternationalOrganization</xsl:when>
                        <xsl:when test="$code = '6'">PublicBody</xsl:when>
                        <xsl:when test="$code = '8'">Other</xsl:when> <!-- Not in scheme! -->
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- TED-to-RDF -->
            <xsl:when test="(string-length($kind) &gt; 0) and (string-length($code) = 0) and not($localname = '')">
               <xsl:value-of select="concat($authority_kinds_nm, $localname)"/>                
            </xsl:when>
            <!-- META-XML-to-RDF -->
            <xsl:when test="(string-length($kind) = 0) and (string-length($code) &gt; 0) and not($localname = '')">
               <xsl:value-of select="concat($authority_kinds_nm, $localname)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <!-- get contract kind resource uri -->
    <xsl:function name="f:getContractKind" as="xsd:string?">
        <xsl:param name="kind" as="xsd:string"/>
        <xsl:param name="code" as="xsd:string"/>
        <xsl:variable name="localname">
            <xsl:choose>
                <!-- TED-to-RDF -->
                <xsl:when test="(string-length($kind) &gt; 0) and (string-length($code) = 0)">
                    <xsl:choose>
                        <xsl:when test="matches($kind, 'SERVICES')">Services</xsl:when>
                        <xsl:when test="matches($kind, 'WORKS')">Works</xsl:when>
                        <xsl:when test="matches($kind, 'SUPPLIES')">Supplies</xsl:when>    
                        
                    </xsl:choose>
                </xsl:when>
                <!-- META-XML-to-RDF -->
                <xsl:when test="(string-length($kind) = 0) and (string-length($code) &gt; 0)">
                    <xsl:variable name="lowercasedCode" select="lower-case($code)"/>
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
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- TED-to-RDF -->
            <xsl:when test="(string-length($kind) &gt; 0) and (string-length($code) = 0) and not($localname = '')">
                    <xsl:value-of select="concat($contract_kinds_nm, $localname)"/>
            </xsl:when>
            <!-- META-XML-to-RDF -->
            <xsl:when test="(string-length($kind) = 0) and (string-length($code) &gt; 0) and not($localname = '')">
                    <xsl:value-of select="concat($contract_kinds_nm, $localname)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
  
    
   <!-- get procedure type --> 
    <xsl:function name="f:getProcedureType" as="xsd:string?">
        <xsl:param name="procedureTypeElementName" as="xsd:string"/>
        <xsl:param name="code" as="xsd:string"/>
        <xsl:variable name="localname">
           <xsl:choose>
               <!-- TED-to-RDF -->
               <xsl:when test="(string-length($procedureTypeElementName) &gt; 0) and (string-length($code) = 0)">
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
               </xsl:when>
               <!-- META-XML-to-RDF -->
               <xsl:when test="(string-length($procedureTypeElementName) = 0) and (string-length($code) &gt; 0)">
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
               </xsl:when>
           </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- TED-to-RDF -->
            <xsl:when test="(string-length($procedureTypeElementName) &gt; 0) and (string-length($code) = 0) and not($localname = '')">
                    <xsl:value-of select="concat($procedure_type_nm, $localname)" />
            </xsl:when>
            <!-- META-XML-to-RDF -->
            <xsl:when test="(string-length($procedureTypeElementName) = 0) and (string-length($code) &gt; 0) and not($localname = '')">
                    <xsl:value-of select="concat($procedure_type_nm, $localname)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    
    <!-- get authority kind resource uri -->
    <xsl:function name="f:getAuthorityOrMainActivity" as="xsd:string?">
        <xsl:param name="activity" as="xsd:string" />
        <xsl:param name="code" as="xsd:string"/>
        <xsl:variable name="localname">        
            <xsl:choose>
                <!-- TED-to-RDF -->
                <xsl:when test="(string-length($activity) &gt; 0) and (string-length($code) = 0)">
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
                        
                        <xsl:when test="matches($activity,'RAILWAY_SERVICES')">RailwayServices</xsl:when>
                        <xsl:when test="matches($activity,'EXPLORATION_EXTRACTION_COAL_OTHER_SOLID_FUEL')">ExplorationExtractionCoalAndSolidFuels</xsl:when>
                        <xsl:when test="matches($activity,'PORT_RELATED_ACTIVITIES')">PortRelated</xsl:when>
                        <xsl:when test="matches($activity,'WATER')">Water</xsl:when>
                        <xsl:when test="matches($activity,'ELECTRICITY')">Electricity</xsl:when>
                        <xsl:when test="matches($activity,'AIRPORT_RELATED_ACTIVITIES')">AirportRelated</xsl:when>
                        <xsl:when test="matches($activity,'URBAN_RAILWAY_TRAMWAY_TROLLEYBUS_BUS_SERVICES')">TransportServices</xsl:when>
                        <xsl:when test="matches($activity,'EXPLORATION_EXTRACTION_GAS_OIL')">ExplorationExtractionGasOil</xsl:when>
                        <xsl:when test="matches($activity,'PRODUCTION_TRANSPORT_DISTRIBUTION_GAS_HEAT')">ProductionTransportDistributionGasAndHeat</xsl:when>
                        <xsl:when test="matches($activity,'POSTAL_SERVICES')">PostalServices</xsl:when>
                        
                        <xsl:when test="matches($activity,'OTHER')">Other</xsl:when>
                    </xsl:choose>
                </xsl:when>
                <!-- META-XML-to-RDF -->
                <xsl:when test="(string-length($activity) = 0) and (string-length($code) &gt; 0)">
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
                        <xsl:when test="$code = 'J'">ExplorationExtractionGasAndOil</xsl:when> <!-- "Exploration and extraction of gas and oil" Not in the scheme! -->
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
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <!-- TED-to-RDF -->
            <xsl:when test="(string-length($activity) &gt; 0) and (string-length($code) = 0) and not($localname = '')">
                    <xsl:value-of select="concat($authority_activities_nm, $localname)"/>
            </xsl:when>
            <!-- META-XML-to-RDF -->
            <xsl:when test="(string-length($activity) = 0) and (string-length($code) &gt; 0) and not($localname = '')">
                    <xsl:value-of select="concat($authority_activities_nm, $localname)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
    
    <xsl:function name="f:getClassInstanceURI" as="xsd:anyURI">
        <xsl:param name="class" as="xsd:string"/>
        <xsl:param name="key" as="xsd:string"/>
        <xsl:value-of select="concat($ted_nm, f:slugify($class,'META'), '/', $key)"/>
    </xsl:function>
    
    <xsl:function name="f:getClassInstanceURI" as="xsd:anyURI">
        <xsl:param name="class" as="xsd:string"/>
        <xsl:value-of select="f:getClassInstanceURI($class, uuid:randomUUID())"/>
    </xsl:function>
    
    <xsl:function name="f:getNoticeType" as="xsd:anyURI?">
        <xsl:param name="type" as="xsd:string"/>
        <xsl:param name="code" as="xsd:string"/>
        <xsl:variable name="localname">
            <xsl:choose>
                <xsl:when test="(string-length($type) &gt; 0) and (string-length($code) = 0)">
                   <xsl:choose>
                       <xsl:when test="$type = 'PRIOR_INFORMATION_NOTICE'">PriorInformationNotice</xsl:when>
                       <xsl:when test="$type = 'PERIODIC_INDICATIVE_NOTICE'">PeriodicIndicativeNotice</xsl:when>
                       <xsl:when test="$type = 'PRIOR_INFORMATION_NOTICE_DEFENCE'">PriorInformationNoticeDefence</xsl:when>
                   </xsl:choose>
                </xsl:when>
                <xsl:when test="(string-length($type) = 0) and (string-length($code) &gt; 0)">
                    <xsl:choose>
                        
                        <xsl:when test="$code = ('3', 'B', 'V', 'Q', 'O', 'F')">ContractNotice</xsl:when>
                        <xsl:when test="$code = '7'">ContractAwardNotice</xsl:when>
                        <xsl:when test="$code = ('M', 'P', '4', '0')">PriorInformationNotice</xsl:when>
                        
                    </xsl:choose>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="(string-length($type) &gt; 0) and (string-length($code) = 0) and not($localname = '')">
                    <xsl:value-of select="concat($pc_nm, $localname)"/>
            </xsl:when>
            <xsl:when test="(string-length($type) = 0) and (string-length($code) &gt; 0) and not($localname = '')">
                    <xsl:value-of select="concat($pc_nm, $localname)"/>
            </xsl:when>
        </xsl:choose>
    </xsl:function>
        
        <xsl:function name="f:getDirectiveType" as="xsd:anyURI">
            <xsl:param name="type" as="xsd:string"/>
                <xsl:variable name="localname">
                        <xsl:if test="(string-length($type) &gt; 0)">
                            <xsl:choose>
                                <xsl:when test="$type = 'DIRECTIVE_2004_17'">Directive-2014-17</xsl:when>
                                <xsl:when test="$type = 'DIRECTIVE_2004_17'">Directive-2004-18</xsl:when>
                            </xsl:choose>
                        </xsl:if> 
                </xsl:variable>
                    <xsl:if test="(string-length($type) &gt; 0) and not($localname = '')">
                        <xsl:value-of select="concat($pc_nm, $localname)"/>
                    </xsl:if>
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
    
<!-- slugify  -->
    <xsl:function name="f:slugify" as="xsd:anyURI">
        <xsl:param name="text" as="xsd:string"/>
        <xsl:param name="type" as="xsd:string"/>
        <xsl:choose>
            <!-- TED-to-RDF -->
            <xsl:when test="$type = 'TED'">
                <xsl:value-of select="encode-for-uri(translate(replace(lower-case(normalize-unicode($text, 'NFKD')), '\P{IsBasicLatin}', ''), ' ', '-'))" />
            </xsl:when>
            <!-- META-XML-to-RDF -->
             <xsl:when test="$type = 'META'">
                     <xsl:value-of select="encode-for-uri(replace(lower-case($text), '\s', '-'))"/>
             </xsl:when>
        </xsl:choose>
    </xsl:function>
  
    <!-- get business entity id -->
    <xsl:function name="f:getBusinessEntityId" as="xsd:string">
        <xsl:param name="countryCode" as="xsd:string"/>
        <xsl:param name="identificationNumber" as="xsd:string"/>
        <xsl:variable name="normalizedID" select="replace($identificationNumber, '\s', '')"/>
        <xsl:value-of select="concat($countryCode, $normalizedID)"/>
    </xsl:function>

    <xsl:function name="f:getNutsUri" as="xsd:string">
        <xsl:param name="nuts" as="xsd:string"/>
        <xsl:sequence select="concat($nuts_nm, $nuts)"/>
    </xsl:function>
    
    <xsl:function name="f:getCpvUri" as="xsd:string">
        <xsl:param name="cpvCode" as="xsd:string"/>
        <xsl:sequence select="concat($cpv_nm, $cpvCode)"/>
    </xsl:function>
    
    <xsl:function name="f:getDuration" as="xsd:duration?">
        <xsl:param name="durationValue" as="xsd:string?"/>
        <xsl:param name="unitChar" as="xsd:string"/>
        <xsl:if test="$durationValue">
            <xsl:variable name="parsedDuration" select="f:parseDuration($durationValue)"/>
            <xsl:if test="$parsedDuration">
                <xsl:value-of select="concat('P', $parsedDuration, $unitChar)"/>
            </xsl:if>
        </xsl:if>
    </xsl:function>
    
    <xsl:function name="f:getDate" as="xsd:string">
        <xsl:param name="year" as="xsd:integer"/>
        <xsl:param name="month" as="xsd:integer"/>
        <xsl:param name="day" as="xsd:integer"/>
        <xsl:value-of select="concat($year, '-', format-number($month, '00'), '-', format-number($day, '00'))"/>
    </xsl:function>
    
    <xsl:function name="f:getDate" as="xsd:gYearMonth">
        <xsl:param name="year" as="xsd:integer"/>
        <xsl:param name="month" as="xsd:integer"/>
        <xsl:value-of select="xsd:gYearMonth(concat($year, '-', format-number($month, '00')))"/>
    </xsl:function>
    
    <xsl:function name="f:getDate" as="xsd:gYear">
        <xsl:param name="year" as="xsd:string"/>
        <xsl:value-of select="xsd:gYear($year)"/>
    </xsl:function>
    
    <xsl:function name="f:getDateTime" as="xsd:string">
        <xsl:param name="year" as="xsd:integer"/>
        <xsl:param name="month" as="xsd:integer"/>
        <xsl:param name="day" as="xsd:integer"/>
        <xsl:param name="hoursMinutes" as="xsd:string?"/>
        <xsl:variable name="date" select="f:getDate($year, $month, $day)"/>
        <xsl:variable name="time" select="f:getTime($hoursMinutes)"/>
        <xsl:value-of select="concat($date, 'T', $time)"/>
    </xsl:function>
    
    
    <xsl:function name="f:getTime" as="xsd:time">
        <xsl:param name="hoursMinutes" as="xsd:string?"/>
        <xsl:choose>
            <xsl:when test="$hoursMinutes">
                <xsl:analyze-string select="$hoursMinutes" regex="^(\d+):(\d+)$">
                    <xsl:matching-substring>
                        <xsl:value-of select="concat(format-number(xsd:integer(regex-group(1)), '00'), ':', format-number(xsd:integer(regex-group(2)), '00'), ':', '00')"/>
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
    
    <xsl:function name="f:parseDuration" as="xsd:integer?">
        <xsl:param name="durationValue" as="xsd:string"/>
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
    
    <xsl:function name="f:parseDate">
        <xsl:param name="dateString" as="xsd:string"/>
        <xsl:variable name="year" select="xsd:integer(substring($dateString,1,4))" as="xsd:integer" />
        <xsl:variable name="month" select="xsd:integer(substring($dateString,5,2))" as="xsd:integer" />
        <xsl:variable name="day" select="xsd:integer(substring($dateString,7,2))" as="xsd:integer" />
        <xsl:value-of select="f:getDate($year, $month, $day)" />
    </xsl:function>
    
    <xsl:function name="f:getServiceCategory">
        <xsl:param name="text" as="xsd:string"/>
        <xsl:param name="regex" as="xsd:string"/>
   <xsl:variable name="localname">
            <xsl:if test="matches($text,$regex)">
                <xsl:choose>
                    <xsl:when test="$text = '1'">MaintenanceAndRepairServices</xsl:when>
                    <xsl:when test="$text = '2'">LandTransportServices</xsl:when>
                    <xsl:when test="$text = '3'">AirTransportServices</xsl:when>
                    <xsl:when test="$text = '4'">TransportOfMailServices</xsl:when>
                    <xsl:when test="$text = '5'">TelecommunicationServices</xsl:when>
                    <xsl:when test="$text = '6'">FinancialServices</xsl:when>
                    <xsl:when test="$text = '7'">ComputerServices</xsl:when>
                    <xsl:when test="$text = '8'">ResearchAndDevelopmentServices</xsl:when>
                    <xsl:when test="$text = '9'">AccountingServices</xsl:when>
                    <xsl:when test="$text = '10'">MarketResearchServices</xsl:when>
                    <xsl:when test="$text = '11'">ConsultingServices</xsl:when>
                    <xsl:when test="$text = '12'">ArchitecturalServices</xsl:when>
                    <xsl:when test="$text = '13'">AdvertisingServices</xsl:when>
                    <xsl:when test="$text = '14'">BuildingCleaningServices</xsl:when>
                    <xsl:when test="$text = '15'">PublishingServices</xsl:when>
                    <xsl:when test="$text = '16'">SewageServices</xsl:when>
                    <xsl:when test="$text = '17'">HotelAndRestaurantServices</xsl:when>
                    <xsl:when test="$text = '18'">RailTransportServices</xsl:when>
                    <xsl:when test="$text = '19'">WaterTransportServices</xsl:when>
                    <xsl:when test="$text = '20'">SupportingTransportServices</xsl:when>
                    <xsl:when test="$text = '21'">LegalServices</xsl:when>
                    <xsl:when test="$text = '22'">PersonnelPlacementServices</xsl:when>
                    <xsl:when test="$text = '23'">InvestigationAndSecurityServices</xsl:when>
                    <xsl:when test="$text = '24'">EducationServices</xsl:when>
                    <xsl:when test="$text = '25'">HealthServices</xsl:when>
                    <xsl:when test="$text = '26'">CulturalServices</xsl:when>
                    <xsl:when test="$text = '27'">Other</xsl:when> <!-- NOT in PC ONTOLOGY -->
                </xsl:choose>
               
            </xsl:if>    
   </xsl:variable>
        <xsl:if test="not($localname = '')">
            <xsl:value-of select="concat($contract_kinds_nm, $localname)"/>
        </xsl:if>
    </xsl:function>
    
</xsl:stylesheet>