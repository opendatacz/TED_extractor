<?xml version="1.0" encoding="UTF-8"?>
<!-- 
####################################################################################
# Source format documentation:  <ftp://ted.europa.eu/Description_Metaform-v1.03.pdf>

/part/doc[@t = 'O'][CONTRACT[@category = 'orig']]
####################################################################################
 -->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:gr="http://purl.org/goodrelations/v1#" 
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:pc="http://purl.org/procurement/public-contracts#" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" 
    xmlns:rdfs="http://www.w3.org/2000/01/rdf-schema#" 
    xmlns:s="http://schema.org/"
    xmlns:vcard="http://www.w3.org/2006/vcard/ns#" 
    xmlns:pceu="http://purl.org/procurement/public-contracts-eu#" 
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
    xmlns:adms="http://www.w3.org/ns/adms#" 
    xmlns:f="http://opendata.cz/xslt/functions#" 
    xmlns:uuid="http://www.uuid.org"
    exclude-result-prefixes="f uuid"
    version="2.0">

    <xsl:import href="uuid.xsl"/>
    <xsl:output encoding="UTF-8" indent="yes" method="xml" normalization-form="NFC"/>

    <!-- Namespaces -->
    <xsl:variable name="xsd_nm">http://www.w3.org/2001/XMLSchema#</xsl:variable>
    <xsl:variable name="pcdt_nm">http://purl.org/procurement/public-contracts-datatypes#</xsl:variable>
    <xsl:variable name="pc_nm">http://purl.org/procurement/public-contracts#</xsl:variable>
    <xsl:variable name="pcAuthorityKinds">http://purl.org/procurement/public-contracts-authority-kinds#</xsl:variable>
    <xsl:variable name="pcContractKinds">http://purl.org/procurement/public-contracts-kinds#</xsl:variable>
    <xsl:variable name="pcProcedureTypes">http://purl.org/procurement/public-contracts-procedure-types#</xsl:variable>
    <xsl:variable name="pcAwardCriteria">http://purl.org/procurement/public-contracts-criteria#</xsl:variable>
    <xsl:variable name="pcActivities">http://purl.org/procurement/public-contracts-activities#</xsl:variable>
    <xsl:variable name="cpv_nm">http://linked.opendata.cz/resource/cpv-2008/concept/</xsl:variable>
    <xsl:variable name="nuts_nm">http://ec.europa.eu/eurostat/ramon/rdfdata/nuts2008/</xsl:variable>
    <xsl:variable name="lod_nm">http://linked.opendata.cz/resource/</xsl:variable>
    <xsl:variable name="ted_nm" select="concat($lod_nm, 'ted.europa.eu/')"/>
    <xsl:variable name="ted_business_entity_nm" select="concat($ted_nm, 'business-entity/')"/>
    <xsl:variable name="ted_pc_nm" select="concat($ted_nm, 'public-contract/')"/>
    
    <!-- URIs -->
    <xsl:variable name="xsd_date_uri" select="concat($xsd_nm, 'date')"/>
    <xsl:variable name="xsd_datetime_uri" select="concat($xsd_nm, 'dateTime')"/>
    <xsl:variable name="xsd_boolean_uri" select="concat($xsd_nm, 'boolean')"/>
    <xsl:variable name="xsd_duration_uri" select="concat($xsd_nm, 'duration')"/>
    <xsl:variable name="xsd_date_time_uri" select="concat($xsd_nm, 'dateTime')"/>
    <xsl:variable name="xsd_decimal_uri" select="concat($xsd_nm, 'decimal')"/>
    <xsl:variable name="xsd_non_negative_integer_uri" select="concat($xsd_nm, 'nonNegativeInteger')"/>
    <xsl:variable name="pcdt_percentage_uri" select="concat($pcdt_nm, 'percentage')"/>
    <xsl:variable name="pc_criterion_lowest_price_uri" select="concat($pcAwardCriteria, 'LowestPrice')"/>
    
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
        <xsl:value-of select="concat($ted_nm, '/', encode-for-uri(replace(lower-case($class), '\s', '-')), '/', $key)"/>
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
    
    <xsl:function name="f:getNoticeType" as="xsd:anyURI">
        <xsl:param name="code" as="xsd:string"/>
        <xsl:variable name="localname">
            <xsl:choose>
                <xsl:when test="$code = '3'">ContractNotice</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:value-of select="concat($pc_nm, $localname)"/>
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
    
    <xsl:function name="f:parseDate" as="xsd:date">
        <xsl:param name="dateString" as="xsd:string"/>
        <xsl:analyze-string select="$dateString" regex="^(\d{{4}})(\d{{2}})(\d{{2}})$">
            <xsl:matching-substring>
                <xsl:value-of select="concat(regex-group(1), '-', regex-group(2), '-', regex-group(3))"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <xsl:function name="f:parseDateTime" as="xsd:dateTime">
        <xsl:param name="dateTimeString" as="xsd:string"/>
        <xsl:analyze-string select="$dateTimeString" regex="^(\d{{4}})(\d{{2}})(\d{{2}})\s(\d{{2}}:\d{{2}})$">
            <xsl:matching-substring>
                <xsl:value-of select="concat(regex-group(1),
                                             '-',
                                             regex-group(2),
                                             '-',
                                             regex-group(3),
                                             'T',
                                             regex-group(4),
                                             ':00')"/>
            </xsl:matching-substring>
        </xsl:analyze-string>
    </xsl:function>
    
    <!-- Templates -->
    
    <xsl:template match="/">
        <rdf:RDF>
            <xsl:apply-templates select="part/doc[@t = 'O'][*[self::CONTRACT or self::CONTRACT_AWARD][@category='orig']]"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="doc[CONTRACT]">
        <xsl:variable name="lang" select="@lgorig"/>
        <xsl:variable name="pc_uri" select="concat($ted_pc_nm, @id)"/>
        <xsl:variable name="contract_address_uri" select="f:getClassInstanceURI('Postal address')"/>
        
        <pc:Contract rdf:about="{$pc_uri}">
            <xsl:apply-templates>
                <xsl:with-param name="lang" tunnel="yes" select="$lang"/>
                <xsl:with-param name="pc_uri" tunnel="yes" select="$pc_uri"/>
                <xsl:with-param name="contract_address_uri" tunnel="yes" select="$contract_address_uri"/>
            </xsl:apply-templates>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="@ctype[parent::doc]">
        <xsl:variable name="contractKind" select="f:getContractKind(.)"/>
        <if test="$contractKind">
            <pc:contractKind rdf:resource="{$contractKind}"/>
        </if>
    </xsl:template>
    
    <xsl:template match="refojs/datepub">
        <dcterms:issued rdf:datatype="{$xsd_date_uri}"><xsl:value-of select="f:parseDate(text())"/></dcterms:issued>
    </xsl:template>
    
    <xsl:template match="codifdata">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="sector">
        <pc:authorityKind rdf:resource="{f:getAuthorityKind(@code)}"/>
    </xsl:template>
    
    <xsl:template match="natnotice">
        <rdf:type rdf:resource="{f:getNoticeType(@code)}"/>
    </xsl:template>
    
    <xsl:template match="market">
        <pc:kind rdf:resource="{f:getContractKind(@code)}"/>
    </xsl:template>
    
    <xsl:template match="proc">
        <pc:procedureType rdf:resource="{f:getProcedureType(@code)}"/>
    </xsl:template>
    
    <xsl:template match="marketorg">
        <!-- TODO: What's the semantics of this element? -->
    </xsl:template>
    
    <xsl:template match="typebid">
        <!-- TODO: What's the semantics of this element? -->
    </xsl:template>
    
    <xsl:template match="awardcrit">
        <xsl:param name="pc_uri"/>
        <pc:awardCriteriaCombination>
            <pc:AwardCriteriaCombination rdf:about="{concat($pc_uri, '/combination-of-contract-award-criteria/1')}">
                <xsl:call-template name="awardCriteriaCombination">
                    <xsl:with-param name="code" select="@code"/>
                </xsl:call-template>
            </pc:AwardCriteriaCombination>
        </pc:awardCriteriaCombination>
    </xsl:template>
    
    <xsl:template match="originalcpv[position() = 1]">
        <pc:mainObject rdf:resource="{concat($cpv_nm, @code)}"/>
    </xsl:template>
    
    <xsl:template match="originalcpv[position() > 1]">
        <pc:additionalObject rdf:resource="{concat($cpv_nm, @code)}"/>
    </xsl:template>
    
    <xsl:template match="codenuts">
        <xsl:param name="contract_address_uri"/>
        <pc:location>
            <s:Place rdf:about="{f:getClassInstanceURI('Place')}">
                <s:address>
                    <s:PostalAddress rdf:about="{$contract_address_uri}">
                        <s:addressRegion rdf:resource="{concat($nuts_nm, @code)}"/>
                    </s:PostalAddress>
                </s:address>
            </s:Place>
        </pc:location>
    </xsl:template>
    
    <xsl:template match="datedisp">
        <dcterms:issued rdf:datatype="{$xsd_date_uri}"><xsl:value-of select="f:parseDate(text())"/></dcterms:issued>
    </xsl:template>
    
    <xsl:template match="refnotice">
        <adms:identifier>
            <adms:Identifier rdf:about="{f:getClassInstanceURI('Identifier')}">
                <skos:notation><xsl:value-of select="text()"/></skos:notation>
            </adms:Identifier>
        </adms:identifier>
    </xsl:template>
    
    <xsl:template match="deadlinereq | deadlinerec">
        <pc:tenderDeadline rdf:datatype="{$xsd_datetime_uri}"><xsl:value-of select="f:parseDateTime(text())"/></pc:tenderDeadline>
    </xsl:template>
    
    <xsl:template match="isocountry">
        <xsl:param name="contract_address_uri"/>
        <rdf:Description rdf:about="{$contract_address_uri}">
            <s:addressCountry><xsl:value-of select="text()"/></s:addressCountry>
        </rdf:Description>
    </xsl:template>
    
    <xsl:template match="mainactivities">
        <pc:mainActivity rdf:resource="{f:getMainActivity(@code)}"/>
    </xsl:template>
    
    <xsl:template match="contents">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="grseq[tigrseq[contains(., 'CONTRACTING AUTHORITY')]]">
        <xsl:apply-templates mode="contractingAuthority"/>
    </xsl:template>
    
    <xsl:template mode="contractingAuthority" match="marklist/mlioccur[timark[contains(., 'NAME, ADDRESSES AND CONTACT POINT(S)')]]/txtmark/p/addr">
        <pc:contact>
            <s:ContactPoint rdf:about="{f:getClassInstanceURI('Postal address')}">
                <xsl:apply-templates mode="postalAddress"/>
            </s:ContactPoint>
        </pc:contact>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="organisation">
        <s:name><xsl:value-of select="text()"/></s:name>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="address">
        <s:description><xsl:value-of select="text()"/></s:description>    
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="attention">
        <s:contactType><xsl:value-of select="text()"/></s:contactType>    
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="town">
        <s:addressLocality><xsl:value-of select="text()"/></s:addressLocality>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="countrycode">
        <s:addressCountry><xsl:value-of select="text()"/></s:addressCountry>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="tel">
        <s:telephone><xsl:value-of select="text()"/></s:telephone>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="email/txemail">
        <s:email><xsl:value-of select="text()"/></s:email>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="fax">
        <s:faxNumber><xsl:value-of select="text()"/></s:faxNumber>
    </xsl:template>
    
    <!-- Named templates -->
    
    <xsl:template name="awardCriteriaCombination">
        <xsl:param name="code" as="xsd:string"/>
        <xsl:param name="lang" as="xsd:string"/>
        <pc:awardCriterion>
            <pc:CriterionWeighting rdf:about="{f:getClassInstanceURI('Criterion weighting')}">
                <pc:weightedCriterion>
                    <xsl:choose>
                        <xsl:when test="$code = '1'">
                            <!-- Code 1: Lowest price -->
                            <xsl:attribute name="rdf:resource" select="$pc_criterion_lowest_price_uri"/>
                        </xsl:when>
                        <xsl:otherwise>
                            <!--
                                Code 2: The most economic tender
                                Code 8: Not defined
                                Code 9: Not applicable
                            -->
                            <skos:Concept rdf:about="{f:getClassInstanceURI('Weighted criterion', $code)}">
                                <skos:prefLabel xml:lang="{$lang}"><xsl:value-of select="text()"/></skos:prefLabel>
                            </skos:Concept>
                        </xsl:otherwise>
                    </xsl:choose>
                </pc:weightedCriterion>
                <pc:criterionWeight rdf:datatype="{$pcdt_percentage_uri}">100</pc:criterionWeight>
            </pc:CriterionWeighting>
        </pc:awardCriterion>
    </xsl:template>
    
    <!-- Catch-all empty template -->
    <xsl:template match="text()|@*"/>

</xsl:stylesheet>