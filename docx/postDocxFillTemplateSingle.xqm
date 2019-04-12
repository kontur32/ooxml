module namespace restDocx= "http://iro37.ru/xq/modules/docx/rest";
import module namespace docx= "http://iro37.ru/xq/modules/docx" at "lib/docxFillWithTrci.xqm";

declare
  %rest:POST
  %rest:path ( "/ooxml/api/v1/docx/single" )
  %rest:consumes( "multipart/form-data" ) 
  %rest:form-param( "data", "{ $data }" )
  %rest:form-param( "template", "{ $template }" )
function  restDocx:fillTemplateSingle( $data as xs:string, $template as xs:base64Binary ) {
 
  let $formData := 
    try{
      parse-xml( $data )
    /table
    }
    catch* { <error>Не верный формат данных</error> }
    
  let $formTemplate := convert:string-to-base64( $template )
    return
    (
    <rest:response>
      <http:response status="200">
        <http:header name="Content-Disposition" value="attachment; filename=response.docx" />
        <http:header name="Content-type" value="application/octet-stream"/>
      </http:response>
    </rest:response>,  
    docx:fillTemplateWithTrci( $template,  $formData )
    )
};


(: ------------ старый варинат ---------------------------:)
declare
  %rest:POST("{ $data }")
  %rest:path ( "/ooxml/api/v1/docx/single1" ) (:/docx/api/fillTemplate:)
  %rest:consumes( "multipart/*" ) 
  %output:media-type( "application/octet-stream" )
function  restDocx:fillTemplateSingle1 ( $data ) {
  let $tpl := xs:base64Binary ( $data[ 1 ] )
  let $formData := parse-xml(  convert:binary-to-string( $data[ 2 ] ) )/table
  return  
    docx:fillTemplateWithTrci ( $tpl,  $formData )        
};