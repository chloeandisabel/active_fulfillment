# -*- coding: utf-8 -*-
module ActiveFulfillment
  module DotcomDistribution

    # = Dotcom ActiveFulfillment Order
    #
    # This is the shipment request sent to us based on your customer’s order
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

      include ::ActiveModel::Model
      include ::ActiveModel::Validations
      include ::ActiveModel::Serializers::Xml

      include XMLHelper

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

      # Date expected in format yyyy-mm-dd
      DATE_REGEX = /\d{4}-\d{2}-\d{2}/

      validates_format_of :ship_date, :order_date, with: DATE_REGEX
      validates_format_of :cancel_date, with: DATE_REGEX, allow_nil: true
      validates_format_of :credit_card_expiration, with: /\d{2}\d{2}/, allow_nil: true

      validates_length_of :order_number, :in => 1..20, allow_blank: false
      validates_length_of :ship_via, maximum: 20, allow_blank: true
      validates_length_of :drop_ship, maximum: 1, allow_blank: true
      validates_length_of :pool, maximum: 24, allow_blank: true
      validates_length_of :ok_partial_ship, maximum: 1, allow_blank: true
      validates_length_of :special_instructions, maximum: 40, allow_blank: true
      validates_length_of :special_messaging,  maximum: 250, allow_blank: true
      validates_length_of :po_number, maximum: 20, allow_blank: true
      validates_length_of :salesman, maximum: 20, allow_blank: true
      validates_length_of :credit_card_number, maximum: 32, allow_blank: true
      validates_length_of :credit_card_expiration, maximum: 4, allow_blank: true
      validates_length_of :ad_code, maximum: 5, allow_blank: true
      validates_length_of :continuity_flag, maximum: 1, allow_blank: true
      validates_length_of :freight_terms, maximum: 20, allow_blank: true
      validates_length_of :department, maximum: 5, allow_blank: true
      validates_length_of :pay_terms, maximum: 5, allow_blank: true
      validates_length_of :asn_qualifier, maximum: 5, allow_blank: true
      validates_length_of :order_source, maximum: 8, allow_blank: true
      validates_length_of :third_party_account, maximum: 25, allow_blank: true
      validates_length_of :priority, maximum: 5, allow_blank: true
      validates_length_of :retail_department, maximum: 10, allow_blank: true
      validates_length_of :retail_store, maximum: 10, allow_blank: true
      validates_length_of :retail_vendor, maximum: 10, allow_blank: true

      validates_inclusion_of :ship_method, in: :shipping_methods
      validates_inclusion_of :gift_order_indicator, in: %w(Y N), allow_blank: true

      validates_numericality_of :tax_percent, greater_than_or_equal_to: 0, less_than: 100, allow_nil: true
      validates_numericality_of :total_tax, :total_shipping_handling, :total_order_amount, greater_than_or_equal_to: 0
      validates_numericality_of :declared_value, less_than_or_equal_to: 99999999.99, allow_nil: true
      validates_numericality_of :invoice_number, only_integer: true, less_than: 4294967296, allow_nil: true
      validates_numericality_of :total_discount, greater_than_or_equal_to: 0, less_than: 100.00, allow_nil: true

      class LineItemValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          if record.line_items
            record.line_items.each do |li|
              record.errors[:line_items] << li.errors unless li.valid?
            end
          end
        end
      end

      class BillingInformationValidator < ActiveModel::EachValidator
        def validate_each(record, attribute, value)
          if record.billing_information
            unless record.billing_information.valid?
              record.errors[:billing_information] << record.billing_information.errors
            end
          end
        end
      end

      validates_presence_of :line_items, :billing_information
      validates :line_items, line_item: true
      validates :billing_information, billing_information: true

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
        success = true, message = '', hash = {}, records = []
        doc = REXML::Document.new(xml)

        REXML::XPath.each(doc, "//a:order_error", {"a" => "http://schemas.datacontract.org/2004/07/DCDAPIService"}) do |error|
          hash[:error_description] = error.elements["//a:error_description"].try(:text)
          hash[:order_number] = error.elements["//a:order_number"].try(:text)

          records << hash
        end
        if records.length > 0
          return Response.new(false, '', {data: records})
        end
      end

      def self.to_xml(orders)
        doc = REXML::Document.new
        doc.add_element("orders", {"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance"})
        (orders || []).each do |order|
          doc.root.elements << order.to_rexml
        end
        doc.to_s
      end

      def to_xml
        doc = REXML::Document.new
        doc.add_element("orders", {"xmlns:xsi" => "http://www.w3.org/2001/XMLSchema-instance"})
        doc.root.elements << to_rexml

        doc.to_s
      end

      def to_rexml
        order = REXML::Element.new("order")
        order.add_element("order-number").text = order_number
        order.add_element("order-date").text = order_date
        order.add_element("ship-date").text = ship_date
        order.add_element("ship-method").text = ship_method
        order.add_element("ship-via", inject_nil(ship_via)).text = ship_via
        order.add_element("drop-ship", inject_nil(drop_ship)).text = drop_ship
        order.add_element("special-instructions", inject_nil(special_instructions)).text = special_instructions
        order.add_element("special-messaging", inject_nil(special_messaging)).text = special_messaging
        order.add_element("invoice-number", inject_nil(invoice_number)).text = invoice_number
        order.add_element("declared-value", inject_nil(declared_value)).text = declared_value
        order.add_element("ok-partial-ship", inject_nil(ok_partial_ship)).text = ok_partial_ship
        order.add_element("cancel-date", inject_nil(cancel_date)).text = cancel_date
        order.add_element("total-tax").text = total_tax
        order.add_element("total-shipping-handling").text = total_shipping_handling
        order.add_element("total-discount").text = total_discount
        order.add_element("total-order-amount").text = total_order_amount
        order.add_element("po-number", inject_nil(po_number)).text = po_number
        order.add_element("salesman", inject_nil(salesman)).text = salesman
        order.add_element("credit-card-number", inject_nil(credit_card_number)).text = credit_card_number
        order.add_element("credit-card-expiration", inject_nil(credit_card_expiration)).text = credit_card_expiration
        order.add_element("ad-code", inject_nil(ad_code)).text = ad_code
        order.add_element("continuity-flag", inject_nil(continuity_flag)).text = continuity_flag
        order.add_element("freight-terms", inject_nil(freight_terms)).text = freight_terms
        order.add_element("department", inject_nil(department)).text = department
        order.add_element("pay-terms", inject_nil(pay_terms)).text = pay_terms
        order.add_element("tax-percent", inject_nil(tax_percent)).text = tax_percent
        order.add_element("asn-qualifier", inject_nil(asn_qualifier)).text = asn_qualifier
        order.add_element("gift-order-indicator", inject_nil(gift_order_indicator)).text = gift_order_indicator
        order.add_element("order-source", inject_nil(order_source)).text = order_source
        order.add_element("promise-date", inject_nil(promise_date)).text = promise_date
        order.add_element("third-party-account", inject_nil(third_party_account)).text = third_party_account
        order.add_element("priority", inject_nil(priority)).text = priority
        order.add_element("retail-department", inject_nil(retail_department)).text = retail_department
        order.add_element("retail-store", inject_nil(retail_store)).text = retail_store
        order.add_element("retail-vendor", inject_nil(retail_vendor)).text = retail_vendor
        order.add_element("pool", inject_nil(pool)).text = pool

        custom_fields = order.add_element("custom-fields")
        1.upto(5) do |i|
          field = custom_fields.add_element("custom-field-#{i}", inject_nil(custom_fields[i]))
          field.text = custom_fields[i]
        end

        order.elements << billing_information.to_rexml("billing")
        order.elements << shipping_information.to_rexml("shipping")

        # TODO: ideally this will be like this instead of using add_store_information
        # order.add_element("store-information").elements << store_information.to_rexml
        add_store_information(order, self.store_information)

        line_items_el = order.add_element("line-items")
        Array(line_items).each do |li|
          line_items_el.elements << li.to_rexml
        end

        order
      end

      private

      def add_store_information(order, address)
        si = REXML::Element.new("store-information")
        store_name = si.add_element("store-name", inject_nil(address.try(:name)))
        store_name.text = REXML::CData.new(address.name) if address.try(:name)
        store_addr1 = si.add_element("store-address1", inject_nil(address.try(:address1)))
        store_addr1.text = REXML::CData.new(address.address1) if address.try(:address1)
        store_addr2 = si.add_element("store-address2", inject_nil(address.try(:address2)))
        store_addr2.text = REXML::CData.new(address.address2) if address.try(:address2)
        store_city = si.add_element("store-city", inject_nil(address.try(:city)))
        story_city.text = REXML::CData.new(address.city) if address.try(:city)


        si.add_element("store-state", inject_nil(address.try(:state))).text = address.try(:state)
        si.add_element("store-zip", inject_nil(address.try(:zip))).text = address.try(:zip)
        si.add_element("store-country", inject_nil(address.try(:country))).text = address.try(:country)
        si.add_element("store-phone", inject_nil(address.try(:phone))).text = address.try(:phone)
        order.elements << si
      end
    end

    class LineItem
      include ::ActiveModel::Model
      include ::ActiveModel::Validations

      include XMLHelper

      attr_accessor :sku,
                    :quantity,
                    :price,
                    :tax,
                    :shipping_handling,
                    :client_item,
                    :line_number,
                    :gift_box_wrap_quantity,
                    :gift_box_wrap_type

      # required arguments
      validates_length_of :sku, maximum: 17, allow_blank: false
      validates_length_of :line_number, maximum: 20, allow_blank: true
      validates_length_of :client_item, maximum: 20, allow_blank: true
      validates_numericality_of :quantity, only_integer: true, greater_than: 0
      validates_numericality_of :tax, :price, greater_than_or_equal_to: 0,
        less_than_or_equal_to: 99999.99
      validates_numericality_of :shipping_handling, greater_than_or_equal_to: 0,
        less_than_or_equal_to: 999999.99

      validates_numericality_of :gift_box_wrap_quantity, only_integer: true, greater_than: 0, less_than_or_equal_to: 9999999999, allow_nil: true
      validates_numericality_of :gift_box_wrap_type, only_integer: true, greater_than: 0, less_than_or_equal_to: 9999, allow_nil: true
      validates_numericality_of :line_number, only_integer: true, greater_than: 0, allow_nil: true

      def price
        @price || 0
      end

      def tax
        @tax || 0
      end

      def shipping_handling
        @shipping_handling || 0
      end

      def to_rexml
        el = REXML::Element.new("line-item")
        el.add_element("sku").text = sku
        el.add_element("quantity").text = quantity

        el.add_element("tax").text = tax
        el.add_element("price").text = price
        el.add_element("shipping-handling").text = shipping_handling
        el.add_element("client-item", inject_nil(client_item)).text = client_item
        el.add_element("line-number").text = line_number
        el.add_element("gift-box-wrap-quantity", inject_nil(gift_box_wrap_quantity)).text = gift_box_wrap_quantity
        el.add_element("gift-box-wrap-type", inject_nil(gift_box_wrap_type)).text = gift_box_wrap_type
        el
      end
    end

    class Address
      include ::ActiveModel::Model
      include ::ActiveModel::Validations

      include XMLHelper

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

      # required arguments
      validates_length_of :name, :address1, maximum: 30, allow_blank: false
      validates_length_of :city, maximum: 20, allow_blank: false
      validates_length_of :state, maximum: 2, allow_blank: false
      validates_length_of :zip, maximum: 10, allow_blank: false

      validates_length_of :customer_number, maximum: 19, allow_blank: true
      validates_length_of :address2, :address3, maximum: 30, allow_blank: true
      validates_length_of :country, maximum: 2, allow_blank: true
      validates :phone, presence: true, length: {maximum: 19}, if: -> { country.present? }

      def to_rexml(prefix)
        el = REXML::Element.new("#{prefix}-information")
        el.add_element("#{prefix}-customer-number", inject_nil(customer_number)).text = customer_number
        el.add_element("#{prefix}-name").text = REXML::CData.new(name)
        c_el = el.add_element("#{prefix}-company", inject_nil(company))
        c_el.text = REXML::CData.new(company) if company
        el.add_element("#{prefix}-address1").text = REXML::CData.new(address1)
        ad2 = el.add_element("#{prefix}-address2", inject_nil(address2))
        ad2.text = REXML::CData.new(address2) if address2
        ad3 = el.add_element("#{prefix}-address3", inject_nil(address3))
        ad3.text = REXML::CData.new(address3) if address3
        el.add_element("#{prefix}-city").text = REXML::CData.new(city)
        el.add_element("#{prefix}-state").text = state
        el.add_element("#{prefix}-zip").text = zip
        el.add_element("#{prefix}-country", inject_nil(country)).text = country
        if prefix == "shipping"
          el.add_element("#{prefix}-iso-country-code").text = iso_country_code
        end
        el.add_element("#{prefix}-phone", inject_nil(phone)).text = phone
        el.add_element("#{prefix}-email", inject_nil(email)).text = email
        el
      end
    end

  end
end
