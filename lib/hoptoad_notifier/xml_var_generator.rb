module HoptoadNotifier
  class XmlVarGenerator
    def initialize(params)
      @params = params
    end

    def build(builder)
      @params.each do |key, value|
        Generic.get(value).build(builder, key)
      end
      builder
    end

    class Generic
      def self.serialize(value)
        get(value).serialize
      end

      def self.get(value)
        klass = @subclasses.select{|c| value.is_a?(c.for_class) }.first || Generic
        klass.new(value)
      end

      def self.inherited(other)
        (@subclasses ||= []) << other
      end

      def initialize(value)
        @value = value
      end

      def build(builder, key = nil)
        builder.var(serialize, :key => key)
      end

      def serialize
        @value.to_s
      end
    end

    class Hash < Generic
      def self.for_class; ::Hash; end

      def build(builder, key = nil)
        builder.var(:key => key) do |subhash|
          XmlVarGenerator.new(@value).build(subhash)
        end
      end
    end

    class Array < Generic
      def self.for_class; ::Array; end

      def serialize
        @value.inspect
      end
    end

    class File < Generic
      def self.for_class; ::File; end

      def serialize
        @value.inspect
      end
    end
  end
end
