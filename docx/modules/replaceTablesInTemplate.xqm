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
) as element( w:document ) {};