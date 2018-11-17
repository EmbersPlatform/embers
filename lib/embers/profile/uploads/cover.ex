defmodule Embers.Profile.Uploads.Cover do
  use Arc.Definition

  alias Embers.Helpers.IdHasher

  # Include ecto support (requires package arc_ecto installed):
  # use Arc.Ecto.Definition

  @versions [:original]

  @acl :public_read

  # To add a thumbnail version:
  # @versions [:original, :thumb]

  # Override the bucket on a per definition basis:
  # def bucket do
  #   :custom_bucket_name
  # end

  # Whitelist file extensions:
  def validate({file, _}) do
    ~w(.jpg .jpeg .gif .png) |> Enum.member?(Path.extname(file.file_name))
  end

  # Define a thumbnail transformation:
  def transform(:original, _) do
    {:convert,
     "-strip -resize 800x500 -background #1a1b1d -gravity center -extent 800x500 -format jpg",
     :jpg}
  end

  # Override the persisted filenames:
  def filename(_version, {_file, user}) do
    id_hash = IdHasher.encode(user.id)
    "#{id_hash}"
  end

  # Override the storage directory:
  def storage_dir(_version, {_file, _name}) do
    "uploads/user/cover"
  end

  # Provide a default URL if there hasn't been a file uploaded
  # def default_url(version, scope) do
  #   "/images/avatars/default_#{version}.png"
  # end

  # Specify custom headers for s3 objects
  # Available options are [:cache_control, :content_disposition,
  #    :content_encoding, :content_length, :content_type,
  #    :expect, :expires, :storage_class, :website_redirect_location]
  #
  # def s3_object_headers(version, {file, scope}) do
  #   [content_type: MIME.from_path(file.file_name)]
  # end
end
