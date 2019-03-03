(ns front.core
  (:require
    [reagent.core :as reagent]
    [re-frame.core :as rf]
    [front.router :as router]
    [front.pages.current :as current]
    [front.state.events]
    [front.state.subs]))


(defn mount-root []
  (reagent/render [current/page] (.getElementById js/document "app")))

(defn init! [base-url]
  (rf/dispatch-sync [:initialize {:base-url base-url}])
  (router/init-router!)
  (mount-root))