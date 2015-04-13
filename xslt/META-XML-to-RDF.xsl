<?xml version="1.0" encoding="UTF-8"?>
<!-- 
####################################################################################
# Source format documentation:  <ftp://ted.europa.eu/Description_Metaform-v1.03.pdf>

/part/doc[@t = 'O'][CONTRACT[@category = 'orig']]
####################################################################################
 -->
<xsl:stylesheet 
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:pc="http://purl.org/procurement/public-contracts#" 
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"  
    xmlns:s="http://schema.org/"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:gr="http://purl.org/goodrelations/v1#"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#" 
    xmlns:adms="http://www.w3.org/ns/adms#"
    xmlns:f="http://opendata.cz/xslt/functions#"
    xmlns:foaf="http://xmlns.com/foaf/0.1/" 
    xmlns:pceu="http://purl.org/procurement/public-contracts-eu#"
    xmlns:ProcurementRegulations="https://loted2.googlecode.com/svn/trunk/modules/ProcurementRegulations#"
    xmlns:TenderDocuments="https://loted2.googlecode.com/svn/trunk/modules/TenderDocuments#"
    exclude-result-prefixes="f"
    version="2.0">

    <!-- <xsl:import href="META-XML-functions.xsl"/> -->
    <xsl:import href="functions.xsl"/>
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
    
    <xsl:variable name="ted_business_entity_nm" select="concat($ted_nm, 'business-entity/')"/>
    <!-- Templates -->
    
    
    <!--
    *********************************************************
    *** ROOT TEMPLATE
    *********************************************************
    -->
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

   
        
   <!-- <xsl:template match="@ctype">
        <xsl:variable name="contractKind" select="f:getContractKind('',.)"/>
        <xsl:if test="$contractKind">
            <pc:contractKind rdf:resource="{$contractKind}"/>
        </xsl:if>
    </xsl:template>  -->
    
    <xsl:template match="refojs/datepub">
        <dcterms:issued rdf:datatype="{$xsd_date_uri}"><xsl:value-of select="f:parseDateTime(text())"/></dcterms:issued>
    </xsl:template>
    
    <xsl:template match="codifdata">
        <xsl:apply-templates/>
    </xsl:template>
    
    <xsl:template match="sector">
        <xsl:param name="contracting_authority_uri" tunnel="yes"/>
        <pc:contractingAuthority>
            <gr:BusinessEntity rdf:about="{$contracting_authority_uri}">
                <xsl:variable name="authority_kind_uri" select="f:getAuthorityKind('',@code)"/>
                <xsl:if test="$authority_kind_uri">
                    <pc:authorityKind rdf:resource="{$authority_kind_uri}"/>
                </xsl:if>
               
            </gr:BusinessEntity>
        </pc:contractingAuthority>
    </xsl:template>
    
    <xsl:template match="natnotice">
       <!-- <rdf:type rdf:resource="{f:getNoticeType('',@code)}"/> -->
    </xsl:template>
    
    <xsl:template match="market">
        <xsl:variable name="contract_kind_uri" select="f:getContractKind('',@code)"/>
        <xsl:if test="$contract_kind_uri">
            <pc:kind rdf:resource="{$contract_kind_uri}"/>
        </xsl:if>
    </xsl:template>
    
    <xsl:template match="proc">
        <xsl:variable name="procedure_type_uri" select="f:getProcedureType('',@code)"/>
        <xsl:if test="$procedure_type_uri">
            <pc:procedureType rdf:resource="{$procedure_type_uri}"/>
        </xsl:if>
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
            <adms:Identifier rdf:about="{f:getClassInstanceURI('Identifier', f:slugify(text(),'META'))}">
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
            <gr:BusinessEntity rdf:about="{$contracting_authority_uri}"> 
                <xsl:variable name="main_activity_uri" select="f:getAuthorityOrMainActivity('',@code)"/>
                <xsl:if test="$main_activity_uri">
                    <pc:mainActivity rdf:resource="{$main_activity_uri}"/>
                </xsl:if>
          </gr:BusinessEntity>
        </pc:contractingAuthority> 
    </xsl:template>
    
    <xsl:template match="contents">
        <xsl:apply-templates/>
    </xsl:template>
    
    
    <!--  
    *********************************************************
    *** SECTION I: CONTRACTING AUTHORITY
    *********************************************************
    -->
    
    <xsl:template match="grseq[tigrseq[contains(lower-case(.), 'contracting authority')]]">
        <xsl:param name="contracting_authority_uri" tunnel="yes"/>
        <pc:contractingAuthority>
            <gr:BusinessEntity rdf:about="{$contracting_authority_uri}">
                <xsl:apply-templates mode="contractingAuthority"/>
            </gr:BusinessEntity>
        </pc:contractingAuthority>
        <xsl:apply-templates mode="onBehalfOf"/>
    </xsl:template>
    
    <xsl:template mode="contractingAuthority" match="marklist/mlioccur/timark[contains(lower-case(.), 'name, addresses and contact point(s):')]/txtmark">
        <xsl:apply-templates mode="contractingAuthority"/>
     
    </xsl:template>
    
    <xsl:template mode="contractingAuthority" match="p[position() = 1]/addr">
        <xsl:param name="contract_address_uri" tunnel="yes"/>
        <xsl:apply-templates mode="contractingAuthority"/>
        <s:address>
            <s:PostalAddress rdf:about="{$contract_address_uri}">
                <xsl:apply-templates mode="postalAddress"/>
            </s:PostalAddress>
        </s:address>
    </xsl:template>
    
    <xsl:template mode="onBehalfOf" match="marklist/mlioccur/txtmark/p[contains(lower-case(.), 'authorities: yes')]">
        <xsl:param name="contract_address_uri" tunnel="yes"/>
        
        <xsl:if test="./p[position() = 1]/addr/organisation/officialname">
            
        <pc:onBehalfOf>
            <xsl:for-each select="./p/addr">
                <xsl:variable name="uuid"><xsl:value-of select="f:getUuid()"/></xsl:variable>
                <gr:BusinessEntity rdf:about="{concat($ted_business_entity_nm,$uuid)}">
                <xsl:apply-templates mode="behalfEntity"/>
                <xsl:if test="./(address|postalcode|town|countrycode)">
            <s:address>
                <s:PostalAddress rdf:about="{$contract_address_uri}">
                   <xsl:apply-templates mode="behalfAddress"/>
                 </s:PostalAddress>
            </s:address>
                 </xsl:if>
            </gr:BusinessEntity>
                </xsl:for-each>
        </pc:onBehalfOf>
        </xsl:if>
    </xsl:template>
   
    <xsl:template mode="behalfEntity" match="./organisation/officialname">
       <xsl:if test="./text()">
           <gr:legalName><xsl:value-of select="./text()"/></gr:legalName>
       </xsl:if>
   </xsl:template>
   
    <xsl:template mode="behalfAddress" match="./address">
        <xsl:if test=".">
            <s:description><xsl:value-of select="text()"/></s:description>
        </xsl:if>
    </xsl:template>
   
    <xsl:template mode="behalfAddress" match="./town">
        <xsl:if test=".">
            <s:addressLocality><xsl:value-of select="text()"/></s:addressLocality>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="behalfAddress" match="./countrycode">
        <xsl:if test=".">
            <s:addressCountry><xsl:value-of select="text()"/></s:addressCountry>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="behalfAddress" match="./postalcode">
        <xsl:if test=".">
            <s:postalCode><xsl:value-of select="text()"/></s:postalCode>
        </xsl:if>
    </xsl:template>
   
   
   
   
   
   
    <xsl:template mode="contractingAuthority" match="p/txurl">
        <pc:profile><xsl:value-of select="text()"/></pc:profile>
    </xsl:template>
    
    <xsl:template mode="contractingAuthority" match="p[position() = 1]/organisation/officialname">
        <xsl:if test="./text()">
        <gr:legalName><xsl:value-of select="text()"/></gr:legalName>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="contractingAuthority" match="nationalid">
        <adms:identifier>
            <adms:Identifier rdf:about="{f:getClassInstanceURI('Identifier')}">
                <skos:notation><xsl:value-of select="text()"/></skos:notation>
            </adms:Identifier>
        </adms:identifier>    
    </xsl:template>
    
  <!--  <xsl:template mode="contractingAuthority" match="organisation">
        <xsl:if test="./text()">
        <gr:legalName><xsl:value-of select="text()"/></gr:legalName>
        </xsl:if>
    </xsl:template> -->
    
    <xsl:template mode="postalAddress" match="address">
        <xsl:if test=".">
        <s:description><xsl:value-of select="text()"/></s:description>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="attention">
        <xsl:if test=".">
        <s:name><xsl:value-of select="text()"/></s:name>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="town">
        <xsl:if test=".">
        <s:addressLocality><xsl:value-of select="text()"/></s:addressLocality>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="countrycode">
        <xsl:if test=".">
        <s:addressCountry><xsl:value-of select="text()"/></s:addressCountry>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="postalcode">
        <xsl:if test=".">
        <s:postalCode><xsl:value-of select="text()"/></s:postalCode>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="tel">
        <xsl:if test=".">
        <s:telephone><xsl:value-of select="text()"/></s:telephone>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="*[self::email or self::emails]/txemail">
        <xsl:if test=".">
        <s:email><xsl:value-of select="text()"/></s:email>
        </xsl:if>
    </xsl:template>
    
    <xsl:template mode="postalAddress" match="fax">
        <xsl:if test=".">
        <s:faxNumber><xsl:value-of select="text()"/></s:faxNumber>
        </xsl:if>
    </xsl:template>
    
    
    <!--  
    *********************************************************
    *** SECTION II: Object of the Contract
    *********************************************************
    -->
    
    <xsl:template match="grseq[tigrseq[contains(lower-case(.), 'object of the contract')]]">
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
    
    
    <!--  
    *********************************************************
    *** SECTION V: Awarded
    *********************************************************
    -->
    
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