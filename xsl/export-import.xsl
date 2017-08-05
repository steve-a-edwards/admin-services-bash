<xsl:stylesheet
	version="1.0"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
    
    <xsl:template match="/">
    	<xsl:variable name="file-text"
    		select="*[local-name() = 'Envelope']/*[local-name() = 'Body']/*[local-name() = 'response']/*[local-name() = 'file']/text()"/>
<S:Envelope xmlns:dp="http://www.datapower.com/schemas/management"
	xmlns:S="http://schemas.xmlsoap.org/soap/envelope/">
	<S:Body>
		<ns2:request domain="{$x_param_target_domain}"
			xmlns:ns2="http://www.datapower.com/schemas/management">
			<ns2:do-import source-type="ZIP" overwrite-files="true"
				overwrite-objects="true">
				<ns2:input-file><xsl:value-of select="$file-text"></xsl:value-of>
				</ns2:input-file>
			</ns2:do-import>
		</ns2:request>
	</S:Body>
</S:Envelope>
    </xsl:template>
</xsl:stylesheet>




