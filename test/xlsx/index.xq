import module  namespace xlsx = 'http://iro37.ru.ru/xq/modules/xlsx' at '../../xlsx/funct/parseXLSX.xqm';

let $data := doc(
  "C:\Users\kontu\Downloads\Ямпольский А — копия\xl\worksheets\sheet9.xml"
)

let $str :=  doc(
  "C:\Users\kontu\Downloads\Ямпольский А — копия\xl\sharedStrings.xml"
)

return
   xlsx:index-to-text( $data, $str )