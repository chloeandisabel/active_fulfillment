module ActiveFulfillment
  module DotcomDistribution

    class Backorder
      include Model
      attr_accessor :carrier,
                    :dcd_order_number,
                    :dcd_order_release_number,
                    :department,
                    :order_date,
                    :order_number,
                    :priority_date,
                    :ship_to_email,
                    :ship_to_name,
                    :backorder_items

      def self.response_from_xml(xml)
        success = true, message = '', records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!
        doc.xpath("//backorder").each do |el|
          hash = {carrier: el.at('.//carrier').try(:text),
                  dcd_order_number: el.at('.//dcd_order_number').try(:text),
                  dcd_order_release_number: el.at('.//dcd_order_release_number').try(:text),
                  department: el.at('.//department').try(:text),
                  order_date: el.at('.//order_date').try(:text),
                  order_number: el.at('.//order_number').try(:text),
                  priority_date: el.at('.//priority_date').try(:text),
                  ship_to_email: el.at('.//ship_to_email').try(:text),
                  ship_to_name: el.at('.//ship_to_name').try(:text)}
          hash[:backorder_items] = [] if hash[:backorder_items].nil? && el.xpath('.//bo_items').size > 0
          el.xpath('.//bo_item').each do |item|
            hash[:backorder_items] <<
              BackorderItem.new({vendor: item.at('.//vendor').try(:text),
                                 sku: item.at('.//sku').try(:text),
                                 quantity_pending: item.at('.//quantity_pending').try(:text).try(:to_i),
                                 quantity_backordered: item.at('.//quantity_backordered').try(:text).try(:to_i),
                                 quantity_available: item.at('.//quantity_available').try(:text).try(:to_i)})
          end
          records << Backorder.new(hash)
        end
        Response.new(true, '', {data: records})
      end
    end

    class BackorderItem
      include Model
      attr_accessor :vendor,
                    :sku,
                    :quantity_pending,
                    :quantity_backordered,
                    :quantity_available
    end
  end
end
