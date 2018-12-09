module namespace restDocx= "http://iro37.ru/xq/modules/docx/rest";
import module namespace docx= "http://iro37.ru/xq/modules/docx" at "fillDocxForm.xqm";

declare
  %rest:POST("{$data}")
  %rest:path ( "/docx/post" )
  %rest:consumes( "multipart/*" ) 
  %output:media-type( "application/octet-stream" )
function  restDocx:post ( $data ) {
  let $tpl := xs:base64Binary ( $data[1] )
  let $formData := parse-xml( convert:binary-to-string($data[2] ) )/table
  return  
    docx:tpl-with-trci ( $tpl,  $formData )        
};