require 'test_helper'

class OrderTest < Minitest::Test
  include ActiveFulfillment::Test::Fixtures
  include ActiveFulfillment::DotcomDistribution

  def setup
    ActiveFulfillment::Base.mode = :test

    xml = <<-SQL
      <?xml version="1.0" encoding="UTF-8"?>
      <response>
        <orders>
          <order>
            <client_order_number>R12345678</client_order_number>
            <dcd_order_number>text</dcd_order_number>
            <order_status>Shipped</order_status>
            <ship_date>2010-03-04</ship_date>
          </order>
        </orders>
      </response>
    SQL

    @order = GetOrder.response_from_xml(xml).data.first
  end


  def test_get_order_deserialization
    assert_equal @order.client_order_number, 'R12345678'
  end

end
