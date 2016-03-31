module ActiveFulfillment
  module DotcomDistribution

    class Return
      include Model
      attr_accessor :dcd_return_number,
                    :department,
                    :original_order_number,
                    :return_date,
                    :rn,
                    :return_items

      def self.response_from_xml(xml)
        success = true, message = '', records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!
        doc.xpath("//Return").each do |el|
          next if el.attributes["nil"]

          hash = {
            dcd_return_number: el.at('.//dcd_return_number').try(:text),
            department: el.at('.//department').try(:text),
            original_order_number: el.at('.//original_order_number').try(:text),
            return_date: el.at('.//return_date').try(:text),
            rn: el.at('.//rn').try(:text)
          }

          hash[:return_items] = el.xpath('.//ret_items//ret_item').collect do |item|
            ReturnItem.new(sku: item.at('.//sku').try(:text),
                           quantity_returned: item.at('.//quantity_returned').try(:text),
                           line_number: item.at('.//line_number').try(:text),
                           item_disposition: item.at('.//item_disposition').try(:text),
                           returns_reason_code: item.at('.//returns_reason_code').try(:text))
          end
          hash[:return_items] = nil if hash[:return_items].length == 0

          records << Return.new(hash)
        end
        Response.new(success, message, {data: records})
      end
    end

    class ReturnItem
      include Model
      attr_accessor :sku,
                    :quantity_returned,
                    :line_number,
                    :item_disposition,
                    :returns_reason_code
    end
  end
end
