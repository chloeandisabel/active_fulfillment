module ActiveFulfillment
  module DotcomDistribution

    class Receipt
      include Model
      attr_accessor :dcd_identifier,
                    :po_reference_number,
                    :sku,
                    :quantity_received,
                    :item_receipt_date,
                    :receipt_date

      def self.response_from_xml(xml)
        success = true, message = '', records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!
        doc.xpath("//response/receipts/receipt").each do |el|
          next if el.attributes["nil"]

          hash = {
            dcd_identifier: el.at('.//dcd_identifier').try(:text),
            po_reference_number: el.at('.//po_reference_number').try(:text),
            sku: el.at('.//sku').try(:text),
            quantity_received: el.at('.//quantity_received').try(:text).try(:to_i),
            item_receipt_date: el.at('.//item_receipt_date').try(:text),
            receipt_date: el.at('.//receipt_date').try(:text)
          }
          records << Receipt.new(hash)
        end
        Response.new(success, message, {data: records})
      end
    end
  end
end
