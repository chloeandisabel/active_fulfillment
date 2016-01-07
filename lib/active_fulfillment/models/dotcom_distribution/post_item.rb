require_relative 'nil_injector'
require_relative 'string_normalizer'

module ActiveFulfillment
  module DotcomDistribution

    class PostItem
      include Model
      include ::ActiveFulfillment::DotcomDistribution::NilInjector
      include ::ActiveFulfillment::DotcomDistribution::StringNormalizer

      attr_accessor :sku,
                    :description,
                    :long_description,
                    :upc,
                    :weight,
                    :cost,
                    :price,
                    :root_sku,
                    :package_qty,
                    :serial_indicator,
                    :client_company,
                    :client_department,
                    :client_product_class,
                    :client_product_type,
                    :avg_cost,
                    :master_pack,
                    :item_barcode,
                    :country_of_origin,
                    :harmonized_code,
                    :manufacturing_code,
                    :quantity,
                    :style_number,
                    :short_name,
                    :color,
                    :size

      def self.response_from_xml(xml)
        success = true, message = '', records = []
        doc = Nokogiri.XML(xml)
        doc.remove_namespaces!
        doc.xpath("//item_error").each do |error|
          records << {sku: error.at('.//sku').try(:text),
                      error_description: error.at('.//error_description').try(:text)}
        end
        if records.length > 0
          return Response.new(false, '', {data: records})
        end
      end

      def self.to_xml(items)
        xml_builder = Nokogiri::XML::Builder.new do |xml|
          xml.items({'xmlns:xsi': "http://www.w3.org/2001/XMLSchema-instance"}) do
            items.each do |item|
              item = PostItem.new(item) unless item.instance_of?(self)
              item.item_to_xml(xml)
            end
          end
        end

        xml_builder.to_xml
      end

      # Returns complete XML document containing a single item. To send a
      # list of items, use the class method PostItem.to_xml.
      def to_xml
        xml_builder = Nokogiri::XML::Builder.new do |xml|
          xml.items({'xmlns:xsi': "http://www.w3.org/2001/XMLSchema-instance"}) do
            item_to_xml(xml)
          end
        end

        xml_builder.to_xml
      end

      def item_to_xml(xml)
        xml.item do
          xml.send(:"sku", normalize(self.sku, :sku))
          xml.send(:"description") do
            xml.cdata normalize(self.description, :description)
          end
          if quantity
            xml.send(:"quantity", self.quantity)
          end
          xml.send(:"weight", self.weight,
                   inject_nil(self.weight))
          xml.send(:"cost", self.cost,
                   inject_nil(self.cost))
          xml.send(:"upc", self.upc,
                   inject_nil(self.upc))
          xml.send(:"price", self.price,
                   inject_nil(self.price))
          xml.send(:"root-sku", normalize(self.root_sku, :sku),
                   inject_nil(self.root_sku))
          xml.send(:"package-qty", self.package_qty,
                   inject_nil(self.package_qty))
          xml.send(:"serial-indicator", normalize(self.serial_indicator, :serial_indicator),
                   inject_nil(self.package_qty))
          xml.send(:"client-company", normalize(self.client_company, :client_company),
                   inject_nil(self.client_company))
          xml.send(:"client-department", normalize(self.client_department, :client_department),
                   inject_nil(self.client_department))
          xml.send(:"client-product-class", normalize(self.client_product_class, :client_product_class),
                   inject_nil(self.client_product_class))
          xml.send(:"client-product-type", normalize(self.client_product_type, :client_product_type),
                   inject_nil(self.client_product_type))
          xml.send(:"avg-cost", self.avg_cost,
                   inject_nil(self.avg_cost))
          xml.send(:"master-pack", self.master_pack,
                   inject_nil(self.master_pack))
          xml.send(:"item-barcode", normalize(self.item_barcode, :item_barcode),
                   inject_nil(self.item_barcode))
          xml.send(:"country-of-origin", normalize(self.country_of_origin, :country_of_origin),
                   inject_nil(self.country_of_origin))
          xml.send(:"harmonized-code", normalize(self.harmonized_code, :harmonized_code),
                   inject_nil(self.harmonized_code))
          xml.send(:"manufacturing-code", normalize(self.manufacturing_code, :manufacturing_code),
                   inject_nil(self.manufacturing_code))
          xml.send(:"style-number", normalize(self.style_number, :style_number),
                   inject_nil(self.style_number))
          xml.send(:"short-name", normalize(self.short_name, :short_name),
                   inject_nil(self.short_name))
          xml.send(:"color", normalize(self.color, :color),
                   inject_nil(self.color))
          xml.send(:"size", normalize(self.size, :size),
                   inject_nil(self.size))
          xml.send(:"long-description", inject_nil(self.long_description)) do
            xml.cdata normalize(self.long_description, :long_description) if self.long_description
          end
        end
      end
    end
  end
end
