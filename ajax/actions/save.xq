xquery version "1.0-ml";
import module namespace helpers="http://maxdewpoint.blogger.com/moxide/helpers" at "/libraries/helpers.xqy";
declare variable $module as xs:string := xdmp:get-request-field("module");
declare variable $location as xs:string := xdmp:get-request-field("location");
declare variable $extension as xs:string := replace($location, ".*\.([a-z0-9]+)", "$1");
declare variable $app-root as xs:string := helpers:determine-app-root($location);
declare variable $static-check as xs:boolean? :=
  try {
    xdmp:eval(
      $module,
      (),
      <options xmlns="xdmp:eval"><static-check>true</static-check><root>{ $app-root }</root></options>),
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
          text { xdmp:pretty-print($module) }
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