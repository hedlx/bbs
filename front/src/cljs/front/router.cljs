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

;; That's a shame
(def routes (atom {}))

(defn init-router! []
  (secretary/set-config! :prefix "#")
  (defroute threads "/" [] (rf/dispatch [:change-location {:current-page :threads}]))
  (swap! routes assoc :threads threads)
  (hook-browser-navigation!))