<?php require dirname(__DIR__) . "../../includes/bootstrap.php"; ?>

<title>About</title>
<div class="modal-inner-content modal-inner-content-about" style="padding-bottom: 30px;">
    <div class="modal-inner-content-menu">
        <span>About</span>
    </div>
    <div class="horizontal-line">&nbsp;</div>
    <h3>NYUAD APRS Server</h3>
    <p>
	If the config file is loaded successfully, you can see the admin datails below:
	<p>
	    Site admin name: <?php echo getWebsiteConfig('owner_name'); ?>, email address is: <?php echo getWebsiteConfig('owner_email'); ?>
	</p>
    </p>

    <img src="/images/aprs-symbols.png" title="APRS symbols" style="width:100%"/>

    <h3>Project details</h3>
    <p>
        This website is based on the APRS Track Direct tools, but with some modifications. More information:
	<ul>
	    <li><h4><a href="https://github.com/ha5dzs/nyuad-aprs-server">Source code for this implmementation</a></h4></li>
	    <li><h4><a href="https://github.com/qvarforth/trackdirect">Original TrackDirect code</a></h4></li>
	    <li><h4><a href="http://aprs-is.net/">APRS IS</a></h4></li>
	    <li><h4><a href="http://aprs2.net/">Tier 2 network</a></h4></li>
	    <li><h4><a href="http://he.fi/aprsc/">aprsc</a></h4></li>
	    <li><h4><a href="http://www.aprs.org/">The original APRS website</a></h4></li>

	</ul>
    </p>


</div>
