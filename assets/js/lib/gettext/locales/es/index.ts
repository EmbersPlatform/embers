const messages = {
  Accept: "Aceptar",
  Cancel: "Cancelar",
  Retry: "Reintentar",

  "Processing link": "Procesando enlace",
  "Remove link": "Quitar enlace",
  "Could not process the link": "No se pudo procesar el enlace",

  "Share post": "Compartir publicacion",

  Show: "Mostrar",
  Hide: "Ocultar",
  "Loading...": "Cargando...",

  "Scroll to top": "Ir hacia arriba",

  "Create post": "Crear post",

  "The max file size if 5MB": "El tamaño máximo es de 5MB",
  "The file type is not allowed": "El tipo de archivo no está permitido",

  Profile: "Perfil",
  Content: "Contenido",
  Design: "Diseño",
  Privacy: "Privacy",
  Security: "Seguridad",

  Username: "Nombre de usuario",
  Email: "Correo electrónico",
  Bio: "Descripción",

  "Save changes": "Guardar cambios",
  "Saving changes...": "Guardando cambios...",

  "Not Safe For Work content": "Contenido NSFW",
  "Show NSFW content": "Mostrar contenido NSFW",
  "Ask before showing": "Preguntar antes de mostrar",
  "Hide NSFW content": "Ocultar contenido NSFW",

  Images: "Imágenes",
  "Collapse tall images in posts": "Contraer imágenes muy largas",
  Dark: "Oscuro",
  Light: "Claro",

  "Show my online status": "Mostrar a los demás usuarios si estoy en línea",
  "Everyone can see my reactions":
    "Los demás usuarios pueden ver a qué reaccioné",

  "Who can comment my posts": "Quién puede comentar mis publicaciones",
  Everyone: "Todos",
  "Only those I follow": "Sólo quienes sigo",

  "Reset password": "Restablecer contraseña",
  "A mail was sent with a link to reset your password":
    "Enviamos un enlace a tu correo para que puedas cambiar tu contraseña",
  "An unexpected error ocurred, please try again later":
    "Ocurrió un error inesperado, por favor intenta más tarde",
  "Please wait a few minutes before requesting another password reset":
    "Por favor espera unos minutos antes de solicitar otro cambio de contraseña",

  "There are no online friends": "No hay amigos conectados",

  Filter: "Filtrar",

  Users: "Usuarios",

  "Popular tags": "Tags populares",

  "You reached the bottom!": "¡Llegaste al final!",
};

const domains = {
  chat: {
    "The message could not be sent": "No se pudo enviar el mensaje",
    "Send message to @%1": "Enviar mensaje a @%1",
    "New message": "Nuevo mensaje",
    "Who do you want to talk to?": "¿Con quién quieres hablar?",
  },
  "design-optios": {
    "5 minutes ago": "Hace 5 minutos",
    "Hello world!": "¡Hola mundo!",
  },
  editor: {
    "Share something with your followers!":
      "¡Comparte algo con tus seguidores!",
    "Tags, separated by spaces": "Tags, separados por espacios",
    Publish: "Publicar",
    Cancel: "Cancelar",
    Retry: "Volver a intentar",
    "Add image": "Agregar imagen",
    "Remove multimedia": "Quitar",

    "too similar to previous posts":
      "Ya publicaste algo muy similar hace un momento, intenta más tarde",
    "can't comment to this user posts":
      "El dueño de este post ha habilitado los comentarios solo a sus seguidores",
    "parent post owner has blocked the post creator":
      "La persona a quien intentas responder te ha bloqueado",
  },
  "mod-user": {
    "View profile": "Ver perfil",
    "Manage user": "Gestionar usuario",
    "Manage %1": "Gestionar a %1",
    "Remove avatar": "Quitar avatar",
    "Remove cover": "Quitar portada",
    Roles: "Roles",
  },
  moderation: {
    "Report reasons": "Motivos de reporte",
    "Reason not specified": "No se especificó un motivo",
    "Report resolved": "Reporte resuelto",
    "Could not resolve the report": "No se pudo resolver el reporte",

    "User was banned for %1 days": "Usuario suspendido por %1 días",
    "Ban «@%1»?": "¿Suspender a «@%1»?",
    "Duration(days)": "Duración(días)",
    "Ban reason": "Motivo de la suspensión",
    Permanent: "Permanente",
    "Delete posts? Can't be undone":
      "¿Eliminar publicaciones? No se puede deshacer",
    "Don't delete": "No eliminar",
    "Last 24 hours": "Últimas 24 horas",
    "Last 7 days": "Últimos 7 días",
    Everything: "Todo",
    Ban: "Suspender",
  },
  notifications: {
    "%1 replied to your %2": "%1 respondió a tu %2",
    "%1 commented in your %2": "%1 comentó en tu %1",
    "%1 mentioned you in a %2": "%1 te mencionó en un %2",
    "%1 is following you": "%1 te está siguiendo",
  },
  "pinned-tags": {
    "Pinned tags": "Tags fijados",
    "View all": "Ver todos",
  },
  "post-viewer-modal": {
    "@%1's post": "Post de @%1",
    "Post details": "Detalles del post",
  },
  "profile-options": {
    "Change avatar": "Cambiar avatar",
    "Change cover": "Cambiar portada",
  },
  "reactions-dialog": {
    All: "Todas",
    Reactions: "Reacciones",
    "Fetching reactions...": "Cargando reacciones...",
    "There was an error loading reactions.":
      "Hubo un error al cargar las reacciones.",
    "This post has no reactions :(": "Esta publicación no tiene reacciones :(",
  },
  tags: {
    Pin: "Fijar",
    Unpin: "Quitar",
  },
};

export default { messages, ...domains };
