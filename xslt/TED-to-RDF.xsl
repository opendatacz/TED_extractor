<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    
    xmlns:dcterms="http://purl.org/dc/terms/"
    xmlns:pc="http://purl.org/procurement/public-contracts#"
    xmlns:rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#"
    
    xpath-default-namespace="http://publications.europa.eu/TED_schema/Export"
    version="2.0">
    
    <xsl:output encoding="UTF-8" indent="yes" method="xml" normalization-form="NFC"/>
    
    <xsl:template match="/">
        <rdf:RDF>
            <xsl:apply-templates/>
        </rdf:RDF>
    </xsl:template>
    
    <!-- Catch all empty template -->
    <xsl:template match="text()|@*"/>
    
</xsl:stylesheet>