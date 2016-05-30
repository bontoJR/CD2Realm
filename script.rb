require 'rubygems'
require 'nokogiri'
require 'erubis'
require 'fileutils'

def mapAttributeType(attributeType)
    case attributeType
        when "Boolean"
            return "Bool"
        when "Integer 16"
            return "Int16"
        when "Integer 32"
            return "Int32"
        when "Integer 64"
            return "Int64"
        when "Decimal"
            return "Double"
        when "Double"
            return "Double"
        when "Float"
            return "Float"
        when "Date"
            return "NSDate"
        when "Binary"
            return "NSData"
        when "Transformable"
            return "NSData"
        when "String"
            return "String"
        else
            return "Undefined"
    end
end

File.open(ARGV[0]) do |f|
    xml_doc = Nokogiri::XML::Document.parse(f)
    elements = Array.new # all the elements here
    
    xml_doc.css("elements element").each do |element|
        input = File.read('template.eruby')
        eruby = Erubis::Eruby.new(input)
        
        # entity definitions
        entity = element['name']
        properties = Array.new
        relationships = Array.new

        # get attributes for entity
        attributes = xml_doc.css("entity[name='#{entity}'] attribute")
        attributes.each do |attribute|
            
            name = attribute['name']
            attribute_type = mapAttributeType(attribute['attributeType'])
            default_value = 'nil'

            if attribute['optional'] == 'YES'
                attribute_type << '?'
                if attribute['defaultValueString'] != nil
                    default_value = attribute['defaultValueString']
                end
            end

            # property hash MUST have the following keys: 
            # name, type, default_value
            property = Hash.new
            property[:name] = name
            property[:type] = attribute_type
            property[:default_value] = default_value

            properties.push(property)
        end

        # relationships
        rels = xml_doc.css("entity[name='#{entity}'] relationship")
        rels.each do |rel|

            if rel['toMany'] == 'YES'
                relationships.push("let #{rel['name']} = List<#{rel['destinationEntity']}>()")
            else
                relationships.push("dynamic var #{rel['name']}: #{rel['destinationEntity']}?")
            end
            
        end 
        
        current_path = File.expand_path(File.dirname(__FILE__))
        output_path = current_path << "/output"
        FileUtils.mkdir_p(output_path)

        output_file = output_path << "/#{entity}.swift"
        output_text = eruby.result(:class_name => entity, :properties => properties, :relationships => relationships)
        File.open(output_file, 'w') { |file| file.write(output_text) }
    end
    
    f.close 
end