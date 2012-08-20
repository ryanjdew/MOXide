xquery version "1.0-ml";

declare variable $location as xs:string := xdmp:get-request-field('location');
declare variable $document as document-node()? := fn:doc($location);

if (exists($document/element()))
then xdmp:quote($document/element())
else $document/text()