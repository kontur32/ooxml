module namespace xlsx = "http://iro37.ru/xq/modules/xlsx";

import module namespace parse = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" 
  at "../../funct/parseXLSX-to-TRCI.xqm";

declare
  %rest:POST
  %rest:path("/ooxml/api/v1.1/xlsx/parse/workbook")
  %rest:form-param("data", "{$data}", "")
  %rest:form-param("column-direction", "{$column-direction}", "")
  %rest:consumes("multipart/form-data")
  %output:method("xml") 
function  xlsx:parse ($data, $column-direction as xs:string){
  if($data instance of map(*))
  then(
    let $raw :=  map:get($data, map:keys($data)[1])
    return
      parse:xlsx(xs:base64Binary($raw), $column-direction)
  )
  else(
    if($data)
    then(parse:xlsx(xs:base64Binary($data), $column-direction))
    else(<error>данные не удалось получить</error>)
  )
};