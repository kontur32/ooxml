module namespace restDocx= "http://iro37.ru/xq/modules/docx/rest";
import module namespace docx= "http://iro37.ru/xq/modules/docx" at "modules/docxFillWithTrci.xqm";

declare
  %rest:POST("{ $data }")
  %rest:path ( "/docx/api/fillTemplate" )
  %rest:consumes( "multipart/*" ) 
  %output:media-type( "application/octet-stream" )
function  restDocx:fillTemplateSingle ( $data ) {
  let $tpl := xs:base64Binary ( $data[1] )
  let $formData := parse-xml( convert:binary-to-string( $data[ 2 ] ) )/table
  return  
    docx:fillTemplateWithTrci ( $tpl,  $formData )        
};