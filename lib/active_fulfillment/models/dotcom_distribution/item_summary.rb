module ActiveFulfillment
  module DotcomDistribution

    class ItemSummary
      include Model
      attr_accessor :sku,
                    :description,
                    :last_receipt_date,
                    :upc_number,
                    :vendor_items

      def self.response_from_xml(xml)
        success = true, message = '', records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!
        doc.xpath("//item_info").each do |el|
          records << ItemSummary.new({sku: el.at('.//sku').try(:text),
                                      description: el.at('.//item_description').try(:text),
                                      last_receipt_date: el.at('.//last_receipt_date').try(:text),
                                      upc_number: el.at('.//upc_num').try(:text),
                                      vendor_items: el.xpath('.//vendor_items//vendor_item').collect { |item|
                                        VendorItem.new(cross_ref: item.at('.//vendor_cross_ref').try(:text))
                                      }})
        end
        Response.new(success, '', {data: records})
      end
    end

    class VendorItem
      include Model
      attr_accessor :cross_ref
    end
  end
end
