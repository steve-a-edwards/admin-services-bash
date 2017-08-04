export project_location=/Users/steve/Applications/eclipse/workspace-sse/admin-services-bash

# cd $project_location/bash
# ./export-import.sh

# ======== The following variables are used in both this script file and in the XSL transforms
# ###### export x_param_source_domain=XB60-B2B-Tutorial
# ###### export x_param_target_domain=XB60-B2B-Target

# ###### export x_param_source_soma_host=source-datapower:5550 	# hostname in /etc/hosts
# ###### export x_param_target_soma_host=target-datapower:5550 	# hostname in /etc/hosts

export settings_file=$project_location/settings/admin-services-settings.xml
export x_param_source_domain="$(xmllint --xpath 'string(/admin-services-settings/B2B-Synchronization/source-datapower/@domain)' $settings_file)"
export x_param_target_domain="$(xmllint --xpath 'string(/admin-services-settings/B2B-Synchronization/target-datapower/@domain)' $settings_file)"

export x_param_source_soma_host="$(xmllint --xpath 'string(/admin-services-settings/B2B-Synchronization/source-datapower/@soma_host_port)' $settings_file)"
export x_param_target_soma_host="$(xmllint --xpath 'string(/admin-services-settings/B2B-Synchronization/target-datapower/@soma_host_port)' $settings_file)"

echo "****************** $x_param_source_domain"

export working=$project_location/bash/working
echo "******** Working folder for temporary files produced by this script: $working"
export xsl=$project_location/xsl
echo "******** Folder containing XSL transforms used by this script: $xsl"
export results=$project_location/results
echo "******** Folder containing results of this script: $results"

# cd $project_location/bash

export xmi_user=xmi-user
export xmi_pwrd=XM1-US3R

# Provide DataPower object type and name (if name is blank then all objects of the chosen type)
# export x_param_object_class=B2BProfile
export x_param_object_class=B2BGateway
export x_param_object_name=


# export xsltproc_switch=--verbose # provides lots of output
export xsltproc_switch=--timing	   # provides less output!

# ======== Following is an XSL template that will produce an XMI request for export
export xmi_export_template=$xsl/do-export_template.xsl
export null_xml=$xsl/null.xml
export xmi_export_request=$working/$x_param_object_class.export.request.xml

# ======== Produce an XMI request for export
xsltproc $xsltproc_switch\
 $xmi_export_template $null_xml\
 -stringparam x_param_source_domain $x_param_source_domain\
 -stringparam x_param_object_class $x_param_object_class\
 -stringparam x_param_object_name $x_param_object_name\
 >$xmi_export_request
 
echo "******** Produced xmi_export_request file: $xmi_export_request"
# ======== Call XMI for export from source DataPower and domain
export xmi_export_response=$working/$x_param_object_class.export.response.xml
echo xmi_export_response

curl -d @$xmi_export_request\
 https://$x_param_source_soma_host/service/mgmt/current\
 -k -u$xmi_user:$xmi_pwrd\
 >$xmi_export_response

echo "******** Received xmi_export_response to file: $xmi_export_response"
# ======== Produce an XMI request for import
export xmi_import_request=$working/$x_param_object_class.import.request.xml
export export_import=$xsl/export-import.xsl

xsltproc $xsltproc_switch\
 -stringparam x_param_target_domain $x_param_target_domain \
 $export_import $xmi_export_response >$xmi_import_request

echo "******** Produced xmi_import_requestfile: $xmi_import_request"
# ======== Call XMI to import to target DataPower and domain
export xmi_import_response=$results/$x_param_object_class.import.response.xml

curl -d @$xmi_import_request\
 https://$x_param_target_soma_host/service/mgmt/current\
 -k -u$xmi_user:$xmi_pwrd\
  >$xmi_import_response

echo "******** Received xmi_import_response to file: $xmi_import_response"
# ========  Create readable import results file to HTML
export tabulate_file=$xsl/tabulate-import-results.xsl

export html_file=$results/$x_param_object_class.import.response.html

xsltproc $xsltproc_switch\
 -stringparam x_param_target_soma_host $x_param_target_soma_host\
 -stringparam x_param_source_soma_host $x_param_source_soma_host\
 $tabulate_file $xmi_import_response >$html_file
 
echo "******** Produced readable form of import results in file: $html_file"
 
# ======== Produce an XMI request for setting PasswordAliases
 export xmi_password_aliases_request=$working/password_aliases.import.request.xml
 export set_config_file=$xsl/set-config-PasswordAliases_template.xsl
 
 xsltproc $xsltproc_switch\
 -stringparam x_param_target_domain $x_param_target_domain \
 $set_config_file $settings_file >$xmi_password_aliases_request
 
 echo "******** Produced xmi_password_aliases_request file: $xmi_password_aliases_request"
 # ======== Call XMI to set PasswordAlias config on target DataPower and domain
export xmi_password_aliases_response=$results/password_aliases.import.response.xml

curl -d @$xmi_password_aliases_request\
 https://$x_param_target_soma_host/service/mgmt/current\
 -k -u$xmi_user:$xmi_pwrd\
  >$xmi_password_aliases_response

echo "******** Received xmi_password_aliases_response to file: $xmi_password_aliases_response"

