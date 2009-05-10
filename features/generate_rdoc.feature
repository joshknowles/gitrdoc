Feature: Generate RDoc

  As a developer
  I want to be able to generate RDoc for projects on GitHub
  So that I can see how things are implemented

  Background:

    Given a project on GitHub named "josh-my-awesome-project"

  Scenario: Clone repository and generate RDoc for master

    When I visit "/josh/my-awesome-project"
    Then I should see "Cloning repository..."
    When it is done cloning the repository
    And I visit "/josh/my-awesome-project"
    Then I should be redirected to "/josh/my-awesome-project/tree/master"
    And I should see "Generating RDoc..."
    When it is done generating the RDoc
    And I visit "/josh/my-awesome-project/tree/master"
    Then I should see the generated rdoc

  Scenario: Generate RDoc for a given tag

    Given the repository has already been cloned
    And it contains a tag named "awesome-tag-name"
    When I visit "/josh/my-awesome-project/tree/awesome-tag-name"
    Then I should see "Generating RDoc..."
    When it is done generating the RDoc
    And I visit "/josh/my-awesome-project/tree/awesome-tag-name"
    Then I should see the generated rdoc

  Scenario: Error cloning repository

    When I visit "/josh/my-awesome-project"
    Then I should see "Cloning repository..."
    When there are errors cloning the repository
    And I visit "/josh/my-awesome-project"
    Then I should see "Error cloning repository"

  Scenario: Unknown tag/branch

    Given the repository has already been cloned
    And it doesn't contain a reference named "invalid-tag-name"
    When I visit "/josh/my-awesome-project/tree/invalid-tag-name"
    Then I should see "Unknown reference"

  Scenario: Error generating RDoc

    Given the repository has already been cloned
    When I visit "/josh/my-awesome-project"
    Then I should be redirected to "/josh/my-awesome-project/tree/master"
    And I should see "Generating RDoc..."
    When there are errors generating the RDoc
    And I visit "/josh/my-awesome-project/tree/master"
    Then I should see "Error generating RDoc"