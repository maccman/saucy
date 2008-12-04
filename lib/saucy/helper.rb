module Saucy
  module Helper
    
    # Arguments:
    # saucy_tag(name, :option1 => 'foo')
    # saucy_tag(name1, name2, :option2 => 'foo', :hover => {:color => 'blue'})
    
    def saucy_tag(*args, &block)
      options   = args.extract_options!
      texts     = args
      filename  = [
          Digest::MD5.hexdigest(texts.to_s + options.to_s),
          texts.collect(&:underscore)
      ].flatten.join('_') + '.png'
      
      unless File.exists?(File.join(ABS_OUTPUT_DIR, filename))
        # Reverse texts so the normal
        # state is the last one
        Saucy::Render.render(texts.reverse, filename, options)
      end
      
      size = Saucy::Image.cached_png_size(filename)
      # We divide by the number of images to get the height
      # of the first one (for sprites)
      real_height = (size[1] / args.length)
      
      src  = File.join(OUTPUT_DIR, filename)
      src  = "'#{src}'"
      
      options[:html] ||= {}
      options[:html][:class] ||= []
      style = options[:html][:style] ||= {}
      
      style['text-indent'] = '-5000px'
      style['background'] = "url(#{src}) 0 -#{size[1] - real_height}px no-repeat"
      style['width']      = "#{size[0]}px"
      style['height']     = "#{real_height}px"
      
      trans = !style.has_key?('background') || style['background'] == "transparent"
      
      options[:html][:class] << 'saucy'
      if texts.length > 1
        options[:html][:class] << 'saucySprite'
      end
      
      options[:tag] ||= :a
      # A's need to be display:block for text-indent to work
      options[:html][:style]['display'] = 'block' if options[:tag] == :a
      
      options[:html][:style] = style.collect {|key, value| [key, value].join(':') }.join(';')
      options[:html][:class] = options[:html][:class].join(' ')
      options[:html].delete(:class) if options[:html][:class].blank?

      
      if block_given?
        concat(content_tag(options[:tag] || :a, capture(&block), options[:html] || {}))
      else
        content_tag(options[:tag] || :a, options[:content], options[:html] || {})
      end
    end

  end
end
