Feature: Builder
  Scenario: Building a basic theme
    Given I am in a forge project named "basic-theme"
    When I successfully run `bundle exec forge build`
    Then the following files should exist:
      | build/style.css         |
      | build/theme.js          |
      | build/functions.php     |
      | build/index.php         |
      | build/partials/loop.php |
