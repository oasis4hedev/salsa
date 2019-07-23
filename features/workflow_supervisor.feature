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
     Given I am on the workflow_steps index page for the organization
     When I click the "New" link
     And I fill in the workflow_step form with:
        | slug | step_1 |
        | name | Step 1 |
        | next_workflow_step_id | |
     And I click on "Create Workflow step"
     Then I should see "Workflow step was successfully created."

  Scenario: see error when creating workflow step
     Given I am on the workflow_steps index page for the organization
     When I click the "New" link
     And I fill in the workflow_step form with:
        | slug | step 1 |
        | name | Step 1 |
        | next_workflow_step_id | |
     And I click on "Create Workflow step"
     Then I should see "Slug only allows letters, numers, _ and -"

  Scenario: update workflow step
     Given there is a workflow_step on the organization
     And I am on the workflow_steps index page for the organization
     When I click the "Edit" link
     When I fill in the workflow_step form with:
        | slug | step_54|
        | name | Step 54 |
        | next_workflow_step_id | |
     And I click on "Update Workflow step"
     Then I should see "Workflow step was successfully updated."

  Scenario: see error when updating workflow step
     Given there is a workflow_step on the organization
     And I am on the workflow_steps index page for the organization
    When I click the "Edit" link
     When I fill in the workflow_step form with:
        | slug | step 54|
        | name | Step 54 |
        | next_workflow_step_id | |
     And I click on "Update Workflow step"
     Then I should see "Slug only allows letters, numers, _ and -"

  Scenario: delete workflow step
     Given there is a workflow_step on the organization
     And I am on the workflow_steps index page for the organization
     When I click the "Delete" link
     Then I should see "Workflow step was successfully destroyed."

  @javascript
  Scenario: fail to complete step_1
    Given there is a workflow
    And there is a user with the role of staff
    And there is a document on the first step in the workflow and assigned to the user
    And I am on the "/workflow/documents" page
    Then I should not see "#edit_document"
    When I go to the document edit page for the users document
    Then I should see "you are not authorized to edit that document"

  @javascript
  Scenario: fail to complete final_step
    Given there is a workflow
    And there is a document on the last step in the workflow and assigned to the current user
    And I am on the "/workflow/documents" page
    Then I should not see "Edit"
    And I should not see "#edit_document"
    When I go to the document edit page for the users document
    And I click the "#tb_share" link
    Then I should see "You are not authorized to edit this document"
