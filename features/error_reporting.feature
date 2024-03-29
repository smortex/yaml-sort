Feature: Error reporting
  Scenario: Invalid file content with unexpected key
    Given a file named "sample.yaml" with:
      """
      ---
      - baz



      foo: bar

      """
    When I run `exe/yaml-sort sample.yaml`
    Then the exit status should be 1
    And the stderr should contain:
      """
      sample.yaml:6 unexpected KEY
      foo: bar
      ^~~~
      """

  Scenario: Invalid file content with unexpected list item
    Given a file named "sample.yaml" with:
      """
      ---




      foo: bar
      - baz
      """
    When I run `exe/yaml-sort sample.yaml`
    Then the exit status should be 1
    And the stderr should contain:
      """
      sample.yaml:7 unexpected ITEM
      - baz
      ^~
      """

  Scenario: Invalid file content with unexpected end-of-file
    Given a file named "sample.yaml" with:
      """
      ---


      foo:

      """
    When I run `exe/yaml-sort sample.yaml`
    Then the exit status should be 1
    And the stderr should contain exactly:
      """
      sample.yaml:4 unexpected UNINDENT
      foo:
      ^
      """

  Scenario: Invalid file content with unexpected end-of-file
    Given a file named "sample.yaml" with:
      """
      ---




      """
    When I run `exe/yaml-sort sample.yaml`
    Then the exit status should be 1
    And the stderr should contain exactly:
      """
      sample.yaml:4 unexpected end-of-file
      """
  Scenario: Usupported <<: references
    Given a file named "sample.yaml" with:
      """
      ---
      foo: &ref
        a: 1
        b: 2
      bar:
        <<: *ref
      """
    When I run `exe/yaml-sort sample.yaml`
    Then the exit status should be 1
    And the stderr should contain exactly:
      """
      sample.yaml:6: '<<:' references are not sortable:
        <<: *ref
        ^~~
      """
