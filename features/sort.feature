Feature: Sorting YAML files
  Scenario: Sorting dictionaries by key
    Given a file named "dictionaries.yaml" with:
      """
      ---
      foo: foo
      bar: bar
      baz: baz
      """
    When I successfully run `exe/yaml-sort dictionaries.yaml`
    Then the stdout should contain:
      """
      ---
      bar: bar
      baz: baz
      foo: foo
      """
  Scenario: Sorting lists by value
    Given a file named "list.yaml" with:
      """
      ---
      - foo
      - bar
      - baz
      """
    When I successfully run `exe/yaml-sort list.yaml`
    Then the stdout should contain:
      """
      ---
      - bar
      - baz
      - foo
      """
