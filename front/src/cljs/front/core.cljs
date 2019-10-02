(ns front.core
  (:require
    [front.router :as router]
    [front.pages.current :as current]
    [front.state.events]
    [front.state.subs]
    [reagent.core :as reagent]
    [cljss.core :as css]
    [re-frame.core :as rf]))


(defn mount-root []
  (css/remove-styles!)
  (reagent/render [current/page] (.getElementById js/document "app")))

(defn init! [base-url]
  (rf/dispatch-sync [:initialize {:base-url base-url}])
  (router/init-router!)
  (mount-root))