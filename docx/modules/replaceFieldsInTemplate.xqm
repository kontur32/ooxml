module namespace fields= "http://iro37.ru/xq/modules/docx/fields/replace";

declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

declare variable $fields:delimiter := "|";

(:~
 : ЕЩЕ НЕ РАБОТАЕТ
 : Эта функция возвращает поля из шаблона в виде стоки.
 : @param $template  шаблон в формате w:document
 : @param $data  данные для заполения шаблона в формате TRCI
 : @return возвращает обработанный w:document
 :)
declare
  %public 
function fields:getFieldsAsString (
  $template as element ( w:document )
) as xs:string* {
   for $p in $template/w:body/w:p[ w:r[ w:fldChar ] ]
   for  $r in $p/w:r[ w:fldChar/@w:fldCharType="begin" ]
   let $fieldsToBeReplased := $r/following-sibling::*[ position() <= fields:endPos( $r ) ]
   return 
      normalize-space( string-join( $fieldsToBeReplased ) )
};


(:~
 : АЛЬФА-версия
 : Эта функция заменяет поля в шаблоне документа.
 : @param $template  шаблон в формате w:document
 : @param $data  данные для заполения шаблона в формате TRCI
 : @return возвращает обработанный w:document
 :)
declare
  %public 
function fields:replaceFieldsInTemplate (
  $template as element ( w:document ),
  $data as element ( table )
) as element( w:document ) {
   $template update 
   for $p in ./w:body/w:p[ w:r[ w:fldChar ] ]
   for  $r in $p/w:r[ w:fldChar/@w:fldCharType="begin" ]

   let $fieldsToBeReplased := $r/following-sibling::*[ position() <= fields:endPos( $r ) ]
   
   let $replaceWith := fields:replaceWith ( $fieldsToBeReplased, $data )
   return
     if( $replaceWith )
     then
      (
        insert node $replaceWith before $r,
        delete node $fieldsToBeReplased,
        delete node $r
      )
      else ()
};

(:~
 : Эта функция возвращает позицию конечного узла w:r поля, 
 : начинающегося с узла $r.
 : @param $r узлы w:r, начиная от первого узла поля и до конца документа
 : @return число
 :)
declare 
  %private 
function fields:endPos( $r as element ( w:r ) ) as xs:integer {
  let $endPos :=
     for $i in $r/following-sibling::*
     count $c
     return 
       if ($i[ w:fldChar/@w:fldCharType="end" ])
       then ( $c )
       else ( )
   return $endPos[ 1 ]  
};

(:~
 : Эта функция генерирует содержимые для замены.
 : @param $fieldRuns  узлы поля
 : @param $data  данные для заполения шаблона в формате TRCI
 : @return возвращает строку
 :)
declare 
  %private 
function fields:replaceWith (
  $fieldRuns as element( )*, (: узлы внутри поля :)
  $data as element( table )
) as element( w:r )* {
   let $fieldAsText := 
     let $string := normalize-space( string-join( $fieldRuns/data() ) )
     return 
       if ( contains( $string, $fields:delimiter ) )
       then (
         normalize-space( substring-before( $string, $fields:delimiter ) )
       )
       else (
         $string
       )
     
     return
       if ( $data/row[ @id="fields" ]/cell[ @id=$fieldAsText ] )
       then ( 
         element { "w:r" }{
           attribute { "w:rsidR"} { "filldocx" },
           element { "w:t" } {
              attribute { "xml:space" } { "preserve" },
              $data/row/cell[ @id=$fieldAsText ]/text()
           }
         }
       )
       else ( )
};