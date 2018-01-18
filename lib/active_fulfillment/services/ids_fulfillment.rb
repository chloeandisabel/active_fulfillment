module ActiveFulfillment
  class IDSFulfillment < Service

    BASE_URLS = {
      production: "https://api.teamidslogistics.com",
      test: "https://api.teamidslogistics.com"
    }.freeze

    def initialize(options = {})
      requires!(options, :api_key)
      @api_key = options.delete(:api_key)
      super
      @base_url = BASE_URLS[test? ? :test : :production]
    end

    def test_mode?
      true
    end

    def fulfill(order_id, shipping_address, line_items, options = {})
      fulfill_multiple([[order_id, shipping_address, line_items, options]])
    end

    def fulfill_multiple(orders)
      make_request(:post, "/request/ship", data: request_to_ship(orders).to_json)
    end

    # +order_id+ may be nil or unspecified (not yet sent shipment
    # confirmations), a single customer order reference number, or an array of
    # customer order reference numbers.
    def get_order_status(order_id = nil)
      query_string =
        case order_id
        when nil
          ""
        else
          "customerOrderReferenceNumbers=#{Array.wrap(order_id).join(",")}"
        end

      make_request(:get, "/request/ship", query: query_string)
    end

    def fetch_stock_levels(_options = {})
      make_request(:get, "/request/storerinventory")
    end

    def fetch_tracking_data(order_ids, _options = {})
      response = get_order_status(order_ids)
      return response unless response.success?
      tracking_numbers = response.params["Orders"].flat_map do |order|
        order["Packages"].map { |package| package["PackageNumber"] }
      end
      tracking_companies = response.params["Orders"].map { |order| order["CarrierCode"] }
      Response.new(true, "", tracking_companies: tracking_companies,
                             tracking_numbers: tracking_numbers,
                             tracking_urls: [])
    end

    def receipt(reference_number)
      make_request(:get, "/request/inventoryreceipt/#{reference_number}")
    end

    def unsent_receipts
      make_request(:get, "/request/inventoryreceipt")
    end

    def inventory_receipt(reference_number, items, options = {})
      inventory_receipts([[reference_number, items, options]])
    end

    def inventory_receipts(inventory_receipts)
      make_request(:post, "/request/inventoryreceipt",
                   data: inventory_receipt_data(inventory_receipts).to_json)
    end

    private

    def make_request(verb, path, data: nil, query: nil)
      url = query.present? ? "#{@base_url}#{path}?#{query}" : "#{@base_url}#{path}"
      response = ssl_request(verb, url, data, headers)
      Response.new(true, "", parse_response(response))
    rescue ActiveUtils::ResponseError => e
      response = {
        http_code: e.response.code,
        http_message: e.response.message
      }
      Response.new(false, e.response.message, response)
    end

    # We extracted this method to allow subclasses to override it in cases
    # where we want to log the raw response.
    def parse_response(response)
      JSON.parse(response)
    end

    def request_to_ship(orders)
      {
        requesttoship: {
          "Orders" => orders.map do |order_id, shipping_address, line_items, options|
            order_data(order_id, shipping_address, line_items, options)
          end
        }
      }
    end

    def headers
      {
        "ApiKey" => @api_key,
        "Accept" => "application/json",
        "Content-Type" => "application/json",
      }
    end

    def inventory_receipt_data(inventory_receipts)
      tallies = inventory_receipts.map do |(reference_number, items, options)|
        options ||= {}
        tally = {
          "CustomerReferenceNumber": reference_number,
          "TallyDetails": items.map { |item| item_data(item) }
        }
        copy_updates!(tally, options,
                      return_authorization_number: "ReturnAuthorizationNumber",
                      scheduled_arrival_date: "ScheduledArrivalDate")
        tally
      end
      { "Tallies": tallies }
    end

    def item_data(item)
      validate_line_item!(item)
      { "ItemCode": item[:sku], "QuantityInTransit": item[:quantity] }
    end

    def order_data(order_id, shipping_address, line_items, options = {})
      validate_order_options!(options)
      order_data = {
        "CustomerOrderReferenceNumber" => order_id,
        "CosigneePONumber" => options[:cosignee_po_number],
        "ProNumber" => options[:pro_number],
        "ScheduledShipDate" => options[:ship_date],
        "CarrierCode" => options[:carrier_code],
        "ShipType" => options[:ship_type],
        "OrderItems" => line_items_data(line_items),
        "ShipToAddress" => shipping_address_data(shipping_address)
      }
      if options[:extra_data]
        order_data.update("OrderExtraDataFields" => extract_extra_data(options[:extra_data]))
      end
      if options[:comments]
        order_data.update("OrderComments" => extract_comments(options[:comments]))
      end
      order_data
    end

    def extract_comments(comments)
      comments.map.with_index do |comment, index|
        {
          "PrintSequence" => (index + 1).to_s,
          "PrintLabel" => comment[:label],
          "CommentText" => comment[:text]
        }
      end
    end

    def extract_extra_data(extra_data)
      extra_data.map do |data|
        {
          "ExtraDataFieldLabel" => data[:label],
          "ExtraDataFieldLength" => data[:length],
          "ExtraDataFieldValue" => data[:value]
        }
      end
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
      data = {
        "SKU" => line_item[:sku],
        "QuantityOrdered" => line_item[:quantity]
      }
      if line_item[:extra_data]
        data.update(
          "OrderItemExtraDataFields" =>
            extract_extra_data(line_item[:extra_data])
        )
      end
      data
    end

    # Options:
    # - :ship_type - Integer. IDS Internal Field. Truckload/LTL - 2, Partial - 6
    # - :carrier_code - String. Code of designated shipping method. Contact IDS
    #   to get a list
    # - :ship_date - DateTime. in MDT.
    def validate_order_options!(options)
      requires!(options, :ship_type, :carrier_code)
      unless [2, 6].include?(options[:ship_type])
        raise ArgumentError.new("Parameter ship_type is not a valid integer")
      end
    end

    def validate_line_item!(line_item)
      requires!(line_item, :sku, :quantity)
    end

    def validate_shipping_address!(shipping_address)
      requires!(shipping_address, :name, :address1, :city, :state, :zip_code, :country_code)
    end

    def copy_updates!(destination, source, attribute_mapping)
      attribute_mapping.each do |source_attr, destination_attr|
        destination.update(destination_attr => source[source_attr]) if source[source_attr]
      end
    end
  end
end
