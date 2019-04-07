module namespace restDocx= "http://iro37.ru/xq/modules/docx/rest";

import module namespace docx= "http://iro37.ru/xq/modules/docx" at "lib/docxFillWithTrci.xqm";

declare
  %rest:POST
  %rest:path ( "/docx/api/fillTemplateMulti" )
  %rest:form-param ("template", "{$template}")
  %rest:form-param ("data", "{$data}")
  %rest:consumes( "multipart/form-data" ) 
  %output:media-type( "application/octet-stream" )
function  restDocx:fillTemplateMulti ( $template, $data ) {
  
  let $recordsData := parse-xml( $data )/multi/table
  let $entries :=
    for $i in $recordsData
    order by $i/@id/data()
    return 
      docx:fillTemplateWithTrci( xs:base64Binary( $template ),   $i )
  let $archiveEntriesNames := 
    for $i in $recordsData/@id/data()
    order by $i
    count $c 
    return $c || "-" || $i || ".docx"
  return
    archive:create( $archiveEntriesNames, $entries )
};