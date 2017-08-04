export project_location=/Users/steve/Applications/eclipse/workspace-sse/export-import

# cd $project_location/bash

export working=$project_location/bash/working
echo "******** Working folder for temporary files produced by this script: $working"
export xsl=$project_location/xsl
echo "******** Folder containing XSL transforms used by this script: $xsl"
export results=$project_location/results
echo "******** Folder containing results of this script: $results"

# cd $project_location/bash

export xmi_port=5550
export xmi_user=xmi-user
export xmi_pwrd=XM1-US3R

# ======== The following variables are used in both this script file and in the XSL transforms
export x_param_source_domain=XB60-B2B-Tutorial
export x_param_target_domain=XB60-B2B-Target

# Provide DataPower object type and name (if name is blank then all objects of the chosen type)
# export x_param_object_class=B2BProfile
export x_param_object_class=B2BGateway
export x_param_object_name=

export x_param_source_soma_host=source-datapower 	# hostname in /etc/hosts
export x_param_target_soma_host=target-datapower 	# hostname in /etc/hosts

# ======== Following is an XSL template that will produce an XMI request for export
export xmi_export_template=$xsl/do-export_template.xsl
export null_xml=$xsl/null.xml
export xmi_export_request=$working/$x_param_object_class.export.request.xml

# ======== Produce an XMI request for export
xsltproc --verbose\
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
 https://$x_param_source_soma_host:$xmi_port/service/mgmt/current\
 -k -u$xmi_user:$xmi_pwrd\
 >$xmi_export_response

echo "******** Received xmi_export_response to file: $xmi_export_response"
# ======== Produce an XMI request for import
export xmi_import_request=$working/$x_param_object_class.import.request.xml
export export_import=$xsl/export-import.xsl

xsltproc --verbose\
 -stringparam x_param_target_domain $x_param_target_domain \
 $export_import $xmi_export_response >$xmi_import_request

echo "******** Produced xmi_import_requestfile: $xmi_import_request"
# ======== Call XMI to impport to target DataPower and domain
export xmi_import_response=$results/$x_param_object_class.import.response.xml

curl -d @$xmi_import_request\
 https://$x_param_target_soma_host:$xmi_port/service/mgmt/current\
 -k -u$xmi_user:$xmi_pwrd\
  >$xmi_import_response

echo "******** Received xmi_import_response to file: $xmi_import_response"
# ========  Create readable import results file to HTML
export tabulate_file=$xsl/tabulate-import-results.xsl

export html_file=$results/$x_param_object_class.import.response.html

xsltproc --verbose\
 -stringparam x_param_target_soma_host $x_param_target_soma_host\
 -stringparam x_param_source_soma_host $x_param_source_soma_host\
 $tabulate_file $xmi_import_response >$html_file
 
 echo "******** Produced readable form of import results in file: $html_file"
 
