use strict;
use warnings;

use Test::More tests => 1;

use HTML::FormFu;

my $form = HTML::FormFu->new;

my $proc = $form->output_processor( {
        type   => 'Indent',
        indent => " " x 4,
    } );

my $input = <<INPUT;
<form action="" method="post">
<fieldset>
<legend>Legend</legend>
<input name="hidden" type="hidden" value="1" />
<pre>
    foo bar
</pre>
<span class="text comment label">
<label for="text">Label</label>
<input name="text" type="text" />
<span class="comment">Comment</span>
</span>
<span class="textarea">
<textarea name="textarea" cols="40" rows="20">foo
bar
</textarea>
</span>
<span class="select">
<select name="select">
<option value="1">1</option>
<option value="2">2</option>
<option value="3">3</option>
</select>
</span>
<span class="submit">
<input name="submit" type="submit" />
</span>
</fieldset>
</form>
INPUT

my $output = <<OUTPUT;
<form action="" method="post">
    <fieldset>
        <legend>Legend</legend>
        <input name="hidden" type="hidden" value="1" />
        <pre>
    foo bar
</pre>
        <span class="text comment label">
            <label for="text">Label</label>
            <input name="text" type="text" />
            <span class="comment">Comment</span>
        </span>
        <span class="textarea">
            <textarea name="textarea" cols="40" rows="20">foo
bar
</textarea>
        </span>
        <span class="select">
            <select name="select">
                <option value="1">1</option>
                <option value="2">2</option>
                <option value="3">3</option>
            </select>
        </span>
        <span class="submit">
            <input name="submit" type="submit" />
        </span>
    </fieldset>
</form>
OUTPUT

is( $proc->process($input), $output );
