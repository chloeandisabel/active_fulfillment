module ActiveFulfillment
  module DotcomDistribution

    class PurchaseOrder
      include Model
      attr_accessor :po_number,
                    :priority_date,
                    :expected_on_dock,
                    :items

      def items=(attributes)
        attributes.each do |params|
          items.push(PostItem.new(params))
        end
      end

      def items
        @items ||= []
      end

      def self.to_xml(purchase_orders)
        xml_builder = Nokogiri::XML::Builder.new do |xml|
          xml.purchase_orders({'xmlns:xsi': "http://www.w3.org/2001/XMLSchema-instance"}) do
            purchase_orders.each do |po|
              po = PurchaseOrder.new(po) unless po.instance_of?(self)
              po.po_to_xml(xml)
            end
          end
        end

        xml_builder.to_xml
      end

      def to_xml
        xml_builder = Nokogiri::XML::Builder.new do |xml|
          xml.purchase_orders({'xmlns:xsi': "http://www.w3.org/2001/XMLSchema-instance"}) do
            po_to_xml(xml)
          end
        end

        xml_builder.to_xml
      end

      def po_to_xml(xml)
        xml.send(:"purchase_order") do
          xml.send(:"po-number", self.po_number)
          xml.send(:"priority-date", self.priority_date)
          xml.send(:"expected-on-dock", self.expected_on_dock)
          xml.send(:"items") do
            Array(items).each do |item|
              item.send(:item_to_xml, xml)
            end
          end
        end
      end

      def self.response_from_xml(xml)
        hash = {}
        records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!

        doc.xpath("//purchase_order_error").each do |error|
          hash[:error_description] = error.at('.//error_description').try(:text)
          hash[:purchase_order_number] = error.at('.//purchase_order_number').try(:text)

          records << hash
        end
        if records.length > 0
          return Response.new(false, '', {data: records})
        end
      end

    end
  end
end
