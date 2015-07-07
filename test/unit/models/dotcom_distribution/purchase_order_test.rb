require 'test_helper'

class PurchaseOrderTest < Minitest::Test
  include ActiveFulfillment::Test::Fixtures
  include ActiveFulfillment::DotcomDistribution

  def setup
    ActiveFulfillment::Base.mode = :test

    @purchase_order = {
      po_number: 'PO1234',
      items: [{
        sku: 'MDX-2379-3',
        description: 'Leaf Drop Flex',
        root_sku: 'MDX-2379-3',
        package_qty: 5
      }]
    }

    @po_doc = Nokogiri.XML(PurchaseOrder.new(@purchase_order).to_xml)
  end

  def test_purchase_order_serialization
    item = @po_doc.xpath("//item").first

    assert_equal item.at('.//sku').text, @purchase_order[:items].first[:sku]
    assert_equal item.at('.//description').text, @purchase_order[:items].first[:description]
  end
end
