module namespace postXLSX = "http://iro37.ru/xq/modules/xlsx";

import module namespace Parse = "http://www.iro37.ru/stasova/TRCI-parse" at "parseTRCI.xqm";

declare
  %rest:POST
  %rest:path ( "/xlsx/api/parse" )
  %rest:form-param( "data", "{ $data }" )
  %rest:form-param( "model", "{ $model }" )
  %output:media-type( "xml" )
function postXLSX:post ( $data, $model ) {
 let $trciData := Parse:from-xlsx( map:get ( $data, map:keys ( $data )[1] ) )
 let $trciModel :=  parse-xml( convert:binary-to-string( map:get( $model, map:keys( $model )[1] ) ) )/table
 return
  Parse:data( $trciData, $trciModel , "http://localhost:8984/trac/api/processing/parse/")
};

declare
  %rest:POST ( "{ $data }" )
  %rest:path ( "/xlsx/api/parse1" )
  %rest:consumes( "multipart/mixed" )
  %output:media-type( "xml" )
function postXLSX:post1 ( $data ) {
  $data[2]
};