module namespace postXLSX = "http://iro37.ru/xq/modules/xlsx";

import module namespace parseRawTRCI = "http://www.iro37.ru/stasova/TRCI-parse" at "funct/parseTRCI.xqm";

declare
  %rest:POST
  %rest:path (  "/xlsx/api/parse/raw-trci" )
  %rest:form-param ( "data", "{ $data }" )
  %rest:consumes( "multipart/form-data" )
  %output:method( "xml" ) 
function  postXLSX:rawTRCI ( $data ){
 parseRawTRCI:from-xlsx( xs:base64Binary( $data ) )
};