require 'test_helper'

class PostItemTest < Minitest::Test
  include ActiveFulfillment::Test::Fixtures
  include ActiveFulfillment::DotcomDistribution

  def setup
    ActiveFulfillment::Base.mode = :test

    @item = {
      sku: 'MDX-2379-3',
      description: 'Leaf Drop Flex',
      root_sku: 'MDX-2379-3',
      package_qty: 5
    }

  end


  def test_post_item_serialization
    item_doc = Nokogiri.XML(PostItem.new(@item).to_xml)
    item = item_doc.xpath("//item")
    check_item(item)
  end

  def test_post_items_serialization
    items_doc = Nokogiri.XML(PostItem.to_xml([@item, @item, @item]))
    xml_items = items_doc.xpath(".//items/item")
    assert_equal 3, xml_items.length
    xml_items.each do |item|
      check_item(item)
    end
  end

  def test_error_response_parsing
    error_xml = xml_fixture('dotcom_distribution/item_error_response')
    response = PostItem.response_from_xml(error_xml)
    assert_equal false, response.success?
    records = response.params["data"]
    assert_equal 3, records.length
    assert_equal 'C028', records[0][:sku]
    assert_equal 'The First Error', records[0][:error_description]
    assert_equal 'C028K', records[-1][:sku]
    assert_equal 'Something completely different', records[-1][:error_description]
  end

  def check_item(item)
    assert_equal item.at('.//sku').text, @item[:sku]
    assert_equal item.at('.//description').text, @item[:description]

    assert_equal item.at('.//upc').text, ''
    assert_equal item.at('.//weight').text, ''
    assert_equal item.at('.//cost').text, ''
    assert_equal item.at('.//price').text, ''
    assert_equal item.at('.//root-sku').text, @item[:root_sku]
    assert_equal item.at('.//package-qty').text, @item[:package_qty].to_s
    assert_equal item.at('.//serial-indicator').text, ''
    assert_equal item.at('.//client-company').text, ''
    assert_equal item.at('.//client-department').text, ''
    assert_equal item.at('.//client-product-class').text, ''
    assert_equal item.at('.//client-product-type').text, ''
    assert_equal item.at('.//avg-cost').text, ''
    assert_equal item.at('.//master-pack').text, ''
    assert_equal item.at('.//item-barcode').text, ''
    assert_equal item.at('.//country-of-origin').text, ''
    assert_equal item.at('.//harmonized-code').text, ''
    assert_equal item.at('.//manufacturing-code').text, ''
    assert_equal item.at('.//style-number').text, ''
    assert_equal item.at('.//short-name').text, ''
    assert_equal item.at('.//color').text, ''
    assert_equal item.at('.//size').text, ''
    assert_equal item.at('.//long-description').text, ''
  end
end
