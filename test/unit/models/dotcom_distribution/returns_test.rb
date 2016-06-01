require 'test_helper'

class ReceiptsTest < Minitest::Test
  include ActiveFulfillment::Test::Fixtures
  include ActiveFulfillment::DotcomDistribution

  def setup
    ActiveFulfillment::Base.mode = :test
  end

  def test_get_receipts_deserialization
    xml = xml_fixture('dotcom_distribution/receipts_response')
    item = Receipt.response_from_xml(xml).data.first

    assert_equal 'E154G', item.sku
    assert_equal 1, item.quantity_received
    assert_equal 'RMA463618740', item.po_reference_number
    assert_equal 'RTU', item.dcd_identifier
    assert_equal '02/23/16 10:38', item.item_receipt_date
    assert_equal '02/23/16 10:35', item.receipt_date
  end

  def test_get_returns_deserialization
    xml = xml_fixture('dotcom_distribution/returns_response')
    ret = Return.response_from_xml(xml).data.first

    assert_equal 'H03847877315', ret.original_order_number
    assert_equal '01', ret.department
    assert_equal '262155673501', ret.dcd_return_number
    assert_equal '05/11/16', ret.return_date

    item = ret.return_items.first
    assert_equal 'MKT-CAT20', item.sku
    assert_equal 2, item.quantity_returned
    assert_equal "", item.line_number
    assert_equal '011', item.item_disposition
    assert_equal 'RTGD', item.returns_reason_code
    assert_equal 'C', item.returns_action_code
  end
end
