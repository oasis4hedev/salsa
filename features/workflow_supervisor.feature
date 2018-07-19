Feature: workflow steps supervisor
as a supervisor
In order to do employee review
I want to have a defined set of workflow steps to go thrugh

  Background:
    Given there is a organization
    And the organization enable_workflows option is enabled
    And that I am logged in as a supervisor on the organization

  Scenario: View all workflow_steps for the organization
    Given there is a workflow
    And there is a workflow_step on the organization
    And I am on the workflow_steps index page for the organization
    Then I should be able to see all the workflow_steps for the organization

  Scenario: create workflow step
     When I click the "New" link
     And I fill in the workflow_step form with:
        | slug | step_1 |
        | name | Step 1 |
        | next_workflow_step_id | |
        | start_step | true |
        | end_step | true |
     And I click on "Create Workflow step"
     Then I should see "Workflow step was successfully created."

  Scenario: update workflow step
     Given there is a workflow_step on the organization
     And I am on the workflow_steps index page for the organization
     And I click the "Edit" link
     When I fill in the workflow_step form with:
        | slug | step_54|
        | name | Step 54 |
        | next_workflow_step_id | |
        | start_step | false |
        | end_step | false |
     And I click on "Update Workflow step"
     Then I should see "Workflow step was successfully updated."

  Scenario: delete workflow step
     Given there is a workflow_step on the organization
     And I am on the workflow_steps index page for the organization
     When I click the "Delete" link
     Then I should see "Workflow step was successfully destroyed."

  @javascript
  Scenario: review employee's document
     Given there is a user with the role of staff
     And there is a workflow
     And the user has a document with a workflow_step of 4
     And I am on the "/workflow/documents" page
     And I save the page
     When I click the "Edit" link
     # Then I should not be able to edit the employee section
     And I click the "tb_share" link
     Then the document workflow_step_id should be nil
