<% module_namespacing do -%>
class <%= class_name %> < Outbox::Notifier
  default email: { from: 'noreply@myapp.com' }
<% actions.each do |action| -%>

  def <%= action %>
    @greeting = 'Hi'

    email do
      subject 'Example Subject'
    end

    render_message
  end
<% end -%>
end
<% end -%>
