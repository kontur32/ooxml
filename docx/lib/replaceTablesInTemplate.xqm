module namespace tables= "http://iro37.ru/xq/modules/docx/tables/replace";

declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

(:~
 : Эта функция вставляет таблицы в шаблон документа.
 : @param $template  шаблон в формате w:document
 : @param $data  данные для заполения шаблона в формате TRCI
 : @return возвращает обработанный w:document
 :)
declare
  %public 
function tables:replaceTablesInTemplate (
  $template as element ( w:document ),
  $data as element ( table )
)  {
    
    let $tablesData := $data/row[@id="tables"]/cell
    return
    $template update    
    
    let $tablesTemplate := ./w:body/w:tbl
    
    for $tbl in $tablesTemplate
    let $tablesName := $tbl/w:tblPr/w:tblCaption/@w:val/data()
    let $rowsData :=  $tablesData[@id=$tablesName]/table/row
    let $rowsToInsert := tables:buildTableRow ( $rowsData )

    return 
       insert node $rowsToInsert into $tbl
};

declare 
  %private
function tables:buildTableRow ( $row as element ( row )* ) {
  for $r in $row
  return
  <w:tr w:rsidR="docxFill" w:rsidRPr="docxFill" w:rsidTr="docxFill">
               {
                for $cell in $r/cell
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
};