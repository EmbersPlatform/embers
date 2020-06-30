export interface UserData {
  id: string,
  username: string,
  canonical: string
}

export interface UserSettings {
  content_nsfw: "hide" | "ask" | "show",
  content_lowres_images: boolean,
  content_collapse_media: boolean,
  privacy_show_status: boolean,
  privacy_show_reactions: boolean,
  privacy_trust_level: string
}

export interface ApplicationData {
  csrf_token: string,
  ws_token: string,
  user?: UserData,
  permissions: string[],
  settings: UserSettings
}

let app_data = window["embers"] as ApplicationData;

export const is_authenticated = () => {
  return !!app_data.user;
}

export const can = (permission: string) => {
  return (app_data.permissions.includes("any") || app_data.permissions.includes(permission))
}

export const get_data = () => app_data;

export const get_ws_token = () => app_data.ws_token;

export const get_user = () => app_data.user;
export const update_user = updater => {
  app_data.user = updater(app_data.user);
  return app_data.user;
}

export const get_settings = () => app_data.settings;
export const update_settings = (updater) => {
  app_data.settings = updater(app_data.settings);
  return app_data.settings;
}
