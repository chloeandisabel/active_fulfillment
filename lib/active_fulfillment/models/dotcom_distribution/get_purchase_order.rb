module ActiveFulfillment
  module DotcomDistribution

    class GetPurchaseOrder
      include Model

      attr_accessor :po_number,
                    :po_status,
                    :dcd_po_number,
                    :po_date,
                    :priority_date,
                    :expected_date,
                    :po_items

      def self.response_from_xml(xml)
        success = true, message = '', hash = {}, records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!
        doc.xpath("//purchase-order").each do |el|
          hash[:po_number] = el.at('.//po-number').try(:text)
          hash[:po_status] = el.at('.//po-status').try(:text)
          hash[:dcd_po_number] = el.at('.//dcd-po-number').try(:text)
          hash[:po_date] = el.at('.//po-date').try(:text)
          hash[:priority_date] = el.at('.//priority-date').try(:text)
          hash[:expected_date] = el.at('.//expected-date').try(:text)
          hash[:po_items] = el.xpath('.//po-items//po-item').collect do |item|
            PurchaseOrderItem.new(sku: item.at('.//sku').try(:text),
                                  item_description: item.at('.//item-description').try(:text),
                                  expected_qty: item.at('.//expected-qty').try(:text).to_i,
                                  received_qty: item.at('.//received-qty').try(:text).to_i,
                                  open_qty: item.at('.//open-qty').try(:text).to_i,
                                  status: item.at('.//status').try(:text),
                                  po_line_num: item.at('.//po-line-num').try(:text).to_i,
                                  style: item.at('.//style').try(:text),
                                  color: item.at('.//color').try(:text),
                                  size: item.at('.//size').try(:text))
          end
          records << GetPurchaseOrder.new(hash)
        end
        Response.new(true, '', {data: records})
      end
    end

    class PurchaseOrderItem
      include Model
      attr_accessor :sku,
                    :item_description,
                    :expected_qty,
                    :received_qty,
                    :open_qty,
                    :status,
                    :po_line_num,
                    :style,
                    :color,
                    :size
    end
  end
end
