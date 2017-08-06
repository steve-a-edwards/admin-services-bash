<xsl:stylesheet
	version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:template match="/">
<soapenv:Envelope xmlns:soapenv="http://schemas.xmlsoap.org/soap/envelope/">
	<soapenv:Body>
		<dp:RestartDomainRequest xmlns:dp="http://www.datapower.com/schemas/appliance/management/3.0">
			<dp:Domain><xsl:value-of select="$x_param_target_domain"/></dp:Domain>
		</dp:RestartDomainRequest>
	</soapenv:Body>
</soapenv:Envelope>
	</xsl:template>
</xsl:stylesheet>
