module Saucy
  class Image
    class << self
      
      def png_dimensions(file)
        IO.read(file)[0x10..0x18].unpack('NN')
      end

      def get_png_size(filename)
        size = Rails.cache.read("saucy:" + filename)

        if(!size)
          size = png_dimensions("#{RAILS_ROOT}/public" + filename)
          Rails.cache.write("saucy:" + filename, size)
        end
        size
      end

      def cache_sizes 
        Dir.entries(ABS_OUTPUT_DIR).select {|f| f.match(/.png$/)}.each do |image|
           get_png_size("#{OUTPUT_DIR}/#{image}")
        end
      end
      
    end
  end
end