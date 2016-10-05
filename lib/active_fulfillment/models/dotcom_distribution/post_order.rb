require_relative 'nil_injector'
require_relative 'string_normalizer'

module ActiveFulfillment
  module DotcomDistribution

    # = Dotcom ActiveFulfillment Order
    #
    # This is the shipment request sent to us based on your customer's order
    #
    # Credit Card number: Is not required and we would prefer not getting it at
    #   all unless you need us to print it on an invoice or packing document.  It
    #   is in the spec for specific clients that want it reported on.
    # Continuity flag:
    #   I do not believe we will have a continuity program with you.  This
    #   was for a client that we did vitamin fulfillment.  It is not a required
    #   field.
    # Gift order indicator:
    #   Is a Y/N field.  If you pass us Y and we display prices on your
    #   invoice we will suppress printing the price and values.
    class PostOrder
      include Model
      include ::ActiveFulfillment::DotcomDistribution::NilInjector
      include ::ActiveFulfillment::DotcomDistribution::StringNormalizer

      attr_accessor :order_number,
                    :order_date,
                    :ship_method,
                    :ship_via,
                    :drop_ship,
                    :ok_partial_ship,
                    :special_instructions,
                    :special_messaging,
                    :invoice_number,
                    :declared_value,
                    :cancel_date,
                    :total_tax,
                    :total_shipping_handling,
                    :total_discount,
                    :total_order_amount,
                    :po_number,
                    :salesman,
                    :credit_card_number,
                    :credit_card_expiration,
                    :ad_code,
                    :continuity_flag,
                    :freight_terms,
                    :department,
                    :pay_terms,
                    :tax_percent,
                    :asn_qualifier,
                    :gift_order_indicator,
                    :order_source,
                    :ship_date,
                    :promise_date,
                    :third_party_account,
                    :priority,
                    :billing_information,
                    :shipping_information,
                    :store_information,
                    :retail_department,
                    :retail_vendor,
                    :retail_store,
                    :pool,
                    :line_items

      def shipping_methods
        self.class.shipping_methods.collect {|s| s[1]}
      end

      # The first is the label, and the last is the code
      def self.shipping_methods
        [
         ["UPS NEXT DAY 10:30 NEXT BUSINESS MORNING", "01"],
         ["UPS NEXT DAY 10:30 NEXT BUSINESS MORNING - Signature", "01S"],
         ["UPS 2ND DAY", "02"],
         ["UPS 2ND DAY - signature", "02S"],
         ["UPS GROUND", "03"],
         ["UPS INTERNATIONAL", "04"],
         ["DHL NEXT DAY - SATURDAY", "05"],
         ["UPS 2ND DAY AIR AM", "07"],
         ["UPS NEXT DAY AIR - SATURDAY", "08"],
         ["UPS NEXT DAY AIR SATURDAY - signature", "08s"],
         ["USPS STANDARD", "10"],
         ["USPS 1ST CLASS", "11"],
         ["USPS FIRST CLASS INTERNATIONAL", "11i"],
         ["UPS 3 DAY SELECT - signature", "12s"],
         ["UPS NEXT DAY SAVER", "13"],
         ["UPS NEXT DAY AIR AM", "15"],
         ["USPS - PARCEL POST", "20"],
         ["USPS APO", "22"],
         ["NEMF", "24"],
         ["FEDEX EVENING DELIVERY", "29"],
         ["JEVIC", "31"],
         ["FEDEX SATURDAY OVERNIGHT", "32"],
         ["EXPEDITOR AIR", "33"],
         ["OT INSIDE DELIV", "34"],
         ["EXPEDITOR OCEAN", "35"],
         ["CANADA POST", "39"],
         ["DHL GROUND", "40"],
         ["DHL 2ND DAY", "41"],
         ["DHL NEXT DAY", "42"],
         ["DHL EXPRESS", "43"],
         ["DHL @HOME", "44"],
         ["DHL NEXT DATE 12:00", "45"],
        ].inject({}){|h, (k,v)| h[k] = v; h}
      end

      def store_information=(attributes)
        @store_information = Address.new(attributes)
      end

      def shipping_information=(attributes)
        @shipping_information = Address.new(attributes)
      end

      def billing_information=(attributes)
        @billing_information = Address.new(attributes)
      end

      def line_items=(attributes)
        @line_items ||= []
        attributes.each do |params|
          @line_items.push(LineItem.new(params))
        end
      end

      def declared_value
        @declared_value || 0
      end

      def total_tax
        @total_tax || 0
      end

      def total_shipping_handling
        @total_shipping_handling || 0
      end

      def total_order_amount
        @total_order_amount || 0
      end

      def total_discount
        @total_discount || 0
      end

      def custom_fields
        @custom_fields || []
      end

      def self.response_from_xml(xml)
        success = true, message = '', records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!
        doc.xpath("//order_error").each do |error|
          records << {order_number: error.at('.//order_number').try(:text),
                      error_description: error.at('.//error_description').try(:text)}
                      
        end
        if records.length > 0
          return Response.new(false, '', {data: records})
        end
      end

      def self.to_xml(orders)
        xml_builder = Nokogiri::XML::Builder.new do |xml|
          xml.orders({'xmlns:xsi': "http://www.w3.org/2001/XMLSchema-instance"}) do
            orders.each do |order|
              order.order_to_xml(xml)
            end
          end
        end

        xml_builder.to_xml
      end

      def to_xml
        xml_builder = Nokogiri::XML::Builder.new do |xml|
          xml.orders({'xmlns:xsi': "http://www.w3.org/2001/XMLSchema-instance"}) do
            order_to_xml(xml)
          end
        end

        xml_builder.to_xml
      end

      private

      def order_to_xml(xml)
        xml.order do
          xml.send(:"order-number", normalize(self.order_number, :order_number))
          xml.send(:"order-date", normalize(self.order_date, :date))
          xml.send(:"ship_date", normalize(self.ship_date, :date))
          xml.send(:"ship-method", normalize(self.ship_method, :ship_method))
          xml.send(:"ship_via", normalize(self.ship_via, :ship_via),
                   inject_nil(self.ship_via))
          xml.send(:"drop-ship", normalize(self.drop_ship, :drop_ship),
                   inject_nil(self.drop_ship))
          xml.send(:"special-instructions", normalize(self.special_instructions, :special_instructions),
                   inject_nil(self.special_instructions))
          xml.send(:"special-messaging", normalize(self.special_messaging, :special_messaging),
                   inject_nil(self.special_messaging))
          xml.send(:"invoice-number", normalize(self.invoice_number, :invoice_number),
                   inject_nil(self.invoice_number))
          xml.send(:"declared-value", self.declared_value,
                   inject_nil(self.declared_value))
          xml.send(:"ok-partial-ship", normalize(self.ok_partial_ship, :ok_partial_ship),
                   inject_nil(self.ok_partial_ship))
          xml.send(:"cancel-date", normalize(self.cancel_date, :date),
                   inject_nil(self.cancel_date))
          xml.send(:"total-tax", self.total_tax)
          xml.send(:"total-shipping-handling", self.total_shipping_handling)
          xml.send(:"total-discount", self.total_discount)
          xml.send(:"total-order-amount", self.total_order_amount)
          xml.send(:"po-number", normalize(self.po_number, :po_number),
                   inject_nil(self.po_number))
          xml.send(:"salesman", normalize(self.salesman, :salesman),
                   inject_nil(self.salesman))
          xml.send(:"credit-card-number", normalize(self.credit_card_number, :credit_card_number),
                   inject_nil(self.credit_card_number))
          xml.send(:"credit-card-expiration", normalize(self.credit_card_expiration, :credit_card_expiration),
                   inject_nil(self.credit_card_expiration))
          xml.send(:"ad-code", normalize(self.ad_code, :ad_code),
                   inject_nil(self.ad_code))
          xml.send(:"continuity-flag", normalize(self.continuity_flag, :continuity_flag),
                   inject_nil(self.continuity_flag))
          xml.send(:"freight-terms", normalize(self.freight_terms, :freight_terms),
                   inject_nil(self.freight_terms))
          xml.send(:"department", normalize(self.department, :department),
                   inject_nil(self.department))
          xml.send(:"pay-terms", normalize(self.pay_terms, :pay_terms),
                   inject_nil(self.pay_terms))
          xml.send(:"tax-percent", self.tax_percent,
                   inject_nil(self.tax_percent))
          xml.send(:"asn-qualifier", normalize(self.asn_qualifier, :asn_qualifier),
                   inject_nil(self.asn_qualifier))
          xml.send(:"gift-order-indicator", normalize(self.gift_order_indicator, :gift_order_indicator),
                   inject_nil(self.gift_order_indicator))
          xml.send(:"order-source", normalize(self.order_source, :order_source),
                   inject_nil(self.order_source))
          xml.send(:"promise-date", normalize(self.promise_date, :date),
                   inject_nil(self.promise_date))
          xml.send(:"third-party-account", normalize(self.third_party_account, :third_party_account),
                   inject_nil(self.third_party_account))
          xml.send(:"priority", normalize(self.priority, :priority),
                   inject_nil(self.priority))
          xml.send(:"retail-department", normalize(self.retail_department, :retail_department),
                   inject_nil(self.retail_department))
          xml.send(:"retail-store", normalize(self.retail_store, :retail_store),
                   inject_nil(self.retail_store))
          xml.send(:"retail-vendor", normalize(self.retail_vendor, :retail_vendor),
                   inject_nil(self.retail_vendor))
          xml.send(:"pool", normalize(self.pool, :pool),
                   inject_nil(self.pool))

          add_billing_or_shipping_information(xml, self.billing_information, 'billing')
          add_billing_or_shipping_information(xml, self.shipping_information, 'shipping')

          add_store_information(xml, self.store_information)

          xml.send(:"custom-fields") do
            for i in 1..5
              xml.send(:"custom-field-#{i}", normalize(self.custom_fields[i], :custom_field),
                       inject_nil(self.custom_fields[i]))
            end
          end

          xml.send(:"line-items") do
            Array(self.line_items).each_with_index do |line_item, index|
              add_line_item(xml, line_item, index)
            end
          end

        end
      end

      def add_billing_or_shipping_information(xml, address, pref = 'billing')
        xml.send(:"#{pref}-information") do
          xml.send(:"#{pref}-customer-number", normalize(address.customer_number, :customer_number),
                   inject_nil(address.customer_number))
          xml.send(:"#{pref}-name") do
            xml.cdata normalize(address.name, :name)
          end
          xml.send(:"#{pref}-company", inject_nil(address.company)) do
            xml.cdata normalize(address.company, :company) if address.company
          end
          xml.send(:"#{pref}-address1") do
            xml.cdata normalize(address.address1, :address)
          end
          xml.send(:"#{pref}-address2", inject_nil(address.address2)) do
            xml.cdata normalize(address.address2, :address) if address.address2
          end
          xml.send(:"#{pref}-address3", inject_nil(address.address3)) do
            xml.cdata normalize(address.address3, :address) if address.address3
          end
          xml.send(:"#{pref}-city") do
            xml.cdata normalize(address.city, :city)
          end
          xml.send(:"#{pref}-state", normalize(address.state, :state))
          xml.send(:"#{pref}-zip", normalize(address.zip, :zip))
          xml.send(:"#{pref}-country", normalize(address.country, :country),
                   inject_nil(address.country))
          if pref == 'shipping'
            xml.send(:"#{pref}-iso-country-code", normalize(address.iso_country_code, :country))
          end
          xml.send(:"#{pref}-phone", normalize(address.phone, :phone),
                   inject_nil(address.phone))
          xml.send(:"#{pref}-email", normalize(address.email, :email),
                   inject_nil(address.email))
        end
      end

      def add_store_information(xml, address)
        xml.send(:"store-information") do
          xml.send(:"store-name", inject_nil(address.try(:name))) do
            xml.cdata normalize(address.name, :name) if address.try(:name)
          end
          xml.send(:"store-address1", inject_nil(address.try(:address1))) do
            xml.cdata normalize(address.try(:address1), :address)
          end
          xml.send(:"store-address2", inject_nil(address.try(:address2))) do
            xml.cdata normalize(address.try(:address2), :address)
          end
          xml.send(:"store-city", inject_nil(address.try(:city))) do
            xml.cdata normalize(address.try(:city), :address)
          end
          xml.send(:"store-state", normalize(address.try(:state), :state),
                   inject_nil(address.try(:state)))
          xml.send(:"store-zip", normalize(address.try(:zip), :zip),
                   inject_nil(address.try(:zip)))
          xml.send(:"store-country", normalize(address.try(:country), :country),
                   inject_nil(address.try(:country)))
          xml.send(:"store-phone", normalize(address.try(:phone), :phone),
                   inject_nil(address.try(:phone)))
        end
      end

      def add_line_item(xml, line_item, index)
        xml.send(:"line-item") do
          xml.send(:"sku", normalize(line_item.sku, :sku))
          xml.send(:"quantity", line_item.quantity)
          xml.send(:"tax", line_item.tax)
          xml.send(:"price", line_item.price)
          xml.send(:"shipping-handling", line_item.shipping_handling)
          xml.send(:"client-item", normalize(line_item.client_item, :client_item),
                   inject_nil(line_item.client_item))
          xml.send(:"line-number", normalize(line_item.line_number, :line_number))
          xml.send(:"gift-box-wrap-quantity", line_item.gift_box_wrap_quantity,
                   inject_nil(line_item.gift_box_wrap_quantity))
          xml.send(:"gift-box-wrap-type", normalize(line_item.gift_box_wrap_type, :gift_box_wrap_type),
                   inject_nil(line_item.gift_box_wrap_type))
          xml.send(:"HS_code", normalize(line_item.hs_code, :hs_code),
                   inject_nil(line_item.hs_code))
        end
      end
    end

    class LineItem
      include Model

      attr_accessor :sku,
                    :quantity,
                    :price,
                    :tax,
                    :shipping_handling,
                    :client_item,
                    :line_number,
                    :gift_box_wrap_quantity,
                    :gift_box_wrap_type,
                    :hs_code

      def price
        @price || 0
      end

      def tax
        @tax || 0
      end

      def shipping_handling
        @shipping_handling || 0
      end
    end

    class Address
      include Model
      attr_accessor :customer_number,
                    :name,
                    :company,
                    :address1,
                    :address2,
                    :address3,
                    :city,
                    :state,
                    :zip,
                    :country,
                    :iso_country_code,
                    :phone,
                    :email
    end

  end
end
