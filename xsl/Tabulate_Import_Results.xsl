<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<!-- 
	$import-results = /*[local-name()='Envelope']/*[local-name()='Body']/*[local-name()='response']/*[local-name()='import']/import-results
	
	&import-results/imported-objects/object
	$import-results/exec-script-results/cfg-result
	
	$import-results/imported-files/file
	$import-results/file-copy-log/file-result
 -->

	<xsl:variable name="import-results"
				  select="/*[local-name()='Envelope']/*[local-name()='Body']/*[local-name()='response']/*[local-name()='import']/import-results"/>
	
	<xsl:variable name="imported-objects-object" select="$import-results/imported-objects/object"/>
	<xsl:variable name="exec-script-results-cfg-result" select="$import-results/exec-script-results/cfg-result"/>
	
	<xsl:variable name="exec-script-results-imported-files-file" select="$import-results/imported-files/file"/>
	<xsl:variable name="exec-script-results-file-copy-log-file-result" select="$import-results/file-copy-log/file-result"/>
		
	<xsl:template match="/">

		<html>
			<head>
			<style>
			table, th, td {border: 1px solid black;}
			th, td {padding: 3px;}
			.css_highlight { background: pink; }
			.css_normal { background: white; }
			</style>
			</head>
			
			<body>
			
			<h2>DataPower Export / Import Utility</h2>
			
			This utility allows the export from a source DataPower and domain to a target DataPower and domain.<p/>
			The utility makes an XMI / SOMA call to the source, and subsequently makes an XMI / SOMA call to the target.
			
			<h3>Details</h3>
			<table border="1">
				<tr><td>Exported from host: </td>		<td><xsl:value-of select="$x_param_source_soma_host"/></td></tr>
				<tr><td>Exported device name: </td>		<td><xsl:value-of select="$import-results/export-details/device-name"/></td></tr>
				<tr><td>Exported from domain: </td>		<td><xsl:value-of select="$import-results/export-details/domain"/></td></tr>
				<tr><td>Imported to host: </td>			<td><xsl:value-of select="$x_param_target_soma_host"/><br/></td></tr>
				<tr><td>Imported to domain: </td>		<td><xsl:value-of select="$import-results/@domain"/><br/></td></tr>
			</table>
			<br/>
			Any highlighted cells below indicate either:
			<ul>
				<li>Password Alias objects may need to have password set</li>
				<li>Key or Certificate files may need to be uploaded</li>
			</ul>
			since the import process does not cater for these.
			<p/>
			<hr/>
			
			<h3>Export File: Object Content / Object Import Results</h3>
			<table border="1">
				<tr><th colspan="2">Export Content</th><th colspan="2">Import Intent</th><th colspan="2">Import Target</th></tr>
				<tr><th>class</th><th>name</th><th>import-debug</th><th>overwrite</th><th>Exists in target</th><th>Import result</th></tr>
				<xsl:apply-templates select="$imported-objects-object"/>
			</table>
			
			<hr/>
			
			<h3>Export File: File Content / File Import Results</h3>
			<table border="1">
				<tr><th>Export Content</th><th>Import Intent</th><th colspan="2">Import Target</th></tr>
				<tr><th>name</th><th>overwrite</th><th>Comparison</th><th>Import result</th></tr>
				<xsl:apply-templates select="$exec-script-results-imported-files-file"/>
			</table>
			
			<hr/>
			Imported date: <xsl:value-of select="$import-results/export-details/current-date"/>
			at: <xsl:value-of select="$import-results/export-details/current-time"/><p/>
			
			</body>
		</html>	
		
	</xsl:template>
		
	<!-- Imported object output -->
	<xsl:template match="object">
		<xsl:variable name="class" select="@class"/>
		<xsl:variable name="name" select="@name"/>
		<xsl:variable name="corrresponding-cfg-result"
					  select="$exec-script-results-cfg-result[@class = $class][@name = $name]"/>
		
		<xsl:variable name="bg-style">
			<xsl:choose>
				<xsl:when test="$class = 'PasswordAlias'">css_highlight</xsl:when>
				<xsl:when test="$class = 'CryptoKey'">css_highlight</xsl:when>
				<xsl:when test="$class = 'CryptoCertificate'">css_highlight</xsl:when>
				<xsl:otherwise>css_normal</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<tr>
		<td class="{$bg-style}"><xsl:value-of select="@class"/></td>
		<td class="{$bg-style}"><i><xsl:value-of select="@name"/></i></td>
		<td><xsl:value-of select="@import-debug"/></td>
		<td><xsl:value-of select="@overwrite"/></td>
	
		<td><xsl:value-of select="@status"/></td>	<!-- Does the object already exist in target -->
		<td><xsl:value-of select="$corrresponding-cfg-result/@status"/></td>	<!-- Has there been a successful import -->
		</tr>
	</xsl:template>
	
	<!-- Imported file output -->
	<xsl:template match="file">
	
		<xsl:variable name="name" select="@name"/>
		
		<xsl:variable name="bg-style">
			<xsl:choose>
				<xsl:when test="starts-with($name, 'cert:')">css_highlight</xsl:when>
				<xsl:otherwise>css_normal</xsl:otherwise>
			</xsl:choose>
		</xsl:variable>
		
		<xsl:variable name="corrresponding-file-result"
					  select="$exec-script-results-file-copy-log-file-result[@name = $name]"/>

		<tr>
		<td class="{$bg-style}"><xsl:value-of select="@name"/></td>
		<td><xsl:value-of select="@overwrite"/></td>
		<td class="{$bg-style}"><xsl:value-of select="@status"/></td>

		<td><xsl:value-of select="$corrresponding-file-result/@result"/></td>	<!-- Has there been a successful import? -->
		</tr>
	</xsl:template>
	
</xsl:stylesheet>