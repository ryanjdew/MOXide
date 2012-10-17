xquery version "1.0-ml";
import module namespace helpers="http://maxdewpoint.blogger.com/moxide/helpers" at "/libraries/helpers.xqy";
declare variable $module as xs:string := xdmp:get-request-field("module");
declare variable $location as xs:string := xdmp:get-request-field("location");
declare variable $extension as xs:string := replace($location, ".*\.([a-z0-9]+)", "$1");
declare variable $app-root as xs:string := helpers:determine-app-root($location);
declare variable $static-check as xs:boolean? :=
  try {
    xdmp:eval(
      (: if module declaration exists change it to a main module:)
	  if (fn:matches($module,'(^|[&#10;&#13;])\s*module\s+namespace\s+.+?=.*?;'))
      then 
		(: retrieve namespace name for module :)
		let $namespace :=  fn:replace($module,'.*(^|[&#10;&#13;])\s*module\s+namespace\s+([^\s=]+)\s*=.*','$2','s'),
			(: check module to see if a default function namespace declaration already exists :)
			$has-default-namespace := fn:matches($module, '(declare\s+default\s+function\s+namespace\s+["''])([^"''])*(["''])')
        return
		(: add empty sequence for query body :)
		fn:concat(
			(: change function calles to local namespace :)
			fn:replace(
				(: change function declarations to local namespace :)
				fn:replace(
					(: change module  namespace declaration to just a namespace declaration :)
					fn:replace(
						$module,
						'(^|[&#10;&#13;])\s*module\s+(namespace\s+.+?=.*?;)',
						(: if a default function namespace declaration doesn't already exist set it to the local namespace :)
						fn:concat('$1 declare $2', if (fn:not($has-default-namespace)) then '&#10; declare default function namespace "http://www.w3.org/2005/xquery-local-functions";' else ())
					),
					'(^|[&#10;&#13;])\s*declare[\s&#10;&#13;]+function[\s&#10;&#13;]+([^\s&#10;&#13;][^:\(]+:)?([^:][^\(]+\()',
					'$1declare function local:$3'
				),
				fn:concat('([^a-xA-Z0-9\-_])(',$namespace,':)'),
				(: had default namespace specify local namespace, otherwise remove namespace :)
				if ($has-default-namespace)  then '$1local:' else '$1'
			),
		' ()'
        )[xdmp:log(.),fn:true()]
      else $module,
      (),
      <options xmlns="xdmp:eval"><static-check>true</static-check><modules>{xdmp:database()}</modules><root>{ $app-root }</root></options>),
    true()
  } catch ($e) {
    if ($e/*:code eq "XDMP-EVALLIBMOD")
    then true()
    else
      error(
        QName(
          "http://maxdewpoint.blogspot.com/moxide",
          "STATIC_CHECK"),
        concat(
          "This module failed to pass a static check: ",
          $e/*:message))
  };

try {
  if ($extension = ("xq", "xqy", "xquery", "xqm", "xql"))
  then
    if ($static-check)
    then
      xdmp:document-insert(
        $location,
        document {
          text { $module }
        })
    else
      ()
  else if ($extension = ("xml", "xsl"))
  then
    xdmp:document-insert(
      $location,
      document {
        xdmp:unquote($module)
      })
  else
    xdmp:document-insert(
      $location,
      document {
        text { $module }
      }),
  "{ success: true }"
} catch ($e) {
  concat(
    "{&#10;    success: false,&#10;    reason: &quot;",
    $e/*:message/string(),
    " data:",
    string-join($e/*:data/*:datum/replace(.,'"','\"'), ","),
    "&quot;}")
}