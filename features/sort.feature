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
  Scenario: Sorting Puppet hiera data
    The `lookup_options` key is special, we want it to always be at the
    beginning of the file.
    Given a file named "common.yaml" with:
      """
      ---
      profile::acme::secret: password
      lookup_options:
        "profile::acme::secret":
          convert_to: "Sensitive"
        "^secrets::.*":
          convert_to: "Sensitive"
      classes:
      - foo
      - bar
      - baz
      """
    When I successfully run `exe/yaml-sort common.yaml`
    Then the stdout should contain:
      """
      ---
      lookup_options:
        "^secrets::.*":
          convert_to: "Sensitive"
        "profile::acme::secret":
          convert_to: "Sensitive"
      classes:
      - bar
      - baz
      - foo
      profile::acme::secret: password
      """
  Scenario: Preserving comments
    Given a file named "common.yaml" with:
      """
      ---
      # A single-line comment is attached to the following item
      foo: foo
      # A multi-line comment is attached to the following item
      # (Just like a single-line comment)
      bar: bar
      baz:
        # Single line
        - foo
        # Multi
        # line
        - bar
      """
    When I successfully run `exe/yaml-sort common.yaml`
    Then the stdout should contain:
      """
      ---
      # A multi-line comment is attached to the following item
      # (Just like a single-line comment)
      bar: bar
      baz:
        # Multi
        # line
        - bar
        # Single line
        - foo
      # A single-line comment is attached to the following item
      foo: foo
      """
