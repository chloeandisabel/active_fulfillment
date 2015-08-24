require 'test_helper'

class ItemSummaryTest < Minitest::Test
  include ActiveFulfillment::Test::Fixtures
  include ActiveFulfillment::DotcomDistribution

  def setup
    ActiveFulfillment::Base.mode = :test

    xml = <<-SQL
      <?xml version="1.0" encoding="UTF-8"?>
      <response xmlns="http://dcd/datacontracts/iteminfo" xmlns:i="http://www.w3.org/2001/XMLSchema- instance">
        <items_info xmlns:a="http://schemas.datacontract.org/2004/07/DCDAPIService">
        <a:item_info>
          <a:item_description>Cassie Cardigan</a:item_description>
          <a:last_receipt_date>7/27/2012 2:53:00 PM</a:last_receipt_date>
          <a:sku>360-103053-DEW-M</a:sku>
          <a:upc_num />
          <a:vendor_items>
            <a:vendor_item>
              <a:vendor_cross_ref>846255082961</a:vendor_cross_ref>
            </a:vendor_item>
          </a:vendor_items>
        </a:item_info>
        </items_info>
      </response>
    SQL

    @item = ItemSummary.response_from_xml(xml).data.first
  end


  def test_get_order_deserialization
    assert_equal @item.sku, '360-103053-DEW-M'
    assert_equal @item.description, 'Cassie Cardigan'
    assert_equal @item.last_receipt_date, '7/27/2012 2:53:00 PM'
    assert_equal @item.vendor_items.length, 1
    assert_equal @item.vendor_items[0].cross_ref, '846255082961'
  end

end
