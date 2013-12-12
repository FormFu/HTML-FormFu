use strict;
use warnings;

use Test::More;

eval { require Template; };

if ($@) {
    plan skip_all => 'Template.pm required';
    exit;
}
else {
    plan tests => 2;
}

use HTML::FormFu;

my $form = HTML::FormFu->new(
    { tt_args => { INCLUDE_PATH => 'share/templates/tt/xhtml' } } );

$form->element('Password')->name('foo')->label('Foo')
    ->label_attributes( { class => 'my_label' } )->comment('Comment')
    ->render_value(1);

$form->element('Submit')->name('submit');

$form->constraint( Required => 'foo' );

my $template = Template->new;
my $data = do { local $/; <DATA> };
my $output;

$template->process( \$data, { form => $form }, \$output )
    or die $template->error;

my $xhtml = <<EOF;
<html>
<body>
<form action="" method="post">
<div class="password">
<label class="my_label">Foo</label>
<input name="foo" type="password" />
<span>
Comment
</span>
</div>
<div class="text">
<label class="my_label">Foo</label>
<input name="foo" type="text" disabled="disabled" />
<span>
Comment
</span>
</div>
<div class="submit">
<input name="submit" type="submit" />
</div>
</form>
</body>
</html>
EOF

is( $output, $xhtml );

# check that errors are carried to the new field
{
    my $xhtml = <<EOF;
<html>
<body>
<form action="" method="post">
<div class="password">
<span>This field is required</span>
<label class="my_label">Foo</label>
<input name="foo" type="password" value="" />
<span>
Comment
</span>
</div>
<div class="text">
<span>This field is required</span>
<label class="my_label">Foo</label>
<input name="foo" type="text" value="" disabled="disabled" />
<span>
Comment
</span>
</div>
<div class="submit">
<input name="submit" type="submit" value="Submit" />
</div>
</form>
</body>
</html>
EOF

    $form->process( { submit => 'Submit', } );

    my $output = undef;
    $template->process( \$data, { form => $form }, \$output )
        or die $template->error;

    is( $output, $xhtml );
}

__DATA__
<html>
<body>
[% form.start %]
[% form.get_field('foo') %]
[% form.get_field('foo').as('Text', 'disabled', 'disabled') %]
[% form.get_field('submit') %]
[% form.end %]
</body>
</html>
