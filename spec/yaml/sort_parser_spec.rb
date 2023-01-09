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

          Plop
        baz biz: 42
        qux: 'quux: quuux'
        ta'ata: mā'ohi
        multi-line: starts here
          continues

          and ends there
      YAML
    end

    subject { Yaml::Sort::Parser.new.scan(document) }

    it do
      is_expected.to eq([[:START_OF_DOCUMENT, { length: 3, lineno: 1, position: 0, value: "---", indent: nil }],
                         [:KEY, { length: 4, lineno: 2, position: 0, value: "foo:", indent: "" }],
                         [:VALUE, { length: 3, lineno: 2, position: 5, value: "bar", indent: nil }],
                         [:KEY, { length: 4, lineno: 3, position: 0, value: "bar:", indent: "" }],
                         [:VALUE, { length: 17, lineno: 3, position: 5, value: "|-\n  Plop\n\n  Plop", indent: nil }],
                         [:KEY, { length: 8, lineno: 7, position: 0, value: "baz biz:", indent: "" }],
                         [:VALUE, { length: 2, lineno: 7, position: 9, value: "42", indent: nil }],
                         [:KEY, { length: 4, lineno: 8, position: 0, value: "qux:", indent: "" }],
                         [:VALUE, { length: 13, lineno: 8, position: 5, value: "'quux: quuux'", indent: nil }],
                         [:KEY, { length: 7, lineno: 9, position: 0, value: "ta'ata:", indent: "" }],
                         [:VALUE, { length: 6, lineno: 9, position: 8, value: "mā'ohi", indent: nil }],
                         [:KEY, { length: 11, lineno: 10, position: 0, value: "multi-line:", indent: "" }],
                         [:VALUE, {
                           length: 41,
                           lineno: 10,
                           position: 12,
                           value: "starts here\n  continues\n\n  and ends there",
                           indent: nil,
                         }],
                         [:UNINDENT, { length: 0, lineno: 13, position: 0, value: "", indent: nil }]])
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
        is_expected.to eq(%i[START_OF_DOCUMENT
                             ITEM
                             VALUE
                             ITEM
                             VALUE
                             ITEM
                             VALUE
                             UNINDENT])
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
        is_expected.to eq(%i[START_OF_DOCUMENT
                             ITEM
                             KEY
                             VALUE
                             KEY
                             VALUE
                             UNINDENT
                             ITEM
                             KEY
                             VALUE
                             UNINDENT
                             UNINDENT])
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
        is_expected.to eq(%i[START_OF_DOCUMENT
                             KEY
                             ITEM
                             VALUE
                             ITEM
                             VALUE
                             ITEM
                             VALUE
                             UNINDENT
                             UNINDENT])
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
        is_expected.to eq(%i[START_OF_DOCUMENT
                             KEY
                             ITEM
                             VALUE
                             ITEM
                             VALUE
                             ITEM
                             VALUE
                             UNINDENT
                             UNINDENT])
      end
    end
  end
end
