package HTML::FormFu::tt_files;

=pod

This package should only be used by L<HTML::FormFu::Deploy>.

It contains the data needed to generate the L<TT|Template> template files. 
This file should only be updated using the update_pm_from_templates.pl file, 
which is only available from the subversion repository.

update_pm_from_templates.pl must always be run before creating a distribution 
for release.

=cut

1;
__DATA__
__CPAN_HTML_FormFu__block__
[% INCLUDE start_block %]
[% IF self.content.defined %][% self.content %]
[% ELSE %][% FOREACH element = self.elements %][% INCLUDE $element.filename self = element %]
[% END %][% END %][% INCLUDE end_block %]__CPAN_HTML_FormFu__form__
[% INCLUDE start_form %]
[% FOREACH element = self.elements %][% INCLUDE $element.filename self=element %]
[% END %][% INCLUDE end_form %]
__CPAN_HTML_FormFu__label__
<label[% process_attrs(self.label_attributes) %]>[% self.label %]</label>__CPAN_HTML_FormFu__legend__
<legend[% process_attrs(self.label_attributes) %]>[% self.label %]</legend>__CPAN_HTML_FormFu__radiogroup__
[% WRAPPER field %][% INCLUDE $self.radiogroup_filename %][% END %]__CPAN_HTML_FormFu__radiogroup_tag__
<span[% process_attrs(self.attributes) %]>
[% FOREACH option = self.options %][% IF option.group %]<span[% process_attrs(option.attributes) %]>
[% FOREACH item = option.group %]<span>
<input name="[% self.name %]" type="radio" value="[% item.value %]"[% process_attrs(item.attributes) %] />
<label[% process_attrs(item.label_attributes) %]>[% item.label %]</label>
</span>
[% END %]</span>
[% ELSE %]<span>
<input name="[% self.name %]" type="radio" value="[% option.value %]"[% process_attrs(option.attributes) %] />
<label[% process_attrs(option.label_attributes) %]>[% option.label %]</label>
</span>
[% END %][% END %]</span>__CPAN_HTML_FormFu__multi_ltr__
[% IF self.label.defined %][% INCLUDE $self.label_filename %]
[% END %][% INCLUDE $self.field_filename %]__CPAN_HTML_FormFu__content_button__
[% WRAPPER field %]<button name="[% self.name %]" type="[% self.field_type %]"[% IF self.value.defined %] value="[% self.value %]"[% END %][% process_attrs(self.attrs) %]>[% self.content %]</button>[% END %]__CPAN_HTML_FormFu__start_block__
<[% self.tag %][% process_attrs(self.attrs) %]>[% IF self.legend.defined %]
<legend>[% self.legend %]</legend>[% END %]__CPAN_HTML_FormFu__field__
<[% self.container_tag %][% process_attrs(self.container_attributes) %]>[% IF self.label.defined && self.label_filename == 'legend' %]
[% INCLUDE $self.label_filename %][% END %][% IF self.errors %][% FOREACH error = self.errors %]
<span class="error_message [% error.class %]">[% error.message %]</span>[% END %][% END %][% IF self.label.defined && self.label_filename != 'legend' %]
[% INCLUDE $self.label_filename %][% END %]
[% content %][% IF self.comment.defined %]
<span[% process_attrs(self.comment_attributes) %]>
[% self.comment %]
</span>[% END %]
</[% self.container_tag %]>[% IF self.javascript.defined %]
<script type="text/javascript">
[% self.javascript %]
</script>[% END %]__CPAN_HTML_FormFu__select__
[% WRAPPER field %][% INCLUDE $self.field_filename %][% END %]__CPAN_HTML_FormFu__input__
[% WRAPPER field %][% INCLUDE $self.field_filename %][% END %]__CPAN_HTML_FormFu__multi__
[% WRAPPER field %]<span[% process_attrs(self.attributes) %]>
[% FOREACH element = self.elements %][% element.multi %]
[% END %]</span>[% END %]__CPAN_HTML_FormFu__input_tag__
<input[% IF self.name.defined %] name="[% self.name %]"[% END %] type="[% self.field_type %]"[% IF self.value.defined %] value="[% self.value %]"[% END %][% process_attrs(self.attrs) %] />__CPAN_HTML_FormFu__textarea_tag__
<textarea name="[% self.name %]"[% process_attrs(self.attrs) %]>[% self.value IF self.value.defined %]</textarea>__CPAN_HTML_FormFu__hidden__
[% INCLUDE $self.field_filename %]__CPAN_HTML_FormFu__end_block__
</[% self.tag %]>__CPAN_HTML_FormFu__non_block__
<[% self.tag %][% process_attrs(self.attrs) %] />__CPAN_HTML_FormFu__blank__
__CPAN_HTML_FormFu__form_error_message__
[% IF self.force_error_message || self.form_error_message.defined && self.form.has_errors %]
<div class="form_error_message">[% self.form_error_message %]</div>[% END %]__CPAN_HTML_FormFu__end_form__
</form>__CPAN_HTML_FormFu__select_tag__
<select name="[% self.name %]"[% process_attrs(self.attrs) %]>
[% FOREACH option = self.options %][% IF option.group %]<optgroup[% IF option.label.defined %] label="[% option.label %]"[% END %][% process_attrs(option.attributes) %]>
[% FOREACH item = option.group %]<option value="[% item.value %]"[% process_attrs(item.attributes) %]>[% item.label %]</option>
[% END %]</optgroup>
[% ELSE %]<option value="[% option.value %]"[% process_attrs(option.attributes) %]>[% option.label %]</option>
[% END %][% END %]</select>__CPAN_HTML_FormFu__start_form__
<form[% process_attrs(self.attrs) %]>[% INCLUDE form_error_message %][% IF self.javascript_src.defined %][% FOREACH src = self.javascript_src.list %]
<script type="text/javascript" src="[% src %]">
</script>[% END %][% END %][% IF self.javascript.defined %]
<script type="text/javascript">
[% self.javascript %]
</script>[% END %]__CPAN_HTML_FormFu__multi_rtl__
[% INCLUDE $self.field_filename %][% IF self.label.defined %]
[% INCLUDE $self.label_filename %][% END %]__CPAN_HTML_FormFu__END_OF_FILE__
