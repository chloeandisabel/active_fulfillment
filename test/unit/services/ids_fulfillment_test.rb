require 'test_helper'

class IDSFulfillmentTest < Minitest::Test
  def setup
    @service = ActiveFulfillment::IDSFulfillment.new(api_key: "xxxxxx")

    @options = {
      carrier_code: "FEDG",
      ship_type: 6,
    }

    @address = {
      name: "Jane Smith",
      address1: "100 Main St",
      city: "Beverly Hills",
      state: "CA",
      zip_code: "90210",
      country_code: "US"
    }

    @line_items = [{
      sku: "N001",
      quantity: 1
    }]
  end

  def test_fulfill
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :post &&
        url.end_with?("/request/ship") &&
        data.include?('"CustomerOrderReferenceNumber":"H0000000001"') &&
        data.include?('"SKU":"N001"') &&
        headers.key?("ApiKey")
    end.returns("{}")
    @service.fulfill("H0000000001", @address, @line_items, @options)
  end

  def test_fulfill_multiple
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :post &&
        url.end_with?("/request/ship") &&
        data.include?('"CustomerOrderReferenceNumber":"H0000000001"') &&
        data.include?('"CustomerOrderReferenceNumber":"H0000000002"') &&
        data.include?('"SKU":"N001"') &&
        data.include?('"SKU":"R001-6"') &&
        data.include?('"QuantityOrdered":2') &&
        headers.key?("ApiKey")
    end.returns("{}")
    @service.fulfill_multiple([
      ["H0000000001", @address, @line_items, @options],
      ["H0000000002", @address, [{ sku: "R001-6", quantity: 2 }], @options]
    ])
  end

  def test_fetch_tracking_data
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :get &&
        url.end_with?("/request/ship?customerOrderReferenceNumbers=H0000000001") &&
        headers.key?("ApiKey")
    end.returns(successful_order_status_response)
    response = @service.fetch_tracking_data(["H0000000001"])
    assert_equal(response.params, { tracking_companies: ["TESTCARRIERCODE"],
                                    tracking_numbers: ["TESTPACKAGENUMBER"],
                                    tracking_urls: [] }.stringify_keys)
  end

  def test_fetch_stock_levels
    @service.expects(:ssl_request).with do |verb, url, data, headers|
      verb == :get &&
        url.end_with?("/request/storerinventory") &&
        headers.key?("ApiKey")
    end.returns(successful_inventory_response)
    response = @service.fetch_stock_levels
    assert_equal(response.params["Items"][0]["ItemCode"], "N001")
    assert_equal(response.params["Items"][0]["ItemDetails"][0]["QuantityOnHand"], "100")
  end

  def test_validate_shipping_address
    [:name, :address1, :city, :state, :zip_code, :country_code].each do |required_field|
      assert_raises(ArgumentError) do
        address = @address.dup.tap { |a| a.delete(required_field) }
        @service.send(:validate_shipping_address!, address)
      end
    end
  end

  def test_shipping_address_data
    @address[:phone] = "(555)555-5555"
    @address[:email] = "janesmith@gmail.com"
    @address[:address2] = "Apt A"

    assert_equal(@service.send(:shipping_address_data, @address), {
      "Name" => "Jane Smith",
      "AddressLine1" => "100 Main St",
      "AddressLine2" => "Apt A",
      "Phone" => "(555)555-5555",
      "Email" => "janesmith@gmail.com",
      "City" => "Beverly Hills",
      "State" => "CA",
      "Zip" => "90210",
      "CountryCode" => "US"
    })
  end

  private

  def successful_order_status_response
    <<-JSON
{
  "Orders": [
    {
      "OrderStatus": "",
      "CustomerOrderReferenceNumber": "H0000000001",
      "WarehouseOrderReferenceNumber": "",
      "ShipDate": "",
      "CarrierCode": "TESTCARRIERCODE",
      "CustomerCarrierCode": "",
      "ShipType": "",
      "BrokerName": "",
      "FreightChargeCode": "",
      "ProNumber": "",
      "ConsolidationLoadNumber": "",
      "HazardousMaterials": "",
      "POs": [
        {
          "PONumber": ""
        }
      ],
      "Events": [
        {
          "DataElementCode": "",
          "StatusCode": "",
          "Description": ""
        }
      ],
      "OrderExtraDataFields": [
        {
          "ExtraDataFieldLabel": "",
          "ExtraDataFieldValue": "",
          "ExtraDataFieldLength": ""
        }
      ],
      "OrderItems": [
        {
          "LineStatus": "",
          "LineNumber": "",
          "WMSLineNumber": "",
          "ShipFromBucket": "",
          "QuantityOrdered": "",
          "QuantityShipped": "",
          "SKU": "",
          "LotCode1": "",
          "LotCode2": "",
          "LotCode3": "",
          "HazardousMaterials": "",
          "PackageNumber": "TESTPACKAGENUMBER",
          "OrderItemExtraDataFields": [
            {
              "ExtraDataFieldLabel": "",
              "ExtraDataFieldValue": "",
              "ExtraDataFieldLength": ""
            }
          ]
        }
      ],
      "Packages": [
        {
          "PackageNumber": "TESTPACKAGENUMBER",
          "Items": "",
          "Quantity": "",
          "Weight": "",
          "Height": "",
          "Width": "",
          "Depth": "",
          "FreightCharge": "",
          "ShippingCost": ""
        }
      ]
    }
  ]
}
    JSON
  end

  def successful_inventory_response
    <<-JSON
{
  "Items": [
    {
      "ItemCode": "N001",
      "ItemDescription1": "",
      "ItemDescription2": "",
      "WeightDesignation": "",
      "TotalGrossWeight": "",
      "UnitCubicFeet": "",
      "MaterialHandlingCode1": "",
      "MaterialHandlingCode2": "",
      "MaterialHandlingCode3": "",
      "InventoryUnitofMeasure": "",
      "ItemUPCCode": "",
      "ItemUPCTailCode": "",
      "ItemDetails": [
        {
          "LotCode1": "",
          "LotCode2": "",
          "LotCode3": "",
          "QuantityOnHand": "100",
          "QuantityHeld": "",
          "QuantityCommitted": "",
          "QuantityFutureAllocated": "",
          "QuantityDamaged": "",
          "QuantityShipped": "",
          "QuantityInTransit": "",
          "QuantityUser1": "",
          "QuantityUser2": "",
          "QuantityUser3": "",
          "QuantityUser4": "",
          "ItemDetailSerials": [
            {
              "SerialNumber": "",
              "OriginalSerialQuantity": "",
              "SerialQuantity": "",
              "UnitWeight": "",
              "EachQuantity": "",
              "EachWeight": ""
            }
          ]
        }
      ]
    }
  ]
}
    JSON
  end
end
