(ns front.pages.threads
  (:require
    [front.components.thread :as thread-comp]
    [front.components.spinner-overlay :as spinner-overlay]
    [front.util.reagent :refer [fragment]]
    [re-frame.core :refer [subscribe]]))


(defn- render-thread [thread]
  ^{:key (:id thread)}
  [:div {:class "w-100 pa1"}
        [thread-comp/c {:thread thread}]])

(defn- render-separator [key]
  ^{:key key} [:hr {:class "w-90"}])

(defn- render-threads [threads]
  (->> threads
       (map-indexed
         (fn [idx thread] [(render-thread thread) (render-separator (str idx "s"))]))
       (apply concat)
       (butlast)))

(defn- render-content [threads loading? error]
  (cond
    (and (empty? threads) loading?) [spinner-overlay/c]
    error    [:div "ERROR"] ;TODO: you know
    :default (render-threads threads)))

(defn page []
  (fn []
    (let [threads @(subscribe [:sorted-threads])
          loading? @(subscribe [:threads-loading?])
          error @(subscribe [:threads-error])]
      [:div {:class "relative flex flex-column items-start w-100 h-100"}
        (render-content threads loading? error)])))