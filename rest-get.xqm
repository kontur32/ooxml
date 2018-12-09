module namespace restDocx = "http://iro37.ru/xq/modules/docx/rest";

declare 
  %rest:path ( "/docx/get" )
  %rest:method ( "GET" )
  %rest:query-param ( "template", "{$tplPath}" )
  %rest:query-param ( "data", "{$dataPath}" )
  %output:media-type( "application/octet-stream" )
function restDocx:get ( $tplPath as xs:string, $dataPath as xs:string) {
  
  let $tpl := 
    try {
      fetch:binary ( iri-to-uri ( $tplPath ) )
    }
    catch * { 
    }
  
  let $data := 
    try {
      fetch:xml ( iri-to-uri( $dataPath ) )
    }
    catch * {    
    }
  
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
      'http://localhost:8984/docx/post'
  )
  return 
   $response[2]
};