import auth from "../auth";

//inicia import INSIDE APP
const _Home = () => import("../views/_Home");
const _Discover = () => import("../views/_Discover");
const _Subscriptions = () => import("../views/_Subscriptions");
const _Search = () => import("../views/_Search");
const _Chat = () => import("../views/_Chat");
const _Favorites = () => import("../views/_Favorites");

const _Settings = () => import("../views/_Settings");
const AppsSettings = () => import("../views/Settings/Apps");
const AppearanceSettings = () => import("../views/Settings/Appearance");
const ContentSettings = () => import("../views/Settings/Content");
const PrivacySettings = () => import("../views/Settings/Privacy");
const ProfileSettings = () => import("../views/Settings/Profile");
const SecuritySettings = () => import("../views/Settings/Security");

const _UserProfile = () => import("../views/_UserProfile");
const Profile = () => import("../views/UserProfile/Profile");
const Post = () => import("../views/UserProfile/Post");

const SB_Default = () => import("../views/Sidebar/Default");
const SB_Home = () => import("../views/Sidebar/Home");
const SB_Discover = () => import("../views/Sidebar/Discover");
const SB_Profile = () => import("../views/Sidebar/UserProfile");
const SB_Settings = () => import("../views/Sidebar/Settings");
const SB_Chat = () => import("../views/Sidebar/Chat");
const SB_Subscriptions = () => import("../views/Sidebar/Subscriptions");

const SUBS_FollowingUsers = () =>
  import("../views/Subscriptions/FollowingUsers");
const SUBS_Tags = () => import("../views/Subscriptions/Tags");
const SUBS_Blocks = () => import("../views/Subscriptions/Blocks");
//termina import INSIDE APP

//inicia import OUTSIDE APP
const Register = () => import("../views/Register");
const PasswordReset = () => import("../views/PasswordReset");
const Error404 = () => import("../views/404");
const Rules = () => import("../views/Rules");
const FAQ = () => import("../views/FAQ");
const Acknowledgment = () => import("../views/Acknowledgment");
//termina import OUTSIDE APP

/**
 * Authentication check middleware
 * @param to
 * @param from
 * @param next
 */
function requireAuth(to, from, next) {
  if (auth.loggedIn()) {
    next();
  } else {
    location.reload();
  }
}

/**
 * Guest check middleware
 * @param to
 * @param from
 * @param next
 */
function mustBeGuest(to, from, next) {
  if (auth.loggedIn()) {
    next("/");
  } else {
    next();
  }
}

const routes = [
  //inicia OUTSIDE APP

  /**
   * Rules
   */
  {
    name: "rules",
    path: "/rules",
    components: {
      default: Rules,
      sidebar: SB_Default
    },
    meta: {
      title: "Reglas"
    }
  },
  /**
   * Faq
   */
  {
    name: "faq",
    path: "/faq",
    components: {
      default: FAQ,
      sidebar: SB_Default
    },
    meta: {
      title: "Preguntas frecuentes"
    }
  },
  /**
   * Acknowledgment
   */
  {
    name: "acknowledgment",
    path: "/acknowledgment",
    components: {
      default: Acknowledgment,
      sidebar: SB_Default
    },
    meta: {
      title: "Agradecimientos"
    }
  },

  /**
   * Sign up
   */
  {
    name: "register",
    path: "/register",
    component: Register,
    beforeEnter: mustBeGuest,
    meta: {
      title: "Registrarme"
    },
    children: [
      {
        path: ":pass"
      }
    ]
  },

  /**
   * Reset password
   */
  {
    name: "reset",
    path: "/reset",
    component: PasswordReset,
    beforeEnter: mustBeGuest,
    meta: {
      title: "Restablecer contraseña"
    }
  },
  /**
   * Error 404
   */
  {
    name: "404",
    path: "/404",
    components: {
      default: Error404
    },
    meta: {
      title: "Error 404"
    }
  },
  //termina OUTSIDE APP

  //inicia INSIDE APP
  /**
   * Home
   */
  {
    name: "home",
    path: "/",
    components: {
      default: _Home,
      sidebar: SB_Home
    },
    beforeEnter: requireAuth,
    meta: {
      title: "Inicio"
    }
  },
  /**
   * Discover
   */
  {
    name: "discover",
    path: "/discover",
    components: {
      default: _Discover,
      sidebar: SB_Discover
    },
    beforeEnter: requireAuth,
    meta: {
      title: "Descubre"
    }
  },

  /**
   * Favorites
   */
  {
    name: "favorites",
    path: "/favorites",
    components: {
      default: _Favorites,
      sidebar: SB_Home
    },
    beforeEnter: requireAuth,
    meta: {
      title: "Favoritos"
    }
  },

  /**
   * Subscriptions
   */
  {
    name: "subscriptions",
    path: "/subscriptions",
    components: {
      default: _Subscriptions,
      sidebar: SB_Subscriptions
    },
    beforeEnter: requireAuth,
    meta: {
      title: "Subscripciones"
    },
    children: [
      {
        path: "users",
        component: SUBS_FollowingUsers,
        meta: {
          title: "Subscripciones"
        }
      },
      {
        path: "tags",
        component: SUBS_Tags,
        meta: {
          title: "Subscripciones"
        }
      },
      {
        path: "blocks",
        component: SUBS_Blocks,
        meta: {
          title: "Subscripciones"
        }
      }
    ]
  },

  /**
   * Chat
   */
  {
    name: "chat",
    path: "/chat",
    components: {
      default: _Chat,
      sidebar: SB_Chat
    },
    beforeEnter: requireAuth,
    meta: {
      title: "Conversaciones"
    },
    children: [
      {
        path: ":id",
        component: _Chat,
        meta: {
          title: "Embers",
          noSuffix: true
        }
      }
    ]
  },

  /**
   * User settings
   */
  {
    // name: 'settings',
    path: "/settings",
    components: {
      default: _Settings,
      sidebar: SB_Settings
    },
    beforeEnter: requireAuth,
    children: [
      {
        path: "",
        component: ProfileSettings,
        meta: {
          title: "Configuración › Perfil"
        }
      },
      {
        path: "appearance",
        component: AppearanceSettings,
        meta: {
          title: "Configuración › Apariencia"
        }
      },
      {
        path: "content",
        component: ContentSettings,
        meta: {
          title: "Configuración › Contenido"
        }
      },
      {
        path: "privacy",
        component: PrivacySettings,
        meta: {
          title: "Configuración › Privacidad"
        }
      },
      {
        path: "security",
        component: SecuritySettings,
        meta: {
          title: "Configuración › Seguridad"
        }
      },
      {
        path: "apps",
        component: AppsSettings
      }
    ]
  },

  /**
   * User profile & post view
   */
  {
    // name: 'user',
    path: "/@:name",
    components: {
      default: _UserProfile,
      sidebar: SB_Profile
    },
    meta: {
      title: "Embers",
      noSuffix: true
    },
    children: [
      {
        path: "",
        component: Profile,
        meta: {
          title: "Embers",
          noSuffix: true
        }
      },
      {
        path: ":id",
        component: Post,
        name: "post",
        meta: {
          title: "Embers",
          noSuffix: true
        }
      }
    ]
  },

  /**
   * Search
   */
  {
    name: "search",
    path: "/search",
    components: {
      default: _Search
    },
    meta: {
      title: "Embers",
      noSuffix: true
    },
    children: [
      {
        path: ":searchParams",
        meta: {
          title: "Embers",
          noSuffix: true
        }
      }
    ]
  },
  //termina INSIDE APP

  //inicia DEFAULTS
  {
    path: "*",
    redirect: {
      name: "404"
    }
  }
  //termina DEFAULTS
];

export default routes;
