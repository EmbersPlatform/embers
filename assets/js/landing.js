import { register } from "./components/component";
import "./modernizr";
import "./soft_keyboard";
import "./polyfills/dialog";

import MasonryLayout from "./components/masonry.comp";
import "./components/infinite-scroll";
import IntersectObserver from "./components/intersection_observer/intersection_observer.comp";
import LoadingIndicator from "./components/loading_indicator/loading_indicator.comp";
import ModalDialog from "./components/dialog/dialog.comp";
import MediaGallery from "./components/media_gallery/media_gallery.comp";
import TwitterEmbed from "./components/twitter_embed/twitter_embed.comp";
import PostTag from "./components/post/tags.comp";

register(MasonryLayout);
register(IntersectObserver);
register(LoadingIndicator);
register(ModalDialog);
register(MediaGallery);
register(TwitterEmbed);
register(PostTag);

import { Application } from "stimulus";
import * as PostController from "./controllers/post";
import * as MediasController from "./controllers/medias";
import * as ContentWarningController from "./controllers/content-warning";

const application = Application.start();
application.register(PostController.name, PostController.default);
application.register(MediasController.name, MediasController.default);
application.register(ContentWarningController.name, ContentWarningController.default);
