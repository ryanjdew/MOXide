xquery version "1.0-ml";

declare variable $module as xs:string := xdmp:get-request-field('module');
declare variable $location as xs:string := xdmp:get-request-field('location');
declare variable $extension as xs:string := replace($location,'.*\.([a-z0-9]+)','$1');
declare variable $static-check as xs:boolean := 
		try {
			let $execute := xdp:eval($module,<options xmlns="xdmp:eval"><static-check>true</static-check></options>)
			return true()
		} catch($e) {
			false()
		}
if  ($extension = ('xq','xqy','xquery','xqm','xql'))
then 
	if ($static-check)
	then xdmp:document-insert($location,document{text{xdmp:pretty-print($module)}})
	else ()
else if  ($extension = ('xml','xsl'))
then xdmp:document-insert($location,document{xdmp:unquote($module)})
else xdmp:document-insert($location,document{text{$module}})
