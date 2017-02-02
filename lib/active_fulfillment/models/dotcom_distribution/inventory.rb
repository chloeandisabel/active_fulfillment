module ActiveFulfillment
  module DotcomDistribution

    class Inventory
      include Model
      attr_accessor :sku,
                    :description,
                    :product_group,
                    :quantity_available,
                    :quantity_onhand,
                    :quantity_demand,
                    :quantity_backordered,
                    :quantity_pending,
                    :quantity_unavailable,
                    :quantity_reserved


      def self.response_from_xml(xml)
        success = true, message = '', records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!

        doc.xpath("//item").each do |el|
          records << Inventory.new({sku: el.at('.//sku').try(:text),
                                    description: el.at('.//description').try(:text),
                                    product_group: el.at('.//product_group').try(:text),
                                    quantity_available: el.at('.//quantity_available').try(:text).try(:to_i),
                                    quantity_onhand: el.at('.//quantity_onhand').try(:text).try(:to_i),
                                    quantity_demand: el.at('.//quantity_demand').try(:text).try(:to_i),
                                    quantity_backordered: el.at('.//quantity_backordered').try(:text).try(:to_i),
                                    quantity_pending: el.at('.//quantity_pending').try(:text).try(:to_i),
                                    quantity_unavailable: el.at('.//quantity_unavailable').try(:text).try(:to_i),
                                    quantity_reserved: el.at('.//quantity_reserved').try(:text).try(:to_i)})
        end
        Response.new(true, '', {data: records})
      end
    end
  end
end
