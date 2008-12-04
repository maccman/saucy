module Saucy
  module Helper
    
    # Arguments:
    # saucy_tag(name, :option1 => 'foo')
    # saucy_tag(name1, :option2 => 'foo', :hover => {:font => {:color => 'blue'}})
    
    def saucy_tag(name, options = {}, &block)      
      filename  = Digest::MD5.hexdigest(name + options.to_s) + '_' + name + '.png'
      
      unless File.exists?(File.join(ABS_OUTPUT_DIR, filename))
        Saucy::Render.render(name, filename, options)
      end
      
      size = Saucy::Image.cached_size(filename)
      # We divide by the number of images to get the height
      # of the first one (for sprites)
      real_height = size[1] / (options[:hover] ? 2 : 1)
      
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
      if options[:transparent] || trans
        style['_background']    = 'transparent';
        style['_filter:progid'] = "DXImageTransform.Microsoft.AlphaImageLoader(src=#{src}, sizingMethod='crop')"
      end
      
      options[:html][:class] << 'saucy'
      if options[:hover]
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
        content_tag(options[:tag] || :a, name, options[:html] || {})
      end
    end

  end
end
