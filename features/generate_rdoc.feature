Feature: Generate RDoc

  As a developer
  I want to be able to generate RDoc for projects on GitHub
  So that I can see how things are implemented

  Scenario: Clone repository and generate RDoc

    Given a project on github named "josh-my-awesome-project"
    When I visit "/josh/my-awesome-project"
    Then I should see "Cloning repository..."
    When it is done cloning the repository
    And I visit "/josh/my-awesome-project"
    Then I should be redirected to "/josh/my-awesome-project/tree/master"
    And I should see "Generating RDoc..."
    When it is done generating the RDoc
    And I visit "/josh/my-awesome-project/tree/master"
    Then I should see the generated rdoc

  Scenario: Error cloning repository

    Given a project on github named "josh-my-awesome-project"
    When I visit "/josh/my-awesome-project"
    Then I should see "Cloning repository..."
    When there are errors cloning the repository
    And I visit "/josh/my-awesome-project"
    Then I should see "Error cloning repository"

  Scenario: Error generating RDoc

    Given a project on github named "josh-my-awesome-project"
    When I visit "/josh/my-awesome-project"
    Then I should see "Cloning repository..."
    When it is done cloning the repository
    And I visit "/josh/my-awesome-project"
    Then I should be redirected to "/josh/my-awesome-project/tree/master"
    And I should see "Generating RDoc..."
    When there are errors generating the RDoc
    And I visit "/josh/my-awesome-project/tree/master"
    Then I should see "Error generating RDoc"
