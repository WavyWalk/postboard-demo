#the class is used to download files from url
# !!!!!!!!!!!!! NOT USED !!!!!! MAY BE DELETED
class Services::FileByURLDownloader

  def self.is_valid_url?(string)

    if string.is_a?(String) && (Uri.parse(self.file) rescue nil)
      return true
    else
      return false
    end

  end

  def self.download_file_from_url(url)

  end

end
