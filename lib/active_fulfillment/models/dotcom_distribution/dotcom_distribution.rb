module ActiveFulfillment
  module DotcomDistribution
    module XMLHelper
      def inject_nil(v)
        v ? {} : {'xsi:nil' => 'true'}
      end
    end
  end
end
