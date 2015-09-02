module ActiveFulfillment
  module DotcomDistribution

    class ShipMethod
      include Model

      attr_accessor :carrier,
                    :service,
                    :shipping_code,
                    :shipping_description

      def self.response_from_xml(xml)
        success = true, message = '', hash = {}, records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!

        doc.xpath("//ship_method").each do |r|
          hash[:carrier] = r.at('.//carrier').try(:text)
          hash[:service] = r.at('.//service').try(:text)
          hash[:shipping_code] = r.at('.//shipping_code').try(:text)
          hash[:shipping_description] = r.at('.//shipping_description').try(:text)

          records << ShipMethod.new(hash)
        end
        records
      end

    end

  end
end
