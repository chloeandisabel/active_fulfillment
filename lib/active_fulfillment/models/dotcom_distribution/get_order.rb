module ActiveFulfillment
  module DotcomDistribution

    class GetOrder
      include Model
      attr_accessor :client_order_number,
                    :dcd_order_number,
                    :dcd_order_suffix,
                    :order_status,
                    :ship_date


      def self.response_from_xml(xml)
        success = true, message = '', records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!
        doc.xpath("//order").each do |el|
          records << GetOrder.new({client_order_number: el.at('.//client_order_number').try(:text),
                                   dcd_order_number: el.at('.//dcd_order_number').try(:text),
                                   dcd_order_suffix: el.at('.//dcd_order_suffix').try(:text),
                                   order_status: el.at('.//order_status').try(:text),
                                   ship_date: el.at('.//ship_date').try(:text)})
        end
        Response.new(true, '', {data: records})
      end
    end
  end
end
