require 'test_helper'

<% module_namespacing do -%>
class <%= class_name %>Test < ActiveSupport::TestCase
<% if actions.blank? -%>
  # test 'the truth' do
  #   assert true
  # end
<% else -%>
<% actions.each do |action| -%>
  test '<%= action %>' do
    message = <%= class_name %>.<%= action %>
    email = message.email
    assert_equal '<%= action.to_s.humanize %>', email.subject
    assert_equal ['from@example.com'], email.from
    assert_match 'Hi', email.body.encoded
  end
<% end -%>
<% end -%>
end
<% end -%>
