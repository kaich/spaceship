require 'fileutils'

module Spaceship
  # a wrapper around the concept of file required to make uploads to DU
  class UploadFile
    attr_reader :file_path
    attr_reader :file_name
    attr_reader :file_size
    attr_reader :content_type
    attr_reader :bytes

    class << self
      def from_path(path)
        raise "Image must exists at path: #{path}" unless File.exist?(path)
        path = remove_alpha_channel(path) if File.extname(path).downcase == '.png'

        content_type = Utilities.content_type(path)
        self.new(
          file_path: path,
          file_name: File.basename(path),
          file_size: File.size(path),
          content_type: content_type,
          bytes: File.read(path)
        )
      end

      # As things like screenshots and app icon shouldn't contain the alpha channel
      # This will copy the image into /tmp to remove the alpha channel there
      # That's done to not edit the original image
      def remove_alpha_channel(original)
        path = "/tmp/#{Digest::MD5.hexdigest(original)}.png"
        FileUtils.copy(original, path)
        `sips -s format bmp '#{path}' &> /dev/null ` # &> /dev/null since there is warning because of the extension
        `sips -s format png '#{path}'`
        return path
      end
    end

    private

    def initialize(args)
      args.each do |k, v|
        instance_variable_set("@#{k}", v) unless v.nil?
      end
    end
  end
end
