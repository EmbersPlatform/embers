defmodule Embers.OldFactory do
  use ExMachina.Ecto, repo: Embers.Repo

  @password Pbkdf2.add_hash("password")

  def user_factory do
    %Embers.Accounts.User{
      username: sequence("username"),
      canonical: sequence("username"),
      email: sequence(:email, &"email-#{&1}@example.com"),
      password: @password,
      meta: build(:meta),
      settings: build(:setting),
      posts: nil
    }
  end

  def meta_factory do
    %Embers.Profile.Meta{
      avatar_version: 123_456,
      bio: "blablabla",
      cover_version: 123_456,
      user: nil
    }
  end

  def setting_factory do
    %Embers.Profile.Settings.Setting{
      content_nsfw: 0,
      content_lowres_images: false,
      privacy_show_status: true,
      privacy_show_reactions: true,
      user: nil
    }
  end

  def post_factory do
    %Embers.Feed.Post{
      body: sequence("body"),
      nesting_level: 0,
      replies_count: 0,
      shares_count: 0,
      user: nil,
      replies: nil,
      reactions: nil
    }
  end
end
