Feature: Generator
  Scenario: Checking the project folder for structure
    Given I am in a forge project named "basic-theme"

    Then the following files should exist:
      | Gemfile   |
      | config.rb |

    When I cd to "source"

    Then the following files should exist:
      | functions/functions.php                       |
      | assets/javascripts/theme.js                   |
      | assets/stylesheets/style.css.sass             |
      | assets/stylesheets/_base.sass                 |

    And the file "functions/functions.php" should contain "basic-theme_setup"

