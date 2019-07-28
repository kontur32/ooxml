(:
  модуль для тестирования фукнции docxFillWithTrci.xqm
:)

import module namespace docx= "http://iro37.ru/xq/modules/docx" at "../docx/lib/docxFillWithTrci.xqm"; 
import module namespace config = 'http://iro37.ru/xq/modules/ooxml/config.xqm' at '../config.xqm';

declare function local:compare (
    $bin1 as xs:base64Binary,
    $bin2 as xs:base64Binary,
    $docName as xs:string
  )
{
   abs(
     compare(
       string( archive:extract-binary( $bin1, $docName ) ),
       string( archive:extract-binary( $bin2, $docName ) )
     )
   )
};

let $testDataDir := config:param( 'testDataDir' )
let $dataPath := $testDataDir || "ooxmlData02.xml"
let $referencePath :=  $testDataDir || "reference01.docx"
let $templatePath :=  $testDataDir || "CV-template.docx"

let $data := doc( $dataPath )/table
let $template := file:read-binary( $templatePath )

let $a := file:read-binary( $referencePath )
let $b := docx:fillTemplateWithTrci( $template, $data )

let $mediaList := archive:entries( $a )[ starts-with( text(), "word/media/" ) ]/text()
let $docList := ( 'word/document.xml', 'word/_rels/document.xml.rels', $mediaList )
let $result := for-each( $docList,  local:compare( $a, $b, ? ) )
return 
  (
    for $i in 1 to count( $docList )
    return
      $docList[ $i ] || " : " ||  local:compare( $a, $b, $docList[ $i ] ),
    "Итог : " || sum( $result )
  )