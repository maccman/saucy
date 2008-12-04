module Saucy
  class Image
    class << self
      
      def png_size(file)
        IO.read(file)[0x10..0x18].unpack('NN')
      end

      def cached_png_size(filename)
        size = Rails.cache.read("saucy:" + filename)
        unless size
          size = png_size(File.join(ABS_OUTPUT_DIR, filename))
          Rails.cache.write("saucy:" + filename, size)
        end
        size
      end
      
    end
  end
end