module namespace config = 'http://iro37.ru/xq/modules/ooxml/config.xqm';

declare function config:param( $param as xs:string ){
  doc( "config.xml" )/config/param[ @id = $param ]/text()
};