module namespace restDocx = "http://iro37.ru/xq/modules/docx/rest";

import module namespace request = "http://exquery.org/ns/request";

declare 
  %rest:path ( "/docx/api/заполниТитул.docx" )
  %rest:method ( "GET" )
  %rest:query-param ( "template", "{ $template }" )
  %output:media-type( "application/octet-stream" )
function restDocx:get ( $template as xs:string ) {
  let $tpl := 
    try {
      fetch:binary ( iri-to-uri ( $template ) )
    }
    catch * { 
    }
    
  let $data :=
    <table>
      <row id="fields">
      {
        for $param in request:parameter-names()
        return 
          <cell id="{ $param }">{request:parameter( $param )}</cell>
      }
      </row>
    </table>     
    
  let $request :=
    <http:request method='post'>
      <http:multipart media-type = "multipart/*" >
          <http:body media-type = "text" >
            { string ( $tpl ) }
          </http:body>
          <http:body media-type = "xml">
            { $data }
          </http:body>
      </http:multipart> 
    </http:request>

  let $response := 
    http:send-request(
      $request,
      'http://localhost:8984/docx/api/fillTemplate'
  )
  return
   $response[ 2 ]
};