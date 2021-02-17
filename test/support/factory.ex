defmodule Embers.Factory do
  use ExMachina.Ecto, repo: Embers.Repo

  def user_factory do
    name = sequence(:username, &"user_#{&1}")

    %Embers.Accounts.User{
      username: name,
      canonical: name,
      email: sequence(:email, &"user_#{&1}@example.com"),
      password_hash: Pbkdf2.hash_pwd_salt("yayapapaya")
    }
  end

  def meta_factory do
    bio = sequence(:bio, &"bio_#{&1}")

    %Embers.Profile.Meta{
      bio: bio,
      user: build(:user)
    }
  end

  def role_factory(%{permissions: permissions} = _attrs) do
    %Embers.Authorization.Role{
      name: sequence(:rolename, &"role_#{&1}"),
      permissions: permissions
    }
  end

  def post_factory do
    body = sequence(:post_body, &"post_#{&1}")

    %Embers.Posts.Post{
      user: build(:user),
      body: body
    }
  end

  def media_item_factory do
    %Embers.Media.MediaItem{
      url: sequence(:url, &"http://example.com/#{&1}"),
      type: "link",
      user: build(:user)
    }
  end

  def link_factory do
    %Embers.Links.Link{
      url: sequence(:url, &"http://example.com/#{&1}"),
      user: build(:user),
      embed: %Embers.Links.EmbedSchema{}
    }
  end

  def reaction_factory do
    name =
      Enum.random(
        ~w(thumbip thumbsdown grin cry thinking point_up angry tada heart eggplant hoht_pepper cookie)
      )

    %Embers.Reactions.Reaction{
      name: name,
      user: build(:user),
      post: build(:post)
    }
  end

  def tag_factory do
    %Embers.Tags.Tag{
      name: sequence(:tag_name, &"tag#{&1}")
    }
  end

  def tag_post_factory do
    %Embers.Tags.TagPost{
      tag: build(:tag),
      post: build(:post)
    }
  end
end
