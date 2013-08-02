require 'spec_helper'

<% module_namespacing do -%>
describe <%= class_name %> do
<% if actions.blank? -%>
  pending "add some examples to (or delete) #{__FILE__}"
<% else -%>
<% actions.each do |action| -%>
  describe '.<%= action %>' do
    let(:message) { <%= class_name %>.<%= action %> }
    let(:email) { message.email }

    it 'renders the headers' do
      email.subject.should eq('<%= action.to_s.humanize %>')
      email.from.should eq(['noreply@myapp.com'])
    end

    it 'renders the body' do
      email.body.encoded.should match('Hi')
    end
  end
<% end -%>
<% end -%>
end
<% end -%>
