xquery version "1.0-ml";

import module namespace json = 'http://marklogic.com/json' at '/MarkLogic/appservices/utils/json.xqy';

declare variable $location as xs:string := xdmp:get-request-field('location');
declare variable $document as document-node()? := fn:doc($location);

json:serialize(
    element contents {
        if (exists($document/element()))
        then xdmp:quote($document/element())
        else $document/text()
    }
)