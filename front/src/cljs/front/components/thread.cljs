(ns front.components.thread
  (:require [front.components.post :as post]
            [re-frame.core :refer [subscribe]]))


(defn c []
  (fn [{:keys [thread]}]
    (let [{:keys [id op]} thread
          {:keys [name text] :or {:name "Anonymous"}} op]
      [post/c {:id id
               :name name
               :text text
               :show-link? @(subscribe [:threads-page?])}])))