xquery version "1.0-ml";

module namespace helpers = 'http://maxdewpoint.blogger.com/moxide/helpers';

declare namespace group="http://marklogic.com/xdmp/group";

(:
declare variable $helpers:ADMIN_CONFIG := admin:get-configuration();
declare variable $helpers:GROUP_ID := admin:group-get-id($helpers:APP_CONFIG, "Default");
:)
declare function find-sub-files($directory as xs:string) {
cts:uris($directory, ('properties','concurrent'), 
    cts:and-query((
        cts:directory-query($directory,"1"),
        cts:not-query(
            cts:properties-query(
                cts:element-query(xs:QName('prop:directory'),cts:and-query(()))
            )
        )
    ))
)	
};

declare function find-sub-directories($directory as xs:string) {
cts:uris($directory, ('properties','concurrent'), 
    cts:and-query((
        cts:directory-query($directory,"1"),
        cts:properties-query(
            cts:element-query(xs:QName('prop:directory'),cts:and-query(()))
        )
    ))
)
};

declare function determine-app-root($location as xs:string) as xs:string? {
    xdmp:read-cluster-config-file("groups.xml")//group:http-servers/group:http-server[group:webDAV eq fn:false()]/group:root[fn:starts-with($location,.)]
};