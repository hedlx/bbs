(ns front.pages.threads
  (:require
    [front.components.thread :as thread-comp]
    [re-frame.core :refer [subscribe]]))


(defn render-thread [thread]
  ^{:key (:id thread)}
  [:div {:class "pa1"}
        [thread-comp/c {:thread thread}]])

(defn page []
  (fn []
    [:div {:class "w-100 flex flex-column"}
      (map render-thread @(subscribe [:threads]))]))