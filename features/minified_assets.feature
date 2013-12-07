Feature: Minified assets
  Scenario: Minifying CSS
    Given a fixture theme "minified-assets-theme"
    When I successfully run `bundle exec forge build`
    Then the following files should exist:
      | build/style.css |
    Then the file "build/style.css" should contain exactly:
      """
      p{margin:1em 0;background:#fff;color:red}

      """
