module ActiveFulfillment
  module DotcomDistribution

    class ItemSummary

      include ::ActiveModel::Model

      attr_accessor :sku,
                    :description,
                    :last_receipt_date,
                    :upc_number,
                    :vendor_items

      def self.response_from_xml(xml)
        success = true, message = '', hash = {}, records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!

        doc.xpath("//item_info").each do |el|
          hash[:sku] = el.at('.//sku').try(:text)
          hash[:description] = el.at('.//item_description').try(:text)
          hash[:last_receipt_date] = el.at('.//last_receipt_date').try(:text)
          hash[:upc_number] = el.at('.//upc_num').try(:text)
          hash[:vendor_items] = el.xpath('.//vendor_items//vendor_item').collect do |item|
            VendorItem.new(cross_ref: item.at('.//vendor_cross_ref').try(:text))
          end
          records << ItemSummary.new(hash)
        end
        Response.new(success, '', {data: records})
      end
    end

    class VendorItem
      include ::ActiveModel::Model

      attr_accessor :cross_ref
    end
  end
end
