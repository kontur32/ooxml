module namespace parse = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX";

import module  namespace xlsx = 'http://iro37.ru.ru/xq/modules/xlsx' at 'parseXLSX.xqm';

(: парсит все листы кники xlsx в формат trci :)

declare 
  %public
function 
  parse:xlsx( $data as xs:base64Binary )
as element( data ){
  let $sheetsList := archive:entries($data )[contains( ./text(), 'xl/worksheets/sheet')]/text()
  let $rels1 := parse-xml( archive:extract-text( $data, 'xl/_rels/workbook.xml.rels') )
  let $rels2 := parse-xml( archive:extract-text( $data, 'xl/workbook.xml') )
  let $trci :=
    for $sheetPath in $sheetsList
    let $target := substring-after( $sheetPath, 'xl/' )
    let $sheetID := $rels1/*:Relationships/*:Relationship[ @*:Target= $target ]/@*:Id/data()
    let $sheetName := $rels2//*:sheet[ @*:id/data() = $sheetID ]/@*:name/data()
    order by $target
    return
     xlsx:binary-row-to-TRCI( xs:base64Binary( $data ), $sheetPath )
     update insert node attribute {'label'} { $sheetName } into .
  return
    <data>{ $trci }</data>
};