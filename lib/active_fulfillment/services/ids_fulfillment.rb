module ActiveFulfillment
  class IDSFulfillment < Service

    def fulfill(order_id, shipping_address, line_items, options = {})
      order_data = order_data(order_id, shipping_address, line_items, options)
    end

    def order_data(order_id, shipping_address, line_items, options = {})
      validate_order_options!(order)
      {
        "CustomerOrderReferenceNumber" => order_id,
        "CosigneePONumber" => options[:cosignee_po_number],
        "ScheduledShipDate" => options[:ship_date],
        "CarrierCode" => options[:carrier_code],
        "ShipType" => options[:ship_type],
        "OrderItems" => line_items_data(line_items),
        "ShipToAddress" => shipping_address_data(shipping_address)
      }
    end

    def shipping_address_data(shipping_address)
      validate_shipping_address!(shipping_address)
      {
        "Name" => shipping_address[:name],
        "AddressLine1" => shipping_address[:address1],
        "AddressLine2" => shipping_address[:address2],
        "Phone" => shipping_address[:phone],
        "Email" => shipping_address[:email],
        "City" => shipping_address[:city],
        "State" => shipping_address[:state],
        "Zip" => shipping_address[:zip_code],
        "CountryCode" => shipping_address[:country_code]
      }
    end

    def line_items_data(line_items)
      line_items.map { |li| line_item_data(li) }
    end

    def line_item_data(line_item)
      validate_line_item!(line_item)
      {
        "SKU" => line_item[:sku],
        "QuantityOrdered" => line_item[:quantity_ordered]
      }
    end

    private

    # Options:
    # - :ship_type - Integer. IDS Internal Field. Partial - 2, Truckload/LDL - 6
    # - :carrier_code - String. Code of designated shipping method. Contact IDS to get a list
    # - :ship_date - DateTime. in MDT.
    def validate_order_options!(options)
      requires!(options, :ship_type, :carrier_code, :ship_date)
      unless [2, 6].inlcude?(options[:ship_type])
        raise ArgumentError.new("Parameter ship_type is not a valid integer")
      end
    end

    def validate_line_item!(line_item)
      requires!(line_item, :sku, :quantity_ordered)
    end

    def validate_shipping_address!(shipping_address)
      requires!(shipping_address, :name, :address1, :city, :state, :zip_code, :country_code)
    end
  end
end
