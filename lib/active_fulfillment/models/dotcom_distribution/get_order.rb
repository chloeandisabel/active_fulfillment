module ActiveFulfillment
  module DotcomDistribution

    class GetOrder

      include ::ActiveModel::Model

      attr_accessor :client_order_number,
                    :dcd_order_number,
                    :dcd_order_suffix,
                    :order_status,
                    :ship_date


      def self.response_from_xml(xml)
        success = true, message = '', hash = {}, records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!

        doc.xpath("//order").each do |el|
          hash[:client_order_number] = el.at('.//client_order_number').try(:text)
          hash[:dcd_order_number] = el.at('.//dcd_order_number').try(:text)
          hash[:dcd_order_suffix] = el.at('.//dcd_order_suffix').try(:text)
          hash[:order_status] = el.at('.//order_status').try(:text)
          hash[:ship_date] = el.at('.//ship_date').try(:text)

          records << GetOrder.new(hash)
        end

        Response.new(true, '', {data: records})
      end

    end

  end
end
