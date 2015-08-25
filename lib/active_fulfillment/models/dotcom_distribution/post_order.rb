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

      validates_format_of :ship_date, with: DATE_REGEX
      validates_format_of :cancel_date, with: DATE_REGEX, allow_blank: true
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

      def inject_nil(v)
        v ? {} : {'xsi:nil': 'true'}
      end

      def self.response_from_xml(xml)
        success = true, message = '', hash = {}, records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!

        doc.xpath("//order_error").each do |error|
          hash[:error_description] = error.at('.//error_description').try(:text)
          hash[:order_number] = error.at('.//order_number').try(:text)

          records << hash
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
          xml.send(:"order-number", self.order_number)
          xml.send(:"order-date", self.order_date)
          xml.send(:"ship_date", self.ship_date, inject_nil(self.ship_date))
          xml.send(:"ship-method", self.ship_method)
          xml.send(:"ship_via", self.ship_via, inject_nil(self.ship_via))
          xml.send(:"drop-ship", self.drop_ship, inject_nil(self.drop_ship))
          xml.send(:"special-instructions", self.special_instructions, inject_nil(self.special_instructions))
          xml.send(:"special-messaging", self.special_messaging, inject_nil(self.special_messaging))
          xml.send(:"invoice-number", self.invoice_number, inject_nil(self.invoice_number))
          xml.send(:"declared-value", self.declared_value, inject_nil(self.declared_value))
          xml.send(:"ok-partial-ship", self.ok_partial_ship, inject_nil(self.ok_partial_ship))
          xml.send(:"cancel-date", self.cancel_date, inject_nil(self.declared_value))
          xml.send(:"total-tax", self.total_tax)
          xml.send(:"total-shipping-handling", self.total_shipping_handling)
          xml.send(:"total-discount", self.total_discount)
          xml.send(:"total-order-amount", self.total_order_amount)
          xml.send(:"po-number", self.po_number, inject_nil(self.po_number))
          xml.send(:"salesman", self.salesman, inject_nil(self.salesman))
          xml.send(:"credit-card-number", self.credit_card_number, inject_nil(self.credit_card_number))
          xml.send(:"credit-card-expiration", self.credit_card_expiration, inject_nil(self.credit_card_expiration))
          xml.send(:"ad-code", self.ad_code, inject_nil(self.ad_code))
          xml.send(:"continuity-flag", self.continuity_flag, inject_nil(self.continuity_flag))
          xml.send(:"freight-terms", self.freight_terms, inject_nil(self.freight_terms))
          xml.send(:"department", self.department, inject_nil(self.department))
          xml.send(:"pay-terms", self.pay_terms, inject_nil(self.pay_terms))
          xml.send(:"tax-percent", self.tax_percent, inject_nil(self.tax_percent))
          xml.send(:"asn-qualifier", self.asn_qualifier, inject_nil(self.asn_qualifier))
          xml.send(:"gift-order-indicator", self.gift_order_indicator, inject_nil(self.gift_order_indicator))
          xml.send(:"order-source", self.order_source, inject_nil(self.order_source))
          xml.send(:"promise-date", self.promise_date, inject_nil(self.promise_date))
          xml.send(:"third-party-account", self.third_party_account, inject_nil(self.third_party_account))
          xml.send(:"priority", self.priority, inject_nil(self.priority))
          xml.send(:"retail-department", self.retail_department, inject_nil(self.retail_department))
          xml.send(:"retail-store", self.retail_store, inject_nil(self.retail_store))
          xml.send(:"retail-vendor", self.retail_vendor, inject_nil(self.retail_vendor))
          xml.send(:"pool", self.pool, inject_nil(self.pool))

          add_billing_or_shipping_information(xml, self.billing_information, 'billing')
          add_billing_or_shipping_information(xml, self.shipping_information, 'shipping')

          add_store_information(xml, self.store_information)

          xml.send(:"custom-fields") do
            for i in 1..5
              xml.send(:"custom-field-#{i}", self.custom_fields[i], inject_nil(self.custom_fields[i]))
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
          xml.send(:"#{pref}-customer-number", address.customer_number, inject_nil(address.customer_number))
          xml.send(:"#{pref}-name") do
            xml.cdata address.name
          end
          xml.send(:"#{pref}-company", inject_nil(address.company)) do
            xml.cdata address.company if address.company
          end
          xml.send(:"#{pref}-address1") do
            xml.cdata address.address1
          end
          xml.send(:"#{pref}-address2", inject_nil(address.address2)) do
            xml.cdata address.address2 if address.address2
          end
          xml.send(:"#{pref}-address3", inject_nil(address.address3)) do
            xml.cdata address.address3 if address.address3
          end
          xml.send(:"#{pref}-city") do
            xml.cdata address.city
          end
          xml.send(:"#{pref}-state", address.state)
          xml.send(:"#{pref}-zip", address.zip)
          xml.send(:"#{pref}-country", address.country, inject_nil(address.country))
          xml.send(:"#{pref}-iso-country-code", address.iso_country_code) if pref == 'shipping'
          xml.send(:"#{pref}-phone", address.phone, inject_nil(address.phone))
          xml.send(:"#{pref}-email", address.email, inject_nil(address.email))
        end
      end

      def add_store_information(xml, address)
        xml.send(:"store-information") do
          xml.send(:"store-name", inject_nil(address.try(:name))) do
            xml.cdata address.name if address.try(:name)
          end
          xml.send(:"store-address1", inject_nil(address.try(:address1))) do
            xml.cdata address.try(:address1)
          end
          xml.send(:"store-address2", inject_nil(address.try(:address2))) do
            xml.cdata address.try(:address2)
          end
          xml.send(:"store-city", inject_nil(address.try(:city))) do
            xml.cdata address.try(:city)
          end
          xml.send(:"store-state", address.try(:state), inject_nil(address.try(:state)))
          xml.send(:"store-zip", address.try(:zip), inject_nil(address.try(:zip)))
          xml.send(:"store-country", address.try(:country), inject_nil(address.try(:country)))
          xml.send(:"store-phone", address.try(:phone), inject_nil(address.try(:phone)))
        end
      end

      def add_line_item(xml, line_item, index)
        xml.send(:"line-item") do
          xml.send(:"sku", line_item.sku)
          xml.send(:"quantity", line_item.quantity)
          xml.send(:"tax", line_item.tax)
          xml.send(:"price", line_item.price)
          xml.send(:"shipping-handling", line_item.shipping_handling)
          xml.send(:"client-item", line_item.client_item, inject_nil(line_item.client_item))
          xml.send(:"line-number", line_item.line_number)
          xml.send(:"gift-box-wrap-quantity", line_item.gift_box_wrap_quantity, inject_nil(line_item.gift_box_wrap_quantity))
          xml.send(:"gift-box-wrap-type", line_item.gift_box_wrap_type, inject_nil(line_item.gift_box_wrap_type))
        end
      end
    end

    class LineItem
      include ::ActiveModel::Model
      include ::ActiveModel::Validations

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
    end

    class Address
      include ::ActiveModel::Model
      include ::ActiveModel::Validations

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
    end

  end
end
