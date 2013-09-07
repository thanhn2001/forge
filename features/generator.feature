Feature: Generator
  Scenario: Checking the project folder for structure
    Given I am in a forge project named "basic-theme"
    When I cd to "source"
    Then the following files should exist:
      | functions/functions.php                       |
      | assets/javascripts/theme.js                   |
      | assets/stylesheets/style.css.sass             |
      | assets/stylesheets/_base.sass                 |
