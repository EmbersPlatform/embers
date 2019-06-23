import auth from "../auth";

//inicia import INSIDE APP
import _Home from "../views/_Home";
import _Discover from "../views/_Discover";
import _Subscriptions from "../views/_Subscriptions";
import _Search from "../views/_Search";
import _Chat from "../views/_Chat";
import _Favorites from "../views/_Favorites";
import _Tag from "../views/_Tag.vue";

import _Settings from "../views/_Settings";
import AppsSettings from "../views/Settings/Apps";
import AppearanceSettings from "../views/Settings/Appearance";
import ContentSettings from "../views/Settings/Content";
import PrivacySettings from "../views/Settings/Privacy";
import ProfileSettings from "../views/Settings/Profile";
import SecuritySettings from "../views/Settings/Security";

import _UserProfile from "../views/_UserProfile";
import _PostDetails from "../views/_PostDetails";
import Profile from "../views/UserProfile/Profile.vue";

import SB_Default from "../views/Sidebar/Default";
import SB_Home from "../views/Sidebar/Home";
import SB_Discover from "../views/Sidebar/Discover";
import SB_Settings from "../views/Sidebar/Settings";
import SB_Chat from "../views/Sidebar/Chat";
import SB_Subscriptions from "../views/Sidebar/Subscriptions";

import SUBS_FollowingUsers from "../views/Subscriptions/FollowingUsers";
import SUBS_Tags from "../views/Subscriptions/Tags";
import SUBS_Blocks from "../views/Subscriptions/Blocks";
import SUBS_TagBlocks from "../views/Subscriptions/TagBlocks";
//termina import INSIDE APP

//inicia import OUTSIDE APP
import Register from "../views/Register";
import PasswordReset from "../views/PasswordReset";
import Error404 from "../views/404";
import Rules from "../views/Rules";
import FAQ from "../views/FAQ";
import Acknowledgment from "../views/Acknowledgment";
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
    children: [{
      path: ":pass"
    }]
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
      sidebar: SB_Home
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
    children: [{
        path: "users",
        component: SUBS_FollowingUsers,
        meta: {
          title: "Usuarios seguidos"
        }
      },
      {
        path: "tags",
        component: SUBS_Tags,
        meta: {
          title: "Mis tags"
        }
      },
      {
        path: "blocks",
        component: SUBS_Blocks,
        meta: {
          title: "Usuarios bloqueados"
        }
      },
      {
        path: "blocked_tags",
        component: SUBS_TagBlocks,
        meta: {
          title: "Tags bloqueados"
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
    children: [{
      path: ":id",
      component: _Chat,
      meta: {
        title: "Embers",
        noSuffix: true
      }
    }]
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
    children: [{
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
    name: 'user',
    path: "/@:name",
    components: {
      default: _UserProfile,
      sidebar: SB_Home
    },
    meta: {
      title: "Embers",
      noSuffix: true
    },
    children: [{
      path: "",
      component: Profile,
      meta: {
        title: "Embers",
        noSuffix: true
      }
    }]
  },
  {
    name: 'post',
    path: "/@:username/:id",
    components: {
      default: _PostDetails,
      sidebar: SB_Home
    },
    meta: {
      title: "Embers",
      noSuffix: true
    }
  },
  {
    name: 'post_no_user',
    path: "/post/:id",
    components: {
      default: _PostDetails,
      sidebar: SB_Home
    },
    meta: {
      title: "Embers",
      noSuffix: true
    }
  },

  /**
   * Tag
   */
  {
    name: 'tag',
    path: "/tag/:name",
    components: {
      default: _Tag,
      sidebar: SB_Home
    },
    meta: {
      title: "Embers",
      noSuffix: true
    }
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
    children: [{
      path: ":searchParams",
      meta: {
        title: "Embers",
        noSuffix: true
      }
    }]
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
