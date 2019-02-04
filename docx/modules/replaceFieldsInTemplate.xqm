module namespace fields= "http://iro37.ru/xq/modules/docx/fields/replace";

declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

declare 
  %private 
function fields:endPos( $r as element (w:r) ) as xs:integer {
  let $endPos :=
     for $i in $r/following-sibling::*
     count $c
     return 
       if ($i[w:fldChar/@w:fldCharType="end"])
       then ($c)
       else ()
   return $endPos[1]  
};

declare 
  %private 
function fields:toReplace (
  $fieldRuns as element(w:r)*, 
  $data as element(table)
) as element(w:r)* {
   let $fieldAsText :=  normalize-space(string-join($fieldRuns/data()))
     return
       if ( $data/row[@id="fields"]/cell[@id=$fieldAsText] )
       then ( 
         element { "w:r" }{
           attribute { "w:rsidR"} { "filldocx"},
           element { "w:t" } {
              attribute { "xml:space" } { "preserve" },
              $data/row/cell[@id=$fieldAsText]/text()
           }
         }
       )
       else ( )
};

declare
  %public 
function fields:replaceFieldsInTemplate (
  $xmlTpl as element ( w:document ),
  $data as element ( table )
) as element( w:document ) {
   $xmlTpl update 
   for $p in ./w:body/w:p[w:r[w:fldChar]]
   for  $r in $p/w:r[w:fldChar/@w:fldCharType="begin"]

   let $fld := $r/following-sibling::*[position()<=fields:endPos( $r )]
   
   let $toReplace := fields:toReplace ($fld, $data)
   return
     if( $toReplace )
     then
      (
        insert node  $toReplace before $r,
        delete node $fld,
        delete node $r
      )
      else ()
};