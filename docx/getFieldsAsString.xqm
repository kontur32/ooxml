module namespace docx= "http://iro37.ru/xq/modules/docx/getFieldsAsString";

import module namespace fields = "http://iro37.ru/xq/modules/docx/fields/replace" 
  at "../docx/lib/replaceFieldsInTemplate.xqm"; 

declare namespace w = "http://schemas.openxmlformats.org/wordprocessingml/2006/main";

(:~
 : АЛЬФА-версия
 : Эта функция возвращает поля из шаблона в виде стоки.
 : @param $template  шаблон в формате w:document
 : @param $data  данные для заполения шаблона в формате TRCI
 : @return возвращает обработанный w:document
 :)
declare
  %rest:POST
  %rest:path ( "/ooxml/api/v1/docx/fields" )
  %rest:consumes( "multipart/form-data" ) 
  %rest:form-param( "template", "{ $template }" )
  %output:method("text")
function docx:getFieldsAsString ( $template as xs:base64Binary ) {
    
    let $xmlTpl := 
      parse-xml ( 
          archive:extract-text( $template,  'word/document.xml' )
      )/w:document
    return
    serialize (
    <csv>
    { 
      for $i in fields:getFieldsAsString ( $xmlTpl )
      return 
        <record>
          <label>{$i}</label>
        </record>
    }
    </csv>,
    map {
    'method': 'csv',
    'csv': map { 'header': 'no'}
    }
   )
};