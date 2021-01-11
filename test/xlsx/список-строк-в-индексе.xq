for $i in doc("C:\Users\kontu\Downloads\Ямпольский А — копия\xl\sharedStrings.xml")/*:sst/*:si
count $c
return
  $c || ' : ' || string-join( $i//*:t/text() )