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

      def self.from_response(response)
        success = true, message = '', hash = {}, records = []
        doc = Nokogiri.XML(response)
        doc.remove_namespaces!

        doc.xpath("//Return").each do |el|
          hash[:department] = el.at('.//department').try(:text)
          hash[:original_order_number] = el.at('.//original_order_number').try(:text)
          hash[:dcd_order_number] = el.at('.//dcd_order_number').try(:text)
          hash[:return_date] = el.at('.//return_date')
          hash[:original_ship_date] = el.at('.//original_ship_date')
          hash[:rt] = el.at('.//rt')

          hash[:return_items] = [] if hash[:return_items].nil? && el.xpath('.//ret_item').size > 0

          el.xpath('.//ret_item').each do |item|
            h = {}
            h[:sku] = item.at('.//sku').try(:text)
            h[:quantity_returned] = item.at('.//quantity_returned').try(:text)
            h[:line_number] = item.at('.//line_number').try(:text)
            h[:item_disposition] = item.at('.//item_disposition').try(:text)
            h[:return_reason_code] = item.at('.//return_reason_code').try(:text)

            hash[:return_items] << ReturnItem.new(h)
          end

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
                    :return_reason_code
    end

  end
end
