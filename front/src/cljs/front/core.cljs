(ns front.core
  (:require
   [front.router :as router]
   [front.pages.current :as current]
   [front.state.events]
   [front.state.subs]
   [reagent.dom :as rdom]
   [re-frame.core :as rf]
   [front.util.js :as utils]))


(defn ^:export run []
  (rdom/render [current/page] (js/document.getElementById "app")))

(defn init! [base-url]
  (rf/dispatch-sync [:initialize {:base-url base-url
                                  :window {:width js/window.innerWidth
                                           :height js/window.innerHeight}}])
  (set!
   js/window.onresize
   (utils/throttle
    #(rf/dispatch [:window-resized [js/window.innerWidth js/window.innerHeight]])
    200))

  (set!
    js/window.onscroll
    (utils/throttle
      #(rf/dispatch [:window-scrolled [js/window.pageYOffset]])
      200))

  (router/init-router!)
  (run))
