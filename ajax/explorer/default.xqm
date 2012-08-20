xquery version "1.0";

import module namespace helpers := 'http://maxdewpoint.blogger.com/moxide/helpers' at '/libraries/helpers.xql';
import module namespace view := 'http://maxdewpoint.blogger.com/moxide/view' at '/libraries/view.xql';

declare variable $app-id as xs:unsignedLong := xs:unsignedLong(xdmp:get-request-field('app-id'));
declare variable $directory as xs:string := xdmp:get-request-field('directory-start');
(:
declare variable $modules-root as xs:string := admin:appserver-get-root($helpers:ADMIN_CONFIG, $app-id);
declare variable $directory as xs:string := 
	fn:concat(
		if (ends-with($modules-root,'/')) 
		then substring($modules-root,1,string-length($modules-root)-1) 
		else $modules-root,
		xdmp:get-request-field('directory-start')
	);
:)

view:display-directory-contents($directory)