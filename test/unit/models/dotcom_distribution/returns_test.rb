require 'test_helper'

class ReceiptsTest < Minitest::Test
  include ActiveFulfillment::Test::Fixtures
  include ActiveFulfillment::DotcomDistribution

  def setup
    ActiveFulfillment::Base.mode = :test
    xml = xml_fixture('dotcom_distribution/receipts_response')
    @item = Receipt.response_from_xml(xml).data.first
  end


  def test_get_order_deserialization
    assert_equal 'E154G', @item.sku
    assert_equal 1, @item.quantity_received
    assert_equal 'RMA463618740', @item.po_reference_number
    assert_equal 'RTU', @item.dcd_identifier
    assert_equal '02/23/16 10:38', @item.item_receipt_date
    assert_equal '02/23/16 10:35', @item.receipt_date
  end
end
