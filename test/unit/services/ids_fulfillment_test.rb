require 'test_helper'

class IDSFulfillmentTest < Minitest::Test
  def setup
    @service = ActiveFulfillment::IDSFulfillment.new

    @options = {
      ship_type: 2,
      ship_date: Time.now
    }

    @address = {
      name: "Jane Smith",
      address1: "100 Main St",
      city: "Beverly Hills",
      state: "CA",
      country_code: "US",
      zip_code: "90210",
    }

    @line_items = [{
      sku: "N001",
      quantity: 1
    }]
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
end
