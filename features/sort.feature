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
    For now, scalars are not sorted.  At some point, we want to add a flag or
    controll comments to indicate some lists of scalars need to be sorted.
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
      - foo
      - bar
      - baz
      """
  Scenario: Sorting nested lists and dictionaries
    Given a file named "sample.yaml" with:
      """
      ---
      items:
      - foo: 1
        bar: 2
        baz: 3
      - toto: 4
        tata: 5
        titi: 6
      """
    When I successfully run `exe/yaml-sort sample.yaml`
    Then the stdout should contain:
      """
      ---
      items:
      - bar: 2
        baz: 3
        foo: 1
      - tata: 5
        titi: 6
        toto: 4
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
      - foo
      - bar
      - baz
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
        # Single line
        - foo
        # Multi
        # line
        - bar
      # A single-line comment is attached to the following item
      foo: foo
      """
  Scenario: Sorting aliases
    Given a file named "common.yaml" with:
      """
      ---
      def: &alias1
        a: 1
        b: &ref 2
      abc: *alias1
      jkl: &alias2 "3"
      ghi: *alias2
      mno:
        pqr:
          vwx:
            - &ref3 34
            - *ref
            - &ref2 23
            - *ref
            - *ref3
          stu: *alias2
          b: *ref2
          a: *ref
          c: *ref2
      """
    When I successfully run `exe/yaml-sort common.yaml`
    Then the stdout should contain:
      """
      ---
      abc: &alias1
        a: 1
        b: &ref 2
      def: *alias1
      ghi: &alias2 "3"
      jkl: *alias2
      mno:
        pqr:
          a: *ref
          b: &ref2 23
          c: *ref2
          stu: *alias2
          vwx:
            - &ref3 34
            - *ref
            - *ref2
            - *ref
            - *ref3
      """
