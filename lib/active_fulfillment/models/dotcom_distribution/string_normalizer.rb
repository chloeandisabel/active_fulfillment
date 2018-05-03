module ActiveFulfillment
  module DotcomDistribution

    # Takes care of removing non-ASCII characters and enforcing max lengths.
    module StringNormalizer

      MAX_LENGTHS = {
        # Common
        sku: 17,

        # Purchase Orders
        description: 30,
        long_description: 50,
        serial_indicator: 1,
        client_company: 5,
        client_department: 5,
        client_product_class: 4,
        client_product_type: 4,
        item_barcode: 24,
        country_of_origin: 2,
        harmonized_code: 10,
        manufacturing_code: 10,
        style_number: 10,
        short_name: 15,
        color: 5,
        size: 5,

        # Orders
        order_number: 20,
        date: 10,
        customer_number: 19,
        name: 30,
        address: 30,            # address{1-3}
        city: 20,
        state: 2,
        zip: 10,
        country: 2,
        phone: 19,
        email: 50,
        ship_method: 4,
        special_instructions: 40,
        special_messaging: 250,
        drop_ship: 1,
        invoice_number: 13,
        ok_partial_ship: 1,
        po_number: 20,
        salesman: 20,
        credit_card_number: 32,
        credit_card_expiration: 4,
        ad_code: 5,
        continuity_flag: 1,
        custom_field: 50,       # custom_field{1-5}
        client_item: 20,
        ship_via: 20,
        freight_terms: 20,
        department: 5,
        pay_terms: 5,
        line_number: 10,
        asn_qualifier: 5,
        gift_order_indicator: 1,
        order_source: 8,
        company: 30,
        third_party_account: 25,
        priority: 5,
        gift_box_wrap_type: 4,
        hs_code: 10
      }

      # Given a possibly non-nil string, remove non-ASCII characters and
      # enforce max length based on +field_name+.
      def normalize(s, field_name=nil)
        return nil if s.nil?

        # Remove non-ASCII before truncating
        s = s.to_s.dup.encode(Encoding.find("ASCII"),
                              invalid: :replace,
                              undef: :replace,
                              replace: '')
        max_len = MAX_LENGTHS[field_name]
        s = s[0, max_len] if max_len
        s
      end
    end
  end
end
