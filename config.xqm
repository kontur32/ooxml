module namespace config = 'http://iro37.ru/xq/modules/ooxml/config.xqm';

declare function config:param( $param ){
  doc( "config.xml" )/config/param[ @id = $param ]/text()
};