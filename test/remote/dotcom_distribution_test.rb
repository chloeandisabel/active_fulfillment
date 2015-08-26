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
    # it would make things more consistent
    assert_nil response
  end
end
