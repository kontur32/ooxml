module namespace docx= "http://iro37.ru/xq/modules/docx";
 
declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

declare 
function 
  docx:tpl-with-trci ( 
    $rowTpl as xs:base64Binary, 
    $data as element ( table ) 
  ) as xs:base64Binary {
  
  let $xmlTpl := 
      parse-xml ( 
          archive:extract-text($rowTpl,  'word/document.xml')
      )/w:document
  
  let $result := docx:ooxml-with-trci ( $xmlTpl, $data )
  
  return 
    archive:update( $rowTpl, "word/document.xml", serialize($result) )     
};

declare
  %private 
function 
  docx:ooxml-with-trci ( 
    $template as element ( w:document ), 
    $data as element ( table ) 
  )  {
    let $result :=
      $template 
        update 
          for $fld in ./w:body/w:p/w:r[ w:instrText ]
          let $field := normalize-space ( $fld/w:instrText )
          return 
             replace node $fld/w:instrText with <w:t>{ $data/row [ @id = "fields" ]/cell [@id = $field ]/text() }</w:t>
    
    let $resultFlds := $result update delete node ./w:body/w:p/w:r[ w:fldChar ]
    
    let $resultTbl := 
        $resultFlds update 
          for $tblData in  $data/row[@id="tables"]/cell
          let $tbl := ./w:body/w:tbl[ w:tblPr [ w:tblCaption/@w:val/data() = $tblData/@id/data() ] ]
          let $r := 
              for $row in $tblData/table/row
              return 
               <w:tr w:rsidR="docxFill" w:rsidRPr="docxFill" w:rsidTr="docxFill">
               {
                for $cell in $row/cell
                return
                  <w:tc>
                    <w:p 
                      w:rsidR="docxFill" 
                      w:rsidRPr="docxFill" 
                      w:rsidRDefault="docxFill" 
                      w:rsidP="docxFill">
                      <w:r w:rsidRPr="docxFill">
                        <w:t>{ $cell/text() }</w:t>
                      </w:r>
                    </w:p>
                  </w:tc> 
               }
               </w:tr>
                        
          return 
            insert node $r into $tbl
    
    return 
      $resultTbl
};