module ActiveFulfillment
  module DotcomDistribution

    class Return

      include ::ActiveModel::Model
      include ::ActiveModel::Serializers::Xml

      attr_accessor :dcd_return_number,
                    :department,
                    :original_order_number,
                    :return_date,
                    :rn,
                    :return_items

      def self.response_from_xml(xml)
        success = true, message = '', hash = {}, records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!

        doc.xpath("//Return").each do |el|
          hash[:dcd_return_number] = el.at('.//dcd_return_number').try(:text)
          hash[:department] = el.at('.//department').try(:text)
          hash[:original_order_number] = el.at('.//original_order_number').try(:text)
          hash[:return_date] = el.at('.//return_date')
          hash[:rn] = el.at('.//rn')

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
        Response.new(true, '', {data: records})
      end
    end

    class ReturnItem

      include ::ActiveModel::Model

      attr_accessor :sku,
                    :quantity_returned,
                    :line_number,
                    :item_disposition,
                    :returns_reason_code
    end
  end
end
