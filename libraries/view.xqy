xquery version "1.0-ml";

module namespace view = 'http://maxdewpoint.blogger.com/moxide/view';

import module namespace helpers = 'http://maxdewpoint.blogger.com/moxide/helpers' at '/libraries/helpers.xqy';

declare function display-files($files as xs:string*) {
	display-file($files)
};

declare function display-file($file as xs:string) {
	<li><a class="file" data-file="{$file}" href="#f">{fn:tokenize($file,'/')[fn:last()]}</a></li>
};

declare function display-directories($directories as xs:string*) {
	display-directory($directories)
};

declare function display-directory($directory as xs:string) {
	<li><a class="directory closed" data-directory="{$directory}" href="#d">{fn:tokenize($directory,'/')[. ne ''][fn:last()]}</a></li>
};

declare function display-directory-contents($directory as xs:string){
	<ul class="directory-listing">{
	(: directories :)
	view:display-directories(helpers:find-sub-directories($directory)),
	(:files :)
	view:display-files(helpers:find-sub-files($directory))
	}</ul>
};