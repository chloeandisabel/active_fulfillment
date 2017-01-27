module ActiveFulfillment
  module DotcomDistribution

    class InventorySnapshot
      include Model
      attr_accessor :sku,
                    :description,
                    :quantity_bod,
                    :quantity_eod,
                    :quantity_adjusted,
                    :quantity_received,
                    :quantity_returned,
                    :quantity_shipped,
                    :quantity_unavailable_adjustments,
                    :transaction_date

      def self.response_from_xml(xml)
        success = true, message = '', records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!
        doc.xpath("//inv_snapshot_item").each do |el|
          records << InventorySnapshot.new({sku: el.at('.//sku').try(:text),
                                            description: el.at('.//description').try(:text),
                                            quantity_bod: el.at('.//begin_bal').try(:text),
                                            quantity_eod: el.at('.//end_bal').try(:text),
                                            quantity_adjusted: el.at('.//adj_qty').try(:text),
                                            quantity_received: el.at('.//rcpt_qty').try(:text),
                                            quantity_returned: el.at('.//ret_qty').try(:text),
                                            quantity_shipped: el.at('.//shp_qty').try(:text),
                                            quantity_unavailable_adjustments: el.at('.//uad_qty').try(:text),
                                            transaction_date: el.at('.//trans_date').try(:text)})
        end
        Response.new(true, '', {data: records})
      end
    end
  end
end
