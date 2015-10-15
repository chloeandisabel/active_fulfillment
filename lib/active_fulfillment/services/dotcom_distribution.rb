require 'cgi'

require 'active_fulfillment/models/dotcom_distribution'

module ActiveFulfillment

  class DotcomDistributionService < Service

    include ActiveFulfillment::DotcomDistribution

    SIGNATURE_METHOD  = "MD5"

    # TODO: I don't know if this is the correct production endpoint
    BASE_URL = {
      test: 'https://cwa.dotcomdistribution.com/dcd_api_test/DCDAPIService.svc'.freeze,
      live: 'https://cwa.dotcomdistribution.com/dcd_api/DCDAPIService.svc'.freeze,
    }

    # Note that some of these endpoints like +fetch_stock_levels+ don't really
    # map all that nicely to their endpoint. We're inheriting these from the base Service class.
    #
    # The hash format here is:
    #   <action>: [<endpoint>, <class>]
    # where:
    #   action: self explanatory I think
    #   endpoint: DotCom's endpoint. for instance -> https://cwa.dotcomdistribution.com/dcd_api_test/DCDAPIService.svc/item
    #   class: The class that will parse our response
    SERVICE_ENDPOINTS = {
      fulfillment: ["order", PostOrder],
      purchase_order: ["purchase_order", PurchaseOrder],
      purchase_order_status: ["purchase_order", GetPurchaseOrder],
      post_item: ["item", PostItem],
      post_items: ["item", PostItem],
      order_status: ["order", GetOrder],
      shipmethod: ["shipmethod", ShipMethod],
      fetch_stock_levels: ["inventory", Inventory],
      returns: ["return", Return],
      fetch_tracking_data: ["shipment", Shipment],
      adjustment: ["adjustment", Adjustment],
      item_summary: ["item", ItemSummary],
      inventory_snapshot: ["inventory_snapshot", InventorySnapshot],
    }

    attr_reader :base_url

    def initialize(options = {})
      requires!(options, :username, :password)
      super
      @base_url = test? ? BASE_URL[:test] : BASE_URL[:live]
    end

    def sign(uri)
      digest = OpenSSL::Digest.new(SIGNATURE_METHOD)
      hmac = Base64.encode64(OpenSSL::HMAC.digest(digest, @options[:password], uri)).chomp
      @options[:username] + ":" + hmac
    end

    def build_headers(uri)
      {
        'Authorization' => sign(uri),
        'Content-Type' => 'text/xml; charset="utf-8"'
      }
    end

    # API Requirements for Active Fulfillment
    # Dotcom requires a billing_address to be present and sets
    # the shipping address to the billing address
    # if shipping address is not present. For now, set both
    # shipping address and billing address to be the same
    def fulfill(order_id, shipping_address, line_items, options = {})
      requires!(options,
                :order_date, :ship_date, :ship_method, :tax_percent, :billing_information)
      args = {
        order_number: order_id,
        shipping_information: shipping_address,
        line_items: line_items,
      }
      data = SERVICE_ENDPOINTS[:fulfillment][1].new(args.merge(options))
      commit :fulfillment, nil, data
    end

    def fetch_stock_levels(options = {})
      options = options.dup
      get :fetch_stock_levels, options.delete(:item_id), options
    end

    def fetch_tracking_data(order_ids, options = {})
      order_id = order_ids.first unless order_ids.empty?
      unless order_id
        requires!(options, :fromShipDate, :toShipDate, :dept, :kitonly)
      end
      get :fetch_tracking_data, order_id, options
    end

    # Tell Dotcom that stock is being sent to their warehouse.
    # TODO: this may need to take purchase_order as argument instead of option..
    # Check required arguments by dotcom
    def purchase_order(options = {})
      commit :purchase_order, nil, SERVICE_ENDPOINTS[:purchase_order][1].new(options)
    end

    # Accepts an array of either PurchaseOrders or hashes that can be turned
    # into PurchaseOrders.
    def purchase_orders(purchase_orders)
      xml = SERVICE_ENDPOINTS[:purchase_order][1].to_xml(purchase_orders)
      commit :purchase_order, nil, xml
    end

    def order_status(options = {})
      options = options.dup
      order_number = options.delete(:order_number)
      unless order_number
        requires!(options, :fromOrdDate, :toOrdDate)
      end
      get :order_status, order_number, options
    end

    def purchase_order_status(options = {})
      options = options.dup
      purchase_order_number = options.delete(:purchase_order_number)
      unless purchase_order_number
        requires!(options, :status)
      end
      get :purchase_order_status, purchase_order_number, options
    end

    def returns(options = {})
      requires!(options, :fromReturnDate, :toReturnDate)
      get :returns, nil, options
    end

    # +post_item+ and +purchase_order+ are used to let Dotcom know
    # about our products / SKUs.  If you attempt to place an order
    # with a SKU that Dotcom is not aware of, "you're gonna have a bad day!"
    def post_item(options = {})
      commit :post_item, nil, SERVICE_ENDPOINTS[:post_item][1].new(options)
    end

    # Accepts an array of either PostItems or hashes that can be turned into
    # PostItems.
    def post_items(items)
      xml = SERVICE_ENDPOINTS[:post_item][1].to_xml(items)
      commit :post_item, nil, xml
    end

    def item_summary(options={})
      options = options.dup
      get :item_summary, options.delete(:sku), options
    end

    def inventory_snapshot(options={})
      requires!(options, :invDate)
      get :inventory_snapshot, nil, options
    end

    def test_mode?
      true
    end

    private

    def path_for(action, resource=nil)
      path = "/#{SERVICE_ENDPOINTS[action][0]}"
      if resource
        path += "/#{resource}"
      end
      path
    end

    def get(action, resource=nil, query_hash={})
      query = ""
      if query_hash && query_hash.present?
        query = query_hash.collect { |k,v| "#{k}=#{CGI.escape(v)}" }.join("&")
      end

      make_request(:get, action, resource, query: query)
    end

    def commit(action, resource=nil, data = nil)
      make_request(:post, action, resource, data: data)
    end

    def make_request(verb, action, resource, query: nil, data: nil)
      url = base_url + path_for(action, resource)
      if query && query.present?
        url += "?#{query}"
      end
      if data.respond_to?(:to_xml)
        data = data.to_xml
      end

      response = ssl_request(verb, url, data, build_headers(url))
      parse_response(action, response)
    rescue ActiveUtils::ResponseError => e
      response = {
        http_code: e.response.code,
        http_message: e.response.message,
      }
      Response.new(false, e.response.message, response)
    end

    def parse_response(action, xml)
      klass = SERVICE_ENDPOINTS[action][1]
      klass.response_from_xml(xml)
    end

  end
end
