Given(/^that I am logged in as a (\w+) on the organization$/) do |role|
  visit "/admin/login"
  @current_user = FactoryBot.create(:user)
  user_assignment = create(:user_assignment, user_id: @current_user.id, role: role, organization_id: @organization.id)
  fill_in "user_email", :with => @current_user.email
  fill_in "user_password", :with => @current_user.password
  click_button("Log in")
  expect(page).to have_content("Logged in successfully")
end

Given(/^that I am logged in as a (\w+)$/) do |role|
  visit "/admin/login"
  @current_user = FactoryBot.create(:user)
  user_assignment = create(:user_assignment, user_id: @current_user.id, role: role)
  fill_in "user_email", :with => @current_user.email
  fill_in "user_password", :with => @current_user.password
  click_button("Log in")
  expect(page).to have_content("Logged in successfully")
end

Given(/^there is a (\w+) on the organization$/) do |class_name|
  case class_name
  when /user/
    record = create(class_name.singularize)
    record_assignment = create('user_assignment', user: record, organization: @organization)
  when /component/
    record = create(class_name, organization_id: @organization.id, user_role: "admin")
  else
    record = create(class_name, organization_id: @organization.id)
  end
  instance_variable_set("@#{class_name}",record)
end

Given(/^there are (\d+) (\w+) for the organization/) do | number, class_name|
  case class_name
  when /users/
    record = create(class_name.singularize)
    record_assignment = create('user_assignment', user: record, organization: @organization)
  when /components/
    record = create(class_name.singularize, organization: @organization, user_role: "admin")
  else
    record = create(class_name.singularize, organization: @organization)
  end
  instance_variable_set("@#{class_name}",record)
end

Given(/^there is a (\w+) with a (\w+) of (\w+)$/) do |class_name, field, value|
  record = create(class_name, feild => value)
  instance_variable_set("@#{class_name}",record)
end

Then(/^the (\w+) (\w+) should be (\w+)$/) do |class_name, record_name, value|
  record = instance_variable_get("@#{class_name}")
  result = record.send(record_name)
  case value
  when /nil/
    expect(result).to be nil
  else
    expect(result).to have_content(value)
  end
end

Given(/^there is a organization with a sub organization$/) do
  @organization = FactoryBot.create(:organization)
  @sub_organization = FactoryBot.create(:organization, parent_id: @organization.id)
end

Given(/^there is a (\w+) with a (\w+) of "(.*?)"$/) do |class_name, field_name, field_value|
  instance_variable_set("@#{class_name}", create(class_name, field_name => field_value))
end

When /^S3 uploads are stubbed out$/ do
  Aws.config[:s3] = {
    stub_responses: {
      list_buckets: { buckets: [{name: ENV["AWS_BUCKET"] }] },
      get_object: { body: 'data' }
    }
  }
end

Given(/^there is a (\w+)$/) do |class_name|
  case class_name
  when /workflow/
    recordA = create(:workflow_step, slug: "step_5", step_type: "end_step", organization_id: @organization.id)
    componentA = recordA.component
    componentA.user_role = "admin"
    componentA.role = nil
    componentA.save
    recordB = create(:workflow_step, slug: "step_4", next_workflow_step_id:recordA.id, organization_id: @organization.id)
    componentB = recordB.component
    componentA.user_role = "admin"
    componentB.role = "approver"
    componentB.save
    recordC = create(:workflow_step, slug: "step_3", next_workflow_step_id: recordB.id, organization_id: @organization.id)
    componentC = recordC.component
    componentA.user_role = "admin"
    componentC.role = "supervisor"
    componentC.save
    recordD = create(:workflow_step, slug: "step_2", next_workflow_step_id: recordC.id, organization_id: @organization.id)
    componentD = recordD.component
    componentA.user_role = "admin"
    componentD.role = "supervisor"
    componentD.save
    recordE = create(:workflow_step, slug: "step_1", next_workflow_step_id: recordD.id, step_type: "start_step", organization_id: @organization.id)
    componentE = recordE.component
    componentA.user_role = "admin"
    componentE.role = "staff"
    componentE.save
    @workflows = WorkflowStep.workflows(@organization.id)
  when /document/ || /canvas_document/
    record = create(class_name, organization_id: @organization.id)
    instance_variable_set("@#{class_name}",record)
  when /organization/
    @organization = FactoryBot.create(:organization)
  else
    record = create(class_name)
    instance_variable_set("@#{class_name}",record)
  end
end

Given("the user has a document with a workflow_step of {int}") do |int|
  @document = create(:document, organization_id: @organization.id, user_id: @user.id, workflow_step_id: @workflows.first[int.to_i-1].id)
end

Given(/^there is a user with the role of (\w+)$/) do |role|
  user = FactoryBot.create(:user)
  user_assignment = create(:user_assignment, user_id: user.id, role: role, organization_id: @organization.id)
  instance_variable_set("@user",user)
end

Given(/^there is a user with the role of (\w+) on the sub organization$/) do |role|
  user = FactoryBot.create(:user)
  user_assignment = create(:user_assignment, user_id: user.id, role: role, organization_id: @sub_organization.id)
  instance_variable_set("@user",user)
end

Given(/^I save the page$/) do
  save_page
end

Given(/^there is a (\w+) with a (\w+) of "(.*?)"$/) do |class_name, field_name, field_value|
  instance_variable_set("@#{class_name}", create(class_name, field_name => field_value))
end

Given("there are documents with document_metas that match the filter") do
  doc = create(:document, organization_id: @organization.id)
end

Given(/^there is a document on the (\w+) step in the workflow and assigned to the user$/) do |step|
  case step
  when /first/
    @document = create(:document, workflow_step_id: @workflows.first.first.id, user_id: @user.id, organization_id: @organization.id)
  when /second/
    @document = create(:document, workflow_step_id: @workflows.first[1].id, user_id: @user.id, organization_id: @organization.id)
  when /fourth/
    @document = create(:document, workflow_step_id: @workflows.first[3].id, user_id: @user.id, organization_id: @organization.id)
  when /last/
    @document = create(:document, workflow_step_id: @workflows.first.last.id, user_id: @user.id, organization_id: @organization.id)
  else
    pending
  end
end

Given(/^there is a document on the (\w+) step in the workflow and assigned to the user on the sub org$/) do |step|
  case step
  when /first/
    @document = create(:document, workflow_step_id: @workflows.first.first.id, user_id: @user.id, organization_id: @sub_organization.id)
  when /second/
    @document = create(:document, workflow_step_id: @workflows.first[1].id, user_id: @user.id, organization_id: @sub_organization.id)
  when /fourth/
    @document = create(:document, workflow_step_id: @workflows.first[3].id, user_id: @user.id, organization_id: @sub_organization.id)
  when /last/
    @document = create(:document, workflow_step_id: @workflows.first.last.id, user_id: @user.id, organization_id: @sub_organization.id)
  else
    pending
  end
end

Given(/^there is a document on the (\w+) step in the workflow and assigned to the current user$/) do |step|
  case step
  when /first/
    @document = create(:document, workflow_step_id: @workflows.first.first.id, user_id: @current_user.id, organization_id: @organization.id)
  when /second/
    @document = create(:document, workflow_step_id: @workflows.first[1].id, user_id: @current_user.id, organization_id: @organization.id)
  when /fourth/
    @document = create(:document, workflow_step_id: @workflows.first[3].id, user_id: @current_user.id, organization_id: @organization.id)
  when /last/
    @document = create(:document, workflow_step_id: @workflows.first.last.id, user_id: @current_user.id, organization_id: @organization.id)
  else
    pending
  end
end

Given("debugger") do
  debugger
end

Given("the reports are generated") do
    params = {
      "account_filter" => "FL17",
      "controller" => "admin",
      "action" => "canvas"
    }
  report = create(:report_archive, organization_id: @organization.id, report_filters: params, generating_at: Time.now)
  ReportHelper.generate_report(@organization.slug, "FL17", params, report.id)
  sleep 1
  visit "/admin/reports"
  expect(page).to have_content("FL17")
end

Given("I am on the admin reports page for organization") do
  visit "/admin/reports"
  expect(page).to have_content("Reports for")
end

When(/^I click the "(.*?)" link$/) do |string|
  case string
  # when /(tb_share)/
  #   find(string).click
  #   @document.workflow_step_id = @document.workflow_step.next_workflow_step_id
  when /Edit Component/
    click_on("edit_#{@component.slug}")
  when /#edit_document/
    find(string).click
  when /#show_user/ 
    click_link("#{@user.name}")
  else
    click_link(string)
  end
end

When(/^I click on "(.*?)"$/) do |string|
  click_on(string)
end

Then("I should receive the report file") do
  filename = "#{@organization.slug}"
  page.response_headers['Content-Disposition'].to_s.include?(/filename=\"#{filename}_.*\.zip\"/.to_s)

end

Then("the Report zip file should have documents in it") do
  a = page.driver.response.body.gsub(/[^0-9a-z._]/i, '')
  expect(a).to have_content(".html")
  expect(a).to have_content(".css")
end

Given("the organization enable_workflows option is enabled") do
  org = @organization.self_and_ancestors.reorder(depth: :asc).first
  org.enable_workflows = true
  org.save
end

# Given("that i am logged in as a supervisor") do
#   pending # Write code here that turns the phrase above into concrete actions
# end

Given(/^I am on the (\w+) index page for the organization$/) do |controller|
  @controller = controller
  url = "/admin/organization/#{@organization.slug}/#{controller}"
  visit url
end

When(/^I fill in the (\w+) form with:$/) do |record_name, table|
  # table is a Cucumber::Ast::Table
  table.raw.each do |field,value|
    id = "##{record_name}_#{field}"
    e = first(id)
    expect(e).not_to be_nil, "Unable to find #{id}"
    case tag = e.tag_name
    when 'input','textarea'
      e.set(value)
    when 'select'
      option = e.first(:option, value)
      expect(option).not_to be_nil, "Unable to find option #{value}"
      option.select_option
    else
      puts "pending: #{tag}"
      pending # duno how to handle that type of element
    end
  end
end

Then(/^I should be able to see all the (\w+) for the organization$/) do |class_name|
  case class_name
  when /components/
    slugs = Component.where(organization_id: @organization.id).map(&:slug)
  when /workflow/
    slugs = WorkflowStep.where(organization_id: @organization.id).map(&:slug)
  when /periods/
    slugs = Period.where(organization_id: @organization.id).map(&:slug)
  end
  slugs.each do |slug|
    expect(page).to have_content(slug)
  end
end

Given(/^I am on the "(.*?)" page$/) do |page|
  case page
  when /edit_workflow_document/
    visit edit_document
  else
    visit page
  end
end

Then(/^I should see "(.*?)" in the url$/) do |string|
  expect(page.current_url).to have_content(string)
end

Then(/^I should be on the (\w+) document page$/) do |string|
  case string
  when /view/
    expect(page.current_url).to have_content(@document.view_id)
  when /edit/
    expect(page.current_url).to have_content(string)
  else
    pending
  end
end

Then(/^I should be on the (\w+) page$/) do |string|
  expect(page.current_url).to have_content(string)
end

Then(/^I should see "(.*?)"$/) do |string|
  # expect(page).to have_content(string)
  expect(page).to have_content(string)
end

Then(/^I should not see "(.*?)"$/) do |string|
  expect(page).to have_no_content(string)
end

Then(/^there should be a "(.*?)" button$/) do |string|
  raise page.current_url.to_yaml
  expect(page).to have_content(string)
end

Given("there is a {string}") do |table|
  create
  pending # Write code here that turns the phrase above into concrete actions
end

Given("the user has a document with a workflow step") do
  wf_start_step = @workflows[1].detect {|wf| wf["step_type"] == "start_step"}
  @document = create(:document, organization_id: @organization.id, user_id: @user, workflow_step_id: wf_start_step.id )
  expect(@document.workflow_step_id).to have_content(wf_start_step.id)
end

Given("the user has completed a workflow step") do
  @document.workflow_step_id = WorkflowStep.find(@document.workflow_step_id).next_workflow_step_id
  @document.save
end

Then(/^the document should be on step_(\d)$/) do |int|
  expect(@document.workflow_step.slug).to have_content(@workflows.first[int.to_i-1].slug)
end

When("I go to the document edit page for the users document") do
  visit edit_document_path(:id => @document.edit_id)
end

Then("I should not be able to edit the employee section") do
  puts "##### Cant test beyond this point before we have components and permissions setup #####"
  pending
end

Then("I should see a new document edit url") do
  expect(page.current_url).not_to have_content(@document.view_id)
end

Given(/^I am on the (\w*document\b) (\w+) page$/) do |document_type, page_path|
  case document_type
  when /canvas_document/
    pending
    # FakeWeb.register_uri(:any, "#{@organization.lms_authentication_source}/login/oauth2/auth", :body => "Authorizing", :data => {"access_token":"MTQ0NjJkZmQ5OTM2NDE1ZTZjNGZmZjI3","refresh_token":"IwOGYzYTlmM2YxOTQ5MGE3YmNmMDFkNTVk","state":"12345678"})
    # visit "http://lvh.me:#{Capybara.current_session.port}#{lms_course_document_path(@document.lms_course_id)}"
    # save_page
  when /document/
    visit edit_document_path(@document.edit_id)
  else
    pending
  end
end

Given(/^I am the (\w+) of the user$/) do |role|
  Assignment.create(user_id: @current_user.id, team_member_id: @user.id, role: role)
end

Then("I should see a saved document") do
  @document
end

Given(/^there are (\w+) (\w+)$/) do |amount, class_name|
  record = create_list(class_name, amount.to_i)
  instance_variable_set("@#{class_name.pluralize}",record)
end

Then(/^I should be able to see all the organizations$/) do
  slugs = Organization.all.map(&:name)
  slugs.each do |slug|
    expect(page).to have_content(slug)
  end
end

Given(/^I am on the organization (\w+) page$/) do |action|
  case action
  when /show/
    visit organization_path(@organization.slug)
  when /index/
    visit organizations_path
  when /edit/
    visit edit_organization_path(id: @organization[:id], slug: @organization.slug)
  when /new/
    visit new_organization_path
  when /delete/
    page.driver.delete(organization_path(@organization.slug))
  end
end

Then(/^an "(.*?)" should be (present|absent) with:$/) do |class_name, should_be, table|
  record = class_name.classify.safe_constantize
  record = class_name.safe_constantize if record.nil?
  expect(record.find_by(
    Hash[*table.raw.flatten(1)]).present?)
      .to eq(should_be == "present")
end

Given(/^there is a "(.*?)" with:$/) do |class_name, table|
  instance_variable_set( "@#{class_name}",
    class_name.classify.safe_constantize
    .create( Hash[ *table.raw.flatten(1) ] ) )
end

Then(/^the "(.*?)" should be (present|absent)$/) do |class_name, should_be|
  record = instance_variable_get("@#{class_name}")
  expect(class_name.classify.safe_constantize
    .find_by(id: record.id).present?)
      .to eq(should_be == "present")
end

Given(/^I search documents for "(.*?)"$/) do |search|
  visit documents_search_path(slug: @organization.full_slug, q: search)
end

Given(/^the "(.*?)" has:$/) do |class_name, table|
  record = instance_variable_get("@#{class_name}")
  update_hash = Hash[ *table.raw.flatten(1) ]
  record.update update_hash
  expect(class_name.classify.safe_constantize
    .find_by(update_hash).present?)
      .to eq(true)
end

Given(/^the "(.*?)" has a "(.*?)" with:$/) do |parent_var_name, child_class_name, table|
  hash = Hash[ *table.raw.flatten(1) ]
  parent_record = instance_variable_get("@#{parent_var_name}")
  hash["#{parent_record.class}_id".downcase] = parent_record.id
  instance_variable_set( "@#{child_class_name}",
    child_class_name.classify.safe_constantize.create( hash ) )
end

Given(/^the "(.*?)" has a "(.*?)"$/) do |parent_var_name, factory_name|
  factory_name = factory_name.to_sym
  parent_record = instance_variable_get("@#{parent_var_name}")
  record = FactoryBot.create(factory_name,"#{parent_record.class}_id".downcase.to_sym=>parent_record.id)
  instance_variable_set( "@#{record.class.name.downcase}", record)
  expect(record.present? && !record.new_record? && record.is_a?(Document))
      .to eq(true)
end

Then("the document should be associated with my user") do
  expect(Document.find(@document.id).user_id).to eq(@current_user.id)
end
