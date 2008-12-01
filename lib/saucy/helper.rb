module Saucy
  module Helper
     
    def transparent_png(filename, options = {})
      saucy_png_tag( filename, "div", "", options, true)
    end

    def saucy_png_tag( filename, name, content, options, transparent)
      size = Saucy::Image.get_png_size(filename)
     
      src = "'#{filename}'"
      css = "background:url(#{src}) no-repeat; width: #{size[0]}px; height: #{size[1]}px;"

      if(transparent)
        css += "_background: transparent; _filter:progid:DXImageTransform.Microsoft.AlphaImageLoader(src=#{src}, sizingMethod='crop');"
      end

      options[:style] = css + (options[:style] || "")

      content_tag_string(name, content, options)
    end

    def saucy_tag(name, content, style={}, options = {})
      key = Digest::MD5.hexdigest(style.to_s)
      filename = File.join(OUTPUT_DIR, content.gsub(/[^a-z0-9]+/i, '-') + "_#{key}.png")
      
      unless Rails.cache.read("saucy:" + filename)
        Saucy::Render.saucy_render(content, style, filename)
      end
      

    end
    
    # Arguments:
    # saucy_tag(name, :option1 => 'foo')
    # saucy_tag(name1, name2, :option2 => 'foo', :hover => {:color => 'blue'})
    
    def saucy_tag(*args)
      options   = args.extract_options!
      texts     = args
      filename  = [
          texts.collect(&:underscore), 
          Digest::MD5.hexdigest(options.to_s)
      ].flatten.join('_')
      
      unless File.exists?(File.join(AB_OUTPUT_DIR, filename))
         Saucy::Render.render(texts, options)
      end
      
      style ||= {}
      style['text-indent'] = '-5000px;'
      
      
      trans = !style.has_key?('background') || style['background'] == "transparent"
      
      # todo - draw tag
    end

  end
end
