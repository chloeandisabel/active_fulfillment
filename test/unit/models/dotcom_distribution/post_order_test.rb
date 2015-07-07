require 'test_helper'

class PostOrderTest < Minitest::Test
  include ActiveFulfillment::Test::Fixtures
  include ActiveFulfillment::DotcomDistribution

  def setup
    ActiveFulfillment::Base.mode = :test

    @order = {
      order_number: 'MD-6901-396294-1',
      order_date: '2015-05-14',
      cancel_date: '2015-05-14',
      promise_date: '2015-05-14',
      ship_method: '11',
      department: '01',
      billing_information: {
        customer_number: '341569',
        name: 'Dennis Jamrose',
        address1: '22 Fox Hill Dr',
        state: 'NY',
        city: 'Fairport',
        zip: '14450-8602',
        country: 'US'
      },
      shipping_information: {
        customer_number: '341569',
        name: 'Dennis Jamrose',
        address1: '22 Fox Hill Dr',
        state: 'NY',
        city: 'Fairport',
        zip: '14450-8602',
        country: 'US',
        iso_country_code: 'US'
      },
      line_items: [{
        sku: 'MDX-2379-3',
        quantity: 1,
        price: 84.99,
        line_number: 1,
        tax: 0,
        shipping_handling: 0
      }]
    }

    @order_doc = Nokogiri.XML(PostOrder.new(@order).to_xml)

  end

  def test_post_order_top_level_serialization
    order = @order_doc.xpath("//order")

    assert_equal order.at('.//order-number').text, @order[:order_number]
    assert_equal order.at('.//order-date').text, @order[:order_date]
    assert_equal order.at('.//ship-method').text, @order[:ship_method]
    assert_equal order.at('.//ship_via').text, ''
    assert_equal order.at('.//special-instructions').text, ''
    assert_equal order.at('.//special-messaging').text, ''
    assert_equal order.at('.//drop-ship').text, ''
    assert_equal order.at('.//invoice-number').text, ''
    assert_equal order.at('.//ok-partial-ship').text, ''
    assert_equal order.at('.//declared-value').text, '0'
    assert_equal order.at('.//cancel-date').text, '2015-05-14'
    assert_equal order.at('.//total-tax').text, '0'
    assert_equal order.at('.//total-shipping-handling').text, '0'
    assert_equal order.at('.//total-discount').text, '0'
    assert_equal order.at('.//total-order-amount').text, '0'
    assert_equal order.at('.//po-number').text, ''
    assert_equal order.at('.//salesman').text, ''
    assert_equal order.at('.//credit-card-number').text, ''
    assert_equal order.at('.//credit-card-expiration').text, ''
    assert_equal order.at('.//ad-code').text, ''
    assert_equal order.at('.//continuity-flag').text, ''
    assert_equal order.at('.//freight-terms').text, ''
    assert_equal order.at('.//department').text, '01'
    assert_equal order.at('.//pay-terms').text, ''
    assert_equal order.at('.//tax-percent').text, ''
    assert_equal order.at('.//asn-qualifier').text, ''
    assert_equal order.at('.//gift-order-indicator').text, ''
    assert_equal order.at('.//order-source').text, ''
    assert_equal order.at('.//promise-date').text, '2015-05-14'
    assert_equal order.at('.//third-party-account').text, ''
    assert_equal order.at('.//priority').text, ''
    assert_equal order.at('.//retail-department').text, ''
    assert_equal order.at('.//retail-store').text, ''
    assert_equal order.at('.//retail-vendor').text, ''
    assert_equal order.at('.//pool').text, ''

    for i in 1..5
      assert_equal order.at(".//custom-field-#{i}").text, ''
    end
  end

  def test_post_order_store_information_serialization
    order = @order_doc.xpath("//order")

    store_information = order.at('.//store-information')
    assert_equal store_information.at('.//store-name').text, ''
    assert_equal store_information.at('.//store-address1').text, ''
    assert_equal store_information.at('.//store-address2').text, ''
    assert_equal store_information.at('.//store-city').text, ''
    assert_equal store_information.at('.//store-state').text, ''
    assert_equal store_information.at('.//store-country').text, ''
    assert_equal store_information.at('.//store-zip').text, ''
    assert_equal store_information.at('.//store-phone').text, ''
  end

  def test_post_order_billing_and_shipping_information_serialization
    order = @order_doc.xpath("//order")

    billing_information = order.at('.//billing-information')
    assert_equal billing_information.at('.//billing-customer-number').text, @order[:billing_information][:customer_number]
    assert_equal billing_information.at('.//billing-name').text, @order[:billing_information][:name]
    assert_equal billing_information.at('.//billing-company').text, ''
    assert_equal billing_information.at('.//billing-address1').text, @order[:billing_information][:address1]
    assert_equal billing_information.at('.//billing-address2').text, ''
    assert_equal billing_information.at('.//billing-address3').text, ''
    assert_equal billing_information.at('.//billing-phone').text, ''
    assert_equal billing_information.at('.//billing-email').text, ''
    assert_equal billing_information.at('.//billing-city').text, @order[:billing_information][:city]
    assert_equal billing_information.at('.//billing-state').text, @order[:billing_information][:state]
    assert_equal billing_information.at('.//billing-country').text, @order[:billing_information][:country]
    assert_equal billing_information.at('.//billing-zip').text, @order[:billing_information][:zip]

    shipping_information = order.at('.//shipping-information')
    assert_equal shipping_information.at('.//shipping-customer-number').text, @order[:shipping_information][:customer_number]
    assert_equal shipping_information.at('.//shipping-name').text, @order[:shipping_information][:name]
    assert_equal shipping_information.at('.//shipping-company').text, ''
    assert_equal shipping_information.at('.//shipping-address1').text, @order[:shipping_information][:address1]
    assert_equal shipping_information.at('.//shipping-address2').text, ''
    assert_equal shipping_information.at('.//shipping-address3').text, ''
    assert_equal shipping_information.at('.//shipping-phone').text, ''
    assert_equal shipping_information.at('.//shipping-email').text, ''
    assert_equal shipping_information.at('.//shipping-city').text, @order[:shipping_information][:city]
    assert_equal shipping_information.at('.//shipping-state').text, @order[:shipping_information][:state]
    assert_equal shipping_information.at('.//shipping-country').text, @order[:shipping_information][:country]
    assert_equal shipping_information.at('.//shipping-zip').text, @order[:shipping_information][:zip]
  end

  def test_post_order_line_item_serialization
    order = @order_doc.xpath("//order")

    line_item = order.at('.//line-item')
    assert_equal line_item.at('.//sku').text, @order[:line_items].first[:sku]
    assert_equal line_item.at('.//quantity').text, @order[:line_items].first[:quantity].to_s
    assert_equal line_item.at('.//price').text, @order[:line_items].first[:price].to_s
    assert_equal line_item.at('.//tax').text, @order[:line_items].first[:tax].to_s
    assert_equal line_item.at('.//shipping-handling').text, @order[:line_items].first[:shipping_handling].to_s
    assert_equal line_item.at('.//client-item').text, ''
    assert_equal line_item.at('.//line-number').text, @order[:line_items].first[:line_number].to_s
    assert_equal line_item.at('.//gift-box-wrap-quantity').text, ''
    assert_equal line_item.at('.//gift-box-wrap-type').text, ''
  end

end
