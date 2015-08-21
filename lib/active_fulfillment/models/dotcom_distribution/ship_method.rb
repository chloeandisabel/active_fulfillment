module ActiveFulfillment
  module DotcomDistribution

    class ShipMethod

      include ::ActiveModel::Model
      include ::ActiveModel::Validations
      include ::ActiveModel::Serializers::Xml

      attr_accessor :carrier,
                    :service,
                    :shipping_code,
                    :shipping_description

      validates_length_of :carrier, maximum: 20, allow_blank: false
      validates_length_of :service, maximum: 20, allow_blank: false
      validates_length_of :shipping_code, maximum: 40, allow_blank: false
      validates_length_of :shipping_description, maximum: 300, allow_blank: false

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
