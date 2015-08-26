require 'test_helper'

class RemoteDotcomIntegrationTest < Minitest::Test
  include ActiveFulfillment::Test::Fixtures

  def setup
    ActiveFulfillment::Base.mode = :test
    @service = ActiveFulfillment::DotcomDistributionService.new(fixtures(:dotcom_distribution))
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

  #Create Items
  #Create Purchase Orders
  #Create Orders
  #Get Order Status
  #Get Inventory
  #Get Returns


  def test_successful_item_submission
    response = @service.post_item(@item)
    # TODO: we should probably always return a Response object
    # it would make things more consistent as to how other services
    # work in this gem.
    assert_nil response
  end

  def test_successful_create_order
    response = @service.fulfill(SecureRandom.hex(10), @address, @line_items, @options)
    # TODO: This requires the item in @line_items to exist
    assert_nil response
  end

  def test_order_multiple_line_items
    @line_items.push({
      sku: "Test 2",
      line_number: 1,
      client_item: "abc",
      quantity: 1,
      gift_box_wrap_quantity: 1,
      gift_box_wrap_type: 1,
    })
    response = @service.fulfill(SecureRandom.hex(10), @address, @line_items, @options)
    assert_nil response
  end

  def test_successful_purchase_order
    response = @service.purchase_order(@purchase_order)
    assert_nil response
  end

  def test_get_order_status
    # TODO: Check actual order status. Currently returns empty
    response = @service.order_status(order_number: "TEST-JP1")
    assert response.success?
    refute_empty response.data
    assert_equal response.data.length, 1
    order = response.data.first
    assert_equal order.client_order_number, "TEST-JP1"
  end

  def test_get_order_status_with_range
    response = @service.order_status(fromOrdDate: "2001-01-01", toOrdDate: Date.today.to_s)
    assert response.success?
    refute_empty response.data
  end

  def test_get_inventory
    # TODO: test with some inventory data. Currently returns empty
    response = @service.inventory_snapshot(invDate: Date.today.to_s)
    assert response.success?
    refute_empty response.data
  end

  def test_returns
    response = @service.returns(fromReturnDate: "2001-01-01", toReturnDate: Date.today.to_s)
    assert response.success?
    refute_empty response.data
  end
end
