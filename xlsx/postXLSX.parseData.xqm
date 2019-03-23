module namespace postXLSX = "http://iro37.ru/xq/modules/xlsx";

import module namespace parseTRCI = "http://www.iro37.ru/stasova/TRCI-parse" at "funct/parseTRCI.xqm";

declare
  %rest:POST
  %rest:path ( "/xlsx/api/parse" )
  %rest:form-param( "data", "{ $data }" )
  %rest:form-param( "model", "{ $model }" )
  %output:media-type( "xml" )
function postXLSX:parseData ( $data, $model ) {
 let $trciData := parseTRCI:from-xlsx( map:get ( $data, map:keys ( $data )[1] ) )
 let $trciModel :=  parse-xml( convert:binary-to-string( map:get( $model, map:keys( $model )[1] ) ) )/table
 return
  parseTRCI:data( $trciData, $trciModel , "http://localhost:8984/trac/api/processing/parse/")
};

(:
declare
  %rest:POST
  %rest:path (  "/xlsx/api/parse/raw-trci" )
  %rest:form-param ( "data", "{$data}" )
  %rest:consumes( "multipart/form-data" )
  %output:method( "xml" ) 
function  postXLSX:fillTemplateMulti ( $data ){
 Parse:from-xlsx( xs:base64Binary($data) )
};
:)
