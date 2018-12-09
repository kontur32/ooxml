module namespace restDocx = "http://iro37.ru/xq/modules/docx/rest";

declare 
  %rest:path ( "/docx/заполниТитул.docx" )
  %rest:method ( "GET" )
  %rest:query-param ( "student", "{$student}" )
  %rest:query-param ( "theme", "{$theme}" )
  %rest:query-param ( "teacher", "{$teacher}" )
  %output:media-type( "application/octet-stream" )
function restDocx:get ( $student as xs:string, $theme as xs:string, $teacher) {
  let $tpl := 
    try {
      fetch:binary ( iri-to-uri ( "http://iro37.ru/res/trac-src/examle/docx/ТитулМагистерская.docx" ) )
    }
    catch * { 
    }
  
  let $data := 
    <table>
      <row id="fields">
        <cell id="студент">{ $student }</cell>
        <cell id="тема">{ $theme }</cell>
        <cell id="руководитель">{ $teacher }</cell>
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
      'http://localhost:8984/docx/post'
  )
  return 
   $response[2]
};