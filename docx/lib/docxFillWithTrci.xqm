module namespace docx= "http://iro37.ru/xq/modules/docx";

import module namespace fields = "http://iro37.ru/xq/modules/docx/fields/replace" 
  at "replaceFieldsInTemplate.xqm"; 
import module namespace 
  tables= "http://iro37.ru/xq/modules/docx/tables/replace" 
  at "replaceTablesInTemplate.xqm";
  
import  module namespace pic= "http://iro37.ru/xq/modules/docx/pic/replace" 
  at "replacePicturesInTemplate.xqm";

declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

declare
  %public 
function 
  docx:fillTemplateWithTrci ( 
    $template as xs:base64Binary, 
    $data as element ( table ) 
  ) as xs:base64Binary {
  
  let $templateWithPic := 
    if( $data/row[ @id = "pictures" ]/cell[1]/text() )
    then(
       pic:replacePicturesInTemplate( $template, $data )
    )
    else(
      $template
    )
  let $xmlTpl := 
      parse-xml ( 
          archive:extract-text( $templateWithPic,  'word/document.xml' )
      )/w:document
  let $result := docx:fillOoxmlWithTrci ( $xmlTpl, $data )
 
  return 
    archive:update( 
      $templateWithPic, 
      "word/document.xml", 
      serialize( $result )
     )     
};

declare
  %private 
function 
  docx:fillOoxmlWithTrci ( 
    $template as element ( w:document ), 
    $data as element ( table ) 
  )  {
    let $resultFlds := fields:replaceFieldsInTemplate ( $template, $data )      
    let $resultTbl := tables:replaceTablesInTemplate ( $resultFlds, $data )  
    return 
      $resultTbl
};