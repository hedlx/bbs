(ns front.core
  (:require
    [reagent.core :as reagent]
    [front.router :as router]
    [front.pages.current :as current]))


(defn mount-root []
  (reagent/render [current/page] (.getElementById js/document "app")))

(defn init! []
  (router/init-router!)
  (mount-root))
