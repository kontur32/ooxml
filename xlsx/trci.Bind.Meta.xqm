module namespace trciBindMeta = "http://dbx.iro37.ru/zapolnititul/api/trci/bind/meta";

import module namespace trci = "http://www.iro37.ru/stasova/TRCI-parse" at "funct/parseTRCI.xqm";

declare
  %rest:path ( "/xlsx/api/v1/trci/bind/meta" )
  %rest:POST
  %rest:form-param ( "data", "{ $data }" )
  %rest:form-param ( "modelPath", "{ $modelPath }" )
function trciBindMeta:main( $data, $modelPath ){
  let $d := doc( $data )/table
  let $model := fetch:xml ( $modelPath )/table
  return
    trci:data( $d, $model, "" )
};