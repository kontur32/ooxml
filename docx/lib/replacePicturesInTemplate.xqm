module namespace pic= "http://iro37.ru/xq/modules/docx/pic/replace";

declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";
declare namespace wp = "http://schemas.openxmlformats.org/drawingml/2006/wordprocessingDrawing";
declare namespace r = "http://schemas.openxmlformats.org/officeDocument/2006/relationships";
declare namespace a = "http://schemas.openxmlformats.org/drawingml/2006/main";

(:~
 : Эта функция вставляет изображения в шаблон документа.
 : @param $template  шаблон в формате docx  в формате xs:base64Binary
 : @param $data  данные для заполения шаблона в формате TRCI
 : @return возвращает обработанный шаблон в формате xs:base64Binary
 :)
declare
  %public 
function pic:replacePicturesInTemplate (
  $template as xs:base64Binary,
  $data as element( table )
  )  
{
  let $xmlTpl := 
        parse-xml ( 
            archive:extract-text( $template,  'word/document.xml' )
        )/w:document
  
  let $rels := 
    parse-xml ( 
         archive:extract-text( $template,  'word/_rels/document.xml.rels' )
        )

let $picTitleToReplace := $xmlTpl//w:drawing/wp:inline/wp:docPr/@title[ data() = $data/row[ @id = "pictures" ]/cell/@id/data() ]/data()

let $newPicPath := 
 for $picRec in $xmlTpl//w:drawing[wp:inline/wp:docPr/@title/data() = $picTitleToReplace ]
 let $picId := $picRec//a:blip/@r:embed/data()
 let $picLink := "word/" || xs:string( $rels/child::*/child::*[ @Id = $picId ]/@Target/data() )
 return $picLink

let $newPicBin := 
  for $p in  $data/row[ @id = "pictures" ]/cell[ @id = $picTitleToReplace ]/text() 
  return xs:base64Binary( $p )

return 
  map { "newPicPath" : $newPicPath, "newPicBin" : $newPicBin}   
};