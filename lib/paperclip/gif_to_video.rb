module Paperclip
  class GifToVideo < Paperclip::Processor

    def initialize(file, options = {}, attachment = nil)
      super
      @file           = file
      @attachment     = attachment
      @basename       = File.basename(@file.path, '.*')
    end

    def make
      begin

        temp_file = Tempfile.new([@basename, '.ogg'])

        temp_file.binmode

        #! -y overwrites tempfile file (otherwise to_file(temp_file) would result in prompting for overwriting and stalling )
        #Paperclip.run('ffmpeg', "-f gif -i #{from_file} -y -c:v libx264 -vf scale=w=600:h=-1 -an -f mp4 #{to_file(temp_file)}")
        Paperclip.run('ffmpeg', "-i #{from_file} -y -c:v libtheora -c:a libvorbis #{to_file(temp_file)}")
        temp_file

      rescue Exception => e
        #this class is prototype, but probaly should add sort of custom error to get it e.g. composer.
        raise e
      end
    end

    def from_file
      File.expand_path(@file.path)
    end

    def to_file(destination)
      "#{File.expand_path(destination.path)}"
    end

  end
end
