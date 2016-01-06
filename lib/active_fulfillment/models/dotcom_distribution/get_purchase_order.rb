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
        success = true, message = '', records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!
        doc.xpath("//purchase_order").each do |el|
          records << GetPurchaseOrder.new(po_number: el.at('.//po_number').try(:text),
                                          po_status: el.at('.//po_status').try(:text),
                                          dcd_po_number: el.at('.//dcd_po_number').try(:text),
                                          po_date: el.at('.//po_date').try(:text),
                                          priority_date: el.at('.//priority_date').try(:text),
                                          expected_date: el.at('.//expected_date').try(:text),
                                          po_items: el.xpath('.//po_items//po_item').collect { |item|
                                            PurchaseOrderItem.new(sku: item.at('.//sku').try(:text),
                                                                  item_description: item.at('.//item_description').try(:text),
                                                                  expected_qty: item.at('.//expected_qty').try(:text).to_i,
                                                                  received_qty: item.at('.//received_qty').try(:text).to_i,
                                                                  open_qty: item.at('.//open_qty').try(:text).to_i,
                                                                  status: item.at('.//status').try(:text),
                                                                  po_line_num: item.at('.//po_line_num').try(:text).to_i,
                                                                  style: item.at('.//style').try(:text),
                                                                  color: item.at('.//color').try(:text),
                                                                  size: item.at('.//size').try(:text))
                                          })
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
