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
      }]}
  end

  def test_class_to_xml_with_hash
    xml = PurchaseOrder.to_xml([@purchase_order, @purchase_order])
    doc = Nokogiri.XML(xml)

    pos = doc.xpath("//purchase_orders//purchase_order")
    assert_equal 2, pos.length

    item_xml = pos.first.at('.//items//item')
    assert_equal @purchase_order[:items][0][:sku], item_xml.at('.//sku').try(:text)
  end

  def test_purchase_order_serialization
    doc = Nokogiri.XML(PurchaseOrder.new(@purchase_order).to_xml)
    item = doc.xpath("//item").first

    assert_equal item.at('.//sku').text, @purchase_order[:items].first[:sku]
    assert_equal item.at('.//description').text, @purchase_order[:items].first[:description]
  end

  def test_purchase_orders_serialization
    pos = [@purchase_order, @purchase_order]
    doc = Nokogiri.XML(PurchaseOrder.to_xml(pos))

    items = doc.xpath("//item")
    assert_equal 2, items.length
    item = items[0]
    assert_equal item.at('.//sku').text, @purchase_order[:items].first[:sku]
    assert_equal item.at('.//description').text, @purchase_order[:items].first[:description]

    item = items[1]
    assert_equal item.at('.//sku').text, @purchase_order[:items].first[:sku]
    assert_equal item.at('.//description').text, @purchase_order[:items].first[:description]
  end
end
