Feature: Generate RDoc via GitHub post-commit-hook

  As a developer with a project on GitHub
  I want my RDoc to be automatically generated for each commit
  So that I don't have to manually request re-generation

  Background:

    Given a project on GitHub named "josh-my-awesome-project"
    And the repository has already been cloned

  Scenario: Fetch latest code and re-generate RDoc

    When GitHub sends a post commit message for revision "f0af3cbc64f0667c1db3f110274ca8789096f09a"
    And it is done updating the project
    And I visit "/josh/my-awesome-project/tree/master"
    Then I should see the generated rdoc for revision "f0af3cbc64f0667c1db3f110274ca8789096f09a"