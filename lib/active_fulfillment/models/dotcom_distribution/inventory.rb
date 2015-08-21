module ActiveFulfillment
  module DotcomDistribution

    class Inventory

      include ::ActiveModel::Model
      include ::ActiveModel::Serializers::Xml

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
        success = true, message = '', hash = {}, records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!

        doc.xpath("//item").each do |el|
          hash[:sku] = el.at('.//sku').try(:text)
          hash[:description] = el.at('.//description').try(:text)
          hash[:product_group] = el.at('.//product_group').try(:text)
          hash[:quantity_available] = el.at('.//quantity_available').try(:text)
          hash[:quantity_onhand] = el.at('.//quantity_onhand').try(:text)
          hash[:quantity_demand] = el.at('.//quantity_demand').try(:text)
          hash[:quantity_backordered] = el.at('.//quantity_backordered').try(:text)
          hash[:quantity_pending] = el.at('.//quantity_pending').try(:text)
          hash[:quantity_unavailable] = el.at('.//quantity_unavailable').try(:text)
          hash[:quantity_reserved] = el.at('.//quantity_reserved').try(:text)

          records << Inventory.new(hash)
        end

        Response.new(true, '', {data: records})
      end
    end

  end
end
