(ns front.router
  (:require
    [secretary.core :as secretary :refer-macros [defroute]]
    [goog.events :as events]
    [re-frame.core :as rf])
  (:import [goog History]
           [goog.history EventType]))


(defn hook-browser-navigation! []
  (doto (History.)
    (events/listen EventType.NAVIGATE #(secretary/dispatch! (.-token %)))
    (.setEnabled true)))

;; That's a shame
(def routes (atom {}))

(defn push!
  ([page params]
   (let [loc ((page @routes) params)]
    (secretary/dispatch! loc)
    (set! (.-hash js/window.location) loc)))
  ([page] (push! page {})))

(defn init-router! []
  (secretary/set-config! :prefix "#")
  (defroute threads "/" [] (rf/dispatch [:change-location {:current-page :threads}]))
  (defroute
    thread
    "/thread/:id" [id]
    (rf/dispatch [:change-location
                  {:current-page :thread
                   :params {:id id}}]))
  (swap! routes assoc
         :threads threads
         :thread thread)
  (hook-browser-navigation!))
