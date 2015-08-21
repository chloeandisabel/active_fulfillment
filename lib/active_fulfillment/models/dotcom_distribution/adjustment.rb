module ActiveFulfillment
  module DotcomDistribution

    class Adjustment

      include ::ActiveModel::Model
      include ::ActiveModel::Serializers::Xml

      attr_accessor :adjustment_code,
                    :adjustment_desc,
                    :dcd_identifier,
                    :old_stock_status_code,
                    :old_stock_status_desc,
                    :quantity,
                    :sku,
                    :stock_status_code,
                    :stock_status_desc,
                    :transaction_code,
                    :transaction_datetime,
                    :transaction_desc


      def self.response_from_xml(xml)
        success = true, message = '', hash = {}, records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!

        doc.xpath("//item").each do |el|
          hash[:adjustment_code] = el.at('.//adjustment_code').try(:text)
          hash[:adjustment_desc] = el.at('.//adjustment_desc').try(:text)
          hash[:dcd_identifier] = el.at('.//dcd_identifier').try(:text)
          hash[:old_stock_status_code] = el.at('.//old_stock_status_code').try(:text)
          hash[:old_stock_status_desc] = el.at('.//old_stock_status_desc').try(:text)
          hash[:quantity] = el.at('.//quantity').try(:text)
          hash[:sku] = el.at('.//sku').try(:text)
          hash[:stock_status_code] = el.at('.//stock_status_code').try(:text)
          hash[:stock_status_desc] = el.at('.//stock_status_desc').try(:text)
          hash[:transaction_code] = el.at('.//transaction_code').try(:text)
          hash[:transaction_datetime] = el.at('.//transaction_datetime').try(:text)
          hash[:transaction_desc] = el.at('.//transaction_desc').try(:text)

          records << Adjustment.new(hash)
        end

        Response.new(true, '', {data: records})
      end
    end

  end
end
