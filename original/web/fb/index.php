<?php
function parsePageSignedRequest() {
    if (isset($_REQUEST['signed_request'])) {
        $encoded_sig = null;
        $payload = null;
        list($encoded_sig, $payload) = explode('.', $_REQUEST['signed_request'], 2);
        $sig = base64_decode(strtr($encoded_sig, '-_', '+/'));
        $data = json_decode(base64_decode(strtr($payload, '-_', '+/'), true));
        return $data;
    }
    return false;
}?><!DOCTYPE html>
<html xmlns="http://www.w3.org/1999/xhtml" xml:lang="en" lang="en">
<head>
    <title>Herbert - Soundtrack</title>
    <link rel="stylesheet" type="text/css" media="all" href="http://yui.yahooapis.com/2.9.0/build/reset/reset-min.css"/>
</head>
<body>
<?php if($signed_request = parsePageSignedRequest()): ?>
    <?php if($signed_request->page->liked): ?>
	<?php //echo '../../files/get.php?id='. md5('JustinLassenPresentsHerbertOriginalSoundtrack.zip'); ?>
    <img id="herbertShape" src="herbert_ost.png" usemap="#herbertShape" border="0" width="508" height="795" alt="Get soundtrack for free!" />
    <map id="_herbertShape" name="herbertShape">
        <area shape="poly" coords="32,453,328,438,443,467,494,559,473,672,370,734,44,750," href="http://etite.ch/~/herbsoundtrack" alt="Get soundtrack for free!" title="Get soundtrack for free!" />
    </map>
        <?php else: ?>
    <img src="herbert_ost_close.png" border="0" width="508" height="795" alt="Get soundtrack for free!" />
        <?php endif; ?>
    <?php else: ?>
    <img src="herbert_ost_close.png" border="0" width="508" height="795" alt="Get soundtrack for free!" />
    <?php endif; ?>
	<script type="text/javascript">

	  var _gaq = _gaq || [];
	  _gaq.push(['_setAccount', 'UA-25176108-3']);
	  _gaq.push(['_trackPageview']);

	  (function() {
	    var ga = document.createElement('script'); ga.type = 'text/javascript'; ga.async = true;
	    ga.src = ('https:' == document.location.protocol ? 'https://ssl' : 'http://www') + '.google-analytics.com/ga.js';
	    var s = document.getElementsByTagName('script')[0]; s.parentNode.insertBefore(ga, s);
	  })();

	</script>
</body>
</html>