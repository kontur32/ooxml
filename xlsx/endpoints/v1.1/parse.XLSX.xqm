module namespace xlsx = "http://iro37.ru/xq/modules/xlsx";

import module namespace parseXLSX = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "../../funct/parseXLSX-to-TRCI.xqm";

declare
  %rest:POST
  %rest:path (  "/ooxml/api/v1.1/xlsx/parse/workbook" )
  %rest:form-param ( "data", "{ $data }", "" )
  %rest:consumes( "multipart/form-data" )
  %output:method( "xml" ) 
function  xlsx:parse ( $data ){
  if( $data instance of map(*) )
  then(
    let $raw :=  map:get( $data, map:keys( $data )[ 1 ] )
    return
      parseXLSX:xlsx( xs:base64Binary( $raw ) )
  )
  else(
    if( $data )
    then(
      parseXLSX:xlsx( xs:base64Binary( $data ) )
    )
    else(
      <error>данные не удалось получить</error>
    )
  )
};