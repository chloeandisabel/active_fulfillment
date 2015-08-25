require 'thor'
require 'byebug'
require 'nokogiri'
require 'active_fulfillment'

# I thought it would be a useful piece of functionality to add.
# Remove it if that's not the case
# See:
#   http://whatisthor.com/

module ActiveFulfillment

  class CLI < Thor

    desc "post_order", "Place an order"
    def post_order
      order = {
        order_number: "12",
        ship_method: "01",
        tax_percent: 5,
        line_items: [
          {
            sku: "a", line_number: 1, client_item: "abc", quantity: 1,
            gift_box_wrap_quantity: 1, gift_box_wrap_type: 1
          }
        ],
        billing_information: {
          customer_number: "12345",
          name: "Chloe Isabel",
          address1: "123 abc",
          city: "Miami",
          state: "FL",
          zip: "33018"
        },
        shipping_information: {
          customer_number: "12345",
          name: "Chloe Isabel",
          address1: "123 abc",
          city: "Miami",
          state: "FL",
          zip: "33018"
        },
        cancel_date: Time.current.strftime("%Y-%m-%d"),
        order_date: Time.current.strftime("%Y-%m-%d")
      }
      puts api.fulfill(order).inspect
    end

    desc "get_order", "Retrieve an order"
    def get_order
    end

    desc "inventory", "Retrieve all inventory information"
    def inventory(date=Time.current.strftime('%Y-%m-%d'))
      puts api.inventory_snapshot(invDate: date).inspect
    end

    desc "post_item", "Send item information"
    def post_item
      item = {
        sku: "a",
        description: "a",
        upc: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        weight: 100.12,
        cost: 1000.12,
        price: 1000.12,
        root_sku: "aaaaaaaaaaaaaaaaa",
        package_qty: 10,
        serial_indicator: "Y",
        client_company: "aaaaa",
        client_department: "aaaaa",
        client_product_class: 1234,
        client_product_type: 1234,
        avg_cost: 50.12,
        master_pack: 123456,
        item_barcode: "aaaaaaaaaaaaaaaaaaaaaaaa",
        #country_of_origin: "aaaaaaaaaaaaaaaaaaaaaaaaaaaaaa",
        harmonized_code: "aaaaaaaaa",
        manufacturing_code: "aaaaaaaaaa",
        style_number: "aaaaaaaaaa",
        short_name: "aaaaaaaaaa",
        color: "aaaa",
        size: "aaaaa",
        long_description: "aaaaaaaaaa"
      }
      puts api.post_item(item).inspect
    end

    desc "get_item SKU", "Retrieve item information [SKU]"
    def get_items(sku=nil)
      puts api.item_summary(sku: sku).inspect
    end

    private

    def api
      @api ||= begin
                 ActiveFulfillment::Base.mode = :test if ENV['DOTCOM_MODE'] == 'test'
                 unless ENV['DOTCOM_API_KEY'] && ENV['DOTCOM_API_PASSWORD']
                   $stderr.puts "Environment variables $DOTCOM_API_KEY and $DOTCOM_API_PASSWORD must be defined"
                   exit(1)
                 end
                 ActiveFulfillment::Base.service('dotcom_distribution').new(username: ENV['DOTCOM_API_KEY'],
                                                                            password: ENV['DOTCOM_API_PASSWORD'])
               end
    end
  end
end
