(ns front.core
  (:require
   [front.router :as router]
   [front.pages.current :as current]
   [front.state.events]
   [front.state.subs]
   [reagent.core :as reagent]
   [re-frame.core :as rf]
   [front.util.js :as utils]))


(defn mount-root []
  (reagent/render [current/page] (.getElementById js/document "app")))

(defn init! [base-url]
  (rf/dispatch-sync [:initialize {:base-url base-url
                                  :window {:width js/window.innerWidth
                                           :height js/window.innerHeight}}])
  (set!
   js/window.onresize
   (utils/throttle
    #(rf/dispatch [:window-resized [js/window.innerWidth js/window.innerHeight]])
    200))

  (router/init-router!)
  (mount-root))
