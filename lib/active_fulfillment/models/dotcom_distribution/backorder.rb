module ActiveFulfillment
  module DotcomDistribution

    class Backorder
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
        success = true, message = '', hash = {}, records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!

        doc.xpath("//backorder").each do |el|
          hash[:carrier] = el.at('.//carrier').try(:text)
          hash[:dcd_order_number] = el.at('.//dcd_order_number').try(:text)
          hash[:dcd_order_release_number] = el.at('.//dcd_order_release_number').try(:text)
          hash[:department] = el.at('.//department').try(:text)
          hash[:order_date] = el.at('.//order_date').try(:text)
          hash[:order_number] = el.at('.//order_number').try(:text)
          hash[:priority_date] = el.at('.//priority_date').try(:text)
          hash[:ship_to_email] = el.at('.//ship_to_email').try(:text)
          hash[:ship_to_name] = el.at('.//ship_to_name').try(:text)

          hash[:backorder_items] = [] if hash[:backorder_items].nil? && el.xpath('.//bo_items').size > 0

          el.xpath('.//bo_item').each do |item|
            h = {}
            h[:vendor] = item.at('.//vendor').try(:text)
            h[:sku] = item.at('.//sku').try(:text)
            h[:quantity_pending] = item.at('.//quantity_pending').try(:text)
            h[:quantity_backordered] = item.at('.//quantity_backordered').try(:text)
            h[:quantity_available] = item.at('.//quantity_available').try(:text)

            hash[:backorder_items] << BackorderItem.new(h)
          end

          records << Backorder.new(hash)
        end

        Response.new(true, '', {data: records})
      end
    end

    class BackorderItem
      attr_accessor :vendor,
                    :sku,
                    :quantity_pending,
                    :quantity_backordered,
                    :quantity_available

    end

  end
end
