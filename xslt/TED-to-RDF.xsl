<?xml version="1.0" encoding="UTF-8"?>
<!-- 
####################################################################################
#  Author:                      Tomas Posepny
#  Compatible TED XSD release:  R2.0.8.S02.E01
#  Supported XSDs:              F02_CONTRACT, F03_CONTRACT_AWARD
####################################################################################
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:pc="http://purl.org/procurement/public-contracts#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    xmlns:s="http://schema.org/"
    xmlns:pceu="http://purl.org/procurement/public-contracts-eu#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema"
    xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:adms="http://www.w3.org/ns/adms#"
    xmlns:f="http://opendata.cz/xslt/functions#"
    exclude-result-prefixes="f"
    xpath-default-namespace="http://publications.europa.eu/TED_schema/Export"
    version="2.0">

    <xsl:import href="functions.xsl"/>
    <xsl:output encoding="UTF-8" indent="yes" method="xml" normalization-form="NFC"/>

    <!--
    *********************************************************
    *** GLOBAL VARIABLES
    *********************************************************
    -->

    <!-- NAMESPACES -->
    <xsl:variable name="xsd_nm" select="'http://www.w3.org/2001/XMLSchema#'"/>
    <xsl:variable name="pcdt_nm" select="'http://purl.org/procurement/public-contracts-datatypes#'"/>
    <xsl:variable name="pc_nm" select="'http://purl.org/procurement/public-contracts#'"/>
    <xsl:variable name="lod_nm" select="'http://linked.opendata.cz/resource/'"/>
    <xsl:variable name="ted_nm" select="concat($lod_nm, 'ted.europa.eu/')"/>
    <xsl:variable name="ted_business_entity_nm" select="concat($ted_nm, 'business-entity/')"/>
    <xsl:variable name="ted_identifier_nm" select="concat($ted_nm, 'identifier/')"/>
    <xsl:variable name="ted_contract_notice_nm" select="concat($ted_nm, 'contract-notice/')"/>
    <xsl:variable name="ted_pc_nm" select="concat($ted_nm, 'public-contract/')"/>
    <xsl:variable name="ted_postal_address_nm" select="concat($ted_nm, 'postal-address/')"/>
    <xsl:variable name="ted_contact_point_nm" select="concat($ted_nm, 'contact-point/')"/>
    <xsl:variable name="pc_lot_nm" select="concat($pc_uri, '/lot/')"/>
    <xsl:variable name="pc_estimated_price_nm" select="concat($pc_uri, '/estimated-price/')"/>
    <xsl:variable name="pc_weighted_criterion_nm" select="concat($pc_uri, '/weighted_criterion/')"/>
    <xsl:variable name="pc_criterion_weighting_nm" select="concat($pc_uri, '/criterion-weighting/')"/>
    <xsl:variable name="pc_criteria_nm" select="'http://purl.org/procurement/public-contracts-criteria#'"/>

    <!-- URIS -->
    <xsl:variable name="xsd_date_uri" select="concat($xsd_nm, 'date')"/>
    <xsl:variable name="xsd_boolean_uri" select="concat($xsd_nm, 'boolean')"/>
    <xsl:variable name="xsd_duration_uri" select="concat($xsd_nm, 'duration')"/>
    <xsl:variable name="xsd_date_time_uri" select="concat($xsd_nm, 'dateTime')"/>
    <xsl:variable name="xsd_decimal_uri" select="concat($xsd_nm, 'decimal')"/>
    <xsl:variable name="xsd_gYear_uri" select="concat($xsd_nm, 'gYear')"/>
    <xsl:variable name="xsd_gYearMonth_uri" select="concat($xsd_nm, 'gYearMonth')"/>
    <xsl:variable name="xsd_non_negative_integer_uri" select="concat($xsd_nm, 'nonNegativeInteger')"/>
    <xsl:variable name="xsd_time_uri" select="concat($xsd_nm, 'time')"/>
    <xsl:variable name="pcdt_percentage_uri" select="concat($pcdt_nm, 'percentage')"/>
    <xsl:variable name="contract_notice_uri" select="concat($ted_contract_notice_nm,$doc_id)" />
    <xsl:variable name="pc_uri" select="concat($ted_pc_nm, $doc_id)"/>
    <xsl:variable name="pc_location_place_uri" select="concat($pc_uri, '/location-place/1')"/>
    <xsl:variable name="pc_award_criteria_combination_uri_1" select="concat($pc_uri, '/combination-of-contract-award-criteria/1')"/>
    <xsl:variable name="pc_criterion_lowest_price_uri" select="concat($pc_criteria_nm,'LowestPrice')"/>
    <xsl:variable name="pc_identifier_uri_1" select="concat($pc_uri, '/identifier/1')"/>
    <xsl:variable name="pc_documentation_price_uri" select="concat($pc_uri, '/documentation-price/1')"/>
    <xsl:variable name="tenders_opening_uri" select="concat($pc_uri,'/tenders-opening/1')"/>
    <xsl:variable name="tenders_opening_place_uri" select="concat($pc_uri,'/tenders-opening-place/1')"/>
    <xsl:variable name="pc_agreed_price_uri" select="concat($pc_uri, '/agreed-price/1')"/>
    <xsl:variable name="framework_agreement_uri" select="concat($pc_uri, '/framework-agreement/1')"/>


    <!-- OTHER VARIABLES -->
    <xsl:variable name="form_code" select="TED_EXPORT/FORM_SECTION/*[1]/@FORM"/>
    <xsl:variable name="supported_form_codes" select="tokenize('2,3', ',')"/>
    <xsl:variable name="country_code" select="TED_EXPORT/CODED_DATA_SECTION/NOTICE_DATA/ISO_COUNTRY/@VALUE"/>
    <xsl:variable name="lang" select="TED_EXPORT/FORM_SECTION/*[1]/@LG"/>
    <xsl:variable name="doc_id" select="/TED_EXPORT/@DOC_ID"/>
    <xsl:variable name="date_pub" select="f:parseDate(/TED_EXPORT/CODED_DATA_SECTION/REF_OJS/DATE_PUB)" />


    <!--
    *********************************************************
    *** ROOT TEMPLATES
    *********************************************************
    -->

    <!-- ROOT -->
    <xsl:template match="/">
        <rdf:RDF>
            <xsl:if test="$form_code=$supported_form_codes">
                <xsl:apply-templates select="TED_EXPORT/FORM_SECTION/*[1][self::CONTRACT or self::CONTRACT_AWARD][@CATEGORY='ORIGINAL']"/>
            </xsl:if>
        </rdf:RDF>
    </xsl:template>

    <!-- F02 CONTRACT -->
    <xsl:template match="CONTRACT[@CATEGORY='ORIGINAL']">
        <pc:ContractNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:ContractNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}" />
            <xsl:apply-templates select="FD_CONTRACT"/>
        </pc:Contract>
        <!-- tenders opening -->
        <xsl:apply-templates select="FD_CONTRACT/PROCEDURE_DEFINITION_CONTRACT_NOTICE/ADMINISTRATIVE_INFORMATION_CONTRACT_NOTICE/CONDITIONS_FOR_OPENING_TENDERS"/>
    </xsl:template>

    <xsl:template match="FD_CONTRACT">
        <!-- contract kind -->
        <xsl:variable name="contract_kind_uri" select="f:getContractKind(@CTYPE)"/>
        <xsl:if test="$contract_kind_uri">
            <pc:kind rdf:resource="{$contract_kind_uri}"/>
        </xsl:if>
        <xsl:apply-templates select="CONTRACTING_AUTHORITY_INFORMATION"/>
        <xsl:apply-templates select="OBJECT_CONTRACT_INFORMATION"/>
        <xsl:apply-templates select="PROCEDURE_DEFINITION_CONTRACT_NOTICE"/>
    </xsl:template>


    <!-- F03 CONTRACT AWARD -->
    <xsl:template match="CONTRACT_AWARD[@CATEGORY='ORIGINAL']">
        <pc:ContractAwardNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
            <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                <xsl:value-of select="$date_pub"/>
            </pc:publicationDate>
            </xsl:if>
        </pc:ContractAwardNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}" />
            <xsl:apply-templates select="FD_CONTRACT_AWARD"/>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="FD_CONTRACT_AWARD">
        <!-- contract kind -->
        <pc:kind rdf:resource="{f:getContractKind(@CTYPE)}"/>
        <xsl:apply-templates select="CONTRACTING_AUTHORITY_INFORMATION_CONTRACT_AWARD"/>
        <xsl:apply-templates select="OBJECT_CONTRACT_INFORMATION_CONTRACT_AWARD_NOTICE"/>
        <xsl:apply-templates select="PROCEDURE_DEFINITION_CONTRACT_AWARD_NOTICE"/>
        <xsl:choose>
            <xsl:when test="count(AWARD_OF_CONTRACT[LOT_NUMBER]) &gt; 0">
                <xsl:apply-templates select="AWARD_OF_CONTRACT" mode="lot"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="AWARD_OF_CONTRACT"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!--
    *********************************************************
    *** F02 CONTRACT AWARD
    *** SECTION I: CONTRACTING AUTHORITY
    *********************************************************
    -->
    <xsl:template match="CONTRACTING_AUTHORITY_INFORMATION">
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contractingAuthority"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contact"/>
        <xsl:apply-templates select="TYPE_AND_ACTIVITIES_AND_PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"/>
    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contractingAuthority">
        <pc:contractingAuthority>
            <s:Organization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId" select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country" select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>
                
                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE" mode="legalNameAndAddress"/>
                <xsl:apply-templates select="INTERNET_ADDRESSES_CONTRACT/URL_BUYER"/>
                <xsl:apply-templates select="../TYPE_AND_ACTIVITIES_AND_PURCHASING_ON_BEHALF/TYPE_AND_ACTIVITIES"/>
            </s:Organization>
        </pc:contractingAuthority>
    </xsl:template>

    <!-- contract contact -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contact">
        <xsl:call-template name="contractContact"/>
    </xsl:template>


    <!--
    *********************************************************
    *** F02 CONTRACT AWARD
    *** SECTION II: OBJECT OF THE CONTRACT + B_ANNEX
    *********************************************************
    -->
    <xsl:template match="OBJECT_CONTRACT_INFORMATION">
        <xsl:apply-templates select="DESCRIPTION_CONTRACT_INFORMATION"/>
        <xsl:apply-templates select="QUANTITY_SCOPE/NATURE_QUANTITY_SCOPE/COSTS_RANGE_AND_CURRENCY"/>
        <xsl:apply-templates select="PERIOD_WORK_DATE_STARTING"/>
    </xsl:template>

    <xsl:template match="DESCRIPTION_CONTRACT_INFORMATION">
        <xsl:apply-templates select="TITLE_CONTRACT"/>
        <xsl:apply-templates select="LOCATION_NUTS"/>
        <xsl:apply-templates select="F02_FRAMEWORK"/>
        <xsl:apply-templates select="SHORT_CONTRACT_DESCRIPTION"/>
        <xsl:apply-templates select="CPV"/>
        <xsl:apply-templates select="F02_DIVISION_INTO_LOTS/F02_DIV_INTO_LOT_YES/F02_ANNEX_B"/>
    </xsl:template>

    <!-- framework agreement -->
    <xsl:template match="F02_FRAMEWORK">
        <!-- <xsl:call-template name="frameworkAgreement"/>  -->
    </xsl:template>

    <!-- contract part (lot) -->
    <xsl:template match="F02_ANNEX_B">
        <xsl:variable name="lotNumber">
            <xsl:choose>
                <xsl:when test="LOT_NUMBER castable as xsd:integer">
                    <xsl:value-of select="xsd:integer(LOT_NUMBER)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="position()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="pc_lot_uri"><xsl:value-of select="concat($pc_lot_nm, $lotNumber)" /></xsl:variable>
        <pc:lot>
            <pc:Contract rdf:about="{$pc_lot_uri}">
                <xsl:apply-templates select="LOT_TITLE"/>
                <xsl:apply-templates select="LOT_DESCRIPTION"/>
                <xsl:apply-templates select="CPV"/>
                <xsl:apply-templates select="./NATURE_QUANTITY_SCOPE">
                    <xsl:with-param name="pc_lot_uri"><xsl:value-of select="$pc_lot_uri" /></xsl:with-param>
                </xsl:apply-templates>
                <xsl:apply-templates select="PERIOD_WORK_DATE_STARTING"/>
            </pc:Contract>
        </pc:lot>
    </xsl:template>

    <!-- estimated price -->
    <xsl:template match="QUANTITY_SCOPE/NATURE_QUANTITY_SCOPE/COSTS_RANGE_AND_CURRENCY">
        <pc:estimatedPrice>
            <s:PriceSpecification rdf:about="{concat($pc_estimated_price_nm, position())}">
                <xsl:apply-templates select="VALUE_COST"/>
                <xsl:apply-templates select="RANGE_VALUE_COST"/>
                <xsl:call-template name="currency">
                    <xsl:with-param name="currencyCode" select="@CURRENCY"/>
                </xsl:call-template>
                <s:valueAddedTaxIncluded rdf:datatype="{$xsd_boolean_uri}">false</s:valueAddedTaxIncluded>
            </s:PriceSpecification>
        </pc:estimatedPrice>
    </xsl:template>
    
    <!-- lot estimated price -->
    <xsl:template match="F02_ANNEX_B/NATURE_QUANTITY_SCOPE/COSTS_RANGE_AND_CURRENCY">
        <xsl:param name="pc_lot_uri" />
        <pc:estimatedPrice>
            <s:PriceSpecification rdf:about="{concat($pc_lot_uri,'/estimated-price')}">
                <xsl:apply-templates select="VALUE_COST"/>
                <xsl:apply-templates select="RANGE_VALUE_COST"/>
                <xsl:call-template name="currency">
                    <xsl:with-param name="currencyCode" select="@CURRENCY"/>
                </xsl:call-template>
                <s:valueAddedTaxIncluded rdf:datatype="{$xsd_boolean_uri}">false</s:valueAddedTaxIncluded>
            </s:PriceSpecification>
        </pc:estimatedPrice>
    </xsl:template>

    <!-- contract expected duration -->
    <xsl:template match="PERIOD_WORK_DATE_STARTING">
        <xsl:apply-templates select="DAYS"/>
        <xsl:apply-templates select="MONTHS"/>
        <xsl:apply-templates select="INTERVAL_DATE"/>
    </xsl:template>

    <!-- duration in days -->
    <xsl:template match="DAYS">
        <xsl:variable name="duration" select="f:getDuration(text(), 'D')"/>
        <xsl:call-template name="getDuration">
            <xsl:with-param name="duration" select="$duration"/>
        </xsl:call-template>
    </xsl:template>

    <!-- duration in months -->
    <xsl:template match="MONTHS">
        <xsl:variable name="duration" select="f:getDuration(text(), 'M')"/>
        <xsl:call-template name="getDuration">
            <xsl:with-param name="duration" select="$duration"/>
        </xsl:call-template>
    </xsl:template>

    <!-- duration as start date and estimated end date -->
    <xsl:template match="INTERVAL_DATE">
        <xsl:apply-templates select="START_DATE"/>
        <xsl:apply-templates select="END_DATE"/>
    </xsl:template>

    <!-- interval start date -->
    <xsl:template match="START_DATE">
        <xsl:call-template name="getDateProperty">
            <xsl:with-param name="property">pc:startDate</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- interval estimated end date -->
    <xsl:template match="END_DATE">
        <xsl:call-template name="getDateProperty">
            <xsl:with-param name="property">pc:estimatedEndDate</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
    *********************************************************
    *** F02 CONTRACT AWARD 
    *** SECTION IV: PROCEDURE
    *********************************************************
    -->
    <xsl:template match="PROCEDURE_DEFINITION_CONTRACT_NOTICE">
        <xsl:apply-templates select="TYPE_OF_PROCEDURE/TYPE_OF_PROCEDURE_DETAIL_FOR_CONTRACT_NOTICE"/>
        <xsl:apply-templates select="AWARD_CRITERIA_CONTRACT_NOTICE_INFORMATION/AWARD_CRITERIA_DETAIL"/>
        <xsl:apply-templates select="ADMINISTRATIVE_INFORMATION_CONTRACT_NOTICE"/>
    </xsl:template>

    <xsl:template match="ADMINISTRATIVE_INFORMATION_CONTRACT_NOTICE">
        <xsl:apply-templates select="FILE_REFERENCE_NUMBER"/>
        <xsl:apply-templates select="CONDITIONS_OBTAINING_SPECIFICATIONS"/>
        <xsl:apply-templates select="RECEIPT_LIMIT_DATE"/>
        <xsl:apply-templates select="MINIMUM_TIME_MAINTAINING_TENDER"/>
    </xsl:template>

    <xsl:template match="CONDITIONS_OBTAINING_SPECIFICATIONS">
        <xsl:apply-templates select="TIME_LIMIT"/>
        <xsl:apply-templates select="PAYABLE_DOCUMENTS/DOCUMENT_COST"/>
    </xsl:template>

    <!-- contract procedure type -->
    <xsl:template match="TYPE_OF_PROCEDURE_DETAIL_FOR_CONTRACT_NOTICE">
        <xsl:call-template name="procedureType">
            <xsl:with-param name="ptElementName" select="local-name(*)"/>
        </xsl:call-template>
    </xsl:template>

    <!-- contract criteria -->
    <xsl:template match="AWARD_CRITERIA_DETAIL[LOWEST_PRICE or MOST_ECONOMICALLY_ADVANTAGEOUS_TENDER/CRITERIA_STATED_BELOW]">
        <pc:awardCriteriaCombination>
            <pc:AwardCriteriaCombination rdf:about="{$pc_award_criteria_combination_uri_1}">
                <xsl:apply-templates select="LOWEST_PRICE|MOST_ECONOMICALLY_ADVANTAGEOUS_TENDER/CRITERIA_STATED_BELOW/CRITERIA_DEFINITION"/>
            </pc:AwardCriteriaCombination>
        </pc:awardCriteriaCombination>
    </xsl:template>

    <!-- contract documentation request deadline -->
    <xsl:template match="TIME_LIMIT">
        <xsl:call-template name="getDateTimeProperty">
            <xsl:with-param name="property">pc:documentationRequestDeadline</xsl:with-param>
            <xsl:with-param name="object" select="f:getDateTime(YEAR, MONTH, DAY, TIME)"/>
        </xsl:call-template>
    </xsl:template>

    <!-- contract documentation price -->
    <xsl:template match="PAYABLE_DOCUMENTS/DOCUMENT_COST">
        <pc:documentationPrice>
            <s:PriceSpecification rdf:about="{$pc_documentation_price_uri}">
                <xsl:call-template name="priceValue">
                    <xsl:with-param name="value" select="@FMTVAL"/>
                </xsl:call-template>
                <xsl:call-template name="currency">
                    <xsl:with-param name="currencyCode" select="@CURRENCY"/>
                </xsl:call-template>
            </s:PriceSpecification>
        </pc:documentationPrice>
    </xsl:template>

    <!-- contract tender deadline -->
    <xsl:template match="RECEIPT_LIMIT_DATE">
        <xsl:call-template name="getDateTimeProperty">
            <xsl:with-param name="property">pc:tenderDeadline</xsl:with-param>
            <xsl:with-param name="object" select="f:getDateTime(YEAR, MONTH, DAY, TIME)"/>
        </xsl:call-template>
    </xsl:template>

    <!-- tender maintenance duration -->
    <xsl:template match="MINIMUM_TIME_MAINTAINING_TENDER">
        <xsl:if test="(PERIOD_DAY and matches(PERIOD_DAY/text(), '^\d+$')) or (PERIOD_MONTH and matches(PERIOD_MONTH/text(), '^\d+$'))">
            <pc:tenderMaintenanceDuration rdf:datatype="{$xsd_duration_uri}">
                <xsl:apply-templates select="PERIOD_DAY"/>
                <xsl:apply-templates select="PERIOD_MONTH"/>
            </pc:tenderMaintenanceDuration>
        </xsl:if>
    </xsl:template>

    <xsl:template match="PERIOD_DAY">
        <xsl:value-of select="f:getDuration(text(), 'D')"/>
    </xsl:template>

    <xsl:template match="PERIOD_MONTH">
        <xsl:value-of select="f:getDuration(text(), 'M')"/>
    </xsl:template>

    <!-- tenders opening (is outside of Contract element!) -->
    <xsl:template match="CONDITIONS_FOR_OPENING_TENDERS">
        <xsl:if test="DATE_TIME|PLACE_OPENING">
            <pc:TendersOpening rdf:about="{$tenders_opening_uri}">
                <pc:contract rdf:resource="{$pc_uri}"/>
                <xsl:apply-templates select="DATE_TIME"/>
                <xsl:apply-templates select="PLACE_OPENING"/>
            </pc:TendersOpening>
        </xsl:if>
    </xsl:template>

    <!-- tenders opening date -->
    <xsl:template match="CONDITIONS_FOR_OPENING_TENDERS/DATE_TIME">
        <xsl:choose>
            <xsl:when test="YEAR/text() and MONTH/text() and DAY/text() and TIME/text()">
                <xsl:call-template name="getDateTimeProperty">
                    <xsl:with-param name="property">dcterms:date</xsl:with-param>
                    <xsl:with-param name="object" select="f:getDateTime(YEAR, MONTH, DAY, TIME)"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:when test="TIME/text()">
                <dcterms:temporal rdf:datatype="{$xsd_time_uri}">
                    <xsl:value-of select="f:getTime(TIME)"/>
                </dcterms:temporal>
            </xsl:when>
        </xsl:choose>
    </xsl:template>

    <!-- tenders opening place -->
    <xsl:template match="CONDITIONS_FOR_OPENING_TENDERS/PLACE_OPENING">
        <s:location>
            <s:Place rdf:about="{$tenders_opening_place_uri}">
                <xsl:call-template name="postalAddress"/>
                <xsl:apply-templates select="PLACE_NOT_STRUCTURED"/>
            </s:Place>
        </s:location>
    </xsl:template>

    <xsl:template match="PLACE_NOT_STRUCTURED">
        <s:description>
            <xsl:value-of select="normalize-space(.)"/>
        </s:description>
    </xsl:template>


    <!--
    *********************************************************
    *** F03 CONTRACT AWARD
    *** SECTION I: CONTRACTING AUTHORITY
    *********************************************************
    -->
    <xsl:template match="CONTRACTING_AUTHORITY_INFORMATION_CONTRACT_AWARD">
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD" mode="contractingAuthority"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD" mode="contact"/>
        <xsl:apply-templates select="TYPE_AND_ACTIVITIES_AND_PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"/>
    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD" mode="contractingAuthority">
        <pc:contractingAuthority>
            <s:Organization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId" select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country" select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>
                
                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE" mode="legalNameAndAddress"/>
                <xsl:apply-templates select="INTERNET_ADDRESSES_CONTRACT_AWARD/URL_BUYER"/>
                <xsl:apply-templates select="../TYPE_AND_ACTIVITIES_AND_PURCHASING_ON_BEHALF/TYPE_AND_ACTIVITIES"/>
            </s:Organization>
        </pc:contractingAuthority>
    </xsl:template>

    <!-- contract contact -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD" mode="contact">
        <xsl:call-template name="contractContact"/>
    </xsl:template>


    <!--
    *********************************************************
    *** F03 CONTRACT AWARD
    *** SECTION II: OBJECT OF THE CONTRACT
    *********************************************************
    -->
    <xsl:template match="OBJECT_CONTRACT_INFORMATION_CONTRACT_AWARD_NOTICE">
        <xsl:apply-templates select="DESCRIPTION_AWARD_NOTICE_INFORMATION"/>
        <xsl:apply-templates select="TOTAL_FINAL_VALUE/COSTS_RANGE_AND_CURRENCY_WITH_VAT_RATE"/>
    </xsl:template>

    <xsl:template match="DESCRIPTION_AWARD_NOTICE_INFORMATION">
        <xsl:apply-templates select="TITLE_CONTRACT"/>
        <xsl:apply-templates select="LOCATION_NUTS"/>
        <xsl:apply-templates select="NOTICE_INVOLVES_DESC/CONCLUSION_FRAMEWORK_AGREEMENT"/>
        <xsl:apply-templates select="SHORT_CONTRACT_DESCRIPTION"/>
        <xsl:apply-templates select="CPV"/>
    </xsl:template>

    <xsl:template match="NOTICE_INVOLVES_DESC">
        <xsl:apply-templates select="CONCLUSION_FRAMEWORK_AGREEMENT"/>
        <xsl:apply-templates select="CONTRACTS_DPS"/>
    </xsl:template>

    <xsl:template match="CONCLUSION_FRAMEWORK_AGREEMENT">
        <!-- <xsl:call-template name="frameworkAgreement"/> -->
    </xsl:template>

    <xsl:template match="CONTRACTS_DPS">
        <!-- TODO: DPS -->
    </xsl:template>

    <!-- contract agreed price -->
    <xsl:template match="TOTAL_FINAL_VALUE/COSTS_RANGE_AND_CURRENCY_WITH_VAT_RATE">
        <pc:agreedPrice>
            <xsl:call-template name="price">
                <xsl:with-param name="priceUri" select="$pc_agreed_price_uri"/>
            </xsl:call-template>
        </pc:agreedPrice>
    </xsl:template>


    <!--
    *********************************************************
    *** F03 CONTRACT AWARD
    *** SECTION IV: PROCEDURE
    *********************************************************
    -->
    <xsl:template match="PROCEDURE_DEFINITION_CONTRACT_AWARD_NOTICE">
        <xsl:apply-templates select="TYPE_OF_PROCEDURE_DEF"/>
        <xsl:apply-templates select="AWARD_CRITERIA_CONTRACT_AWARD_NOTICE_INFORMATION/AWARD_CRITERIA_DETAIL_F03"/>
        <xsl:apply-templates select="ADMINISTRATIVE_INFORMATION_CONTRACT_AWARD/FILE_REFERENCE_NUMBER"/>
    </xsl:template>

    <!-- contract procedure type -->
    <xsl:template match="TYPE_OF_PROCEDURE_DEF">
        <xsl:call-template name="procedureType">
            <xsl:with-param name="ptElementName" select="local-name(*)"/>
        </xsl:call-template>
    </xsl:template>

    <!-- contract criteria -->
    <xsl:template match="AWARD_CRITERIA_DETAIL_F03">
        <pc:awardCriteriaCombination>
            <pc:AwardCriteriaCombination rdf:about="{$pc_award_criteria_combination_uri_1}">
                <xsl:apply-templates select="LOWEST_PRICE|MOST_ECONOMICALLY_ADVANTAGEOUS_TENDER_SHORT/CRITERIA_DEFINITION"/>
            </pc:AwardCriteriaCombination>
        </pc:awardCriteriaCombination>
    </xsl:template>


    <!--
    *********************************************************
    *** F03 CONTRACT AWARD
    *** SECTION V: AWARD OF CONTRACT
    *********************************************************
    -->

    <!-- contract part (lot) with awarded tender -->
    <xsl:template match="AWARD_OF_CONTRACT" mode="lot">
        <xsl:for-each select="LOT_NUMBER">
            <xsl:variable name="position" select="position()"/>
            <xsl:variable name="lotNumber">
                <xsl:choose>
                    <xsl:when test="text() castable as xsd:integer">
                        <xsl:value-of select="xsd:integer(text())"/>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="position()"/>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:variable>
            <pc:lot>
                <pc:Contract rdf:about="{concat($pc_lot_nm, $lotNumber)}">
                    <xsl:apply-templates select="../CONTRACT_TITLE[$position]"/>
                    <xsl:apply-templates select="../CONTRACT_AWARD_DATE"/>
                    <xsl:apply-templates select="../OFFERS_RECEIVED_NUMBER"/>
                    <xsl:call-template name="awardedTender">
                        <xsl:with-param name="awardNode" select=".."/>
                        <xsl:with-param name="contractUri" select="concat($pc_lot_nm, $lotNumber)"/>
                        <xsl:with-param name="lotNumber" select="text()"/>
                    </xsl:call-template>
                </pc:Contract>
            </pc:lot>
        </xsl:for-each>
    </xsl:template>

    <!-- awarded tender -->
    <xsl:template match="AWARD_OF_CONTRACT">
        <xsl:choose>
            <xsl:when test="LOT_NUMBER">
                <xsl:apply-templates select="." mode="lot"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="CONTRACT_AWARD_DATE"/>
                <xsl:apply-templates select="OFFERS_RECEIVED_NUMBER"/>
                <xsl:call-template name="awardedTender">
                    <xsl:with-param name="awardNode" select="."/>
                    <xsl:with-param name="contractUri" select="$pc_uri"/>
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- contract award date -->
    <xsl:template match="CONTRACT_AWARD_DATE">
        <xsl:call-template name="getDateProperty">
            <xsl:with-param name="property">pc:awardDate</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- number of received tenders -->
    <xsl:template match="OFFERS_RECEIVED_NUMBER">
        <pc:numberOfTenders rdf:datatype="{$xsd_non_negative_integer_uri}">
            <xsl:value-of select="text()"/>
        </pc:numberOfTenders>
    </xsl:template>

    <!-- tenderer info -->
    <xsl:template match="CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME">
        <xsl:call-template name="basicBusinessEntity"/>
    </xsl:template>

    <!-- tender offered price -->
    <xsl:template match="COSTS_RANGE_AND_CURRENCY_WITH_VAT_RATE" mode="offeredPrice">
        <xsl:param name="tenderUri"/>
        <pc:offeredPrice>
            <xsl:call-template name="price">
                <xsl:with-param name="priceUri" select="concat($tenderUri, '/offered-price/1')"/>
            </xsl:call-template>
        </pc:offeredPrice>
    </xsl:template>


    <!--
    *********************************************************
    *** NAMED TEMPLATES
    *********************************************************
    -->

    <xsl:template name="legalName">
        <s:legalName>
            <xsl:value-of select="normalize-space(ORGANISATION/OFFICIALNAME/text())"/>
        </s:legalName>
    </xsl:template>

    <xsl:template name="postalAddress">
        <xsl:if test="(ADDRESS|TOWN|POSTAL_CODE|COUNTRY)/text()">
            <s:address>
                <s:PostalAddress rdf:about="{concat($ted_postal_address_nm, f:getUuid())}">
                    <xsl:apply-templates select="ADDRESS"/>
                    <xsl:apply-templates select="TOWN"/>
                    <xsl:apply-templates select="POSTAL_CODE"/>
                    <xsl:apply-templates select="COUNTRY"/>
                </s:PostalAddress>
            </s:address>
        </xsl:if>
    </xsl:template>

    <xsl:template name="contractContact">
        <xsl:if test="CA_CE_CONCESSIONAIRE_PROFILE/(CONTACT_POINT|ATTENTION|(E_MAILS/E_MAIL)|PHONE|FAX)/text()">
            <pc:contact>
                <s:ContactPoint rdf:about="{concat($ted_contact_point_nm, f:getUuid())}">
                    <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE/CONTACT_POINT"/>
                    <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE/ATTENTION"/>
                    <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE/PHONE"/>
                    <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE/E_MAILS/E_MAIL"/>
                    <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE/FAX"/>
                </s:ContactPoint>
            </pc:contact>
        </xsl:if>
    </xsl:template>

    <xsl:template name="description">
        <xsl:if test="text()">
        <dcterms:description xml:lang="{$lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:description>
        </xsl:if>
    </xsl:template>

    <xsl:template name="price">
        <xsl:param name="priceUri"/>
        <xsl:variable name="isTaxIncluded">
            <xsl:choose>
                <xsl:when test="INCLUDING_VAT">
                    <xsl:value-of select="'true'"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="'false'"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <s:PriceSpecification rdf:about="{$priceUri}">
            <xsl:apply-templates select="VALUE_COST"/>
            <xsl:apply-templates select="RANGE_VALUE_COST"/>
            <xsl:call-template name="currency">
                <xsl:with-param name="currencyCode" select="@CURRENCY"/>
            </xsl:call-template>
            <s:valueAddedTaxIncluded rdf:datatype="{$xsd_boolean_uri}">
                <xsl:value-of select="$isTaxIncluded"/>
            </s:valueAddedTaxIncluded>
        </s:PriceSpecification>
    </xsl:template>

    <xsl:template name="priceValue">
        <xsl:param name="value"/>
        <xsl:if test="$value">
        <s:price rdf:datatype="{$xsd_decimal_uri}">
            <xsl:value-of select="$value"/>
        </s:price>
        </xsl:if>
    </xsl:template>

    <xsl:template name="currency">
        <xsl:param name="currencyCode"/>
        <s:priceCurrency>
            <xsl:value-of select="$currencyCode"/>
        </s:priceCurrency>
    </xsl:template>

    <xsl:template name="procedureType">
        <xsl:param name="ptElementName"/>
        <xsl:variable name="procedure_type_uri" select="f:getProcedureType($ptElementName)"/>
        <xsl:if test="$procedure_type_uri">
            <pc:procedureType rdf:resource="{$procedure_type_uri}"/>
        </xsl:if>
    </xsl:template>

    <xsl:template name="awardCriterion">
        <xsl:param name="isLowestPrice" as="xsd:boolean"/>
        <xsl:param name="name"/>
        <xsl:param name="weight"/>
        <xsl:param name="id" required="yes"/>
        <pc:awardCriterion>
            <pc:CriterionWeighting rdf:about="{concat($pc_criterion_weighting_nm, $id)}">
                <xsl:choose>
                    <xsl:when test="$isLowestPrice = true()">
                        <pc:weightedCriterion rdf:resource="{$pc_criterion_lowest_price_uri}"/>
                        <xsl:call-template name="criterionWeight">
                            <xsl:with-param name="weight" select="100"/>
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <pc:weightedCriterion>
                            <skos:Concept rdf:about="{concat($pc_weighted_criterion_nm, $id)}">
                                <skos:prefLabel xml:lang="{$lang}">
                                    <xsl:value-of select="$name"/>
                                </skos:prefLabel>
                            </skos:Concept>
                            <!--
                                <skos:inScheme rdf:resource="{$pc_criteria_nm}"/>
                                <skos:topConceptOf rdf:resource="{$pc_criteria_nm}"/>
                            </skos:Concept>
                            -->
                        </pc:weightedCriterion>
                        <xsl:call-template name="criterionWeight">
                            <xsl:with-param name="weight" select="$weight"/>
                        </xsl:call-template>
                    </xsl:otherwise>
                </xsl:choose>
            </pc:CriterionWeighting>
        </pc:awardCriterion>
    </xsl:template>

    <xsl:template name="criterionWeight">
        <xsl:param name="weight"/>
        <xsl:if test="$weight">
            <pc:criterionWeight rdf:datatype="{$pcdt_percentage_uri}">
                <xsl:value-of select="$weight"/>
            </pc:criterionWeight>
        </xsl:if>
    </xsl:template>

    <xsl:template name="awardedTender">
        <xsl:param name="awardNode" as="node()"/>
        <xsl:param name="contractUri"/>
        <xsl:param name="lotNumber"/>
        <xsl:variable name="tenderIndex">
            <xsl:choose>
                <xsl:when test="$lotNumber">
                    <xsl:number count="AWARD_OF_CONTRACT[LOT_NUMBER = $lotNumber]"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:number count="AWARD_OF_CONTRACT[not(LOT_NUMBER)]"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tenderUri" select="concat($contractUri, '/tender/', $tenderIndex)"/>
        <pc:awardedTender>
            <pc:Tender rdf:about="{$tenderUri}">
                <xsl:choose>
                    <xsl:when test="$awardNode/ECONOMIC_OPERATOR_NAME_ADDRESS/CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME">
                        <pc:bidder>
                            <xsl:apply-templates select="$awardNode/ECONOMIC_OPERATOR_NAME_ADDRESS/CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME"/>
                        </pc:bidder>
                    </xsl:when>
                    <xsl:otherwise>
                        <pc:bidder rdf:resource="{concat($ted_business_entity_nm, f:getUuid())}"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates select="$awardNode/CONTRACT_VALUE_INFORMATION/COSTS_RANGE_AND_CURRENCY_WITH_VAT_RATE" mode="offeredPrice">
                    <xsl:with-param name="tenderUri" select="$tenderUri"/>
                </xsl:apply-templates>
            </pc:Tender>
        </pc:awardedTender>
    </xsl:template>

    <xsl:template name="basicBusinessEntity">
        <s:Organization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
            <xsl:call-template name="organizationId">
                <xsl:with-param name="nationalId" select="ORGANISATION/NATIONALID"/>
                <xsl:with-param name="country" select="(COUNTRY/@VALUE, $country_code)[1]"/>
            </xsl:call-template>
            
            <xsl:call-template name="legalName"/>
            <xsl:call-template name="postalAddress"/>
            <xsl:call-template name="contactPoint"/>
        </s:Organization>
    </xsl:template>

    <xsl:template name="contactPoint">
        <xsl:if test="(PHONE|E_MAILS/E_MAIL|FAX)/text()">
            <s:contactPoint>
                <s:ContactPoint rdf:about="{concat($ted_contact_point_nm, f:getUuid())}">
                    <xsl:apply-templates select="PHONE"/>
                    <xsl:apply-templates select="E_MAILS/E_MAIL"/>
                    <xsl:apply-templates select="FAX"/>
                </s:ContactPoint>
            </s:contactPoint>
        </xsl:if>
    </xsl:template>

    <xsl:template name="frameworkAgreement">
        <pc:frameworkAgreement>
            <pc:FrameworkAgreement rdf:about="{$framework_agreement_uri}">
                <pc:expectedNumberOfOperators>
                    <xsl:choose>
                        <xsl:when test="SINGLE_OPERATOR">
                            <!-- TODO: -->
                        </xsl:when>
                        <xsl:when test="SEVERAL_OPERATORS">
                            <!-- TODO: -->
                        </xsl:when>
                        <xsl:otherwise>
                            <!-- TODO: -->
                        </xsl:otherwise>
                    </xsl:choose>
                </pc:expectedNumberOfOperators>
            </pc:FrameworkAgreement>
        </pc:frameworkAgreement>
    </xsl:template>
    
    <!-- Generalized date template, handles missing day information -->
    <xsl:template name="getDateProperty">
        <xsl:param name="property"/>
        <xsl:element name="{$property}">
            <xsl:choose>
                <xsl:when test="empty(DAY/text()) and empty(MONTH/text())">
                    <xsl:attribute name="rdf:datatype" select="$xsd_gYear_uri"/>
                    <xsl:value-of select="f:getDate(YEAR)"/>
                </xsl:when>
                <xsl:when test="empty(DAY/text())">
                    <xsl:attribute name="rdf:datatype" select="$xsd_gYearMonth_uri"/>
                    <xsl:value-of select="f:getDate(YEAR, MONTH)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:attribute name="rdf:datatype" select="$xsd_date_uri"/>
                    <xsl:value-of select="f:getDate(YEAR, MONTH, DAY)"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    
    <xsl:template name="getDuration">
        <xsl:param name="duration"/>
        <pc:duration>
            <xsl:choose>
                <xsl:when test="not(empty($duration))">
                    <xsl:attribute name="rdf:datatype" select="$xsd_duration_uri"/>
                    <xsl:value-of select="$duration"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </pc:duration>
    </xsl:template>
    
    <xsl:template name="getDatatypeProperty">
        <xsl:param name="property"/>
        <xsl:param name="object"/>
        <xsl:param name="datatype_uri"/>
        <xsl:param name="datatype_regex"/>
        
        <xsl:if test="not(empty($object))">
            <xsl:element name="{$property}">
                <xsl:if test="matches($object, $datatype_regex)">
                    <xsl:attribute name="rdf:datatype" select="$datatype_uri"/>
                </xsl:if>
                <xsl:value-of select="$object"/>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    
    <xsl:template name="getDateTimeProperty">
        <xsl:param name="property"/>
        <xsl:param name="object"/>
        <xsl:call-template name="getDatatypeProperty">
            <xsl:with-param name="property" select="$property"/>
            <xsl:with-param name="object" select="$object"/>
            <xsl:with-param name="datatype_regex">\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}</xsl:with-param>
            <xsl:with-param name="datatype_uri" select="$xsd_date_time_uri"/>
        </xsl:call-template>
    </xsl:template>
    
    <xsl:template name="organizationId">
        <xsl:param name="nationalId"/>
        <xsl:param name="country"/>
        
        <xsl:if test="not(empty($nationalId))">
            <adms:identifier>
                <adms:Identifier rdf:about="{concat($ted_identifier_nm, f:getUuid())}">
                    <skos:notation><xsl:value-of select="f:getBusinessEntityId($country, $nationalId)"/></skos:notation>
                </adms:Identifier>
            </adms:identifier>
        </xsl:if>
    </xsl:template>

    <!--
    *********************************************************
    *** COMMON TEMPLATES
    *********************************************************
    -->

    <!-- contracting authority name and address -->
    <xsl:template match="CA_CE_CONCESSIONAIRE_PROFILE" mode="legalNameAndAddress">
        <xsl:call-template name="legalName"/>
        <xsl:call-template name="postalAddress"/>
    </xsl:template>

    <!-- contracting authority buyer profile url -->
    <xsl:template match="URL_BUYER">
        <xsl:if test="text()">
            <xsl:for-each select="tokenize(text(),' ')">
                <pc:buyerProfile>
                    <xsl:value-of select="."/>
                </pc:buyerProfile>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <!-- contracting authority kind and main activity  -->
    <xsl:template match="TYPE_AND_ACTIVITIES">
        <xsl:if test="TYPE_OF_CONTRACTING_AUTHORITY">
            <xsl:variable name="authority_kind_uri" select="f:getAuthorityKind(TYPE_OF_CONTRACTING_AUTHORITY/@VALUE)"/>
            <xsl:if test="$authority_kind_uri">
                <pc:authorityKind rdf:resource="{$authority_kind_uri}"/>
            </xsl:if>
        </xsl:if>
        <xsl:if test="TYPE_OF_ACTIVITY">
            <xsl:variable name="authority_activity_uri" select="f:getAuthorityActivity(TYPE_OF_ACTIVITY[1]/@VALUE)"/>
            <xsl:if test="$authority_activity_uri">
                <pc:mainActivity rdf:resource="{$authority_activity_uri}"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!-- on behalf of -->
    <xsl:template match="CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY">
        <pc:onBehalfOf>
            <xsl:call-template name="basicBusinessEntity"/>
        </pc:onBehalfOf>
    </xsl:template>

    <xsl:template match="ADDRESS">
        <xsl:if test="text()">
            <s:streetAddress>
                <xsl:value-of select="text()"/>
            </s:streetAddress>
        </xsl:if>
    </xsl:template>

    <xsl:template match="TOWN">
        <xsl:if test="text()">
            <s:addressLocality>
                <xsl:value-of select="text()"/>
            </s:addressLocality>
        </xsl:if>
    </xsl:template>

    <xsl:template match="POSTAL_CODE">
        <xsl:if test="text()">
            <s:postalCode>
                <xsl:value-of select="text()"/>
            </s:postalCode>
        </xsl:if>
    </xsl:template>

    <xsl:template match="COUNTRY">
        <xsl:if test="@VALUE">
            <s:addressCountry>
                <xsl:value-of select="@VALUE"/>
            </s:addressCountry>
        </xsl:if>
    </xsl:template>

    <xsl:template match="CONTACT_POINT">
        <xsl:if test="text()">
            <s:name>
                <xsl:value-of select="text()"/>
            </s:name>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ATTENTION">
        <xsl:if test="text()">
            <s:description>
                <xsl:value-of select="text()"/>
            </s:description>
        </xsl:if>
    </xsl:template>

    <xsl:template match="E_MAIL">
        <xsl:if test="text()">
            <s:email>
                <xsl:value-of select="text()"/>
            </s:email>
        </xsl:if>
    </xsl:template>

    <xsl:template match="PHONE">
        <xsl:if test="text()">
            <s:telephone>
                <xsl:value-of select="text()"/>
            </s:telephone>
        </xsl:if>
    </xsl:template>

    <xsl:template match="FAX">
        <xsl:if test="text()">
            <s:faxNumber>
                <xsl:value-of select="text()"/>
            </s:faxNumber>
        </xsl:if>
    </xsl:template>

    <!-- contract title -->
    <xsl:template match="TITLE_CONTRACT|CONTRACT_TITLE|LOT_TITLE">
        <dcterms:title xml:lang="{$lang}">
            <xsl:value-of select="normalize-space(.)"/>
        </dcterms:title>
    </xsl:template>

    <!-- contract location -->
    <xsl:template match="LOCATION_NUTS">
        <xsl:if test="LOCATION">
            <pc:location>
                <s:Place rdf:about="{$pc_location_place_uri}">
                    <s:description>
                        <xsl:value-of select="normalize-space(LOCATION)"/>
                    </s:description>
                    <xsl:if test="NUTS">
                        <pceu:hasParentRegion rdf:resource="{f:getNutsUri(NUTS[1]/@CODE)}"/>
                    </xsl:if>
                </s:Place>
            </pc:location>
        </xsl:if>
    </xsl:template>

    <!-- contract description -->
    <xsl:template match="SHORT_CONTRACT_DESCRIPTION|LOT_DESCRIPTION">
        <xsl:call-template name="description"/>
    </xsl:template>

    <!-- cpv codes -->
    <xsl:template match="CPV">
        <xsl:apply-templates select="CPV_MAIN"/>
        <xsl:apply-templates select="CPV_ADDITIONAL"/>
    </xsl:template>

    <!-- main cpv -->
    <xsl:template match="CPV_MAIN">
        <pc:mainObject rdf:resource="{f:getCpvUri(CPV_CODE/@CODE)}"/>
    </xsl:template>

    <!-- additional cpv -->
    <xsl:template match="CPV_ADDITIONAL">
        <pc:additionalObject rdf:resource="{f:getCpvUri(CPV_CODE/@CODE)}"/>
    </xsl:template>

    <!-- price value -->
    <xsl:template match="VALUE_COST">
        <xsl:call-template name="priceValue">
            <xsl:with-param name="value" select="@FMTVAL"/>
        </xsl:call-template>
    </xsl:template>

    <!-- price range min and max values -->
    <xsl:template match="RANGE_VALUE_COST">
        <s:minPrice rdf:datatype="{$xsd_decimal_uri}">
            <xsl:value-of select="LOW_VALUE/@FMTVAL"/>
        </s:minPrice>
        <s:maxPrice rdf:datatype="{$xsd_decimal_uri}">
            <xsl:value-of select="HIGH_VALUE/@FMTVAL"/>
        </s:maxPrice>
    </xsl:template>

    <!-- criterion lowest price -->
    <xsl:template match="LOWEST_PRICE">
        <xsl:call-template name="awardCriterion">
            <xsl:with-param name="isLowestPrice" select="true()"/>
            <xsl:with-param name="id" select="1"/>
        </xsl:call-template>
    </xsl:template>

    <!-- criterion most economically advantageous tender -->
    <xsl:template match="CRITERIA_DEFINITION">
        <xsl:variable name="id" select="(ORDER_C, position())[1]"/>
        <xsl:call-template name="awardCriterion">
            <xsl:with-param name="isLowestPrice" select="false()"/>
            <xsl:with-param name="name" select="CRITERIA"/>
            <xsl:with-param name="weight" select="WEIGHTING"/>
            <xsl:with-param name="id" select="$id"/>
        </xsl:call-template>
    </xsl:template>

    <!-- contract file identifier -->
    <xsl:template match="FILE_REFERENCE_NUMBER">
        <adms:identifier>
            <adms:Identifier rdf:about="{$pc_identifier_uri_1}">
                <skos:notation>
                    <xsl:value-of select="normalize-space(.)"/>
                </skos:notation>
            </adms:Identifier>
        </adms:identifier>
    </xsl:template>

    <!--
    *********************************************************
    *** EMPTY TEMPLATES
    *********************************************************
    -->
    <xsl:template match="text()|@*"/>

</xsl:stylesheet>