require 'rvg/rvg'
require 'fileutils'

module Saucy
  class Render
    FONT_STORES = [
      File.join(File.dirname(__FILE__), *%w[ .. .. fonts ]), 
      File.join(Rails.root, *%w[ lib fonts ])
    ]
    
    DEFAULT_STYLE = { 
      :background => "transparent",
      :font       => {
        :size     => 18, 
        :color    => "#000", 
        :font     => "arial", 
        :stretch  => "normal"
      },
      :stroke => {
        :width    => 0, 
        :color    => "#000", 
        :inner    => true 
      },
      :spacing    => {
        :letter   => 0, 
        :word     => 0
      }
    }
    
    class << self
      def render(name, filename, options = {})
        style = DEFAULT_STYLE.deep_merge(options[:style] || {})    
        
        image = draw(name,  
                     style[:font], 
                     style[:background], 
                     style[:stroke],
                     style[:spacing]
                  )
                  
        if options[:hover]
          images  = Magick::ImageList.new
          style   = style.deep_merge(options[:hover] || {})
          images << draw(name,  
                      style[:font], 
                      style[:background], 
                      style[:stroke],
                      style[:spacing]
                    )
          images << image

          # Append vertically
          image = images.append(true)
        end
        
        # Make saucy dir
        FileUtils.mkdir_p(ABS_OUTPUT_DIR)
        
        image.write(File.join(ABS_OUTPUT_DIR, filename))
      end
    
      def draw(text, font, background, stroke, spacing)
        lines = text.split("\n")

        width   = (font[:size] * text.length) + (stroke[:width] * 2)
        height  = (font[:size] * 2 + stroke[:width] * 2) * lines.length
      
        rvg = Magick::RVG.new(width, height) do |canvas|
          canvas.background_fill = background if background != 'transparent'
          
          styles = {
            :font_size        =>  font[:size], 
            :fill             =>  font[:color], 
            :font_stretch     =>  font[:stretch],
            :letter_spacing   =>  spacing[:letter],
            :word_spacing     =>  spacing[:word],
            :glyph_orientation_horizontal => font[:rotate]
          }
          
          if font_file = font[:font]
            FONT_STORES.each do |store|
              path = File.join(store, font[:font])
              if File.exist?(path)
                font_file = path
                break
              end
            end
            styles[:font] = font_file.inspect
          end
                  
          if stroke[:width] > 0
            styles.merge!(:stroke => stroke[:color], :stroke_width => stroke[:width])
      	  end
        
          line_height = font[:height] || font[:size]
          y = 0

          lines.each do |line|
            canvas.text(stroke[:width], font[:size] + y, line).styles(styles)

            if stroke[:inner] && stroke[:width] > 1
              inner = styles.merge(:stroke_width => 1, :stroke => font[:color])
              canvas.text(stroke[:width], font[:size] + y, line).styles(inner)
            end
            y += line_height
          end
        end
      
        rvg.draw.trim
      end
    end # self
  end
end