<xsl:stylesheet
	version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:template match="/">
<S:Envelope xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
	<S:Body>
		<ns2:request xmlns:ns2="http://www.datapower.com/schemas/management"
			domain="{$x_param_source_domain}">
			<ns2:do-export format="ZIP" all-files="false"
				persisted="true">
				<ns2:object class="{$x_param_object_class}" name="{$x_param_object_name}" ref-objects="true"
					ref-files="true" include-debug="false" />
			</ns2:do-export>
		</ns2:request>
	</S:Body>
</S:Envelope>
	</xsl:template>
</xsl:stylesheet>
