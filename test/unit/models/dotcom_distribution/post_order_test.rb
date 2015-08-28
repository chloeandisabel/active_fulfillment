require 'test_helper'

class PostOrderTest < Minitest::Test
  include ActiveFulfillment::Test::Fixtures
  include ActiveFulfillment::DotcomDistribution

  def required_attributes
    {
      order_number: "MD-6901-396294-1",
      ship_date: "2015-05-14",
      order_date: "2015-05-14",
      ship_method: "01",
      total_tax: 0.00,
      total_shipping_handling: 0.00,
      total_order_amount: 10.00,
      billing_information: address_attributes,
      line_items: [line_item_attributes]
    }
  end

  def address_attributes
    {
      name: 'Dennis Jamrose',
      address1: '22 Fox Hill Dr',
      city: 'Fairport',
      state: 'NY',
      zip: '14450-8602',
    }
  end

  def line_item_attributes
    {
      sku: 'MDX-2379-3',
      quantity: 1,
      line_number: 1,
      tax: 0.00,
      shipping_handling: 0.00,
      price: 84.99,
    }
  end

  def setup
    ActiveFulfillment::Base.mode = :test

    @order = {
      order_number: 'MD-6901-396294-1',
      order_date: '2015-05-14',
      promise_date: '2015-05-14',
      ship_method: '11',
      department: '01',
      billing_information: address_attributes,
      shipping_information: address_attributes.merge({
        customer_number: '341569',
        country: 'US',
        iso_country_code: 'US'
      }),
      line_items: [line_item_attributes]
    }

    @post_order = PostOrder.new(@order)
    @order_doc = REXML::Document.new(@post_order.to_xml)
  end

  def test_address_validation
    address = Address.new(address_attributes)
    assert address.valid?
    address.country = "CO"
    refute address.valid?
    address.phone = "1113334444"
    assert address.valid?
  end

  def test_line_item_validation
    line_item = LineItem.new(line_item_attributes)
    assert line_item.valid?
  end

  def test_validate_post_order
    @post_order = PostOrder.new(required_attributes)
    @post_order.valid?
    puts @post_order.line_items.first.errors.full_messages
    assert @post_order.valid?, "got errors #{@post_order.errors.full_messages}"
  end

  def test_post_order_top_level_serialization
    order = REXML::XPath.first(@order_doc, "//order")

    assert_equal @order[:order_number], order.elements["//order-number"].text
    assert_equal @order[:order_date], order.elements["//order-date"].text
    assert_equal @order[:ship_method], order.elements["//ship-method"].text
    assert_equal order.elements["//declared-value"].text, '0'
    assert_equal order.elements["//total-tax"].text, '0'
    assert_equal order.elements["//total-shipping-handling"].text, '0'
    assert_equal order.elements["//total-discount"].text, '0'
    assert_equal order.elements["//total-order-amount"].text, '0'
    assert_equal order.elements["//department"].text, '01'
    assert_equal order.elements["//promise-date"].text, '2015-05-14'

    assert order.elements["//cancel-date"].attributes["nil"]
    assert order.elements["//ship-via"].attributes["nil"]
    assert order.elements["//special-instructions"].attributes["nil"]
    assert order.elements["//special-messaging"].attributes["nil"]
    assert order.elements["//drop-ship"].attributes["nil"]
    assert order.elements["//invoice-number"].attributes["nil"]
    assert order.elements["//ok-partial-ship"].attributes["nil"]
    assert order.elements["//po-number"].attributes["nil"]
    assert order.elements["//salesman"].attributes["nil"]
    assert order.elements["//credit-card-number"].attributes["nil"]
    assert order.elements["//credit-card-expiration"].attributes["nil"]
    assert order.elements["//ad-code"].attributes["nil"]
    assert order.elements["//continuity-flag"].attributes["nil"]
    assert order.elements["//freight-terms"].attributes["nil"]
    assert order.elements["//pay-terms"].attributes["nil"]
    assert order.elements["//tax-percent"].attributes["nil"]
    assert order.elements["//asn-qualifier"].attributes["nil"]
    assert order.elements["//gift-order-indicator"].attributes["nil"]
    assert order.elements["//order-source"].attributes["nil"]
    assert order.elements["//third-party-account"].attributes["nil"]
    assert order.elements["//priority"].attributes["nil"]
    assert order.elements["//retail-department"].attributes["nil"]
    assert order.elements["//retail-store"].attributes["nil"]
    assert order.elements["//retail-vendor"].attributes["nil"]
    assert order.elements["//pool"].attributes["nil"]

    for i in 1..5
      assert order.elements["//custom-field-#{i}"].attributes["nil"]
    end
  end

  def test_post_order_store_information_serialization
    order = REXML::XPath.first(@order_doc, "//order")

    store_information = REXML::XPath.first(order, "//store-information")
    assert store_information.elements['.//store-name'].attributes["nil"]
    assert store_information.elements['.//store-address1'].attributes["nil"]
    assert store_information.elements['.//store-address2'].attributes["nil"]
    assert store_information.elements['.//store-city'].attributes["nil"]
    assert store_information.elements['.//store-state'].attributes["nil"]
    assert store_information.elements['.//store-country'].attributes["nil"]
    assert store_information.elements['.//store-zip'].attributes["nil"]
    assert store_information.elements['.//store-phone'].attributes["nil"]
  end

  def test_post_order_billing_and_shipping_information_serialization
    order = REXML::XPath.first(@order_doc, "//order")

    billing_information = order.elements[".//billing-information"]
    expected = @order[:billing_information]
    assert billing_information.elements[".//billing-customer-number"].attributes["nil"]
    assert billing_information.elements[".//billing-company"].attributes["nil"]
    assert billing_information.elements[".//billing-address2"].attributes["nil"]
    assert billing_information.elements[".//billing-address3"].attributes["nil"]
    assert billing_information.elements[".//billing-phone"].attributes["nil"]
    assert billing_information.elements[".//billing-email"].attributes["nil"]
    assert billing_information.elements[".//billing-country"].attributes["nil"]

    assert_equal expected[:name], billing_information.elements[".//billing-name"].text
    assert_equal expected[:address1], billing_information.elements['.//billing-address1'].text
    assert_equal expected[:city], billing_information.elements[".//billing-city"].text
    assert_equal expected[:state], billing_information.elements[".//billing-state"].text
    assert_equal expected[:zip], billing_information.elements[".//billing-zip"].text

    shipping_information = order.elements[".//shipping-information"]
    expected = @order[:shipping_information]
    assert shipping_information.elements[".//shipping-company"].attributes["nil"]
    assert shipping_information.elements[".//shipping-address2"].attributes["nil"]
    assert shipping_information.elements[".//shipping-address3"].attributes["nil"]
    assert shipping_information.elements[".//shipping-phone"].attributes["nil"]
    assert shipping_information.elements[".//shipping-email"].attributes["nil"]

    assert_equal expected[:customer_number], shipping_information.elements[".//shipping-customer-number"].text
    assert_equal expected[:name], shipping_information.elements[".//shipping-name"].text
    assert_equal expected[:address1], shipping_information.elements[".//shipping-address1"].text
    assert_equal expected[:city], shipping_information.elements[".//shipping-city"].text
    assert_equal expected[:state], shipping_information.elements[".//shipping-state"].text
    assert_equal expected[:country], shipping_information.elements[".//shipping-country"].text
    assert_equal expected[:zip], shipping_information.elements[".//shipping-zip"].text
  end

  def test_post_order_line_item_serialization
    order = REXML::XPath.first(@order_doc, "//order")

    line_item = REXML::XPath.first(order, '//line-item')
    expected = @order[:line_items].first
    assert_equal expected[:sku], line_item.elements["//sku"].text
    assert_equal expected[:quantity].to_s, line_item.elements["//quantity"].text
    assert_equal expected[:price].to_s, line_item.elements['.//price'].text
    assert_equal expected[:tax].to_s, line_item.elements['.//tax'].text
    assert_equal expected[:shipping_handling].to_s, line_item.elements['.//shipping-handling'].text
    assert_equal expected[:line_number].to_s, line_item.elements['.//line-number'].text

    assert line_item.elements["//client-item"].attributes["nil"]
    assert line_item.elements['.//gift-box-wrap-quantity'].attributes["nil"]
    assert line_item.elements['.//gift-box-wrap-type'].attributes["nil"]
  end

  def test_post_order_response_serialization
    xml =  <<-XML
    <response xmlns="http://dcd/datacontracts/post_order" xmlns:i="http://www.w3.org/2001/XMLSchema- instance">
      <order_errors xmlns:a="http://schemas.datacontract.org/2004/07/DCDAPIService">
        <a:order_error>
          <a:error_description>The 'ship-date' element is invalid - The value '2011/03/12' is invalid according to its datatype 'Date' - The string '2011/03/12' is not a valid XsdDateTime value.</a:error_description>
          <a:order_number>123</a:order_number>
        </a:order_error>
      </order_errors>
    </response>
    XML

    response = PostOrder.response_from_xml(xml)
    refute response.success?
    error = response.data.first
    refute_nil error
    refute_empty error[:error_description]
    refute_empty error[:order_number]
  end

end
