# frozen_string_literal: true

RSpec.shared_context "parses document" do
  it "parses the document" do
    expect { Yaml::Sort::Parser.new.parse(document) }.to_not raise_exception
  end
end

RSpec.describe Yaml::Sort::Parser do
  describe "#emit" do
    let(:document) do
      <<~YAML
        ---
        foo: bar
        bar: |-
          Plop
        baz: 42
      YAML
    end

    subject { Yaml::Sort::Parser.new.scan(document) }

    it do
      is_expected.to eq([[:START_OF_DOCUMENT, { length: 3, lineno: 1, position: 0, value: "---", indent: nil }],
                         [:KEY, { length: 4, lineno: 2, position: 0, value: "foo:", indent: "" }],
                         [:VALUE, { length: 3, lineno: 2, position: 5, value: "bar", indent: nil }],
                         [:KEY, { length: 4, lineno: 3, position: 0, value: "bar:", indent: "" }],
                         [:VALUE, { length: 9, lineno: 3, position: 5, value: "|-\n  Plop", indent: nil }],
                         [:KEY, { length: 4, lineno: 5, position: 0, value: "baz:", indent: "" }],
                         [:VALUE, { length: 2, lineno: 5, position: 5, value: "42", indent: nil }],
                         [:UNINDENT, { length: 0, lineno: 5, position: 0, value: "", indent: nil }]])
    end
  end

  context "when given single-quoted string literals" do
    let(:document) do
      # rubocop:disable Layout/TrailingWhitespace
      <<~YAML
        ---
        example: 'Several lines of text,
          containing ''single quotes''. Escapes (like \\n) don''t do anything.
          
          Newlines can be added by leaving a blank line.
            Leading whitespace on lines is ignored.'
      YAML
      # rubocop:enable Layout/TrailingWhitespace
    end

    include_context "parses document"

    context "#scan" do
      subject { Yaml::Sort::Parser.new.scan(document).map { |itm| [itm[0], itm[1][:value]] } }
      it do
        # rubocop:disable Layout/TrailingWhitespace
        is_expected.to eq([[:START_OF_DOCUMENT, "---"],
                           [:KEY, "example:"],
                           [:VALUE, <<~STRING.chomp],
                             'Several lines of text,
                               containing ''single quotes''. Escapes (like \\n) don''t do anything.
                               
                               Newlines can be added by leaving a blank line.
                                 Leading whitespace on lines is ignored.'
                           STRING
                           [:UNINDENT, ""]])
        # rubocop:enable Layout/TrailingWhitespace
      end
    end
  end

  context "when given double-quoted string literals" do
    let(:document) do
      # rubocop:disable Layout/TrailingWhitespace
      <<~YAML
        ---
        example: "Several lines of text,
          containing \\"double quotes\\". Escapes (like \\\\n) work.\\nIn addition,
          newlines can be esc\\
          aped to prevent them from being converted to a space.
          
          Newlines can also be added by leaving a blank line.
            Leading whitespace on lines is ignored."
      YAML
      # rubocop:enable Layout/TrailingWhitespace
    end

    include_context "parses document"

    context "#scan" do
      subject { Yaml::Sort::Parser.new.scan(document).map { |itm| [itm[0], itm[1][:value]] } }
      it do
        # rubocop:disable Layout/TrailingWhitespace
        is_expected.to eq([[:START_OF_DOCUMENT, "---"],
                           [:KEY, "example:"],
                           [:VALUE, <<~STRING.chomp],
                             "Several lines of text,
                               containing \\"double quotes\\". Escapes (like \\\\n) work.\\nIn addition,
                               newlines can be esc\\
                               aped to prevent them from being converted to a space.
                               
                               Newlines can also be added by leaving a blank line.
                                 Leading whitespace on lines is ignored."
                           STRING
                           [:UNINDENT, ""]])
        # rubocop:enable Layout/TrailingWhitespace
      end
    end
  end

  context "when given a dictionary" do
    let(:document) do
      <<~YAML
        ---
        foo: bar
        bar: baz
      YAML
    end

    include_context "parses document"

    context "#scan" do
      subject { Yaml::Sort::Parser.new.scan(document).map(&:first) }
      it do
        is_expected.to eq(%i[START_OF_DOCUMENT
                             KEY
                             VALUE
                             KEY
                             VALUE
                             UNINDENT])
      end
    end
  end

  context "when given a nested dictionary" do
    let(:document) do
      <<~YAML
        ---
        foo: bar
        bar:
          foo: bar
          bar: baz
      YAML
    end

    include_context "parses document"

    context "#scan" do
      subject { Yaml::Sort::Parser.new.scan(document).map(&:first) }
      it do
        is_expected.to eq(%i[START_OF_DOCUMENT
                             KEY
                             VALUE
                             KEY
                             KEY
                             VALUE
                             KEY
                             VALUE
                             UNINDENT
                             UNINDENT])
      end
    end
  end

  context "when given a list" do
    let(:document) do
      <<~YAML
        ---
        - foo
        - bar
        - baz
      YAML
    end

    include_context "parses document"

    context "#scan" do
      subject { Yaml::Sort::Parser.new.scan(document).map(&:first) }
      it do
        is_expected.to eq([:START_OF_DOCUMENT,
                           "-",
                           :VALUE,
                           "-",
                           :VALUE,
                           "-",
                           :VALUE,
                           :UNINDENT])
      end
    end
  end

  context "when given a dictionary in a list" do
    let(:document) do
      <<~YAML
        ---
        - foo: bar
          bar: baz
        - foo: 12
      YAML
    end

    include_context "parses document"

    context "#scan" do
      subject { Yaml::Sort::Parser.new.scan(document).map(&:first) }
      it do
        is_expected.to eq([:START_OF_DOCUMENT,
                           "-",
                           :KEY,
                           :VALUE,
                           :KEY,
                           :VALUE,
                           :UNINDENT,
                           "-",
                           :KEY,
                           :VALUE,
                           :UNINDENT,
                           :UNINDENT])
      end
    end
  end

  context "when given a list in a dictionary" do
    let(:document) do
      <<~YAML
        ---
        foo:
        - foo
        - bar
        - baz
      YAML
    end

    include_context "parses document"

    context "#scan" do
      subject { Yaml::Sort::Parser.new.scan(document).map(&:first) }
      it do
        is_expected.to eq([:START_OF_DOCUMENT,
                           :KEY,
                           "-",
                           :VALUE,
                           "-",
                           :VALUE,
                           "-",
                           :VALUE,
                           :UNINDENT,
                           :UNINDENT])
      end
    end
  end

  context "when given comments" do
    let(:document) do
      <<~YAML
        ---
        # This is a
        # dictionary
        foo:
          # foo
          - foo
          # bar
          - bar
          # baz
          - baz
      YAML
    end

    include_context "parses document"

    context "#scan" do
      subject { Yaml::Sort::Parser.new.scan(document).map(&:first) }
      it do
        is_expected.to eq([:START_OF_DOCUMENT,
                           :KEY,
                           "-",
                           :VALUE,
                           "-",
                           :VALUE,
                           "-",
                           :VALUE,
                           :UNINDENT,
                           :UNINDENT])
      end
    end
  end
end
