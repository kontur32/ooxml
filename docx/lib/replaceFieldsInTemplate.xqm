module namespace fields= "http://iro37.ru/xq/modules/docx/fields/replace";

declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";
declare namespace wp = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing";

declare variable $fields:delimiter := ";";

(:~
 : АЛЬФА ВЕРСИЯ
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
  let $fieldsList :=
     for $p in $template//w:p[ w:r[ w:fldChar ] ]
       for  $r in $p/w:r[ w:fldChar/@w:fldCharType="begin" ]
       let $pos := 
          if( $p/../../../../name() = "w:body" )
          then(
            count( $p/../../../preceding-sibling::* ) + 1 
          )
          else(
            count( $p/preceding-sibling::* ) + 1
          )
       let $fieldsToBeReplaсed := 
         string-join(
           $r/following-sibling::*[ position() <= fields:endPos( $r ) ]
         )
       return 
          normalize-space(  $fieldsToBeReplaсed || " ; position :: " || $pos )  
  let $picList := 
    for $pic in $template//w:drawing
    let $picLabel := $pic/wp:inline/wp:docPr/@title/data()
    where $picLabel
    let $pos := 
      if( $pic/../../../../../name() = "w:tbl" )
      then(
        count( $pic/../../../../../preceding-sibling::* ) + 1
      )
      else(
        count( $pic/parent::*/parent::*/preceding-sibling::* ) + 1
      )
    return 
       $picLabel || " ; inputType :: img " || " ; position :: " || $pos
  return 
    for $i in ( $fieldsList, $picList )
    order by xs:integer( substring-after( $i, "position :: " ) )
    return 
      $i
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
   for $p in .//w:p[ w:r[ w:fldChar ] ]
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
     let $rPr := $fieldRuns/w:rPr[1]
     return
       if ( $data/row[ @id="fields" ]/cell[ @id=$fieldAsText ] )
       then ( 
         element { "w:r" }{
           attribute { "w:rsidR"} { "filldocx" },
           $rPr, (: свойства блока текста из шаблона, в т.ч. стиль :)
           element { "w:t" } {
              attribute { "xml:space" } { "preserve" },
              normalize-space( $data/row[ @id="fields" ]/cell[ @id=$fieldAsText ]/text() )
           }
         }
       )
       else ()
};