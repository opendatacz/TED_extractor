# TED extractor

[UnifiedViews](https://github.com/UnifiedViews/Core) DPU to extract RDF from [Tenders European Daily](http://ted.europa.eu/) XML dumps.

## Source data

* [Bulk download of last month's data for registered users](https://twitter.com/EUTenders/status/442235852916539393)
* Samples in [FTP server](ftp://ted.europa.eu/)
* All relevant XML Schemas can be [downloaded by registered users of TED](http://ted.europa.eu/TED/misc/bulkDownloadExport.do)

## Transformation

* Follows [these URI patterns](https://docs.google.com/document/d/187nVDaKn_e24goqnwExCyiDZowDfnEoqauRWyu55G7M/edit).
* [XSLT for British ContractsFinder](https://github.com/opendatacz/GB-PCO/blob/master/notices2pc.xslt) might be helpful.
* Functions from [XSLT for Czech public contracts](https://github.com/opendatacz/VVZ_extractor/blob/master/xslt/pc.xsl) might be reused.
