require File.dirname(__FILE__) + '/helper'

class XmlVarGeneratorTest < Test::Unit::TestCase
  context "given a hash of values" do
    setup do
      @generator = HoptoadNotifier::XmlVarGenerator.new(
        :string        => "a string",
        :integer       => 3,
        :float         => 2.718281828,
        :subhash       => {
          :substring   => "a substring",
          :subsubarray => [ 1, 2, "3" ]
        },
        :subarray      => ["hello", 3],
        :object        => Module.new
      )
      builder  = Builder::XmlMarkup.new
      builder.container do |container|
        @generator.build(container)
      end
      xml = builder.to_s
      @document = Nokogiri::XML::Document.parse(xml)
    end

    should "output a lonely string" do
      assert_valid_node(@document,
                        "//var[@key='string']",
                        "a string")
    end

    should "output an integer" do
      assert_valid_node(@document,
                        "//var[@key='integer']",
                        '3')
    end

    should "output a float" do
      assert_valid_node(@document,
                        "//var[@key='float']",
                        '2.718281828')
    end

    should "output a subhash" do
      assert_valid_node(@document,
                        "//var/@key",
                        "subhash")
    end

    should "output a string in a subhash" do
      assert_valid_node(@document,
                        "//var[@key='subhash']/var[@key='substring']",
                        "a substring")
    end

    should "output an array, inspecting the contents" do
      assert_valid_node(@document,
                        "//var[@key='subarray']",
                        '["hello", 3]')
    end

    should "output an subarray, inspecting the contents" do
      assert_valid_node(@document,
                        "//var[@key='subhash']/var[@key='subsubarray']",
                        '[1, 2, "3"]')
    end

    should "output generic objects" do
      assert_valid_node(@document,
                        "//var[@key='object']",
                        /#<Module:0x[0-9a-f]+>/)
    end
  end
end
