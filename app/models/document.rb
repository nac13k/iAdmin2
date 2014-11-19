class Document < ActiveRecord::Base
  before_validation :file2md5

  validates :md5, uniqueness: {message: "El archivo ya existe"}
  validates :title, :abstract, :file, presence: true
  validates :abstract, length: {maximum: 120}

  mount_uploader :file, FileUploader

  belongs_to :user

  protected
    def file2md5
      self.md5 = Digest::MD5.hexdigest(File.read(self.file.path))
    end

end
