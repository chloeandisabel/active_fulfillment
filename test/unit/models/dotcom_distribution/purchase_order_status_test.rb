require "test_helper"

class PurchaseOrderStatusTest < Minitest::Test
  include ActiveFulfillment::Test::Fixtures
  include ActiveFulfillment::DotcomDistribution

  def setup
    ActiveFulfillment::Base.mode = :test
    xml = xml_fixture("dotcom_distribution/purchase_order_status")
    @po = GetPurchaseOrder.response_from_xml(xml).data.first
  end


  def test_get_order_deserialization
    assert_equal "D002", @po.po_number
    assert_equal "A", @po.po_status
    assert_equal "260664570", @po.dcd_po_number
    assert_equal "12/29/2015", @po.po_date
    assert_equal "12/29/2015", @po.priority_date
    assert_equal "12/29/2015 12:00:00 AM", @po.expected_date

    assert_equal 2, @po.po_items.length
    item = @po.po_items[0]
    assert_equal "E224SQ", item.sku
    assert_equal "Minaret Light Rose Teardrop Ea", item.item_description
    assert_equal 500, item.expected_qty
    assert_equal 500, item.received_qty
    assert_equal 0, item.open_qty
    assert_equal "A", item.status
    assert_equal 1, item.po_line_num
    assert_equal "color text", item.color
    assert_equal "", item.style
    assert_equal "", item.size
  end
end
