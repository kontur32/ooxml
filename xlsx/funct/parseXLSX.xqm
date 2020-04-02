(:~ 
 : Модуль является частью проекта iro
 : содержит функции для обработки файлов xlsx
 :
 : @author   iro/ssm
 : @see      https://github.com/kontur32/stasova/blob/dev/README.md
 : @version  2.0.1
 :)
module  namespace xlsx = 'http://iro37.ru.ru/xq/modules/xlsx';

declare default element namespace "http://schemas.openxmlformats.org/spreadsheetml/2006/main";
declare namespace r="http://schemas.openxmlformats.org/officeDocument/2006/relationships";

(:~
 : Функция заменяет строковыми значениями индексы в текстовых ячейках 
 : листа данных xlsx 
 :
 : @param $data-sheet as document-node() - лист данных
 : @param $strings-sheet as document-node() - лист строковых значений 
 : @return возвращает лист данных xlsx переданный в $data-sheet, 
 : в котором значения индексов текстовых ячеек заменены их строковыми значениями
 : 
 : @author iro/ssm
 : @since 2.0.1
 : 
:)
declare 
  %public
function xlsx:index-to-text( 
    $data-sheet as document-node(), 
    $strings-sheet as document-node() 
  ) as node()
{
  let $strings := $strings-sheet/sst/si
  let $new := 
          copy $c := $data-sheet 
          modify 
                for $i in $c//c[ @t = 's' ]
                return replace value of node $i/v with $strings[number($i/v/text())+1]//t/text()
          return $c
  return $new
};

(:~
 : Функция преобразует лист данных xlsx формат TRCI (Table/Row/Cell/@Id)
 :
 : @param $data-sheet as document-node() - лист данных
 : @return возвращает лист данных xlsx  $data-sheet преобразованный в формат, 
 : TRCI (Table/Row/Cell/@Id)
 : 
 : @author iro/ssm
 : @since 2.0.1
 : 
:)
declare 
  %public
function xlsx:row-to-TRCI(
  $data-sheet as document-node()
) as element()
{
  let $heads := 
        for $cell in $data-sheet//row[1]
        return $cell//v/text()
  
  return 
  element {QName('','table')}
  {    
  for $row in $data-sheet//row[position()>1 and normalize-space (string-join(c/v/text()))]
  return
    element {QName('','row')}
      { 
      for $cell in $row/c[v/text()]
      return 
          element {QName('','cell')} 
            {
              attribute {'label'} {$heads[count($cell/preceding-sibling::*)+1]}, 
              $cell/v/text()
            }
      }
  }
};

declare 
  %public
function xlsx:col-to-TRCI(
  $data-sheet as document-node()
) as element ()
{  
  let $rows :=  $data-sheet//row[c[1]/v[normalize-space(text())]] (: непустые строки:)  
  let $col-numbers := 
    max (
      for $i in $rows
      return count($i/c)
    )
  
  return
  element {QName ('', 'table')}
  { 
    for $i in 2 to $col-numbers
    return
      element {QName ('', 'row')}
        {
          for $r in $rows
          return
            element {QName('', 'cell')}
            {
              attribute {'label'} {$r/c[1]/v/text()},
              $r/c[$i]/v/text()
            }
        }
   }
};

declare 
  %public
function xlsx:binary-row-to-TRCI(
  $file as xs:base64Binary, 
  $sheet-path as xs:string 
) as element()
{
  let $sheet_data := parse-xml(
              archive:extract-text($file, $sheet-path))
   let $strings := parse-xml(
                archive:extract-text($file, 'xl/sharedStrings.xml'))              
   let $data := xlsx:index-to-text($sheet_data, $strings)             
   return 
    xlsx:row-to-TRCI( $data)
};  

declare 
  %public
function xlsx:binary-col-to-TRCI(
  $file as xs:base64Binary, 
  $sheet-path as xs:string 
) as element()
{
  let $sheet_data := parse-xml(
              archive:extract-text($file, $sheet-path))
   let $strings := parse-xml(
                archive:extract-text($file, 'xl/sharedStrings.xml'))              
   let $data := xlsx:index-to-text($sheet_data, $strings)             
   return 
    xlsx:col-to-TRCI( $data)
};