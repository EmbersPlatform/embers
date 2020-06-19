export interface UserData {
  id: string,
  username: string,
  canonical: string
}

export interface ApplicationData {
  csrf_token: string,
  ws_token: string,
  user?: UserData,
  permissions: string[]
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
