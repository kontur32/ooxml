module namespace restDocx= "http://iro37.ru/xq/modules/docx/rest";
import module namespace docx= "http://iro37.ru/xq/modules/docx" at "modules/docxFillWithTrci.xqm";

declare
  %rest:POST("{ $data }")
  %rest:path ( "/ooxml/api/v1/docx/single" ) (:/docx/api/fillTemplate:)
  %rest:consumes( "multipart/form-data" ) 
  %output:media-type( "application/octet-stream" )
function  restDocx:fillTemplateSingle ( $data ) {
  let $tpl := xs:base64Binary ( $data[1] )
  let $formData := parse-xml( convert:binary-to-string( $data[ 2 ] ) )/table
  return  
    docx:fillTemplateWithTrci ( $tpl,  $formData )        
};

declare
  %rest:POST
  %rest:path ( "/ooxml/api/v1/docx/single1" )
  %rest:consumes( "multipart/form-data" ) 
  %rest:form-param( "data", "{ $data }" )
  %rest:form-param( "template", "{ $template }" )
function  restDocx:fillTemplateSingle1( $data, $template ) {
  let $tpl := 
    xs:base64Binary( map:get( $template, map:keys( $template )[1]  ) )
  let $formData := 
    parse-xml( 
      convert:binary-to-string( map:get( $data, map:keys( $data )[1] ) ) 
    )/table
  return
  (
    <rest:response>
      <http:response status="200">
        <http:header name="Content-Disposition" value="attachment; filename=response.docx" />
        <http:header name="Content-type" value="application/octet-stream"/>
      </http:response>
    </rest:response>,  
    docx:fillTemplateWithTrci( $tpl,  $formData )
  ) 
};