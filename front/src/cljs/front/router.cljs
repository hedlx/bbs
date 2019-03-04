(ns front.router
  (:require
    [secretary.core :as secretary :refer-macros [defroute]]
    [goog.events :as events]
    [re-frame.core :as rf]
    [front.pages.threads :as threads])
  (:import [goog History]
           [goog.history EventType]))


(defn hook-browser-navigation! []
  (doto (History.)
    (events/listen EventType.NAVIGATE #(secretary/dispatch! (.-token %)))
    (.setEnabled true)))

(defn page-for [route]
  (case route
    :threads #'threads/page
    :undefined :div))

(defn init-router! []
  (secretary/set-config! :prefix "#")
  (defroute "/" [] (rf/dispatch [:change-location {:current-page :threads}]))
  (defroute "/test" [] (rf/dispatch [:change-location {:current-page :threads}]))
  (hook-browser-navigation!))
