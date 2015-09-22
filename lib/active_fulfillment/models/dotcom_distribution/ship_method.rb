module ActiveFulfillment
  module DotcomDistribution

    class ShipMethod
      include Model

      attr_accessor :carrier,
                    :service,
                    :shipping_code,
                    :shipping_description

      def self.response_from_xml(xml)
        success = true, message = '', records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!
        doc.xpath("//ship_method").each do |r|
          records << ShipMethod.new(carrier: r.at('.//carrier').try(:text),
                                    service: r.at('.//service').try(:text),
                                    shipping_code: r.at('.//shipping_code').try(:text),
                                    shipping_description: r.at('.//shipping_description').try(:text))
        end
        records
      end
    end
  end
end
