module ActiveFulfillment
  module DotcomDistribution

    class InventorySnapshot

      include ::ActiveModel::Model
      include ::ActiveModel::Serializers::Xml

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
        success = true, message = '', hash = {}, records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!

        doc.xpath("//inv_snapshot_item").each do |el|
          hash[:sku] = el.at('.//sku').try(:text)
          hash[:description] = el.at('.//description').try(:text)
          hash[:quantity_bod] = el.at('.//begin_bal').try(:text)
          hash[:quantity_eod] = el.at('.//end_bal').try(:text)
          hash[:quantity_adjusted] = el.at('.//adj_qty').try(:text)
          hash[:quantity_received] = el.at('.//rcpt_qty').try(:text)
          hash[:quantity_returned] = el.at('.//ret_qty').try(:text)
          hash[:quantity_shipped] = el.at('.//shp_qty').try(:text)
          hash[:quantity_unavailable_adjustments] = el.at('.//uad_qty').try(:text)
          hash[:transaction_date] = el.at('.//trans_date').try(:text)

          records << InventorySnapshot.new(hash)
        end

        Response.new(true, '', {data: records})
      end
    end

  end
end
