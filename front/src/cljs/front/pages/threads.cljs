(ns front.pages.threads
  (:require
    [front.components.thread :as thread-comp]
    [front.components.spinner-overlay :as spinner-overlay]
    [re-frame.core :refer [subscribe]]))


(defn- render-thread [thread]
  ^{:key (:id thread)}
  [:div {:class "pa1"}
        [thread-comp/c {:thread thread}]])

(defn- render-content [threads loading? error]
  (cond
    loading? [spinner-overlay/c]
    error    [:div "ERROR"] ;TODO: you know
    :default (map render-thread threads)))

(defn page []
  (fn []
    (let [threads @(subscribe [:threads])
          loading? @(subscribe [:threads-loading?])
          error @(subscribe [:threads-error])]
      [:div {:class "relative flex flex-column items-start w-100 h-100"}
        (render-content threads loading? error)])))