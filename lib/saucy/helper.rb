module Saucy
  module Helper
    
    # Arguments:
    # saucy_tag(name, :option1 => 'foo')
    # saucy_tag(name1, name2, :option2 => 'foo', :hover => {:color => 'blue'})
    
    def saucy_tag(*args)
      options   = args.extract_options!
      texts     = args
      filename  = [
          Digest::MD5.hexdigest(texts.to_s + options.to_s),
          texts.collect(&:underscore)
      ].flatten.join('_')
      
      unless File.exists?(File.join(AB_OUTPUT_DIR, filename))
         Saucy::Render.render(texts, filename, options)
      end
      
      size = Saucy::Image.cached_png_size(filename)
      src  = File.join(OUTPUT_DIR, 'filename')
      
      style ||= {}
      style['text-indent'] = '-5000px;'
      
      style['background'] = "url(#{src.inspect}) no-repeat;"
      style['width']      = "#{size[0]}px"
      style['height']     = "#{size[1]}px"
      
      trans = !style.has_key?('background') || style['background'] == "transparent"
      if trans || options[:transparent]
        style['_background']    = 'transparent';
        style['_filter:progid'] = "DXImageTransform.Microsoft.AlphaImageLoader(src=#{src.inspect}, sizingMethod='crop');"
      end
      
      options[:html] ||= {}
      options[:html][:style] = style.collect {|key, value| [key, value].join(':') }.join(';')
      
      content_tag_string(options[:tag] || 'div', nil, options[:html])    
    end

  end
end
