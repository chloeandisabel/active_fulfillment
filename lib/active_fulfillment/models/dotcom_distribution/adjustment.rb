module ActiveFulfillment
  module DotcomDistribution

    class Adjustment
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
                    :transaction_desc,
                    :transaction_type, # webhook adjustment attribute
                    :transaction_time  # ditty


      def self.response_from_xml(xml)
        success = true, message = '', records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!
        doc.xpath("//response//adjustments//adjustment").each do |el|
          records << Adjustment.new({adjustment_code: el.at('.//adjustment_code').try(:text),
                                     adjustment_desc: el.at('.//adjustment_desc').try(:text),
                                     dcd_identifier: el.at('.//dcd_identifier').try(:text),
                                     old_stock_status_code: el.at('.//old_stock_status_code').try(:text),
                                     old_stock_status_desc: el.at('.//old_stock_status_desc').try(:text),
                                     quantity: el.at('.//quantity').try(:text),
                                     sku: el.at('.//sku').try(:text),
                                     stock_status_code: el.at('.//stock_status_code').try(:text),
                                     stock_status_desc: el.at('.//stock_status_desc').try(:text),
                                     transaction_code: el.at('.//transaction_code').try(:text),
                                     transaction_datetime: el.at('.//transaction_datetime').try(:text),
                                     transaction_desc: el.at('.//transaction_desc').try(:text),
                                     transaction_type: el.attributes['transaction_type'].try(:text),
                                     transaction_time: el.attributes['transaction_time'].try(:text)})
        end
        Response.new(true, '', {data: records})
      end
    end

  end
end
