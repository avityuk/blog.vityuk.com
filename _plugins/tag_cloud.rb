module Jekyll
  class TagCloudTag < Liquid::Tag
    safe = true
    
    def initialize(tag_name, text, tokens)
      super
    end

    def render(context)
      html = ""
      tags = context.registers[:site].tags
      avg = tags.inject(0.0) {|memo, tag| memo += tag[1].length} / tags.length
      weights = Hash.new
      tags.each {|tag| weights[tag[0]] = tag[1].length/avg}
      tag_names = tags.keys.sort
      tag_names.each do |tag|
        html << "<span style=\"font-size: #{sprintf("%d", weights[tag] * 100)}%\"><a href=\"/tags/#{tag.gsub(/\s/, "-").gsub(/[^\w-]/, '').downcase}/\">#{tag}</a></span>\n"
      end
      html
    end
  end
end

Liquid::Template.register_tag('tag_cloud', Jekyll::TagCloudTag)
