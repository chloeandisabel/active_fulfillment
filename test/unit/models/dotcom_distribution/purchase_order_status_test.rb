require 'test_helper'

class PurchaseOrderStatusTest < Minitest::Test
  include ActiveFulfillment::Test::Fixtures
  include ActiveFulfillment::DotcomDistribution

  def setup
    ActiveFulfillment::Base.mode = :test
    xml = xml_fixture('dotcom_distribution/purchase_order_status')
    @po = GetPurchaseOrder.response_from_xml(xml).data.first
  end


  def test_get_order_deserialization
    assert_equal 'PO1234', @po.po_number
    assert_equal 'O', @po.po_status
    assert_equal 'DCD-PO-1234', @po.dcd_po_number
    assert_equal '2011-07-10', @po.po_date
    assert_equal '2011-07-11', @po.priority_date
    assert_equal '2011-07-12', @po.expected_date

    assert_equal 1, @po.po_items.length
    item = @po.po_items[0]
    assert_equal 'the-sku', item.sku
    assert_equal 'the description', item.item_description
    assert_equal 12, item.expected_qty
    assert_equal 11, item.received_qty
    assert_equal 1, item.open_qty
    assert_equal 'O', item.status
    assert_equal 1, item.po_line_num
    assert_equal 'style text', item.style
    assert_equal 'color text', item.color
    assert_equal 'size text', item.size
  end

end
