module namespace trciBindMeta = "http://dbx.iro37.ru/zapolnititul/api/trci/bind/meta";

import module namespace trci = "http://www.iro37.ru/stasova/TRCI-parse" at "funct/parseTRCI.xqm";

declare
  %rest:path ( "/xlsx/api/v1/trci/bind/meta" )
  %rest:POST
  %rest:form-param ( "data", "{ $data }" )
  %rest:form-param ( "model", "{ $model }" )
function trciBindMeta:main( $data, $model ){
  let $d := parse-xml( $data )/table
  let $m := parse-xml( $model )/table
  return
    trci:data( $d, $m, "" )
};