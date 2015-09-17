require 'test_helper'

class DotcomDistributionTest < Minitest::Test
  include ActiveFulfillment::Test::Fixtures

  def setup
    @endpoints = ActiveFulfillment::DotcomDistributionService::SERVICE_ENDPOINTS
    @service = ActiveFulfillment::DotcomDistributionService.new(
      username: 'u', password: 'p'
    )
    @item = {
      sku: "Test",
      description: "a",
      upc: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
      weight: 100.12,
      cost: 1000.12,
      price: 1000.12,
      root_sku: "aaaaaaaaaaaaaaaaa",
      package_qty: 10,
      serial_indicator: "Y",
      client_company: "aaaaa",
      client_department: "aaaaa",
      client_product_class: 1234,
      client_product_type: 1234,
      avg_cost: 50.12,
      master_pack: 123456,
      item_barcode: "aaaaaaaaaaaaaaaaaaaaaaaa",
      harmonized_code: "aaaaaaaaa",
      manufacturing_code: "aaaaaaaaaa",
      style_number: "aaaaaaaaaa",
      short_name: "aaaaaaaaaa",
      color: "aaaa",
      size: "aaaaa",
      long_description: "aaaaaaaaaa"
    }
    @line_items =  [
      {
        sku: "Test",
        line_number: 1,
        client_item: "abc",
        quantity: 1,
        gift_box_wrap_quantity: 1,
        gift_box_wrap_type: 1
      }
    ]
    @address = {
      customer_number: "12345",
      name: "Chloe Isabel",
      address1: "123 abc",
      city: "Miami",
      state: "FL",
      zip: "33018",
    }
    @options = {
      ship_date: Time.current.strftime("%Y-%m-%d"),
      order_date: Time.current.strftime("%Y-%m-%d"),
      ship_method: "01",
      tax_percent: 5,
      billing_information: @address,
    }
    @purchase_order = {
      po_number: "a",
      priority_date: Time.now.strftime("%Y-%m-%d"),
      expected_on_dock: Time.now.strftime("%Y-%m-%d"),
      items: [@item.merge(quantity: 1)]
    }
  end

  def test_fulfillment_successful
    order_id = "12345678"
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      url.end_with?("/" + @endpoints[:fulfillment].first) &&
        data.include?("<order-number>#{order_id}</order-number>")
    end.returns(successful_fulfillment_response)
    response = @service.fulfill(order_id, @address, @line_items, @options)
    # TODO it may be better to actually return a Response object with success
    # assert response.success?
    assert_nil response
  end

  def test_fulfillment_invalid_arguments
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :post
    end.returns(invalid_post_order_response)
    response = @service.fulfill("12345678", @address, @line_items, @options)

    refute response.success?
    refute_empty response.params["data"]
    errors = response.params["data"]
    assert_equal 1, errors.size
    error = errors.first
    assert_equal "The 'ship-date' element is invalid - The value '2011/03/12' is invalid according to its datatype 'Date' - The string '2011/03/12' is not a valid XsdDateTime value.", error[:error_description]
    assert_equal "123", error[:order_number]
  end

  [:order_date, :ship_date, :ship_method, :tax_percent, :billing_information].each do |attr|
    define_method(:"test_missing_#{attr}") do
      @options.delete(attr)
      assert_raises(ArgumentError) {
        @service.fulfill("12345678", @address, @line_items, @options)
      }
    end
  end

  def test_get_inventory_for_all
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :get &&
        url.end_with?(@endpoints[:fetch_stock_levels].first)
    end.returns(xml_fixture("dotcom_distribution/inventory_for_item"))
    response = @service.fetch_stock_levels
    assert response.success?
  end

  def test_get_inventory_for_item
    item_id = "12345"
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :get &&
        url.end_with?(@endpoints[:fetch_stock_levels].first + "/" + item_id)
    end.returns(xml_fixture("dotcom_distribution/inventory_for_item"))
    response = @service.fetch_stock_levels(item_id: item_id)
    assert response.success?
  end

  def test_fetch_tracking_data
    order_id = "tracking_data_123456789"
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :get &&
        url.end_with?(@endpoints[:fetch_tracking_data].first + "/" + order_id)
    end.returns(xml_fixture("dotcom_distribution/shipment_information_for_order"))

    response = @service.fetch_tracking_data([order_id])
    assert response.success?
  end

  def test_fetch_tracking_data_without_order_ids_fails_without_options
    assert_raises(ArgumentError) { @service.fetch_tracking_data([]) }
  end

  def test_fetch_tracking_data_without_order_ids
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :get &&
        url.end_with?(@endpoints[:fetch_tracking_data].first + "?fromShipDate=2010-1-1&toShipDate=2010-1-1&dept=A&kitonly=1")
    end.returns(xml_fixture("dotcom_distribution/shipment_information_for_order"))

    response = @service.fetch_tracking_data([], fromShipDate: "2010-1-1", toShipDate: "2010-1-1", dept: "A", kitonly: "1")
    assert response.success?
  end

  def test_purchase_order_successful
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :post
    end.returns(successful_purchase_order_response)
    response = @service.purchase_order(po_number: "abc123")
    # TODO: we should be using Response.new success with success rather than nil
    assert_nil response
  end

  def test_purchase_order_invalid_purchase_order
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :post
    end.returns(invalid_purchase_order_response)
    response = @service.purchase_order(po_number: "foobar")
    refute response.success?
  end

  def test_order_status_successful_with_order_number
    order_number = "1234567890"
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :get &&
        url.end_with?(@endpoints[:order_status].first + "/"+ order_number)
    end.returns(xml_fixture("dotcom_distribution/single_order_status_response"))
    response = @service.order_status(order_number: order_number)
    assert response.success?
  end

  def test_order_status_successful_without_order_number
    query = { fromOrdDate: "2010-1-1", toOrdDate: "2010-1-1" }
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :get &&
        url.end_with?(@endpoints[:order_status].first + "?" + query.to_query)
    end.returns(xml_fixture("dotcom_distribution/single_order_status_response"))
    response = @service.order_status(query)
    assert response.success?
  end

  def test_order_status_invalid_arguments
    assert_raises(ArgumentError) { @service.order_status }
  end

  def test_returns_successful
    query = { fromReturnDate: "2010-1-1", toReturnDate: "2010-1-1" }
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :get &&
        url.end_with?(@endpoints[:returns].first + "?" + query.to_query)
    end.returns(xml_fixture("dotcom_distribution/returns_response"))
    response = @service.returns(query)
    assert response.success?
  end

  def test_returns_invalid_arguments
    assert_raises(ArgumentError) { @service.returns }
  end

  def test_post_item_successful
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :post
    end.returns(successful_post_item_response)
    response = @service.post_item(@item)
    # TODO: return a Response object rather than nil
    assert_nil response
  end

  def test_post_item_with_errors
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :post
    end.returns(invalid_post_item_response)
    response = @service.post_item(@item)
    refute response.success?
  end

  def test_post_items_successful
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :post
    end.returns(successful_post_item_response)
    response = @service.post_items([@item, @item, @item])
    # TODO: return a Response object rather than nil
    assert_nil response
  end

  def test_post_items_with_errors
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :post
    end.returns(invalid_post_item_response)
    response = @service.post_items([@item, @item, @item])
    refute response.success?
  end

  def test_item_summary_successful
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :get &&
        url.end_with?(@endpoints[:item_summary].first)
    end.returns(xml_fixture("dotcom_distribution/item_summary"))
    response = @service.item_summary
    assert response.success?
  end

  def test_single_item_summary_successful
    sku = "ABC-123"
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :get &&
        url.end_with?(@endpoints[:item_summary].first + "/" + sku)
    end
    response = @service.item_summary(sku: sku)
    assert response.success?
  end

  private
  def successful_post_item_response
  <<-XML
<response xmlns="http://dcd/datacontracts/post_item" xmlns:i="http://www.w3.org/2001/XMLSchema- instance">
  <item_errors xmlns:a="http://schemas.datacontract.org/2004/07/DCDAPIService">
  </item_errors>
</response>
  XML
  end

  def invalid_post_item_response
  <<-XML
<response xmlns="http://dcd/datacontracts/post_item" xmlns:i="http://www.w3.org/2001/XMLSchema- instance">
  <item_errors xmlns:a="http://schemas.datacontract.org/2004/07/DCDAPIService">
    <a:item_error>
      <a:error_description>The 'sku' element is invalid - The value '' is invalid according to its datatype 'String' - The actual length is less than the MinLength value.</a:error_description>
      <a:sku/>
    </a:item_error>
    <a:item_error>
      <a:error_description>The 'description' element is invalid - The value '' is invalid according to its datatype 'String' - The actual length is less than the MinLength value.</a:error_description>
      <a:sku>a</a:sku>
    </a:item_error>
  </item_errors>
</response>
  XML
  end

  def successful_purchase_order_response
  <<-XML
<response xmlns="http://dcd/datacontracts/post_purchase_order" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
  <purchase_order_errors xmlns:a="http://schemas.datacontract.org/2004/07/DCDAPIService">
  </purchase_order_errors>
</response>
  XML
  end

  def invalid_purchase_order_response
  <<-XML
<response xmlns="http://dcd/datacontracts/post_purchase_order" xmlns:i="http://www.w3.org/2001/XMLSchema-instance">
  <purchase_order_errors xmlns:a="http://schemas.datacontract.org/2004/07/DCDAPIService">
    <a:purchase_order_error>
      <a:error_description>The 'description' element is invalid - The value 'abfdsbdfbfdbfdbbbbbbbbbbbbbbbbbbb' is invalid according to its datatype 'String' - The actual length is greater than the MaxLength value.</a:error_description>
      <a:purchase_order_number>a</a:purchase_order_number>
    </a:purchase_order_error>
  </purchase_order_errors>
</response>
  XML
  end

  def successful_fulfillment_response
  <<-XML
<response xmlns="http://dcd/datacontracts/post_order" xmlns:i="http://www.w3.org/2001/XMLSchema- instance">
  <order_errors xmlns:a="http://schemas.datacontract.org/2004/07/DCDAPIService">
  </order_errors>
</response>
  XML
  end

  def invalid_post_order_response
  <<-XML
<response xmlns="http://dcd/datacontracts/post_order" xmlns:i="http://www.w3.org/2001/XMLSchema- instance">
  <order_errors xmlns:a="http://schemas.datacontract.org/2004/07/DCDAPIService">
    <a:order_error>
      <a:error_description>The 'ship-date' element is invalid - The value '2011/03/12' is invalid according to its datatype 'Date' - The string '2011/03/12' is not a valid XsdDateTime value.</a:error_description>
      <a:order_number>123</a:order_number>
    </a:order_error>
  </order_errors>
</response>
  XML
  end

end

