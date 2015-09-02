module ActiveFulfillment
  module DotcomDistribution
    module Model
      def initialize(args={})
        args.each do |k, v|
          public_send(:"#{k}=", v)
        end
      end
    end
  end
end

Dir[File.join(__dir__, "dotcom_distribution/*.rb")].each do |path|
  require "active_fulfillment/models/dotcom_distribution/#{File.basename(path).sub(/\.rb$/, '')}"
end
