module namespace restDocx= "http://iro37.ru//api/ooxml/docx/template/complete";

import module namespace docx= "http://iro37.ru/xq/modules/docx" at "lib/docxFillWithTrci.xqm";

declare
  %rest:POST
  %rest:path ( "/api/v1/ooxml/docx/template/complete" )
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

(:--------работает с Postman------------------------:)
declare
  %rest:POST
  %rest:path ( "/api/v1.1/ooxml/docx/template/complete" )
  %rest:consumes( "multipart/form-data" ) 
  %rest:form-param( "data", "{ $data }" )
  %rest:form-param( "template", "{ $template }" )
function  restDocx:fillTemplateSingle2( $data, $template ) {
 
  let $formData := 
    try{
      parse-xml( convert:binary-to-string( map:get( $data, map:keys( $data )[1] ) ) )
    /table
    }
    catch* { <error>Не верный формат данных</error> }
    
  let $formTemplate := map:get( $template, map:keys( $template )[1] ) 
    return
    (
    <rest:response>
      <http:response status="200">
        <http:header name="Content-Disposition" value="attachment; filename=response.docx" />
        <http:header name="Content-type" value="application/octet-stream"/>
      </http:response>
    </rest:response>,  
    docx:fillTemplateWithTrci( $formTemplate,  $formData )
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