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
    exclude-result-prefixes="f"
    version="2.0">

    <xsl:import href="META-XML-functions.xsl"/>
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" normalization-form="NFC"/>

    <!-- Namespaces -->
    <xsl:variable name="xsd_nm">http://www.w3.org/2001/XMLSchema#</xsl:variable>
    <xsl:variable name="pcdt_nm">http://purl.org/procurement/public-contracts-datatypes#</xsl:variable>
    <xsl:variable name="cpv_nm">http://linked.opendata.cz/resource/cpv-2008/concept/</xsl:variable>
    <xsl:variable name="nuts_nm">http://ec.europa.eu/eurostat/ramon/rdfdata/nuts2008/</xsl:variable>
    <xsl:variable name="lod_nm">http://linked.opendata.cz/resource/</xsl:variable>
    <xsl:variable name="ted_nm" select="concat($lod_nm, 'ted.europa.eu/')"/>
    <xsl:variable name="pcAwardCriteria">http://purl.org/procurement/public-contracts-criteria#</xsl:variable>
    
    <!-- URIs -->
    <xsl:variable name="xsd_boolean_uri" select="concat($xsd_nm, 'boolean')"/>
    <xsl:variable name="xsd_date_uri" select="concat($xsd_nm, 'date')"/>
    <xsl:variable name="xsd_datetime_uri" select="concat($xsd_nm, 'dateTime')"/>
    <xsl:variable name="xsd_decimal_uri" select="concat($xsd_nm, 'decimal')"/>
    <xsl:variable name="pcdt_percentage_uri" select="concat($pcdt_nm, 'percentage')"/>
    <xsl:variable name="pc_criterion_lowest_price_uri" select="concat($pcAwardCriteria, 'LowestPrice')"/>
    
    <!-- Templates -->
    
    <xsl:template match="/">
        <rdf:RDF>
            <xsl:apply-templates select="part/doc[@t = 'O'][*[@category='orig']]"/>
        </rdf:RDF>
    </xsl:template>

    <xsl:template match="doc">
        <xsl:variable name="pc_uri" select="f:getClassInstanceURI('Public contract', @id)"/>
        <xsl:variable name="contracting_authority_uri" select="f:getClassInstanceURI('Organization')"/>

        <xsl:apply-templates>
            <xsl:with-param name="pc_uri" tunnel="yes" select="$pc_uri"/>
            <xsl:with-param name="contracting_authority_uri" tunnel="yes" select="$contracting_authority_uri"/>
        </xsl:apply-templates>
    </xsl:template>
    
    <xsl:template match="*[@category = 'orig']">
        <xsl:param name="pc_uri" tunnel="yes"/>
        
        <xsl:variable name="lang" select="@lgorig"/>
        <xsl:variable name="contract_place_uri" select="f:getClassInstanceURI('Place')"/>
        <xsl:variable name="contract_address_uri" select="f:getClassInstanceURI('Postal address')"/>
        
        <pc:Contract rdf:about="{$pc_uri}">
            <xsl:apply-templates>
                <xsl:with-param name="lang" tunnel="yes" select="$lang"/>
                <xsl:with-param name="contract_place_uri" tunnel="yes" select="$contract_place_uri"/>
                <xsl:with-param name="contract_address_uri" tunnel="yes" select="$contract_address_uri"/>
            </xsl:apply-templates>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="@ctype">
        <xsl:variable name="contractKind" select="f:getContractKind(.)"/>
        <if test="$contractKind">
            <pc:contractKind rdf:resource="{$contractKind}"/>
        </if>
    </xsl:template>
    
    <xsl:template match="refojs/datepub">
        <dcterms:issued rdf:datatype="{$xsd_date_uri}"><xsl:value-of select="f:parseDateTime(text())"/></dcterms:issued>
    </xsl:template>
    
    <xsl:template match="codifdata">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="sector">
        <xsl:param name="contracting_authority_uri" tunnel="yes"/>
        <pc:contractingAuthority>
            <s:Organization rdf:about="{$contracting_authority_uri}">
                <pc:authorityKind rdf:resource="{f:getAuthorityKind(@code)}"/>
            </s:Organization>
        </pc:contractingAuthority>
    </xsl:template>
    
    <xsl:template match="natnotice">
        <!-- <rdf:type rdf:resource="{f:getNoticeType(@code)}"/> -->
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
        <xsl:param name="pc_uri" tunnel="yes"/>
        <xsl:param name="lang" tunnel="yes"/>
        <pc:awardCriteriaCombination>
            <pc:AwardCriteriaCombination rdf:about="{concat($pc_uri, '/combination-of-contract-award-criteria/1')}">
                <xsl:call-template name="awardCriteriaCombination">
                    <xsl:with-param name="code" select="@code"/>
                    <xsl:with-param name="lang" select="$lang"/>
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
        <xsl:param name="contract_place_uri" tunnel="yes"/>
        <xsl:param name="contract_address_uri" tunnel="yes"/>
        <pc:location>
            <s:Place rdf:about="{$contract_place_uri}">
                <s:address>
                    <s:PostalAddress rdf:about="{$contract_address_uri}">
                        <s:addressRegion rdf:resource="{concat($nuts_nm, @code)}"/>
                    </s:PostalAddress>
                </s:address>
            </s:Place>
        </pc:location>
    </xsl:template>
    
    <xsl:template match="datedisp">
        <!-- Document dispatch -->
        <dcterms:dateSubmitted rdf:datatype="{$xsd_date_uri}"><xsl:value-of select="f:parseDateTime(text())"/></dcterms:dateSubmitted>
    </xsl:template>
    
    <xsl:template match="refnotice">
        <adms:identifier>
            <adms:Identifier rdf:about="{f:getClassInstanceURI('Identifier', f:slugify(text()))}">
                <skos:notation><xsl:value-of select="text()"/></skos:notation>
            </adms:Identifier>
        </adms:identifier>
    </xsl:template>
    
    <xsl:template match="deadlinerec">
        <!-- DT : Deadline for submitting the bids to the call for tender. -->
        <pc:tenderDeadline rdf:datatype="{$xsd_datetime_uri}"><xsl:value-of select="f:parseDateTime(text())"/></pc:tenderDeadline>
    </xsl:template>
    
    <xsl:template match="deadlinereq">
        <!-- DD : Deadline for obtaining documents (specifications) for the call for tender -->
        <pc:documentationRequestDeadline rdf:datatype="{$xsd_datetime_uri}"><xsl:value-of select="f:parseDateTime(text())"/></pc:documentationRequestDeadline>
    </xsl:template>
    
    <xsl:template match="isocountry">
        <xsl:param name="contract_place_uri" tunnel="yes"/>
        <xsl:param name="contract_address_uri" tunnel="yes"/>
        
        <pc:location>
            <s:Place rdf:about="{$contract_place_uri}">
                <s:address>
                    <s:PostalAddress rdf:about="{$contract_address_uri}">
                        <s:addressCountry><xsl:value-of select="text()"/></s:addressCountry>
                    </s:PostalAddress>
                </s:address>
            </s:Place>
        </pc:location>
    </xsl:template>
    
    <xsl:template match="mainactivities">
        <xsl:param name="contracting_authority_uri" tunnel="yes"/>
        <pc:contractingAuthority>
            <s:Organization rdf:about="{$contracting_authority_uri}">
                <pc:mainActivity rdf:resource="{f:getMainActivity(@code)}"/>
            </s:Organization>
        </pc:contractingAuthority>
    </xsl:template>
    
    <xsl:template match="contents">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="grseq[tigrseq[contains(., 'CONTRACTING AUTHORITY')]]">
        <xsl:param name="contracting_authority_uri" tunnel="yes"/>
        <pc:contractingAuthority>
            <s:Organization rdf:about="{$contracting_authority_uri}">
                <xsl:apply-templates mode="contractingAuthority"/>
            </s:Organization>
        </pc:contractingAuthority>
    </xsl:template>
    
    <xsl:template mode="contractingAuthority" match="marklist/mlioccur[timark[contains(., 'NAME, ADDRESSES AND CONTACT POINT(S)')]]/txtmark">
        <xsl:apply-templates mode="contractingAuthority"/>
    </xsl:template>
    
    <xsl:template mode="contractingAuthority" match="p/addr[position() = 1]">
        <xsl:param name="contract_address_uri" tunnel="yes"/>
        <xsl:apply-templates mode="contractingAuthority"/>
        <s:address>
            <s:PostalAddress rdf:about="{$contract_address_uri}">
                <xsl:apply-templates mode="postalAddress"/>
            </s:PostalAddress>
        </s:address>
    </xsl:template>
    
    <xsl:template mode="contractingAuthority" match="p/txurl">
        <s:url><xsl:value-of select="text()"/></s:url>
    </xsl:template>
    
    <xsl:template mode="contractingAuthority" match="officialname">
        <s:legalName><xsl:value-of select="text()"/></s:legalName>
    </xsl:template>
    
    <xsl:template mode="contractingAuthority" match="nationalid">
        <adms:identifier>
            <adms:Identifier rdf:about="{f:getClassInstanceURI('Identifier')}">
                <skos:notation><xsl:value-of select="text()"/></skos:notation>
            </adms:Identifier>
        </adms:identifier>    
    </xsl:template>
    
    <xsl:template mode="contractingAuthority" match="organisation">
        <s:name><xsl:value-of select="text()"/></s:name>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="address">
        <s:description><xsl:value-of select="text()"/></s:description>    
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="attention">
        <s:name><xsl:value-of select="text()"/></s:name>    
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="town">
        <s:addressLocality><xsl:value-of select="text()"/></s:addressLocality>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="countrycode">
        <s:addressCountry><xsl:value-of select="text()"/></s:addressCountry>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="postalcode">
        <s:postalCode><xsl:value-of select="text()"/></s:postalCode>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="tel">
        <s:telephone><xsl:value-of select="text()"/></s:telephone>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="*[self::email or self::emails]/txemail">
        <s:email><xsl:value-of select="text()"/></s:email>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="fax">
        <s:faxNumber><xsl:value-of select="text()"/></s:faxNumber>
    </xsl:template>
    
    <xsl:template match="grseq[tigrseq[contains(., 'OBJECT OF THE CONTRACT')]]">
        <xsl:apply-templates mode="contractObject"/>
    </xsl:template>
    
    <xsl:template mode="contractObject" match="marklist/mlioccur[timark[contains(lower-case(.), 'title attributed to the contract by the contracting authority')]]/txtmark/p">
        <xsl:param name="lang" tunnel="yes"/>
        <dcterms:title xml:lang="{$lang}"><xsl:value-of select="."/></dcterms:title>
    </xsl:template>
    
    <xsl:template mode="contractObject" match="marklist/mlioccur[timark[contains(lower-case(.), 'short description of the contract or purchase(s)')]]/txtmark">
        <xsl:param name="lang" tunnel="yes"/>
        <dcterms:description xml:lang="{$lang}"><xsl:value-of select="p"/></dcterms:description>
    </xsl:template>
    
    <xsl:template mode="contractObject" match="marklist/mlioccur[timark[contains(lower-case(.), 'total final value of contract')]]/txtmark">
        <pc:aggreedPrice>
            <s:PriceSpecification rdf:about="{f:getClassInstanceURI('Price specification')}">
                <xsl:apply-templates mode="contractPrice"/>
            </s:PriceSpecification>
        </pc:aggreedPrice>
    </xsl:template>
    
    <xsl:template mode="contractPrice" match="p">
        <xsl:variable name="text" select="lower-case(text())"/>
        
        <xsl:if test="matches($text, 'vat')">
            <xsl:choose>
                <xsl:when test="contains($text, 'includ')">
                    <s:valueAddedTaxIncluded rdf:datatype="{$xsd_boolean_uri}">true</s:valueAddedTaxIncluded>
                </xsl:when>
                <xsl:when test="contains($text, 'exclud')">
                    <s:valueAddedTaxIncluded rdf:datatype="{$xsd_boolean_uri}">false</s:valueAddedTaxIncluded> 
                </xsl:when>
            </xsl:choose>
        </xsl:if>
    
        <xsl:if test="matches($text, '^value')">
            <xsl:analyze-string select="$text" regex="^value\s([\d\s]+,?\d*)\s*([a-z]{{3}})$">
                <xsl:matching-substring>
                    <s:price rdf:datatype="{$xsd_decimal_uri}">
                        <xsl:value-of select="f:formatDecimal(regex-group(1))"/>
                    </s:price>
                    <s:priceCurrency>
                        <xsl:value-of select="upper-case(regex-group(2))"/>
                    </s:priceCurrency>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:message>Non-matching price: <xsl:value-of select="$text"/></xsl:message>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:if>
        
        <!-- Price ranges:
            Lowest offer 276 790,57 and highest offer 426 697,93 EUR
            Lowest offer 1 582 918,12 and highest offer 1 674 180,56 PLN
            Lowest offer 3 500 000,00 and highest offer 4 000 000,00 EUR
            Lowest offer 536 906,58 and highest offer 596 356,20 EUR
            -->
        <xsl:if test="matches($text, 'lowest|highest\soffer')">
            <xsl:analyze-string select="$text" regex="^lowest offer ([\d\s]+,?\d*) and highest offer ([\d\s]+,?\d*)\s*([a-z]{{3}})$">
                <xsl:matching-substring>
                    <s:minPrice rdf:datatype="{$xsd_decimal_uri}">
                        <xsl:value-of select="f:formatDecimal(regex-group(1))"/>
                    </s:minPrice>
                    <s:maxPrice rdf:datatype="{$xsd_decimal_uri}">
                        <xsl:value-of select="f:formatDecimal(regex-group(2))"/>
                    </s:maxPrice>
                    <s:priceCurrency>
                        <xsl:value-of select="upper-case(regex-group(3))"/>
                    </s:priceCurrency>
                </xsl:matching-substring>
                <xsl:non-matching-substring>
                    <xsl:message>Non-matching price range: <xsl:value-of select="$text"/></xsl:message>
                </xsl:non-matching-substring>
            </xsl:analyze-string>
        </xsl:if>
    </xsl:template>
    
    <!-- Named templates -->
    
    <xsl:template name="awardCriteriaCombination">
        <xsl:param name="code" as="xsd:string"/>
        <xsl:param name="lang" as="xsd:string" tunnel="yes"/>
        <pc:awardCriterion>
            <pc:CriterionWeighting rdf:about="{f:getClassInstanceURI('Criterion weighting', $code)}">
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
    <xsl:template match="text()|@*" mode="#all"/>

</xsl:stylesheet>