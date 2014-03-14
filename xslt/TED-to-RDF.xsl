<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:gr="http://purl.org/goodrelations/v1#"
    xmlns:dcterms="http://purl.org/dc/terms/" xmlns:pc="http://purl.org/procurement/public-contracts#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#" xmlns:s="http://schema.org/" xmlns:vcard="http://www.w3.org/2006/vcard/ns#"
    xmlns:f="http://opendata.cz/xslt/functions#" exclude-result-prefixes="f" xpath-default-namespace="http://publications.europa.eu/TED_schema/Export"
    version="2.0">

    <xsl:import href="functions.xsl"/>

    <xsl:output encoding="UTF-8" indent="yes" method="xml" normalization-form="NFC"/>

    <xsl:variable name="pc_nm" select="'http://purl.org/procurement/public-contracts#'"/>
    <xsl:variable name="lod_nm" select="'http://linked.opendata.cz/resource/'"/>
    <xsl:variable name="ted_nm" select="concat($lod_nm, 'ted.europa.eu/')"/>
    <xsl:variable name="ted_pc_nm" select="concat($ted_nm, 'public-contract/')"/>
    <xsl:variable name="doc_id" select="/TED_EXPORT/@DOC_ID"/>
    <xsl:variable name="pc_uri" select="concat($ted_pc_nm, $doc_id)"/>

    <xsl:template match="/">
        <rdf:RDF>
            <xsl:apply-templates select="TED_EXPORT/FORM_SECTION"/>
        </rdf:RDF>
    </xsl:template>

    <!-- F02 CONTRACT -->
    <xsl:template match="CONTRACT[@CATEGORY='ORIGINAL']">
        <pc:Contract rdf:about="{$pc_uri}">
            <xsl:apply-templates select="FD_CONTRACT"/>
        </pc:Contract>
    </xsl:template>


    <xsl:template match="FD_CONTRACT">
        <!-- contract kind -->
        <pc:kind rdf:resource="{f:getContractKind(@CTYPE)}"/>

        <xsl:apply-templates select="CONTRACTING_AUTHORITY_INFORMATION"/>
    </xsl:template>

    <xsl:template match="CONTRACTING_AUTHORITY_INFORMATION">
        <!-- contracting authority -->
        <pc:contractingAuthority>
            <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contractingAuthority"/>
        </pc:contractingAuthority>

        <!-- contact info -->
        <xsl:apply-templates select="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contact"/>

        <!-- on behalf of -->
        <xsl:apply-templates
            select="TYPE_AND_ACTIVITIES_AND_PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF/PURCHASING_ON_BEHALF_YES/CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY"
        />
    </xsl:template>

    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contractingAuthority">
        <!-- contracting authority -->
        <gr:BusinessEntity>
            <!-- contracting authority legal name and address -->
            <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE" mode="legalNameAndAddress"/>

            <!-- buyer profile url -->
            <xsl:apply-templates select="INTERNET_ADDRESSES_CONTRACT/URL_BUYER"/>

            <!-- authority kind and main activity-->
            <xsl:apply-templates select="../TYPE_AND_ACTIVITIES_AND_PURCHASING_ON_BEHALF/TYPE_AND_ACTIVITIES"/>
        </gr:BusinessEntity>
    </xsl:template>

    <xsl:template match="NAME_ADDRESSES_CONTACT_CONTRACT" mode="contact">
        <!-- contract contact -->
        <xsl:if test="CA_CE_CONCESSIONAIRE_PROFILE/(CONTACT_POINT|ATTENTION|(E_MAILS/E_MAIL)|PHONE|FAX)/text()">
            <pc:contact>
                <vcard:VCard>
                    <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE/CONTACT_POINT"/>
                    <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE/ATTENTION"/>
                    <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE/PHONE"/>
                    <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE/E_MAILS/E_MAIL"/>
                    <xsl:apply-templates select="CA_CE_CONCESSIONAIRE_PROFILE/FAX"/>
                </vcard:VCard>
            </pc:contact>
        </xsl:if>
    </xsl:template>

    <xsl:template match="CA_CE_CONCESSIONAIRE_PROFILE" mode="legalNameAndAddress">
        <xsl:call-template name="legalName"/>
        <xsl:call-template name="postalAddress"/>
    </xsl:template>

    <!-- contracting authority buyer profile url -->
    <xsl:template match="URL_BUYER">
        <xsl:if test="text()">
            <pc:buyerProfile rdf:resource="{text()}"/>
        </xsl:if>
    </xsl:template>

    <!-- contracting authority kind and main activity  -->
    <xsl:template match="TYPE_AND_ACTIVITIES">
        <xsl:if test="TYPE_OF_CONTRACTING_AUTHORITY">
            <pc:authorityKind rdf:resource="{f:getAuthorityKind(TYPE_OF_CONTRACTING_AUTHORITY/@VALUE)}"/>
        </xsl:if>

        <xsl:if test="TYPE_OF_ACTIVITY">
            <pc:mainActivity rdf:resource="{f:getAuthorityActivity(TYPE_OF_ACTIVITY[1]/@VALUE)}"/>
        </xsl:if>
    </xsl:template>

    <!-- on behalf of -->
    <xsl:template match="CONTACT_DATA_OTHER_BEHALF_CONTRACTING_AUTORITHY">
        <pc:onBehalfOf>
            <gr:BusinessEntity>
                <xsl:call-template name="legalName"/>
                <xsl:call-template name="postalAddress"/>
            </gr:BusinessEntity>
        </pc:onBehalfOf>
    </xsl:template>

    <xsl:template name="legalName">
        <gr:legalName>
            <xsl:value-of select="normalize-space(ORGANISATION/OFFICIALNAME/text())"/>
        </gr:legalName>
    </xsl:template>

    <xsl:template name="postalAddress">
        <xsl:if test="(ADDRESS|TOWN|POSTAL_CODE|COUNTRY)/text()">
            <s:address>
                <s:PostalAddress>
                    <xsl:apply-templates select="ADDRESS"/>
                    <xsl:apply-templates select="TOWN"/>
                    <xsl:apply-templates select="POSTAL_CODE"/>
                    <xsl:apply-templates select="COUNTRY"/>
                </s:PostalAddress>
            </s:address>
        </xsl:if>
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
            <vcard:note>
                <xsl:value-of select="text()"/>
            </vcard:note>
        </xsl:if>
    </xsl:template>

    <xsl:template match="ATTENTION">
        <xsl:if test="text()">
            <vcard:fn>
                <xsl:value-of select="text()"/>
            </vcard:fn>
        </xsl:if>
    </xsl:template>

    <xsl:template match="E_MAIL">
        <xsl:if test="text()">
            <vcard:email>
                <xsl:attribute namespace="http://www.w3.org/1999/02/22-rdf-syntax-ns#" name="resource">
                    <xsl:text>mailto:</xsl:text>
                    <xsl:value-of select="text()"/>
                </xsl:attribute>
            </vcard:email>
        </xsl:if>
    </xsl:template>

    <xsl:template match="PHONE">
        <xsl:if test="text()">
            <vcard:tel>
                <rdf:Description>
                    <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Work"/>
                    <rdf:value>
                        <xsl:value-of select="text()"/>
                    </rdf:value>
                </rdf:Description>
            </vcard:tel>
        </xsl:if>
    </xsl:template>

    <xsl:template match="FAX">
        <xsl:if test="text()">
            <vcard:tel>
                <rdf:Description>
                    <rdf:type rdf:resource="http://www.w3.org/2006/vcard/ns#Fax"/>
                    <rdf:value>
                        <xsl:value-of select="text()"/>
                    </rdf:value>
                </rdf:Description>
            </vcard:tel>
        </xsl:if>
    </xsl:template>



    <!-- Catch all empty template -->
    <xsl:template match="text()|@*"/>

</xsl:stylesheet>
