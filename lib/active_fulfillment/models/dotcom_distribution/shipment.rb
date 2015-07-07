module ActiveFulfillment
  module DotcomDistribution

    class Shipment

      include ::ActiveModel::Model
      include ::ActiveModel::Validations
      include ::ActiveModel::Serializers::Xml

      attr_accessor :client_order_number,
                    :customer_number,
                    :dcd_order_number,
                    :order_date,
                    :order_shipping_handling,
                    :order_status,
                    :order_subtotal,
                    :order_tax,
                    :order_total,
                    :ship_date,
                    :ship_weight,
                    :shipto_addr1,
                    :shipto_addr2,
                    :shipto_city,
                    :shipto_email_address,
                    :shipto_name,
                    :shipto_state,
                    :shipto_zip,
                    :ship_items

      def self.from_response(response)
        success = true, message = '', hash = {}, records = []
        doc = Nokogiri.XML(response)
        doc.remove_namespaces!

        doc.xpath("//shipment").each do |el|
          hash[:client_order_number] = el.at('.//client_order_number').try(:text)
          hash[:customer_number] = el.at('.//customer_number').try(:text)
          hash[:dcd_order_number] = el.at('.//dcd_order_number').try(:text)
          hash[:order_date] = el.at('.//order_date').try(:text)
          hash[:order_shipping_handling] = el.at('.//order_shipping_handling').try(:text)
          hash[:order_status] = el.at('.//order_status').try(:text)
          hash[:order_subtotal] = el.at('.//order_subtotal').try(:text)
          hash[:order_tax] = el.at('.//order_tax').try(:text)
          hash[:order_total] = el.at('.//order_total').try(:text)
          hash[:ship_date] = el.at('.//ship_date').try(:text)
          hash[:ship_weight] = el.at('.//ship_weight').try(:text)
          hash[:shipto_addr1] = el.at('.//shipto_addr1').try(:text)
          hash[:shipto_addr2] = el.at('.//shipto_addr2').try(:text)
          hash[:shipto_city] = el.at('.//shipto_city').try(:text)
          hash[:shipto_email_address] = el.at('.//shipto_email_address').try(:text)
          hash[:shipto_name] = el.at('.//shipto_name').try(:text)
          hash[:shipto_state] = el.at('.//shipto_state').try(:text)
          hash[:shipto_zip] = el.at('.//shipto_zip').try(:text)

          hash[:ship_items] = [] if hash[:ship_items].nil? && el.xpath('.//ship_items').size > 0

          el.xpath('.//ship_item').each do |item|
            h = {}
            h[:carrier] = item.at('.//carrier').try(:text)
            h[:carton_id] = item.at('.//carton_id').try(:text)
            h[:item_description] = item.at('.//item_description').try(:text)
            h[:item_unit_price] = item.at('.//item_unit_price').try(:text)
            h[:order_line_number] = item.at('.//order_line_number').try(:text)
            h[:client_line_number] = item.at('.//client_line_number').try(:text)
            h[:quantity_shipped] = item.at('.//quantity_shipped').try(:text)
            h[:serial_lot_number] = item.at('.//serial_lot_number').try(:text)
            h[:service] = item.at('.//service').try(:text)
            h[:sku] = item.at('.//sku').try(:text)
            h[:tracking_number] = item.at('.//tracking_number').try(:text)

            hash[:ship_items] << ShipItem.new(h)
          end
          records << Shipment.new(hash)
        end

        Response.new(true, '', {data: records})
      end
    end

    class ShipItem
      include ::ActiveModel::Model

      attr_accessor :carrier,
                    :carton_id,
                    :item_description,
                    :item_unit_price,
                    :order_line_number,
                    :client_line_number,
                    :quantity_shipped,
                    :serial_lot_number,
                    :service,
                    :sku,
                    :tracking_number
    end

  end
end
