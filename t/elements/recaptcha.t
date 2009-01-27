use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new({ tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } });

$form->load_config_file('t/elements/recaptcha.yml');

my $form_xhtml = <<EOF;
<form action="" method="post">
<div class="recaptcha">
<span class="elements">
<script type="text/javascript">
//<![CDATA[
var RecaptchaOptions = {};
//]]>
</script>
<script src="http://api.recaptcha.net/challenge?k=xxx" type="text/javascript"></script>
<noscript><iframe frameborder="0" height="300" src="http://api.recaptcha.net/noscript?k=xxx" width="500"></iframe><textarea cols="40" name="recaptcha_challenge_field" rows="3"></textarea><input name="recaptcha_response_field" type="hidden" value="manual_challenge" /></noscript>
</span>
</div>
</form>
EOF

is( "$form", $form_xhtml, 'stringified form' );

