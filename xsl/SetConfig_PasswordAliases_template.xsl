 <xsl:stylesheet
	version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:template match="/">
<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
	<S:Body>
		<ns2:request xmlns:ns2="http://www.datapower.com/schemas/management"
			domain="{$x_param_target_domain}">
			<ns2:set-config>
				<xsl:copy-of select="admin-services-settings/PasswordAlias-Set/PasswordAlias"/>
			</ns2:set-config>
		</ns2:request>
	</S:Body>
</S:Envelope>
	</xsl:template>
</xsl:stylesheet>