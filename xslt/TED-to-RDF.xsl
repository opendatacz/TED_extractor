<?xml version="1.0" encoding="UTF-8"?>
<!-- 
####################################################################################
#  Author:                      Tomas Posepny
#  Compatible TED XSD release:  R2.0.8.S02.E01
#  Supported XSDs:              F02_CONTRACT, F03_CONTRACT_AWARD, F04_PERIODIC_INDICATIVE_UTILITIES, 
#                               F05_CONTRACT_UTILITIES, F06_CONTRACT_AWARD_UTILITIES, F07_QUALIFICATION_SYSTEM_UTILITIES,
#                               F08_BUYER_PROFILE, F09_SIMPLIFIED_CONTRACT, F15_VOLUNTARY_EX_ANTE_TRANSPARENCY_NOTICE,
#                               F16_PRIOR_INFORMATION_DEFENCE, F17_CONTRACT_DEFENCE, F18_CONTRACT_AWARD_DEFENCE
####################################################################################
 -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:pc="http://purl.org/procurement/public-contracts#"
    xmlns:gr="http://purl.org/goodrelations/v1#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:s="http://schema.org/"
    xmlns:pceu="http://purl.org/procurement/public-contracts-eu#"
    xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:skos="http://www.w3.org/2004/02/skos/core#"
    xmlns:adms="http://www.w3.org/ns/adms#" xmlns:f="http://opendata.cz/xslt/functions#"
    xmlns:pproc="http://contsem.unizar.es/def/sector-publico/pproc#" 
    xmlns:foaf="http://xmlns.com/foaf/0.1/"
    exclude-result-prefixes="f"
    xpath-default-namespace="http://publications.europa.eu/TED_schema/Export" version="2.0">

    <xsl:import href="functions.xsl"/>
    <xsl:output encoding="UTF-8" indent="yes" method="xml" normalization-form="NFC"/>

    <!--
    *********************************************************
    *** GLOBAL VARIABLES
    *********************************************************
    -->

    <!-- NAMESPACES -->
    <xsl:variable name="xsd_nm" select="'http://www.w3.org/2001/XMLSchema#'"/>
    <xsl:variable name="pproc_nm" select="'http://contsem.unizar.es/def/sector-publico/pproc#'"/>
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
    <xsl:variable name="ted_date_interval_nm" select="concat($ted_nm, 'date-interval/')"/>
    <xsl:variable name="pc_lot_nm" select="concat($pc_uri, '/lot/')"/>
    <xsl:variable name="pc_estimated_price_nm" select="concat($pc_uri, '/estimated-price/')"/>
    <xsl:variable name="pc_weighted_criterion_nm" select="concat($pc_uri, '/weighted_criterion/')"/>
    <xsl:variable name="pc_criterion_weighting_nm" select="concat($pc_uri, '/criterion-weighting/')"/>
    <xsl:variable name="pc_criteria_nm"
        select="'http://purl.org/procurement/public-contracts-criteria#'"/>

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
    <xsl:variable name="contract_notice_uri" select="concat($ted_contract_notice_nm,$doc_id)"/>
    <xsl:variable name="pc_uri" select="concat($ted_pc_nm, $doc_id)"/>
    <xsl:variable name="pc_location_place_uri" select="concat($pc_uri, '/location-place/1')"/>
    <xsl:variable name="pc_recurrement_uri" select="concat($pc_uri,'/recurrement-procurement/1')"/>
    <xsl:variable name="pc_award_criteria_combination_uri_1"
        select="concat($pc_uri, '/combination-of-contract-award-criteria/1')"/>
    <xsl:variable name="pc_criterion_lowest_price_uri"
        select="concat($pc_criteria_nm,'LowestPrice')"/>
    <xsl:variable name="pc_identifier_uri_1" select="concat($pc_uri, '/identifier/1')"/>
    <xsl:variable name="pc_documentation_price_uri"
        select="concat($pc_uri, '/documentation-price/1')"/>
    <xsl:variable name="tenders_opening_uri" select="concat($pc_uri,'/tenders-opening/1')"/>
    <xsl:variable name="tenders_opening_place_uri"
        select="concat($pc_uri,'/tenders-opening-place/1')"/>
    <xsl:variable name="pc_agreed_price_uri" select="concat($pc_uri, '/agreed-price/1')"/>
    <xsl:variable name="framework_agreement_uri" select="concat($pc_uri, '/framework-agreement/1')"/>


    <!-- OTHER VARIABLES -->
    <xsl:variable name="form_code" select="TED_EXPORT/FORM_SECTION/*[1]/@FORM"/>
    <xsl:variable name="supported_form_codes" select="tokenize('2,3,4,5,6,7,8,9,15,16,17,18', ',')"/>
    <xsl:variable name="country_code"
        select="TED_EXPORT/CODED_DATA_SECTION/NOTICE_DATA/ISO_COUNTRY/@VALUE"/>
    <xsl:variable name="lang" select="TED_EXPORT/FORM_SECTION/*[1]/@LG"/>
    <xsl:variable name="doc_id" select="/TED_EXPORT/@DOC_ID"/>
    <xsl:variable name="date_pub"
        select="f:parseDate(/TED_EXPORT/CODED_DATA_SECTION/REF_OJS/DATE_PUB)"/>


    <!--
    *********************************************************
    *** ROOT TEMPLATE
    *********************************************************
    -->

    <!-- ROOT -->
    <xsl:template match="/">
        <rdf:RDF>
            <xsl:if test="$form_code=$supported_form_codes">
                <xsl:apply-templates
                    select="TED_EXPORT/FORM_SECTION/*[1][self::CONTRACT or self::CONTRACT_AWARD or self::PERIODIC_INDICATIVE_UTILITIES or self::CONTRACT_UTILITIES or self::CONTRACT_AWARD_UTILITIES or self::QUALIFICATION_SYSTEM_UTILITIES or self::BUYER_PROFILE or self::SIMPLIFIED_CONTRACT or self::VOLUNTARY_EX_ANTE_TRANSPARENCY_NOTICE or self::PRIOR_INFORMATION_DEFENCE or self::CONTRACT_DEFENCE or self::CONTRACT_AWARD_DEFENCE][@CATEGORY='ORIGINAL']"
                />
            </xsl:if>
        </rdf:RDF>
    </xsl:template>



    <!--  
    ******************************************************************************************************************
    *** F02 CONTRACT AWARD
    *** ROOT TEMPLATE
    ******************************************************************************************************************
    -->

    <xsl:template match="CONTRACT[@CATEGORY='ORIGINAL']">
        <pc:ContractNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:ContractNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}"/>
            <xsl:apply-templates select="FD_CONTRACT"/>
        </pc:Contract>
        <!-- tenders opening -->
        <xsl:apply-templates
            select="FD_CONTRACT/PROCEDURE_DEFINITION_CONTRACT_NOTICE/ADMINISTRATIVE_INFORMATION_CONTRACT_NOTICE/CONDITIONS_FOR_OPENING_TENDERS"
        />
    </xsl:template>

    <xsl:template match="FD_CONTRACT">
        <!-- contract kind -->
        <xsl:variable name="contract_kind_uri" select="f:getContractKind(@CTYPE,'')"/>
        <xsl:if test="$contract_kind_uri">
            <pc:kind rdf:resource="{$contract_kind_uri}"/>
        </xsl:if>
        <xsl:apply-templates select="CONTRACTING_AUTHORITY_INFORMATION"/>
        <xsl:apply-templates select="OBJECT_CONTRACT_INFORMATION"/>
        <xsl:apply-templates select="PROCEDURE_DEFINITION_CONTRACT_NOTICE"/>
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
        <xsl:apply-templates
            select="NAME_ADDRESSES_CONTACT_CONTRACT/FURTHER_INFORMATION/CONTACT_DATA"/>
        <xsl:apply-templates
            select="TYPE_AND_ACTIVITIES_AND_PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"
        />
    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contractingAuthority">
        <pc:contractingAuthority>
            <s:Organization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId"
                        select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country"
                        select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>

                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE"
                    mode="legalNameAndAddress"/>
                <xsl:apply-templates select="INTERNET_ADDRESSES_CONTRACT/URL_BUYER"/>
                <!-- TYPE AND ACTIVITIES part -->
                <xsl:apply-templates
                    select="../TYPE_AND_ACTIVITIES_AND_PURCHASING_ON_BEHALF/TYPE_AND_ACTIVITIES"/>
                <!-- TYPE AND ACTIVITIES part -->
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
        <xsl:variable name="pc_lot_uri">
            <xsl:value-of select="concat($pc_lot_nm, $lotNumber)"/>
        </xsl:variable>
        <pc:lot>
            <pc:Contract rdf:about="{$pc_lot_uri}">
                <xsl:apply-templates select="LOT_TITLE"/>
                <xsl:apply-templates select="LOT_DESCRIPTION"/>
                <xsl:apply-templates select="CPV"/>
                <xsl:apply-templates select="./NATURE_QUANTITY_SCOPE">
                    <xsl:with-param name="pc_lot_uri">
                        <xsl:value-of select="$pc_lot_uri"/>
                    </xsl:with-param>
                </xsl:apply-templates>
                <xsl:apply-templates select="PERIOD_WORK_DATE_STARTING"/>
               
            </pc:Contract>
        </pc:lot>
    </xsl:template>

    <!-- estimated price -->
    <xsl:template
        match="QUANTITY_SCOPE/NATURE_QUANTITY_SCOPE/COSTS_RANGE_AND_CURRENCY|NATURE_QUANTITY_SCOPE/COSTS_RANGE_AND_CURRENCY|COSTS_RANGE_AND_CURRENCY">
        <pc:estimatedPrice>
            <s:PriceSpecification rdf:about="{concat($pc_estimated_price_nm, position())}">
                <xsl:apply-templates select="VALUE_COST"/>
                <xsl:apply-templates select="RANGE_VALUE_COST"/>
                <xsl:call-template name="currency">
                    <xsl:with-param name="currencyCode" select="@CURRENCY"/>
                </xsl:call-template>
                <s:valueAddedTaxIncluded rdf:datatype="{$xsd_boolean_uri}"
                    >false</s:valueAddedTaxIncluded>
                <xsl:if test="../MAIN_FINANCIAL_CONDITIONS">
                    <xsl:apply-templates select="../MAIN_FINANCIAL_CONDITIONS"/>  
                </xsl:if>
            </s:PriceSpecification>
        </pc:estimatedPrice>
    </xsl:template>

    <!-- lot estimated price -->
    <xsl:template match="F02_ANNEX_B/NATURE_QUANTITY_SCOPE/COSTS_RANGE_AND_CURRENCY">
        <xsl:param name="pc_lot_uri"/>
        <pc:estimatedPrice>
            <s:PriceSpecification rdf:about="{concat($pc_lot_uri,'/estimated-price')}">
                <xsl:apply-templates select="VALUE_COST"/>
                <xsl:apply-templates select="RANGE_VALUE_COST"/>
                <xsl:call-template name="currency">
                    <xsl:with-param name="currencyCode" select="@CURRENCY"/>
                </xsl:call-template>
                <s:valueAddedTaxIncluded rdf:datatype="{$xsd_boolean_uri}"
                    >false</s:valueAddedTaxIncluded>
            </s:PriceSpecification>
        </pc:estimatedPrice>
    </xsl:template>

    <!-- contract expected duration -->
    <xsl:template match="PERIOD_WORK_DATE_STARTING">
        <xsl:apply-templates select="DAYS"/>
        <xsl:apply-templates select="MONTHS"/>
        <xsl:apply-templates select="INTERVAL_DATE"/>
    </xsl:template>

    <!-- contract expected duration -->
    <xsl:template match="PERIOD_WORK_DATE_STARTING" mode="F04">
        <xsl:apply-templates select="DAYS"/>
        <xsl:apply-templates select="MONTHS"/>
        <xsl:apply-templates select="INTERVAL_DATE" mode="F04"/>
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
    <xsl:template match="INTERVAL_DATE" mode="F04">
        <xsl:if test="self::INTERVAL_DATE">
            <xsl:variable name="position" select="position()"/>
            <pc:startDate>
                <s:Event rdf:about="{concat($ted_date_interval_nm, f:getUuid())}">
                    <xsl:apply-templates select="START_DATE" mode="F04"/>
                    <xsl:apply-templates select="END_DATE" mode="F04"/>
                </s:Event>
            </pc:startDate>
        </xsl:if>
    </xsl:template>

    <!-- interval start date -->
    <xsl:template match="START_DATE" mode="F04">
        <xsl:call-template name="getDateProperty">
            <xsl:with-param name="property">s:startDate</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!-- interval estimated end date -->
    <xsl:template match="END_DATE" mode="F04">
        <xsl:call-template name="getDateProperty">
            <xsl:with-param name="property">s:endDate</xsl:with-param>
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
        <xsl:apply-templates
            select="AWARD_CRITERIA_CONTRACT_NOTICE_INFORMATION/AWARD_CRITERIA_DETAIL"/>
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
    <xsl:template
        match="AWARD_CRITERIA_DETAIL[LOWEST_PRICE or MOST_ECONOMICALLY_ADVANTAGEOUS_TENDER/CRITERIA_STATED_BELOW]">
        <pc:awardCriteriaCombination>
            <pc:AwardCriteriaCombination rdf:about="{$pc_award_criteria_combination_uri_1}">
                <xsl:apply-templates
                    select="LOWEST_PRICE|MOST_ECONOMICALLY_ADVANTAGEOUS_TENDER/CRITERIA_STATED_BELOW/CRITERIA_DEFINITION"
                />
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
    <xsl:template match="RECEIPT_LIMIT_DATE|TIME_LIMIT_CHP">
        <xsl:call-template name="getDateTimeProperty">
            <xsl:with-param name="property">pc:tenderDeadline</xsl:with-param>
            <xsl:with-param name="object" select="f:getDateTime(YEAR, MONTH, DAY, TIME)"/>
        </xsl:call-template>
    </xsl:template>

    <!-- tender maintenance duration -->
    <xsl:template match="MINIMUM_TIME_MAINTAINING_TENDER">
        <xsl:if
            test="(PERIOD_DAY and matches(PERIOD_DAY/text(), '^\d+$')) or (PERIOD_MONTH and matches(PERIOD_MONTH/text(), '^\d+$'))">
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
    ******************************************************************************************************************
    *** F03 CONTRACT AWARD
    *** ROOT TEMPLATE
    ******************************************************************************************************************
    -->

    <xsl:template match="CONTRACT_AWARD[@CATEGORY='ORIGINAL']">
        <pc:ContractAwardNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:ContractAwardNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}"/>
            <xsl:apply-templates select="FD_CONTRACT_AWARD"/>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="FD_CONTRACT_AWARD">
        <!-- contract kind -->
        <pc:kind rdf:resource="{f:getContractKind(@CTYPE,'')}"/>
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
    *** F03 CONTRACT AWARD
    *** SECTION I: CONTRACTING AUTHORITY
    *********************************************************
    -->
    <xsl:template match="CONTRACTING_AUTHORITY_INFORMATION_CONTRACT_AWARD">
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD"
            mode="contractingAuthority"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD" mode="contact"/>
        <xsl:apply-templates
            select="TYPE_AND_ACTIVITIES_AND_PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"
        />
    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD" mode="contractingAuthority">
        <pc:contractingAuthority>
            <s:Organization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId"
                        select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country"
                        select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>

                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE"
                    mode="legalNameAndAddress"/>
                <xsl:apply-templates select="INTERNET_ADDRESSES_CONTRACT_AWARD/URL_BUYER"/>
                <xsl:apply-templates
                    select="../TYPE_AND_ACTIVITIES_AND_PURCHASING_ON_BEHALF/TYPE_AND_ACTIVITIES"/>
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





    <!--
    *********************************************************
    *** F03 CONTRACT AWARD
    *** SECTION IV: PROCEDURE
    *********************************************************
    -->
    <xsl:template match="PROCEDURE_DEFINITION_CONTRACT_AWARD_NOTICE">
        <xsl:apply-templates select="TYPE_OF_PROCEDURE_DEF"/>
        <xsl:apply-templates
            select="AWARD_CRITERIA_CONTRACT_AWARD_NOTICE_INFORMATION/AWARD_CRITERIA_DETAIL_F03"/>
        <xsl:apply-templates
            select="ADMINISTRATIVE_INFORMATION_CONTRACT_AWARD/FILE_REFERENCE_NUMBER"/>
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
                <xsl:apply-templates
                    select="LOWEST_PRICE|MOST_ECONOMICALLY_ADVANTAGEOUS_TENDER_SHORT/CRITERIA_DEFINITION"
                />
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







    <!--
    ******************************************************************************************************************
    *** F04 PERIODIC INDICATIVE UTILITIES
    *** ROOT TEMPLATE
    ******************************************************************************************************************
    -->

    <xsl:template match="PERIODIC_INDICATIVE_UTILITIES[@CATEGORY='ORIGINAL']">
        <pc:PriorInformationNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:PriorInformationNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}"/>
            <xsl:apply-templates select="FD_PERIODIC_INDICATIVE_UTILITIES"/>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="FD_PERIODIC_INDICATIVE_UTILITIES">
        <pc:kind rdf:resource="{f:getContractKind(@CTYPE,'')}"/>
        <xsl:apply-templates select="INTRODUCTION_PERIODIC_INDICATIVE"/>
        <xsl:apply-templates select="AUTHORITY_PERIODIC_INDICATIVE"/>
        <xsl:apply-templates select="OBJECT_CONTRACT_PERIODIC_INDICATIVE"/>
        <xsl:apply-templates select="PROCEDURE_ADMINISTRATIVE_INFORMATION_PERIODIC"/>
        <xsl:apply-templates select="COMPLEMENTARY_INFORMATION_PERIODIC_INDICATIVE"/>
    </xsl:template>

    <!--
    *********************************************************
    *** F04 PERIODIC INDICATIVE UTILITIES
    *** INTRODUCTION PERIODIC INDICATIVE
    *********************************************************
    -->

    <xsl:template match="INTRODUCTION_PERIODIC_INDICATIVE">
        <xsl:choose>
            <xsl:when test="NOTICE_CALL_COMPETITION">
                <xsl:call-template name="noticeCallCompetition">
                    <xsl:with-param name="yesNo">true</xsl:with-param>
                </xsl:call-template>
            </xsl:when>
                <xsl:when test="NO_NOTICE_CALL_COMPETITION">
                    <xsl:call-template name="noticeCallCompetition">
                        <xsl:with-param name="yesNo">false</xsl:with-param>
                    </xsl:call-template>
                </xsl:when>
            </xsl:choose>
        

        <!-- 
            <xsl:choose>
                <xsl:when test="NOTICE_TIME_LIMITS_RECEIPT_TENDERS"></xsl:when>    
                <xsl:when test="NO_NOTICE_TIME_LIMITS_RECEIPT_TENDERS"></xsl:when>
            </xsl:choose> -->
        <xsl:apply-templates select="ANNEX_I"/>
    </xsl:template>

    <xsl:template name="noticeCallCompetition">
        <xsl:param name="yesNo"/>
        <pc:CompetitiveDialogue rdf:datatype="{$xsd_boolean_uri}">
            <xsl:value-of select="$yesNo"/>
        </pc:CompetitiveDialogue>
    </xsl:template>

    <xsl:template match="ANNEX_I">
        <xsl:apply-templates select="AI_OBJECT_CONTRACT_PERIODIC_INDICATIVE"/>
        <xsl:apply-templates select="AI_LEFTI_PERIODIC_INDICATIVE"/>
        <xsl:apply-templates select="AI_PROCEDURE_PERIODIC_INDICATIVE"/>
        <xsl:apply-templates select="AI_COMPLEMENTARY_INFORMATION_PERIODIC_INDICATIVE"/>
    </xsl:template>

    <xsl:template match="AI_OBJECT_CONTRACT_PERIODIC_INDICATIVE"> </xsl:template>

    <xsl:template match="AI_LEFTI_PERIODIC_INDICATIVE"> </xsl:template>

    <xsl:template match="AI_PROCEDURE_PERIODIC_INDICATIVE"> </xsl:template>

    <xsl:template match="AI_COMPLEMENTARY_INFORMATION_PERIODIC_INDICATIVE"> </xsl:template>

    <!--
    *********************************************************
    *** F04 PERIODIC INDICATIVE UTILITIES
    *** SECTION I: CONTRACTING ENTITY
    *********************************************************
    -->

    <xsl:template match="AUTHORITY_PERIODIC_INDICATIVE">


        <!-- covers INC_01 schema type -->
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_PERIODIC_INDICATIVE_UTILITIES"
            mode="contractingAuthority"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_PERIODIC_INDICATIVE_UTILITIES"
            mode="contact"/>
        <!-- covers INC_01 schema type -->
        <!-- INC_02 -->
        <xsl:apply-templates
            select="NAME_ADDRESSES_CONTACT_PERIODIC_INDICATIVE_UTILITIES/FURTHER_INFORMATION/CONTACT_DATA"/>
        <!-- INC_02 -->

        <xsl:apply-templates
            select="PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"/>

    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_PERIODIC_INDICATIVE_UTILITIES"
        mode="contractingAuthority">
        <pc:contractingAuthority>
            <s:GovernmentOrganization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId"
                        select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country"
                        select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>

                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE"
                    mode="legalNameAndAddress"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates
                    select="INTERNET_ADDRESSES_PERIODIC_INDICATIVE_UTILITIES/URL_BUYER"/>
                <xsl:apply-templates
                    select="INTERNET_ADDRESSES_PERIODIC_INDICATIVE_UTILITIES/URL_GENERAL"/>
                <!-- internet_addresses schema part -->
                
                <xsl:apply-templates select="../ACTIVITIES_OF_CONTRACTING_ENTITY"/>
            </s:GovernmentOrganization>
        </pc:contractingAuthority>
    </xsl:template>

    <xsl:template match="NAME_ADDRESSES_CONTACT_PERIODIC_INDICATIVE_UTILITIES" mode="contact">
        <xsl:call-template name="contractContact"/>
    </xsl:template>

    <!--
    *********************************************************
    *** F04 PERIODIC INDICATIVE UTILITIES
    *** SECTION II: OBJECT OF THE CONTRACT
    *********************************************************
    -->

    <xsl:template match="OBJECT_CONTRACT_PERIODIC_INDICATIVE">
        <xsl:choose>
            <xsl:when test="count(//OBJECT_CONTRACT_PERIODIC_INDICATIVE) > 1">
                <xsl:variable name="lotNumber">
                            <xsl:value-of select="position()"/>
                </xsl:variable>
                <xsl:variable name="pc_lot_uri">
                    <xsl:value-of select="concat($pc_lot_nm, $lotNumber)"/>
                </xsl:variable>
                <pc:lot>
                    <pc:Contract rdf:about="{$pc_lot_uri}">
                <xsl:apply-templates select="TITLE_CONTRACT"/>
                <xsl:apply-templates select="TYPE_CONTRACT_LOCATION_WORKS"/>
                <xsl:apply-templates select="DESCRIPTION_OF_CONTRACT"/>
                <xsl:apply-templates select="CPV"/>
                <!--<xsl:apply-templates select="ANNEX_B_INFORMATION_LOTS_PERIODIC_INDICATIVE"/>-->
                <xsl:apply-templates select="SCHEDULED_DATE_PERIOD/PERIOD_WORK_DATE_STARTING" mode="F04"/>
                <!--   <xsl:apply-templates select="SCHEDULED_DATE_PERIOD/PROCEDURE_DATE_STARTING"/> -->
                <xsl:apply-templates select="ESTIMATED_COST_MAIN_FINANCING"/>
                <xsl:apply-templates select="CONTRACT_COVERED_GPA"/>
                <xsl:apply-templates select="ADDITIONAL_INFORMATION"/>
                    </pc:Contract>
                </pc:lot>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="TITLE_CONTRACT"/>
                <xsl:apply-templates select="TYPE_CONTRACT_LOCATION_WORKS"/>
                <xsl:apply-templates select="DESCRIPTION_OF_CONTRACT"/>
                <xsl:apply-templates select="CPV"/>
                <xsl:apply-templates select="ANNEX_B_INFORMATION_LOTS_PERIODIC_INDICATIVE"/>
                <xsl:apply-templates select="SCHEDULED_DATE_PERIOD/PERIOD_WORK_DATE_STARTING" mode="F04"/>
                <!--   <xsl:apply-templates select="SCHEDULED_DATE_PERIOD/PROCEDURE_DATE_STARTING"/> -->
                <xsl:apply-templates select="ESTIMATED_COST_MAIN_FINANCING"/>
               <!-- <xsl:apply-templates select="CONTRACT_COVERED_GPA"/> -->
                <xsl:apply-templates select="ADDITIONAL_INFORMATION"/>
            </xsl:otherwise>
        </xsl:choose>
        
    </xsl:template>


    <!-- contract part (lot) -->
    <xsl:template match="ANNEX_B_INFORMATION_LOTS_PERIODIC_INDICATIVE">
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
        <xsl:variable name="pc_lot_uri">
            <xsl:value-of select="concat($pc_lot_nm, $lotNumber)"/>
        </xsl:variable>
        <pc:lot>
            <pc:Contract rdf:about="{$pc_lot_uri}">
                <xsl:apply-templates select="LOT_TITLE"/>
                <xsl:apply-templates select="LOT_DESCRIPTION"/>
                <xsl:apply-templates select="CPV"/>
                <xsl:apply-templates select="./NATURE_QUANTITY_SCOPE">
                    <xsl:with-param name="pc_lot_uri">
                        <xsl:value-of select="$pc_lot_uri"/>
                    </xsl:with-param>
                </xsl:apply-templates>
                <xsl:apply-templates select="SCHEDULED_DATE_PERIOD/PERIOD_WORK_DATE_STARTING" mode="F04"/>
                <xsl:apply-templates select="ADDITIONAL_INFORMATION"/>
            </pc:Contract>
        </pc:lot>
    </xsl:template>


    <xsl:template match="ESTIMATED_COST_MAIN_FINANCING">
        <xsl:apply-templates select="COSTS_RANGE_AND_CURRENCY"/>
       
    </xsl:template>

  <!--  <xsl:template match="CONTRACT_COVERED_GPA">
        <xsl:if test="self::CONTRACT_COVERED_GPA">
            <pc: rdf:datatype="{$xsd_boolean_uri}">
                <xsl:choose>
                    <xsl:when test="@VALUE = 'YES'">true</xsl:when>
                    <xsl:otherwise>false</xsl:otherwise>
                </xsl:choose>
            </pc:>
        </xsl:if>
    </xsl:template> -->
    
    <xsl:template match="MAIN_FINANCIAL_CONDITIONS">
            <xsl:if test="./text()">
                <s:description xml:lang="{$lang}">
                    <xsl:value-of select="normalize-space(.)"/>
                </s:description>
            </xsl:if>
    </xsl:template>
    
    <!--
    *********************************************************
    *** F04 PERIODIC INDICATIVE UTILITIES
    *** SECTION IV: PROCEDURE AND ADMINISTRATIVE INFORMATION
    *********************************************************
    -->

    <xsl:template match="PROCEDURE_ADMINISTRATIVE_INFORMATION_PERIODIC">
        <xsl:apply-templates select="REFERENCE_NUMBER_ATTRIBUTED"/>
    </xsl:template>


    <!--
    *********************************************************
    *** F04 PERIODIC INDICATIVE UTILITIES
    *** SECTION VI: COMPLEMENTARY INFORMATION
    *********************************************************
    -->

    <xsl:template match="COMPLEMENTARY_INFORMATION_PERIODIC_INDICATIVE">
        <!-- <xsl:apply-templates select="RELATES_TO_EU_PROJECT_YES|RELATES_TO_EU_PROJECT_NO"/> -->
        <xsl:apply-templates select="ADDITIONAL_INFORMATION"/>
        <xsl:apply-templates select="COSTS_RANGE_AND_CURRENCY_WITH_VAT_RATE"/>
        <xsl:apply-templates select="NOTICE_DISPATCH_DATE"/>
    </xsl:template>

    <xsl:template match="RELATES_TO_EU_PROJECT_YES|RELATES_TO_EU_PROJECT_NO"></xsl:template>

    <!--  
    ******************************************************************************************************************
    *** F05 CONTRACT UTILITIES
    *** ROOT ELEMENT
    ****************************************************************************************************************** 
    -->

    <xsl:template match="CONTRACT_UTILITIES[@CATEGORY='ORIGINAL']">
        <pc:ContractNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:ContractNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}"/>
            <xsl:apply-templates select="FD_CONTRACT_UTILITIES"/>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="FD_CONTRACT_UTILITIES">
       <!-- <pc:kind rdf:resource="{f:getContractKind(@CTYPE,'')}"/> -->
        <xsl:apply-templates select="CONTRACTING_AUTHORITY_INFO"/>
        <xsl:apply-templates select="OBJECT_CONTRACT_INFORMATION_CONTRACT_UTILITIES"/>
        <!--  <xsl:apply-templates select="LEFTI_CONTRACT_NOTICE_UTILITIES"/>  -->
        <xsl:apply-templates select="PROCEDURE_DEFINITION_CONTRACT_NOTICE_UTILITIES"/>
        <xsl:apply-templates select="COMPLEMENTARY_INFORMATION_CONTRACT_UTILITIES"/>
    </xsl:template>

    <!--
    *********************************************************
    *** F05 CONTRACT UTILITIES
    *** SECTION I: CONTRACTING AUTHORITY
    *********************************************************
    -->

    <xsl:template match="CONTRACTING_AUTHORITY_INFO">
        <!-- covers INC_01 schema type -->
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT_UTILITIES"
            mode="contractingAuthority"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT_UTILITIES" mode="contact"/>
        <!-- INC_02 -->
        <xsl:apply-templates
            select="NAME_ADDRESSES_CONTACT_CONTRACT_UTILITIES/FURTHER_INFORMATION/CONTACT_DATA"/>

        <xsl:apply-templates
            select="PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"/>

    </xsl:template>
    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT_UTILITIES" mode="contractingAuthority">
        <pc:contractingAuthority>
            <s:GovernmentOrganization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId"
                        select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country"
                        select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>
                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE"
                    mode="legalNameAndAddress"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates select="INTERNET_ADDRESSES_CONTRACT_UTILITIES/URL_GENERAL"/>
                <xsl:apply-templates select="INTERNET_ADDRESSES_CONTRACT_UTILITIES/URL_BUYER"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates select="../ACTIVITIES_OF_CONTRACTING_ENTITY"/>
            </s:GovernmentOrganization>
        </pc:contractingAuthority>
    </xsl:template>
    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT_UTILITIES" mode="contact">
        <xsl:call-template name="contractContact"/>
    </xsl:template>

    <!--
    *********************************************************
    *** F05 CONTRACT UTILITIES
    *** SECTION II: OBJECT OF THE CONTRACT
    *********************************************************
    -->

    <xsl:template match="OBJECT_CONTRACT_INFORMATION_CONTRACT_UTILITIES">
        <xsl:apply-templates select="CONTRACT_OBJECT_DESCRIPTION"/>
        <xsl:apply-templates select="QUANTITY_SCOPE/NATURE_QUANTITY_SCOPE/COSTS_RANGE_AND_CURRENCY"/>
        <xsl:apply-templates select="PERIOD_WORK_DATE_STARTING"/>
    </xsl:template>
    <xsl:template match="CONTRACT_OBJECT_DESCRIPTION">
     
        <xsl:apply-templates select="TITLE_CONTRACT"/>
        <xsl:apply-templates select="TYPE_CONTRACT_LOCATION" mode="type_contract"/>
        <xsl:apply-templates select="TYPE_CONTRACT_LOCATION" mode="category"/>
        <xsl:apply-templates select="LOCATION_NUTS"/>

        <xsl:apply-templates select="F05_FRAMEWORK"/>
        <xsl:apply-templates select="SHORT_CONTRACT_DESCRIPTION"/>
        <xsl:apply-templates select="CPV"/>
        <!--<xsl:apply-templates select="CONTRACT_COVERED_GPA"/> -->
        <xsl:apply-templates select="F05_DIVISION_INTO_LOTS/F05_DIV_INTO_LOT_YES/F05_ANNEX_B"/>
        
    </xsl:template>

    <xsl:template match="F05_FRAMEWORK">
        <!-- <xsl:call-template name="frameworkAgreement"/>  -->
    </xsl:template>

    <!-- contract part (lot) -->
    <xsl:template match="F05_ANNEX_B">
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
        <xsl:variable name="pc_lot_uri">
            <xsl:value-of select="concat($pc_lot_nm, $lotNumber)"/>
        </xsl:variable>
        <pc:lot>
            <pc:Contract rdf:about="{$pc_lot_uri}">
                <xsl:apply-templates select="LOT_TITLE"/>
                <xsl:apply-templates select="LOT_DESCRIPTION"/>
                <xsl:apply-templates select="CPV"/>
                <xsl:apply-templates select="./NATURE_QUANTITY_SCOPE">
                    <xsl:with-param name="pc_lot_uri">
                        <xsl:value-of select="$pc_lot_uri"/>
                    </xsl:with-param>
                </xsl:apply-templates>
                <xsl:apply-templates select="PERIOD_WORK_DATE_STARTING"/>
                <xsl:apply-templates select="ADDITIONAL_INFORMATION_ABOUT_LOTS"/>
            </pc:Contract>
        </pc:lot>
    </xsl:template>

    <!--
    *********************************************************
    *** F05 CONTRACT UTILITIES
    *** SECTION III: LEGAL, ECONOMIC, FINANCIAL AND TECHNICAL INFORMATION
    *********************************************************
    -->

    <!-- <xsl:template match="LEFTI_CONTRACT_NOTICE_UTILITIES">  -->
    <!--    <xsl:apply-templates select="CONTRACT_RELATING_CONDITIONS"/> -->
    <!--    <xsl:apply-templates select="F05_CONDITIONS_FOR_PARTICIPATION"/> -->
    <!--    <xsl:apply-templates select="SERVICES_CONTRACTS_SPECIFIC_CONDITIONS"/> -->
    <!--   </xsl:template> -->

    <!--   <xsl:template match="CONTRACT_RELATING_CONDITIONS">
        <xsl:apply-templates select="DEPOSITS_GUARANTEES_REQUIRED"/> -->
    <!-- <xsl:apply-templates select="MAIN_FINANCING_CONDITIONS"/>
        <xsl:apply-templates select="LEGAL_FORM"/>
        <xsl:apply-templates select="EXISTENCE_OTHER_PARTICULAR_CONDITIONS"/> -->
    <!--      </xsl:template> -->

    <!--  <xsl:template match="DEPOSITS_GUARANTEES_REQUIRED">
        <xsl:call-template name="legalDescription"/>
    </xsl:template>
     -->

    <!--  <xsl:template match="F05_CONDITIONS_FOR_PARTICIPATION">
        <xsl:apply-templates select="ECONOMIC_OPERATORS_PERSONAL_SITUATION"/>
        <xsl:apply-templates select="F05_ECONOMIC_FINANCIAL_CAPACITY"/>
        <xsl:apply-templates select="TECHNICAL_CAPACITY"/>
        <xsl:apply-templates select="RESERVED_CONTRACTS"/>
    </xsl:template>
    
    <xsl:template match="SERVICES_CONTRACTS_SPECIFIC_CONDITIONS">
        <xsl:apply-templates select="EXECUTION_SERVICE_RESERVED_PARTICULAR_PROFESSION"/>
        <xsl:apply-templates select="REQUESTS_NAMES_PROFESSIONAL_QUALIFICATIONS"/>
    </xsl:template>
    -->
    <!--
    *********************************************************
    *** F05 CONTRACT UTILITIES
    *** SECTION IV: PROCEDURE
    *********************************************************
    -->

    <xsl:template match="PROCEDURE_DEFINITION_CONTRACT_NOTICE_UTILITIES">
        <xsl:apply-templates select="TYPE_OF_PROCEDURE_FOR_CONTRACT"/>
        <xsl:apply-templates select="F05_AWARD_CRITERIA_CONTRACT_UTILITIES_INFORMATION"/>
        <xsl:apply-templates select="ADMINISTRATIVE_INFORMATION_CONTRACT_UTILITIES"/>

    </xsl:template>

    <xsl:template match="TYPE_OF_PROCEDURE_FOR_CONTRACT">
        <xsl:apply-templates select="TYPE_OF_PROCEDURE_DETAIL"/>
        <xsl:apply-templates select="IS_CANDIDATE_SELECTED"/>
    </xsl:template>

    <xsl:template match="TYPE_OF_PROCEDURE_DETAIL">
        <xsl:call-template name="procedureType">
            <xsl:with-param name="ptElementName" select="@VALUE"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="IS_CANDIDATE_SELECTED"> 
    
    </xsl:template>

    <xsl:template match="F05_AWARD_CRITERIA_CONTRACT_UTILITIES_INFORMATION">
        <xsl:apply-templates select="AWARD_CRITERIA_DETAIL"/>
        <xsl:apply-templates select="IS_ELECTRONIC_AUCTION_USABLE"/>
    </xsl:template>

    <xsl:template match="IS_ELECTRONIC_AUCTION_USABLE"> </xsl:template>

    <xsl:template match="ADMINISTRATIVE_INFORMATION_CONTRACT_UTILITIES">
        <xsl:apply-templates select="FILE_REFERENCE_NUMBER"/>
        <xsl:apply-templates select="PREVIOUS_PUBLICATION_INFORMATION_NOTICE_F5"/>
        <xsl:apply-templates select="CONDITIONS_FOR_MORE_INFORMATION"/>
        <xsl:apply-templates select="RECEIPT_LIMIT_DATE"/>
        <xsl:apply-templates select="LANGUAGE"/>
        <xsl:apply-templates select="MINIMUM_TIME_MAINTAINING_TENDER"/>
        <xsl:apply-templates select="CONDITIONS_FOR_OPENING_TENDERS"/>

    </xsl:template>

    <xsl:template match="PREVIOUS_PUBLICATION_INFORMATION_NOTICE_F5"> </xsl:template>

    <xsl:template match="CONDITIONS_FOR_MORE_INFORMATION"> 
    
    </xsl:template>




    <!--
    *********************************************************
    *** F05 CONTRACT UTILITIES
    *** SECTION VI: COMPLEMENTARY INFORMATION
    *********************************************************
    -->

    <xsl:template match="COMPLEMENTARY_INFORMATION_CONTRACT_UTILITIES">
        <xsl:apply-templates select="RECURRENT_PROCUREMENT|NO_RECURRENT_PROCUREMENT"/>
        <!--  <xsl:apply-templates select="RELATES_TO_EU_PROJECT_YES|RELATES_TO_EU_PROJECT_NO"/> -->
        <xsl:apply-templates select="ADDITIONAL_INFORMATION"/>
        <xsl:apply-templates select="PROCEDURES_FOR_APPEAL"/>
        <xsl:apply-templates select="NOTICE_DISPATCH_DATE"/>
    </xsl:template>

    <xsl:template match="RECURRENT_PROCUREMENT|NO_RECURRENT_PROCUREMENT">
        <xsl:variable name="value">
            <xsl:choose>
                <xsl:when test="../RECURRENT_PROCUREMENT">true</xsl:when>
                <xsl:when test="../NO_RECURRENT_PROCUREMENT">false</xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:if test=".">
            <pproc:Remedy rdf:about="{$pc_recurrement_uri}">
                <pproc:recurrentRemedy rdf:datatype="{$xsd_boolean_uri}">
                    <xsl:value-of select="$value"/>
                </pproc:recurrentRemedy>
            </pproc:Remedy>
        </xsl:if>
    </xsl:template>

    <xsl:template match="PROCEDURES_FOR_APPEAL">
        <xsl:apply-templates
            select="APPEAL_PROCEDURE_BODY_RESPONSIBLE/CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME"/>
        <xsl:apply-templates
            select="LODGING_INFORMATION_FOR_SERVICE/CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME"/>
    </xsl:template>



    <!--
    ******************************************************************************************************************
    *** F06 CONTRACT AWARD UTILITIES
    *** ROOT TEMPLATE
    ******************************************************************************************************************
    -->

    <xsl:template match="CONTRACT_AWARD_UTILITIES[@CATEGORY='ORIGINAL']">
        <pc:ContractAwardNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:ContractAwardNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}"/>
            <xsl:apply-templates select="FD_CONTRACT_AWARD_UTILITIES"/>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="FD_CONTRACT_AWARD_UTILITIES">

        <xsl:apply-templates select="CONTRACTING_ENTITY_CONTRACT_AWARD_UTILITIES"/>
        <xsl:apply-templates select="OBJECT_CONTRACT_AWARD_UTILITIES"/>
        <xsl:apply-templates select="PROCEDURES_CONTRACT_AWARD_UTILITIES"/>
        <xsl:apply-templates select="AWARD_CONTRACT_CONTRACT_AWARD_UTILITIES"/>
        <xsl:apply-templates select="COMPLEMENTARY_INFORMATION_CONTRACT_AWARD_UTILITIES"/>
    </xsl:template>


    <!--
    *********************************************************
    *** F06 CONTRACT AWARD UTILITIES
    *** SECTION I: CONTRACTING AUTHORITY
    *********************************************************
    -->

    <xsl:template match="CONTRACTING_ENTITY_CONTRACT_AWARD_UTILITIES">
        <!-- covers INC_01 schema type -->
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD_UTILITIES"
            mode="contractingAuthority"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD_UTILITIES" mode="contact"/>
        <!-- covers INC_01 schema type -->
        <xsl:apply-templates
            select="PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"/>

    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD_UTILITIES"
        mode="contractingAuthority">
        <pc:contractingAuthority>
            <s:GovernmentOrganization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId"
                        select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country"
                        select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>

                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE"
                    mode="legalNameAndAddress"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates select="INTERNET_ADDRESSES_CONTRACT_AWARD_UTILITIES/URL_BUYER"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates select="../ACTIVITIES_OF_CONTRACTING_ENTITY"/>
            </s:GovernmentOrganization>
        </pc:contractingAuthority>
    </xsl:template>

    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD_UTILITIES" mode="contact">
        <xsl:call-template name="contractContact"/>
    </xsl:template>

    <!--
    *********************************************************
    *** F06 CONTRACT AWARD UTILITIES
    *** SECTION II: OBJECT OF THE CONTRACT
    *********************************************************
    -->

    <xsl:template match="OBJECT_CONTRACT_AWARD_UTILITIES">
        <xsl:apply-templates select="DESCRIPTION_CONTRACT_AWARD_UTILITIES"/>
        <xsl:apply-templates select="COSTS_RANGE_AND_CURRENCY_WITH_VAT_RATE"/>
    </xsl:template>


    <xsl:template match="DESCRIPTION_CONTRACT_AWARD_UTILITIES">
        <xsl:apply-templates select="TITLE_CONTRACT"/>
        <xsl:apply-templates select="TYPE_CONTRACT_LOCATION_W_PUB" mode="type_contract"/>
        <xsl:apply-templates select="TYPE_CONTRACT_LOCATION_W_PUB" mode="category"/>
        <xsl:apply-templates select="LOCATION_NUTS"/>
        <xsl:apply-templates select="F06_NOTICE_INVOLVES/CONCLUSION_FRAMEWORK_AGREEMENT" mode="F06"/>
        <xsl:apply-templates select="SHORT_DESCRIPTION"/>
        <xsl:apply-templates select="CPV"/>
        <xsl:apply-templates select="CONTRACT_COVERED_GPA"/>
    </xsl:template>

    <xsl:template match="CONCLUSION_FRAMEWORK_AGREEMENT" mode="F06">
        <!-- <xsl:call-template name="frameworkAgreement"/> -->
    </xsl:template>

    <xsl:template match="TYPE_CONTRACT_LOCATION_W_PUB" mode="type_contract">
        <xsl:if test="TYPE_CONTRACT/@VALUE">
            <xsl:variable name="contract_kind_uri"
                select="f:getContractKind(TYPE_CONTRACT/@VALUE,'')"/>
            <xsl:if test="$contract_kind_uri">
                <pc:kind rdf:resource="{$contract_kind_uri}"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="TYPE_CONTRACT_LOCATION_W_PUB" mode="category">
        <xsl:if test="SERVICE_CATEGORY_PUB/text()">
            <xsl:variable name="services_category"
                select="f:getServiceCategory(SERVICE_CATEGORY_PUB/text(),'([1-5]|6(a|b)?|[7-9]|1[0-6])|((1[7-9]|2[0-7])(Y|N)?)')"/>
            <xsl:if test="$services_category">
                <pc:kind rdf:resource="{$services_category}"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!--
    *********************************************************
    *** F06 CONTRACT AWARD UTILITIES
    *** SECTION IV: PROCEDURES
    *********************************************************
    -->

    <xsl:template match="PROCEDURES_CONTRACT_AWARD_UTILITIES">
        <xsl:apply-templates select="TYPE_PROCEDURE_AWARD"/>
        <xsl:apply-templates
            select="F06_AWARD_CRITERIA_CONTRACT_UTILITIES_INFORMATION/PRICE_AWARD_CRITERIA"/>
        <xsl:apply-templates
            select="ADMINISTRATIVE_INFO_CONTRACT_AWARD_UTILITIES/REFERENCE_NUMBER_ATTRIBUTED"/>
    </xsl:template>

    <!-- contract procedure type -->
    <xsl:template match="TYPE_PROCEDURE_AWARD">
        <xsl:call-template name="procedureType">
            <xsl:with-param name="ptElementName" select="local-name(*)"/>
        </xsl:call-template>
    </xsl:template>

    <!-- contract criteria -->
    <xsl:template match="PRICE_AWARD_CRITERIA">
        <pc:awardCriteriaCombination>
            <pc:AwardCriteriaCombination rdf:about="{$pc_award_criteria_combination_uri_1}">
                <xsl:apply-templates select="../PRICE_AWARD_CRITERIA" mode="attribute"/>
            </pc:AwardCriteriaCombination>
        </pc:awardCriteriaCombination>
    </xsl:template>

    <xsl:template match="PRICE_AWARD_CRITERIA" mode="attribute"> </xsl:template>

    <!--
    *********************************************************
    *** F06 CONTRACT AWARD UTILITIES
    *** SECTION V: AWARD OF CONTRACT
    *********************************************************
    -->

    <xsl:template match="AWARD_CONTRACT_CONTRACT_AWARD_UTILITIES">
        <xsl:apply-templates select="AWARD_AND_CONTRACT_VALUE"/>
        <xsl:apply-templates select="MANDATORY_INFORMATION_NOT_INTENDED_PUBLICATION"/>
    </xsl:template>

    <!-- contract part (lot) with awarded tender -->
    <xsl:template match="AWARD_AND_CONTRACT_VALUE" mode="lot">
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
                    <xsl:apply-templates select="../TITLE_CONTRACT[$position]"/>
                    <xsl:apply-templates select="../DATE_OF_CONTRACT_AWARD"/>
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
    <xsl:template match="AWARD_AND_CONTRACT_VALUE">
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
    <xsl:template match="DATE_OF_CONTRACT_AWARD">
        <xsl:call-template name="getDateProperty">
            <xsl:with-param name="property">pc:awardDate</xsl:with-param>
        </xsl:call-template>
    </xsl:template>



    <!-- tenderer info -->
    <xsl:template match="CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME">
        <xsl:call-template name="basicBusinessEntity"/>
    </xsl:template>



    <!--
    *********************************************************
    *** F06 CONTRACT AWARD UTILITIES
    *** SECTION VI: COMPLEMENTARY INFORMATION
    *********************************************************
    -->

    <xsl:template match="COMPLEMENTARY_INFORMATION_CONTRACT_AWARD_UTILITIES">
        <xsl:apply-templates select="ADDITIONAL_INFORMATION"/>
        <xsl:apply-templates select="APPEAL_PROCEDURES"/>
        <xsl:apply-templates select="NOTICE_DISPATCH_DATE"/>
    </xsl:template>

    <xsl:template match="APPEAL_PROCEDURES">
        <xsl:apply-templates
            select="RESPONSIBLE_FOR_APPEAL_PROCEDURES/CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME"/>
        <xsl:apply-templates
            select="RESPONSIBLE_FOR_MEDIATION_PROCEDURES//CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME"/>
        <xsl:apply-templates select="INFO_ON_DEADLINE"/>
        <xsl:apply-templates select="SERVICE_FROM_INFORMATION/CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME"
        />
    </xsl:template>

    <xsl:template match="INFO_ON_DEADLINE">
        <xsl:call-template name="description"/>
    </xsl:template>

    <!--
    ******************************************************************************************************************
    *** F07 QUALIFICATION SYSTEM UTILITIES
    *** ROOT TEMPLATE
    ******************************************************************************************************************
    -->

    <xsl:template match="QUALIFICATION_SYSTEM_UTILITIES[@CATEGORY='ORIGINAL']">
        <pc:ContractNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:ContractNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}"/>
            <xsl:apply-templates select="FD_QUALIFICATION_SYSTEM_UTILITIES"/>
        </pc:Contract>

    </xsl:template>

    <xsl:template match="FD_QUALIFICATION_SYSTEM_UTILITIES">

        <xsl:apply-templates select="CONTRACTING_ENTITY_QUALIFICATION_SYSTEM"/>
        <!-- COMPLETED -->
        <xsl:apply-templates select="OBJECT_QUALIFICATION_SYSTEM"/>
        <!-- COMPLETED -->

        <xsl:apply-templates select="PROCEDURES_QUALIFICATION_SYSTEM"/>
    </xsl:template>

    <!--
    *********************************************************
    *** F07 QUALIFICATION SYSTEM UTILITIES
    *** SECTION I: CONTRACTING ENTITY
    *********************************************************
    -->

    <xsl:template match="CONTRACTING_ENTITY_QUALIFICATION_SYSTEM">

        <!-- covers INC_01 schema type -->
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_QUALIFICATION_SYSTEM_UTILITIES"
            mode="contractingAuthority"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_QUALIFICATION_SYSTEM_UTILITIES"
            mode="contact"/>
        <!-- covers INC_01 schema type -->
        <!-- INC_02 -->
        <xsl:apply-templates
            select="NAME_ADDRESSES_CONTACT_QUALIFICATION_SYSTEM_UTILITIES/FURTHER_INFORMATION/CONTACT_DATA"/>
        <!-- INC_02 -->

        <xsl:apply-templates
            select="PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"/>

    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_QUALIFICATION_SYSTEM_UTILITIES"
        mode="contractingAuthority">
        <pc:contractingAuthority>
            <s:GovernmentOrganization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId"
                        select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country"
                        select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>

                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE"
                    mode="legalNameAndAddress"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates
                    select="INTERNET_ADDRESSES_QUALIFICATION_SYSTEM_UTILITIES/URL_BUYER"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates select="../ACTIVITIES_OF_CONTRACTING_ENTITY"/>
            </s:GovernmentOrganization>
        </pc:contractingAuthority>
    </xsl:template>

    <xsl:template match="NAME_ADDRESSES_CONTACT_QUALIFICATION_SYSTEM_UTILITIES" mode="contact">
        <xsl:call-template name="contractContact"/>
    </xsl:template>

    <!--
    *********************************************************
    *** F07 QUALIFICATION SYSTEM UTILITIES
    *** SECTION II: OBJECT OF THE QUALIFICATION SYSTEM
    *********************************************************
    -->

    <xsl:template match="OBJECT_QUALIFICATION_SYSTEM">
        <xsl:apply-templates select="TITLE_QUALIFICATION_SYSTEM"/>
        <xsl:apply-templates select="CONTRACT_LOCATION_TYPE/F07_CONTRACT_TYPE"/>
        <xsl:apply-templates select="CONTRACT_LOCATION_TYPE/SERVICE_CATEGORY" mode="category"/>
        <xsl:apply-templates select="DESCRIPTION"/>
        <xsl:apply-templates select="CPV"/>
        <xsl:apply-templates select="CONTRACT_COVERED_GPA"/>
    </xsl:template>



    <xsl:template match="SERVICE_CATEGORY" mode="category">
        <xsl:if test="./text()">
            <xsl:variable name="services_category"
                select="f:getServiceCategory(./text(),'[3-5]|6(a|b)?|[7-9]|1[0-9]?|2[0-7]?')"/>
            <xsl:if test="$services_category">
                <pc:kind rdf:resource="{$services_category}"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!--
    *********************************************************
    *** F07 QUALIFICATION SYSTEM UTILITIES
    *** SECTION IV: PROCEDURES
    *********************************************************
    -->

    <xsl:template match="PROCEDURES_QUALIFICATION_SYSTEM">
        <xsl:apply-templates select="AWARD_CRITERIA_QUALIFICATION_SYSTEM/AWARD_CRITERIA_DETAIL"/>
        <xsl:apply-templates select="ADMINISTRATIVE_INFORMATION_QUALIFICATION_SYSTEM"/>
    </xsl:template>

    <xsl:template match="ADMINISTRATIVE_INFORMATION_QUALIFICATION_SYSTEM">
        <xsl:apply-templates select="FILE_REFERENCE_NUMBER"/>
        <xsl:apply-templates select="DURATION_QUALIFICATION_SYSTEM"/>
    </xsl:template>

    <xsl:template match="DURATION_QUALIFICATION_SYSTEM">
        <xsl:choose>
            <xsl:when test="DURATION_FROM and DURATION_UNTIL">
                <xsl:apply-templates select="DURATION_FROM"/>
                <xsl:apply-templates select="DURATION_UNTIL"/>
            </xsl:when>
            <xsl:when test="DURATION_INDEFINITE"> </xsl:when>
            <xsl:when test="DURATION_OTHER"> </xsl:when>
        </xsl:choose>

    </xsl:template>

    <xsl:template match="DURATION_FROM">
        <xsl:apply-templates select="START_DATE"/>
    </xsl:template>

    <xsl:template match="DURATION_UNTIL">
        <xsl:apply-templates select="END_DATE"/>
    </xsl:template>

    <!--  
    ******************************************************************************************************************
    *** F08 BUYER PROFILE
    *** ROOT TEMPLATE
    ******************************************************************************************************************
    -->

    <xsl:template match="BUYER_PROFILE[@CATEGORY='ORIGINAL']">
        <pc:ContractNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:ContractNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}"/>
            <xsl:apply-templates select="FD_BUYER_PROFILE"/>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="FD_BUYER_PROFILE">
        <xsl:apply-templates select="NOTICE_RELATION_PUBLICATION"/>
        <xsl:apply-templates select="AUTHORITY_ENTITY_NOTICE_BUYER_PROFILE"/>
        <xsl:apply-templates select="OBJECT_NOTICE_BUYER_PROFILE"/>
        <xsl:apply-templates select="COMPLEMENTARY_INFORMATION_NOTICE_BUYER_PROFILE"/>
    </xsl:template>

    <!--  
    *********************************************************
    *** F08 BUYER PROFILE
    *** SECTION I: CONTRACTING AUTHORITY ENTITY
    *********************************************************
    -->

    <!-- contracting entity government organization -->
    <xsl:template match="AUTHORITY_ENTITY_NOTICE_BUYER_PROFILE">
        <!-- covers INC_01 schema type -->
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_BUYER_PROFILE"
            mode="contractingAuthority"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_BUYER_PROFILE" mode="contact"/>
        <!-- covers INC_01 schema type -->
        <!-- INC_02_1 -->
        <xsl:apply-templates
            select="NAME_ADDRESSES_CONTACT_BUYER_PROFILE/FURTHER_INFORMATION/CONTACT_DATA"/>
        <!-- INC_02_1 -->
        <xsl:apply-templates
            select="TYPE_AND_ACTIVITIES_OR_CONTRACTING_ENTITY_AND_PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"
        />
    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_BUYER_PROFILE" mode="contractingAuthority">
        <pc:contractingAuthority>
            <s:GovernmentOrganization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId"
                        select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country"
                        select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>

                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE"
                    mode="legalNameAndAddress"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates select="INTERNET_ADDRESSES_BUYER_PROFILE/URL_BUYER"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates
                    select="../TYPE_AND_ACTIVITIES_OR_CONTRACTING_ENTITY_AND_PURCHASING_ON_BEHALF"/>
            </s:GovernmentOrganization>
        </pc:contractingAuthority>
    </xsl:template>

    <xsl:template match="NAME_ADDRESSES_CONTACT_BUYER_PROFILE" mode="contact">
        <xsl:call-template name="contractContact"/>
    </xsl:template>

    <!--  
    *********************************************************
    *** F08 BUYER PROFILE
    *** SECTION II: OBJECT OF THE CONTRACT
    *********************************************************
    -->

    <xsl:template match="OBJECT_NOTICE_BUYER_PROFILE">
        <!-- Section II.1 -->
        <pc:item>
            <gr:Offering rdf:about="{f:getCpvUri(CPV/CPV_MAIN/CPV_CODE/@CODE)}">
                <xsl:apply-templates select="TITLE_NOTICE_BUYER_PROFILE"/>
                <xsl:apply-templates select="TYPE_CONTRACT"/>
                <xsl:apply-templates select="SHORT_DESCRIPTION_CONTRACT"/>
                <xsl:apply-templates select="CPV"/>
            </gr:Offering>
        </pc:item>
    </xsl:template>

    <!--  
    *********************************************************
    *** F08 BUYER PROFILE
    *** SECTION VI: COMPLEMENTARY INFORMATION
    *********************************************************
    -->

    <xsl:template match="COMPLEMENTARY_INFORMATION_NOTICE_BUYER_PROFILE">
        <xsl:apply-templates select="ADDITIONAL_INFORMATION"/>
        <xsl:apply-templates select="NOTICE_DISPATCH_DATE"/>
    </xsl:template>

    <!-- dispatch date -->
    <xsl:template match="NOTICE_DISPATCH_DATE">
        <pc:ContractNotice>
            <pproc:ContractAwardNotice rdf:about="{$contract_notice_uri}">
                <xsl:call-template name="getDateProperty">
                    <xsl:with-param name="property">pproc:noticeSentDate</xsl:with-param>
                </xsl:call-template>
            </pproc:ContractAwardNotice>
        </pc:ContractNotice>
    </xsl:template>

    <!--  
    ******************************************************************************************************************
    *** F09 SIMPLIFIED CONTRACT
    *** ROOT TEMPLATE
    ******************************************************************************************************************
    -->

    <xsl:template match="SIMPLIFIED_CONTRACT[@CATEGORY='ORIGINAL']">
        <pc:ContractNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:ContractNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}"/>
            <xsl:apply-templates select="FD_SIMPLIFIED_CONTRACT"/>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="FD_SIMPLIFIED_CONTRACT">
        <xsl:apply-templates select="NOTICE_COVERED"/>
        <xsl:apply-templates select="AUTHORITY_ENTITY_SIMPLIFIED_CONTRACT_NOTICE"/>
        <xsl:apply-templates select="OBJECT_SIMPLIFIED_CONTRACT_NOTICE"/>
        <xsl:apply-templates select="PROCEDURES_SIMPLIFIED_CONTRACT_NOTICE"/>
        <xsl:apply-templates select="COMPLEMENTARY_INFORMATION_SIMPLIFIED_CONTRACT"/>
    </xsl:template>

    <!--  
    *********************************************************
    *** F09 SIMPLIFIED CONTRACT
    *** SECTION I: AUTHORITY ENTITY SIMPLIFIED CONTRACT NOTICE
    *********************************************************
    -->

    <!-- <xsl:template match="NOTICE_COVERED">
        <xsl:variable name="notice_covered_uri" select="f:getNoticeType(@VALUE,'')"/>
        NOT COMPLETED
    </xsl:template> -->

    <xsl:template match="AUTHORITY_ENTITY_SIMPLIFIED_CONTRACT_NOTICE">
        <!-- covers INC_01 schema type -->
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_SIMPLIFIED_CONTRACT"
            mode="contractingAuthority"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_SIMPLIFIED_CONTRACT" mode="contact"/>
        <!-- covers INC_01 schema type -->

    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_SIMPLIFIED_CONTRACT" mode="contractingAuthority">
        <pc:contractingAuthority>
            <s:Organization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId"
                        select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country"
                        select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>

                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE"
                    mode="legalNameAndAddress"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates select="INTERNET_ADDRESSES_SIMPLIFIED_CONTRACT/URL_BUYER"/>
                <!-- internet_addresses schema part -->
                <!-- TYPE AND ACTIVITIES part -->
                <xsl:apply-templates select="../ACTIVITIES_OF_CONTRACTING_ENTITY"/>
                <!-- TYPE AND ACTIVITIES part -->
            </s:Organization>
        </pc:contractingAuthority>
    </xsl:template>

    <xsl:template match="NAME_ADDRESSES_CONTACT_SIMPLIFIED_CONTRACT" mode="contact">
        <xsl:call-template name="contractContact"/>
    </xsl:template>

    <!--  
    *********************************************************
    *** F09 SIMPLIFIED CONTRACT
    *** SECTION II: OBJECT OF THE CONTRACT
    *********************************************************
    -->

    <xsl:template match="OBJECT_SIMPLIFIED_CONTRACT_NOTICE">
        <xsl:apply-templates select="TITLE_CONTRACT"/>
        <xsl:apply-templates select="TYPE_CONTRACT"/>
        <xsl:apply-templates select="SHORT_DESCRIPTION_CONTRACT"/>
        <xsl:apply-templates select="CPV"/>
        <xsl:apply-templates select="NATURE_QUANTITY_SCOPE"/>

    </xsl:template>

    <xsl:template match="NATURE_QUANTITY_SCOPE">
        <xsl:if test=".">
            <xsl:apply-templates select="TOTAL_QUANTITY_OR_SCOPE"/>
            <xsl:apply-templates select="COSTS_RANGE_AND_CURRENCY"/>
        </xsl:if>
    </xsl:template>

    <xsl:template match="TOTAL_QUANTITY_OR_SCOPE">
        <xsl:if test=".">
            <xsl:call-template name="description"/>
        </xsl:if>
    </xsl:template>


    <!--  
    *********************************************************
    *** F09 SIMPLIFIED CONTRACT
    *** SECTION IV: PROCEDURES
    *********************************************************
    -->

    <xsl:template match="PROCEDURES_SIMPLIFIED_CONTRACT_NOTICE">
        <xsl:apply-templates select="F09_TYPE_PROCEDURE_OPEN"/>
        <!-- <xsl:apply-templates select="IS_ELECTRONIC_AUCTION_USABLE"/> -->
        <xsl:apply-templates select="ADMINISTRATIVE_INFORMATION_SIMPLIFIED_CONTRACT"/>
    </xsl:template>

    <xsl:template match="F09_TYPE_PROCEDURE_OPEN">
        <xsl:call-template name="procedureType">
            <xsl:with-param name="ptElementName" select="local-name(.)"/>
        </xsl:call-template>
    </xsl:template>

    <!-- <xsl:template match="IS_ELECTRONIC_AUCTION_USABLE"> </xsl:template> -->

    <xsl:template match="ADMINISTRATIVE_INFORMATION_SIMPLIFIED_CONTRACT">
        <xsl:apply-templates select="REFERENCE_NUMBER_ATTRIBUTED"/>
        <xsl:apply-templates select="PREVIOUS_PUBLICATION_OJ"/>
        <xsl:apply-templates select="TIME_LIMIT_CHP"/>
        <xsl:apply-templates select="LANGUAGE"/>
    </xsl:template>

    <xsl:template match="LANGUAGE"/>

    <!--  
    *********************************************************
    *** F09 SIMPLIFIED CONTRACT
    *** SECTION VI: COMPLEMENTARY INFORMATION
    *********************************************************
    -->

    <xsl:template match="COMPLEMENTARY_INFORMATION_SIMPLIFIED_CONTRACT">
        <xsl:apply-templates select="ADDITIONAL_INFORMATION"/>
        <xsl:apply-templates select="NOTICE_DISPATCH_DATE"/>
    </xsl:template>



    <!--  
    ******************************************************************************************************************
    *** F15 VOLUNTARY EX ANTE TRANSPARENCY NOTICE
    *** ROOT TEMPLATE
    ******************************************************************************************************************
    -->

    <xsl:template match="VOLUNTARY_EX_ANTE_TRANSPARENCY_NOTICE[@CATEGORY='ORIGINAL']">
        <pc:ContractNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:ContractNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}"/>
            <xsl:apply-templates select="FD_VOLUNTARY_EX_ANTE_TRANSPARENCY_NOTICE"/>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="FD_VOLUNTARY_EX_ANTE_TRANSPARENCY_NOTICE">
        <xsl:apply-templates select="NOTICE_PUBLISHED"/>
        <xsl:apply-templates select="CONTRACTING_AUTHORITY_VEAT"/>
        <xsl:apply-templates select="OBJECT_VEAT"/>
        <xsl:apply-templates select="PROCEDURE_DEFINITION_VEAT"/>
        <xsl:apply-templates select="AWARD_OF_CONTRACT_DEFENCE"/>
        <xsl:apply-templates select="COMPLEMENTARY_INFORMATION_VEAT"/>
    </xsl:template>

    <xsl:template match="NOTICE_PUBLISHED"> </xsl:template>

    <!--  
    *********************************************************
    *** F15 VOLUNTARY EX ANTE TRANSPARENCY NOTICE
    *** SECTION I: CONTRACTING AUTHORITY
    *********************************************************
    -->

    <!-- contracting entity organization -->
    <xsl:template match="CONTRACTING_AUTHORITY_VEAT">
        <!-- covers INC_01 schema type -->
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_VEAT" mode="contractingAuthority"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_VEAT" mode="contact"/>
        <!-- covers INC_01 schema type -->
        <xsl:apply-templates
            select="TYPE_AND_ACTIVITIES_OR_CONTRACTING_ENTITY_AND_PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"
        />
    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_VEAT" mode="contractingAuthority">
        <pc:contractingAuthority>
            <s:Organization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId"
                        select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country"
                        select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>

                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE"
                    mode="legalNameAndAddress"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates select="INTERNET_ADDRESSES_VEAT/(URL_BUYER|URL_GENERAL)"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates
                    select="../TYPE_AND_ACTIVITIES_OR_CONTRACTING_ENTITY_AND_PURCHASING_ON_BEHALF"/>
            </s:Organization>
        </pc:contractingAuthority>
    </xsl:template>

    <xsl:template match="NAME_ADDRESSES_CONTACT_VEAT" mode="contact">
        <xsl:call-template name="contractContact"/>
    </xsl:template>

    <!--  
    *********************************************************
    *** F15 VOLUNTARY EX ANTE TRANSPARENCY NOTICE
    *** SECTION II: OBJECT OF THE CONTRACT
    *********************************************************
    -->

    <xsl:template match="OBJECT_VEAT">
        <xsl:apply-templates select="DESCRIPTION_VEAT"/>
        <xsl:apply-templates select="TOTAL_FINAL_VALUE/COSTS_RANGE_AND_CURRENCY_WITH_VAT_RATE"/>
    </xsl:template>

    <xsl:template match="DESCRIPTION_VEAT">
        <xsl:apply-templates select="TITLE_CONTRACT"/>
        <xsl:apply-templates select="LOCATION_NUTS"/>
        <xsl:choose>
            <xsl:when test="TYPE_CONTRACT_LOCATION">
                <xsl:apply-templates select="TYPE_CONTRACT_LOCATION" mode="type_contract"/>
                <xsl:apply-templates select="TYPE_CONTRACT_LOCATION" mode="category"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="TYPE_CONTRACT_DEFENCE"/>
                <!-- TO BE DONE -->
            </xsl:otherwise>
        </xsl:choose>


        <xsl:apply-templates select="NOTICE_INVOLVES_DESC/CONCLUSION_FRAMEWORK_AGREEMENT"/>
        <xsl:apply-templates select="SHORT_CONTRACT_DESCRIPTION"/>
        <xsl:apply-templates select="CPV"/>
        <xsl:apply-templates select="CONTRACT_COVERED_GPA"/>
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



    <!--  
    *********************************************************
    *** F15 VOLUNTARY EX ANTE TRANSPARENCY NOTICE
    *** SECTION IV: PROCEDURE
    *********************************************************
    -->

    <xsl:template match="PROCEDURE_DEFINITION_VEAT">
        <xsl:apply-templates select="TYPE_OF_PROCEDURE_DEF_F15"/>
        <xsl:apply-templates select="AWARD_CRITERIA_VEAT_INFORMATION"/>
        <xsl:apply-templates select="ADMINISTRATIVE_INFORMATION_VEAT"/>
    </xsl:template>

    <!-- contract procedure type -->
    <xsl:template match="TYPE_OF_PROCEDURE_DEF_F15">
        <xsl:call-template name="procedureType">
            <xsl:with-param name="ptElementName" select="local-name(*)"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template match="AWARD_CRITERIA_VEAT_INFORMATION">
        <xsl:apply-templates select="AWARD_CRITERIA_DETAIL_F15"/>
        <xsl:apply-templates select="F15_IS_ELECTRONIC_AUCTION_USABLE"/>
    </xsl:template>

    <!-- contract criteria -->
    <xsl:template
        match="AWARD_CRITERIA_DETAIL_F15[LOWEST_PRICE or MOST_ECONOMICALLY_ADVANTAGEOUS_TENDER_SHORT]">
        <pc:awardCriteriaCombination>
            <pc:AwardCriteriaCombination rdf:about="{$pc_award_criteria_combination_uri_1}">
                <xsl:apply-templates
                    select="LOWEST_PRICE|MOST_ECONOMICALLY_ADVANTAGEOUS_TENDER_SHORT/CRITERIA_DEFINITION"
                />
            </pc:AwardCriteriaCombination>
        </pc:awardCriteriaCombination>
    </xsl:template>



    <xsl:template match="ADMINISTRATIVE_INFORMATION_VEAT">
        <xsl:apply-templates select="FILE_REFERENCE_NUMBER"/>
        <xsl:apply-templates select="PREVIOUS_PUBLICATION_INFORMATION_NOTICE_F15"/>
    </xsl:template>

    <xsl:template match="PREVIOUS_PUBLICATION_INFORMATION_NOTICE_F15"> </xsl:template>

    <!--  
    *********************************************************
    *** F15 VOLUNTARY EX ANTE TRANSPARENCY NOTICE
    *** SECTION V: AWARD OF CONTRACT
    *********************************************************
    -->

    <!-- contract part (lot) with awarded tender -->
    <xsl:template match="AWARD_OF_CONTRACT_DEFENCE" mode="lot">
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
    <xsl:template match="AWARD_OF_CONTRACT_DEFENCE">
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


    <!--  
    *********************************************************
    *** F15 VOLUNTARY EX ANTE TRANSPARENCY NOTICE
    *** SECTION VI: COMPLEMENTARY INFORMATION
    *********************************************************
    -->

    <xsl:template match="COMPLEMENTARY_INFORMATION_VEAT">
        <xsl:apply-templates select="ADDITIONAL_INFORMATION"/>
        <xsl:apply-templates select="PROCEDURES_FOR_APPEAL"/>
        <xsl:apply-templates select="NOTICE_DISPATCH_DATE"/>
    </xsl:template>




    <!--  
    ******************************************************************************************************************
    *** F16 PRIOR INFORMATION DEFENCE
    *** ROOT TEMPLATE
    ******************************************************************************************************************
    -->

    <xsl:template match="PRIOR_INFORMATION_DEFENCE[@CATEGORY='ORIGINAL']">
        <pc:PriorInformationNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:PriorInformationNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}"/>
            <xsl:apply-templates select="FD_PRIOR_INFORMATION_DEFENCE"/>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="FD_PRIOR_INFORMATION_DEFENCE">
        <xsl:apply-templates select="AUTHORITY_PRIOR_INFORMATION_DEFENCE"/>
        <xsl:apply-templates select="OBJECT_WORKS_SUPPLIES_SERVICES_PRIOR_INFORMATION"/>
        <!--  <xsl:apply-templates select="LEFTI_PRIOR_INFORMATION"/> -->
        <xsl:apply-templates select="OTH_INFO_PRIOR_INFORMATION"/>
    </xsl:template>

    <!--  
    *********************************************************
    *** F16 PRIOR INFORMATION DEFENCE
    *** SECTION I: CONTRACTING AUTHORITY
    *********************************************************
    -->

    <!-- contracting entity government organization -->
    <xsl:template match="AUTHORITY_PRIOR_INFORMATION_DEFENCE">
        <!-- covers INC_01 schema type -->
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_PRIOR_INFORMATION"
            mode="contractingAuthority"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_PRIOR_INFORMATION" mode="contact"/>
        <!-- covers INC_01 schema type -->
        <!-- INC_02_1 -->
        <xsl:apply-templates
            select="NAME_ADDRESSES_CONTACT_PRIOR_INFORMATION/FURTHER_INFORMATION/CONTACT_DATA"/>
        <!-- INC_02_1 -->
        <xsl:apply-templates
            select="TYPE_AND_ACTIVITIES_OR_CONTRACTING_ENTITY_AND_PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"
        />
    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_PRIOR_INFORMATION" mode="contractingAuthority">
        <pc:contractingAuthority>
            <s:GovernmentOrganization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId"
                        select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country"
                        select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>

                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE"
                    mode="legalNameAndAddress"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates select="INTERNET_ADDRESSES_PRIOR_INFORMATION/URL_BUYER"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates
                    select="../TYPE_AND_ACTIVITIES_OR_CONTRACTING_ENTITY_AND_PURCHASING_ON_BEHALF"/>
            </s:GovernmentOrganization>
        </pc:contractingAuthority>
    </xsl:template>

    <xsl:template match="NAME_ADDRESSES_CONTACT_PRIOR_INFORMATION" mode="contact">
        <xsl:call-template name="contractContact"/>
    </xsl:template>

    <!--  
    *********************************************************
    *** F16 PRIOR INFORMATION DEFENCE
    *** SECTION II: OBJECT OF THE CONTRACT
    *********************************************************
    -->

    <xsl:template match="OBJECT_WORKS_SUPPLIES_SERVICES_PRIOR_INFORMATION">
        <xsl:apply-templates select="TITLE_CONTRACT"/>
        <xsl:apply-templates
            select="TYPE_CONTRACT_PLACE_DELIVERY_DEFENCE/TYPE_CONTRACT_PI_DEFENCE/TYPE_CONTRACT"
            mode="type_contract"/>
        <xsl:apply-templates
            select="TYPE_CONTRACT_PLACE_DELIVERY_DEFENCE/TYPE_CONTRACT_PI_DEFENCE/TYPE_CONTRACT"
            mode="category"/>
        <xsl:apply-templates select="LOCATION_NUTS"/>
        <xsl:apply-templates select="FRAMEWORK_AGREEMENT" mode="F16"/>
        <xsl:apply-templates select="CPV"/>
        <xsl:apply-templates select="ADDITIONAL_INFORMATION"/>

        <xsl:apply-templates select="QUANTITY_SCOPE_WORKS_DEFENCE"/>
        <xsl:apply-templates select="SCHEDULED_DATE_PERIOD/PERIOD_WORK_DATE_STARTING"/>

    </xsl:template>

    <xsl:template match="QUANTITY_SCOPE_WORKS_DEFENCE">

        <xsl:apply-templates select="TOTAL_QUANTITY_OR_SCOPE" mode="F16"/>
        <xsl:apply-templates select="COSTS_RANGE_AND_CURRENCY"/>

    </xsl:template>

    <xsl:template match="TOTAL_QUANTITY_OR_SCOPE" mode="F16">
        <xsl:call-template name="description"/>
    </xsl:template>


    <xsl:template match="FRAMEWORK_AGREEMENT" mode="F16">
        <!-- <xsl:call-template name="frameworkAgreement"/> -->
    </xsl:template>

    <!--  
    *********************************************************
    *** F16 PRIOR INFORMATION DEFENCE
    *** SECTION III: LEGAL, ECONOMIC, FINANCIAL AND TECHNICAL INFORMATION
    *********************************************************
    -->

    <xsl:template match="LEFTI_PRIOR_INFORMATION">
        <xsl:if test="MAIN_FINANCING_CONDITIONS">
            <xsl:apply-templates select="MAIN_FINANCING_CONDITIONS"/>
        </xsl:if>
        <xsl:apply-templates select="RESERVED_CONTRACTS"/>
    </xsl:template>

    <!--  
    *********************************************************
    *** F16 PRIOR INFORMATION DEFENCE
    *** SECTION VI: COMPLEMENTARY INFORMATION
    *********************************************************
    -->

    <xsl:template match="OTH_INFO_PRIOR_INFORMATION">
        <xsl:apply-templates select="ADDITIONAL_INFORMATION"/>
        <!-- <xsl:apply-templates select="INFORMATION_REGULATORY_FRAMEWORK"/> -->
        <xsl:apply-templates select="NOTICE_DISPATCH_DATE"/>
    </xsl:template>

    <xsl:template match="INFORMATION_REGULATORY_FRAMEWORK"> </xsl:template>

    <!--  
    ******************************************************************************************************************
    *** F17 CONTRACT DEFENCE
    *** ROOT TEMPLATE
    ******************************************************************************************************************
    -->

    <xsl:template match="CONTRACT_DEFENCE[@CATEGORY='ORIGINAL']">
        <pc:ContractNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:ContractNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}"/>
            <xsl:apply-templates select="FD_CONTRACT_DEFENCE"/>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="FD_CONTRACT_DEFENCE">
        <xsl:apply-templates select="CONTRACTING_AUTHORITY_INFORMATION_DEFENCE"/>
        <xsl:apply-templates select="OBJECT_CONTRACT_INFORMATION_DEFENCE"/>
        <xsl:apply-templates select="LEFTI_CONTRACT_DEFENCE"/>
        <xsl:apply-templates select="PROCEDURE_DEFINITION_CONTRACT_NOTICE_DEFENCE"/>
        <xsl:apply-templates select="COMPLEMENTARY_INFORMATION_CONTRACT_NOTICE"/>
    </xsl:template>

    <!--  
    *********************************************************
    *** F17 CONTRACT DEFENCE
    *** SECTION I: CONTRACTING AUTHORITY
    *********************************************************
    -->

    <!-- contracting entity government organization -->
    <xsl:template match="CONTRACTING_AUTHORITY_INFORMATION_DEFENCE">
        <!-- covers INC_01 schema type -->
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contractingAuthority1"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contact1"/>
        <!-- covers INC_01 schema type -->
        <!-- INC_02 -->
        <xsl:apply-templates
            select="NAME_ADDRESSES_CONTACT_CONTRACT/FURTHER_INFORMATION/CONTACT_DATA"/>
        <!-- INC_02 -->
        <xsl:apply-templates
            select="TYPE_AND_ACTIVITIES_OR_CONTRACTING_ENTITY_AND_PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"
        />
    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contractingAuthority1">
        <pc:contractingAuthority>
            <s:GovernmentOrganization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId"
                        select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country"
                        select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>

                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE"
                    mode="legalNameAndAddress"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates select="INTERNET_ADDRESSES_CONTRACT/URL_BUYER"/>
                <!-- internet_addresses schema part -->
                <xsl:apply-templates
                    select="../TYPE_AND_ACTIVITIES_OR_CONTRACTING_ENTITY_AND_PURCHASING_ON_BEHALF"/>
            </s:GovernmentOrganization>
        </pc:contractingAuthority>
    </xsl:template>

    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contact1">
        <xsl:call-template name="contractContact"/>
    </xsl:template>

    <!--  
    *********************************************************
    *** F17 CONTRACT DEFENCE
    *** SECTION II: OBJECT OF THE CONTRACT
    *********************************************************
    -->



    <xsl:template match="OBJECT_CONTRACT_INFORMATION_DEFENCE">
        <xsl:apply-templates select="DESCRIPTION_CONTRACT_INFORMATION_DEFENCE"/>
        <xsl:apply-templates select="QUANTITY_SCOPE"/>
        <xsl:apply-templates select="PERIOD_WORK_DATE_STARTING"/>
    </xsl:template>

    <xsl:template match="DESCRIPTION_CONTRACT_INFORMATION_DEFENCE">
        <xsl:apply-templates select="TITLE_CONTRACT"/>
        <xsl:apply-templates select="TYPE_CONTRACT_DEFENCE/TYPE_CONTRACT" mode="type_contract"/>
        <xsl:apply-templates select="TYPE_CONTRACT_DEFENCE/TYPE_CONTRACT" mode="category"/>
        <xsl:apply-templates select="LOCATION_NUTS"/>
        <xsl:apply-templates select="F17_FRAMEWORK" mode="F17"/>
        <xsl:apply-templates select="CPV"/>
        <xsl:apply-templates select="SHORT_CONTRACT_DESCRIPTION"/>


        <xsl:apply-templates select="F17_DIVISION_INTO_LOTS/F17_DIV_INTO_LOT_YES/F17_ANNEX_B"/>
    </xsl:template>

    <!-- contract part (lot) -->
    <xsl:template match="F17_ANNEX_B">
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
        <xsl:variable name="pc_lot_uri">
            <xsl:value-of select="concat($pc_lot_nm, $lotNumber)"/>
        </xsl:variable>
        <pc:lot>
            <pc:Contract rdf:about="{$pc_lot_uri}">
                <xsl:apply-templates select="LOT_TITLE"/>
                <xsl:apply-templates select="LOT_DESCRIPTION"/>
                <xsl:apply-templates select="CPV"/>
                <xsl:apply-templates select="./NATURE_QUANTITY_SCOPE">
                    <xsl:with-param name="pc_lot_uri">
                        <xsl:value-of select="$pc_lot_uri"/>
                    </xsl:with-param>
                </xsl:apply-templates>
                <xsl:apply-templates select="PERIOD_WORK_DATE_STARTING"/>
            </pc:Contract>
        </pc:lot>
    </xsl:template>

    <xsl:template match="F17_FRAMEWORK">
        <!-- <xsl:call-template name="frameworkAgreement"/>  -->
    </xsl:template>

    <!--  
    *********************************************************
    *** F17 CONTRACT DEFENCE
    *** SECTION III: LEGAL, ECONOMIC, FINANCIAL AND TECHNICAL INFORMATION
    *********************************************************
    -->

    <xsl:template match="LEFTI_CONTRACT_DEFENCE">
        <xsl:apply-templates select="CONTRACT_RELATING_CONDITIONS"/>
    </xsl:template>

    <xsl:template match="CONTRACT_RELATING_CONDITIONS"> </xsl:template>

    <!--  
    *********************************************************
    *** F17 CONTRACT DEFENCE
    *** SECTION IV: PROCEDURE
    *********************************************************
    -->

    <xsl:template match="PROCEDURE_DEFINITION_CONTRACT_NOTICE_DEFENCE">
        <xsl:apply-templates
            select="TYPE_OF_PROCEDURE_DEFENCE/TYPE_OF_PROCEDURE_DETAIL_FOR_CONTRACT_NOTICE_DEFENCE"/>
        <xsl:apply-templates
            select="AWARD_CRITERIA_CONTRACT_NOTICE_INFORMATION/AWARD_CRITERIA_DETAIL"/>
        <xsl:apply-templates select="ADMINISTRATIVE_INFORMATION_CONTRACT_NOTICE_DEFENCE"/>
    </xsl:template>

    <xsl:template match="ADMINISTRATIVE_INFORMATION_CONTRACT_NOTICE_DEFENCE">
        <xsl:apply-templates select="FILE_REFERENCE_NUMBER"/>
        <!--   <xsl:apply-templates select="PREVIOUS_PUBLICATION_INFORMATION_NOTICE_F17"/> -->
        <xsl:apply-templates select="CONDITIONS_OBTAINING_SPECIFICATIONS"/>
        <xsl:apply-templates select="RECEIPT_LIMIT_DATE"/>
        <xsl:apply-templates select="DISPATCH_INVITATIONS_DATE"/>
    </xsl:template>

    <xsl:template match="DISPATCH_INVITATIONS_DATE"> </xsl:template>

    <!-- contract procedure type -->
    <xsl:template match="TYPE_OF_PROCEDURE_DETAIL_FOR_CONTRACT_NOTICE_DEFENCE">
        <xsl:call-template name="procedureType">
            <xsl:with-param name="ptElementName" select="local-name(*)"/>
        </xsl:call-template>
    </xsl:template>

    <!--  
    *********************************************************
    *** F17 CONTRACT DEFENCE
    *** SECTION VI: COMPLEMENTARY INFORMATION
    *********************************************************
    -->

    <xsl:template match="COMPLEMENTARY_INFORMATION_CONTRACT_NOTICE">
        <xsl:apply-templates select="ADDITIONAL_INFORMATION"/>
        <xsl:apply-templates select="PROCEDURES_FOR_APPEAL"/>
        <xsl:apply-templates select="NOTICE_DISPATCH_DATE"/>
    </xsl:template>

    <!--  
    ******************************************************************************************************************
    *** F18 CONTRACT AWARD DEFENCE
    *** ROOT TEMPLATE
    ******************************************************************************************************************
    -->

    <xsl:template match="CONTRACT_AWARD_DEFENCE[@CATEGORY='ORIGINAL']">
        <pc:ContractAwardNotice rdf:about="{$contract_notice_uri}">
            <xsl:if test="$date_pub">
                <pc:publicationDate rdf:datatype="{$xsd_date_uri}">
                    <xsl:value-of select="$date_pub"/>
                </pc:publicationDate>
            </xsl:if>
        </pc:ContractAwardNotice>
        <pc:Contract rdf:about="{$pc_uri}">
            <pc:publicNotice rdf:resource="{$contract_notice_uri}"/>
            <xsl:apply-templates select="FD_CONTRACT_AWARD_DEFENCE"/>
        </pc:Contract>
    </xsl:template>

    <xsl:template match="FD_CONTRACT_AWARD_DEFENCE">
        <pc:kind rdf:resource="{f:getContractKind(@CTYPE,'')}"/>
        <xsl:apply-templates select="CONTRACTING_AUTHORITY_INFORMATION_CONTRACT_AWARD_DEFENCE"/>
        <xsl:apply-templates select="OBJECT_CONTRACT_INFORMATION_CONTRACT_AWARD_NOTICE_DEFENCE"/>
        <xsl:apply-templates select="PROCEDURE_DEFINITION_CONTRACT_AWARD_NOTICE_DEFENCE"/>
        <xsl:apply-templates select="AWARD_OF_CONTRACT_DEFENCE"/>
        <xsl:apply-templates select="COMPLEMENTARY_INFORMATION_CONTRACT_AWARD"/>
    </xsl:template>

    <!--  
    *********************************************************
    *** F18 CONTRACT AWARD DEFENCE
    *** SECTION I: CONTRACTING AUTHORITY
    *********************************************************
    -->

    <xsl:template match="CONTRACTING_AUTHORITY_INFORMATION_CONTRACT_AWARD_DEFENCE">
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD"
            mode="contractingAuthority1"/>
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD" mode="contact1"/>
        <xsl:apply-templates
            select="TYPE_AND_ACTIVITIES_OR_CONTRACTING_ENTITY_AND_PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"
        />
    </xsl:template>

    <!-- contracting authority -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD" mode="contractingAuthority1">
        <pc:contractingAuthority>
            <s:Organization rdf:about="{concat($ted_business_entity_nm, f:getUuid())}">
                <xsl:call-template name="organizationId">
                    <xsl:with-param name="nationalId"
                        select="CA_CE_CONCESSIONAIRE_PROFILE/ORGANISATION/NATIONALID"/>
                    <xsl:with-param name="country"
                        select="(CA_CE_CONCESSIONAIRE_PROFILE/COUNTRY/@VALUE, $country_code)[1]"/>
                </xsl:call-template>

                <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE"
                    mode="legalNameAndAddress"/>
                <xsl:apply-templates select="INTERNET_ADDRESSES_CONTRACT_AWARD/URL_BUYER"/>
                <xsl:apply-templates
                    select="../TYPE_AND_ACTIVITIES_OR_CONTRACTING_ENTITY_AND_PURCHASING_ON_BEHALF"/>
            </s:Organization>
        </pc:contractingAuthority>
    </xsl:template>

    <!-- contract contact -->
    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT_AWARD" mode="contact1">
        <xsl:call-template name="contractContact"/>
    </xsl:template>

    <!--  
    *********************************************************
    *** F18 CONTRACT AWARD DEFENCE
    *** SECTION II: OBJECT OF THE CONTRACT
    *********************************************************
    -->

    <xsl:template match="OBJECT_CONTRACT_INFORMATION_CONTRACT_AWARD_NOTICE_DEFENCE">
        <xsl:apply-templates select="DESCRIPTION_AWARD_NOTICE_INFORMATION_DEFENCE"/>
        <xsl:apply-templates select="TOTAL_FINAL_VALUE"/>
    </xsl:template>

    <xsl:template match="DESCRIPTION_AWARD_NOTICE_INFORMATION_DEFENCE">
        <xsl:apply-templates select="TITLE_CONTRACT"/>
        <xsl:apply-templates select="TYPE_CONTRACT_W_PUB_DEFENCE"/>
        <xsl:apply-templates select="LOCATION_NUTS"/>

        <!--<xsl:apply-templates select="NOTICE_INVOLVES_DESC_DEFENCE"/>-->
        <xsl:apply-templates select="SHORT_CONTRACT_DESCRIPTION"/>
        <xsl:apply-templates select="CPV"/>

    </xsl:template>

    <!--  
    *********************************************************
    *** F18 CONTRACT AWARD DEFENCE
    *** SECTION IV: PROCEDURE
    *********************************************************
    -->

    <xsl:template match="PROCEDURE_DEFINITION_CONTRACT_AWARD_NOTICE_DEFENCE">
        <xsl:apply-templates select="TYPE_OF_PROCEDURE_CONTRACT_AWARD_DEFENCE"/>
        <xsl:apply-templates
            select="AWARD_CRITERIA_CONTRACT_AWARD_NOTICE_INFORMATION_DEFENCE/AWARD_CRITERIA_DETAIL_F18"/>
        <xsl:apply-templates select="ADMINISTRATIVE_INFORMATION_CONTRACT_AWARD_DEFENCE"/>
    </xsl:template>

    <!-- contract procedure type -->
    <xsl:template match="TYPE_OF_PROCEDURE_CONTRACT_AWARD_DEFENCE">
        <xsl:call-template name="procedureType">
            <xsl:with-param name="ptElementName" select="local-name(*)"/>
        </xsl:call-template>
    </xsl:template>

    <!-- contract criteria -->
    <xsl:template
        match="AWARD_CRITERIA_DETAIL_F18[LOWEST_PRICE or MOST_ECONOMICALLY_ADVANTAGEOUS_TENDER_SHORT]">
        <pc:awardCriteriaCombination>
            <pc:AwardCriteriaCombination rdf:about="{$pc_award_criteria_combination_uri_1}">
                <xsl:apply-templates
                    select="LOWEST_PRICE|MOST_ECONOMICALLY_ADVANTAGEOUS_TENDER_SHORT/CRITERIA_DEFINITION"
                />
            </pc:AwardCriteriaCombination>
        </pc:awardCriteriaCombination>
    </xsl:template>


    <xsl:template match="ADMINISTRATIVE_INFORMATION_CONTRACT_AWARD_DEFENCE">
        <xsl:apply-templates select="FILE_REFERENCE_NUMBER"/>
        <!--  <xsl:apply-templates select="PREVIOUS_PUBLICATION_INFORMATION_NOTICE_F18"/> -->
    </xsl:template>



    <!--  
    *********************************************************
    *** F18 CONTRACT AWARD DEFENCE
    *** SECTION VI: COMPLEMENTARY INFORMATION
    *********************************************************
    -->

    <xsl:template match="COMPLEMENTARY_INFORMATION_CONTRACT_AWARD">
        <xsl:apply-templates select="ADDITIONAL_INORMATION"/>
        <xsl:apply-templates select="PROCEDURES_FOR_APPEAL"/>
        <xsl:apply-templates select="NOTICE_DISPATCH_DATE"/>
    </xsl:template>



    <!--
    ******************************************************************************************************************
    *** NAMED TEMPLATES
    ******************************************************************************************************************
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
        <xsl:if
            test="CA_CE_CONCESSIONAIRE_PROFILE/(CONTACT_POINT|ATTENTION|(E_MAILS/E_MAIL)|PHONE|FAX)/text()">
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

    <xsl:template name="legalDescription">
        <xsl:if test="text()">
            <dcterms:legalDescription xml:lang="{$lang}">
                <xsl:value-of select="normalize-space(.)"/>
            </dcterms:legalDescription>
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
        <xsl:variable name="procedure_type_uri" select="f:getProcedureType($ptElementName,'')"/>
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
                    <xsl:number
                        count="AWARD_OF_CONTRACT|AWARD_AND_CONTRACT_VALUE[LOT_NUMBER = $lotNumber]"
                    />
                </xsl:when>
                <xsl:otherwise>
                    <xsl:number count="AWARD_OF_CONTRACT|AWARD_AND_CONTRACT_VALUE[not(LOT_NUMBER)]"
                    />
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="tenderUri" select="concat($contractUri, '/tender/', $tenderIndex)"/>
        <pc:awardedTender>
            <pc:Tender rdf:about="{$tenderUri}">
                <xsl:choose>
                    <xsl:when
                        test="$awardNode/ECONOMIC_OPERATOR_NAME_ADDRESS/CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME|$awardNode/CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME_CHP">
                        <pc:bidder>
                            <xsl:apply-templates
                                select="$awardNode/ECONOMIC_OPERATOR_NAME_ADDRESS/CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME|$awardNode/CONTACT_DATA_WITHOUT_RESPONSIBLE_NAME_CHP"
                            />
                        </pc:bidder>
                    </xsl:when>
                    <xsl:otherwise>
                        <pc:bidder rdf:resource="{concat($ted_business_entity_nm, f:getUuid())}"/>
                    </xsl:otherwise>
                </xsl:choose>
                <xsl:apply-templates
                    select="$awardNode/(CONTRACT_VALUE_INFORMATION|INFORMATION_VALUE_CONTRACT)/COSTS_RANGE_AND_CURRENCY_WITH_VAT_RATE"
                    mode="offeredPrice">
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
            <xsl:with-param name="datatype_regex"
                >\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}</xsl:with-param>
            <xsl:with-param name="datatype_uri" select="$xsd_date_time_uri"/>
        </xsl:call-template>
    </xsl:template>

    <xsl:template name="organizationId">
        <xsl:param name="nationalId"/>
        <xsl:param name="country"/>

        <xsl:if test="not(empty($nationalId))">
            <adms:identifier>
                <adms:Identifier rdf:about="{concat($ted_identifier_nm, f:getUuid())}">
                    <skos:notation>
                        <xsl:value-of select="f:getBusinessEntityId($country, $nationalId)"/>
                    </skos:notation>
                </adms:Identifier>
            </adms:identifier>
        </xsl:if>
    </xsl:template>

    <!--
    ******************************************************************************************************************
    *** COMMON TEMPLATES
    ******************************************************************************************************************
    -->

    <xsl:template match="NOTICE_RELATION_PUBLICATION">
        <xsl:variable name="agreement_type_uri"
            select="f:getNoticeType(../NOTICE_RELATION_PUBLICATION/@NOTICE,'')"/>
        <xsl:if test="$agreement_type_uri">
            <pc:previousNotice rdf:about="{$agreement_type_uri}"/>
        </xsl:if>
    </xsl:template>


    <xsl:template match="TYPE_AND_ACTIVITIES_OR_CONTRACTING_ENTITY_AND_PURCHASING_ON_BEHALF">
        <xsl:apply-templates select="TYPE_AND_ACTIVITIES"/>
        <xsl:apply-templates select="ACTIVITIES_OF_CONTRACTING_ENTITY"/>
    </xsl:template>

    <!-- contracting authority further information -->
    <xsl:template match="CONTACT_DATA">
        <xsl:call-template name="basicBusinessEntity"/>
    </xsl:template>

    <!-- contracting authority name and address -->
    <xsl:template match="CA_CE_CONCESSIONAIRE_PROFILE" mode="legalNameAndAddress">
        <xsl:call-template name="legalName"/>
        <xsl:call-template name="postalAddress"/>
    </xsl:template>

    <!-- contracting authority buyer profile url -->
    <xsl:template match="URL_BUYER">
        <xsl:if test="text()">
            <xsl:for-each select="tokenize(text(),' ')">
                <pc:profile>
                    <xsl:value-of select="."/>
                </pc:profile>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>
    
    <!-- website with general information -->
    <xsl:template match="URL_GENERAL">
        <xsl:if test="text()">
            <xsl:for-each select="tokenize(text(),' ')">
                <foaf:page>
                            <xsl:value-of select="."/>
                </foaf:page>
            </xsl:for-each>
        </xsl:if>
    </xsl:template>

    <!-- type contract -->
    <xsl:template match="TYPE_CONTRACT|TYPE_CONTRACT_LOCATION_WORKS|F07_CONTRACT_TYPE">

        <xsl:if test="@VALUE|@CONTRACT_TYPE">
            <xsl:variable name="contract_kind_uri"
                select="f:getContractKind(@VALUE|@CONTRACT_TYPE,'')"/>
            <xsl:if test="$contract_kind_uri">
                <pc:kind rdf:resource="{$contract_kind_uri}"/>
            </xsl:if>
        </xsl:if>

        <xsl:if test="@SERVICES_CATEGORY">
            <xsl:variable name="services_category"
                select="f:getServiceCategory(@SERVICES_CATEGORY,'[3-5]|6(a|b)?|[7-9]|1[0-9]?|2[0-7]?')"/>
            <xsl:if test="$services_category">
                <pc:kind rdf:resource="{$services_category}"/>
            </xsl:if>
        </xsl:if>
        <!--    <xsl:when test="@CONTRACT_TYPE">
                <xsl:variable name="contract_kind_uri" select="f:getContractKind(@CONTRACT_TYPE,'')"/>
                <xsl:if test="$contract_kind_uri">
                    <pc:kind rdf:resource="{$contract_kind_uri}"/>
                </xsl:if>
            </xsl:when> -->

    </xsl:template>

    <xsl:template match="TYPE_CONTRACT_LOCATION|TYPE_CONTRACT_DEFENCE|TYPE_CONTRACT_PI_DEFENCE"
        mode="type_contract">
        <xsl:if test="TYPE_CONTRACT/@VALUE">
            <xsl:variable name="contract_kind_uri"
                select="f:getContractKind(TYPE_CONTRACT/@VALUE,'')"/>
            <xsl:if test="$contract_kind_uri">
                <pc:kind rdf:resource="{$contract_kind_uri}"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <xsl:template match="TYPE_CONTRACT_LOCATION|TYPE_CONTRACT_DEFENCE|TYPE_CONTRACT_PI_DEFENCE"
        mode="category">
        <xsl:choose>
            <xsl:when test="SERVICE_CATEGORY/text()">
                <xsl:variable name="services_category"
                    select="f:getServiceCategory(SERVICE_CATEGORY/text(),'[3-5]|6(a|b)?|[7-9]|1[0-9]?|2[0-7]?')"/>
                <xsl:if test="$services_category">
                    <pc:kind rdf:resource="{$services_category}"/>
                </xsl:if>
            </xsl:when>
            <xsl:when test="SERVICE_CATEGORY_DEFENCE/text()">
                <xsl:variable name="services_category"
                    select="f:getServiceCategory(SERVICE_CATEGORY_DEFENCE/text(),'[3-9]|1[0-9]?|2[0-6]?')"/>
                <xsl:if test="$services_category">
                    <pc:kind rdf:resource="{$services_category}"/>
                </xsl:if>
            </xsl:when>
        </xsl:choose>



    </xsl:template>

    <!-- contracting authority kind and main activity  -->
    <xsl:template match="TYPE_AND_ACTIVITIES">
        <xsl:if test="TYPE_OF_CONTRACTING_AUTHORITY">
            <xsl:variable name="authority_kind_uri"
                select="f:getAuthorityKind(TYPE_OF_CONTRACTING_AUTHORITY/@VALUE,'')"/>
            <xsl:if test="$authority_kind_uri">
                <pc:authorityKind rdf:resource="{$authority_kind_uri}"/>
            </xsl:if>
        </xsl:if>
        <xsl:if test="TYPE_OF_ACTIVITY">
            <xsl:variable name="authority_activity_uri"
                select="f:getAuthorityOrMainActivity(TYPE_OF_ACTIVITY[1]/@VALUE,'')"/>
            <xsl:if test="$authority_activity_uri">
                <pc:mainActivity rdf:resource="{$authority_activity_uri}"/>
            </xsl:if>
        </xsl:if>
    </xsl:template>

    <!-- activity of contracting entity -->
    <xsl:template match="ACTIVITIES_OF_CONTRACTING_ENTITY">
        <xsl:choose>
            <xsl:when test="ACTIVITY_OF_CONTRACTING_ENTITY">
                <xsl:variable name="authority_activity_uri"
                    select="f:getAuthorityOrMainActivity(ACTIVITY_OF_CONTRACTING_ENTITY[1]/@VALUE,'')"/>
                <xsl:if test="$authority_activity_uri">
                    <pc:mainActivity rdf:resource="{$authority_activity_uri}"/>
                </xsl:if>
            </xsl:when>
            <xsl:otherwise>
                <xsl:if test="ACTIVITY_OF_CONTRACTING_ENTITY_OTHER">
                    <xsl:variable name="authority_activity_uri"
                        select="f:getAuthorityOrMainActivity(ACTIVITY_OF_CONTRACTING_ENTITY_OTHER[1]/@VALUE,'')"/>
                    <xsl:if test="$authority_activity_uri">
                        <pc:mainActivity rdf:resource="{$authority_activity_uri}"/>
                    </xsl:if>
                </xsl:if>
            </xsl:otherwise>
        </xsl:choose>
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
                <s:Country>
                    <xsl:value-of select="@VALUE"/>
                </s:Country>
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
    <xsl:template
        match="TITLE_CONTRACT|CONTRACT_TITLE|LOT_TITLE|TITLE_NOTICE_BUYER_PROFILE|TITLE_QUALIFICATION_SYSTEM">
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
    <xsl:template
        match="DESCRIPTION_OF_CONTRACT|SHORT_CONTRACT_DESCRIPTION|SHORT_DESCRIPTION_CONTRACT|LOT_DESCRIPTION|DESCRIPTION">
        <xsl:call-template name="description"/>
    </xsl:template>

    <!-- additional information -->
    <xsl:template match="ADDITIONAL_INFORMATION|ADDITIONAL_INFORMATION_ABOUT_LOTS">
        <xsl:if test="self::node()">
            <xsl:call-template name="description"/>
        </xsl:if>
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
        <xsl:variable name="id_pre" select="(ORDER_C, position())[1]"/>

        <xsl:variable name="id">
            <xsl:choose>
                <xsl:when test="string(number($id_pre))=$id_pre">
                    <xsl:value-of select="$id_pre"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="f:slugify($id_pre,'TED')"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:variable>

        <xsl:call-template name="awardCriterion">
            <xsl:with-param name="isLowestPrice" select="false()"/>
            <xsl:with-param name="name" select="CRITERIA"/>
            <xsl:with-param name="weight" select="WEIGHTING"/>
            <xsl:with-param name="id" select="$id"/>
        </xsl:call-template>
    </xsl:template>

    <!-- contract file identifier -->
    <xsl:template match="FILE_REFERENCE_NUMBER|REFERENCE_NUMBER_ATTRIBUTED">
        <adms:identifier>
            <adms:Identifier rdf:about="{$pc_identifier_uri_1}">
                <skos:notation>
                    <xsl:value-of select="normalize-space(.)"/>
                </skos:notation>
            </adms:Identifier>
        </adms:identifier>
    </xsl:template>

    <!-- number of received tenders -->
    <xsl:template match="OFFERS_RECEIVED_NUMBER">
        <pc:numberOfTenders rdf:datatype="{$xsd_non_negative_integer_uri}">
            <xsl:value-of select="text()"/>
        </pc:numberOfTenders>
    </xsl:template>

    <!-- contract agreed price -->
    <xsl:template
        match="COSTS_RANGE_AND_CURRENCY_WITH_VAT_RATE|TOTAL_FINAL_VALUE/COSTS_RANGE_AND_CURRENCY_WITH_VAT_RATE">
        <pc:agreedPrice>
            <xsl:call-template name="price">
                <xsl:with-param name="priceUri" select="$pc_agreed_price_uri"/>
            </xsl:call-template>
        </pc:agreedPrice>
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

    <!-- contract award date -->
    <xsl:template match="CONTRACT_AWARD_DATE">
        <xsl:call-template name="getDateProperty">
            <xsl:with-param name="property">pc:awardDate</xsl:with-param>
        </xsl:call-template>
    </xsl:template>

    <!--
    *********************************************************
    *** EMPTY TEMPLATES
    *********************************************************
    -->
    <xsl:template match="text()|@*"/>

</xsl:stylesheet>
