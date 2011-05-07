module Jekyll
  class TagCloud < Liquid::Tag
    safe = true
    
    def render(context)
      tags = context.registers[:site].tags.map{|tag| 
        { 
          :tag    => tag[0], 
          :posts  => tag[1] 
        } 
      }

      min_count = tags.min{|a, b| a[:posts].length <=> b[:posts].length }[:posts].length
      max_count = tags.max{|a, b| a[:posts].length <=> b[:posts].length }[:posts].length

      weights = tags.inject({}){|result, tag| result[tag[:tag]] = ( ((tag[:posts].length - min_count) * (280 - 75)) / (max_count - min_count) ) + 75; result }

      tags.inject("") { |html, tag|
        html << "<span style=\"font-size: #{sprintf("%d", weights[tag[:tag]])}%\"><a href=\"/tags/#{tag[:tag]}/\" rel=\"tag\">#{tag[:tag]}</a></span>\n"
        html
      }
    end
  end
end

Liquid::Template.register_tag('tag_cloud', Jekyll::TagCloud)
