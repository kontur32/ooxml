import module namespace parseXLSX = "http://www.iro37.ru/stasova/api/v1.1/parseXLSX" at '../../xlsx/funct/parseXLSX-to-TRCI.xqm';

let $file := file:read-binary(
   "C:\Program Files (x86)\BaseX\webapp\ooxml\test\xlsx\data\эталон.xlsx"
  )
 
let $результат := 
    parseXLSX:xlsx( $file ) 
  
return
   $результат