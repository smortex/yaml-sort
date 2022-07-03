Feature: Linting YAML files
  Scenario: When a file is sorted
    Given a file named "input.yaml" with:
      """
      ---
      bar: bar
      baz: baz
      foo: foo

      """
    When I successfully run `yaml-sort --lint input.yaml`
    And the output should contain exactly ""
      
  Scenario: When a file is not sorted
    Given a file named "input.yaml" with:
      """
      ---
      foo: foo
      bar: bar
      baz: baz

      """
    When I run `yaml-sort --lint input.yaml`
    Then the exit status should be 1
    And the stderr should contain exactly:
      """
      diff a/input.yaml b/input.yaml
      --- a/input.yaml
      +++ b/input.yaml
      @@ -1,4 +1,4 @@
       ---
      -foo: foo
       bar: bar
       baz: baz
      +foo: foo
      """
