module ActiveFulfillment
  module DotcomDistribution
    module NilInjector
      def inject_nil(v)
        v ? {} : {'xsi:nil': 'true'}
      end
    end
  end
end
