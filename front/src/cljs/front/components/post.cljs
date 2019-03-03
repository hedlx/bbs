(ns front.components.post
  (:require [clojure.string :as str]))


(defn c []
  (fn [{:keys [post]}]
    (let [{:keys [id op]} post
          {:keys [name text] :or {:name "Anonymous"}} op]
      [:div {:class "flex flex-column ba b--dashed"}
        [:div {:class "flex ph3"}
          [:div {:class "b pr2"} name]
          [:div {:class "pr2"} id]]
        [:div text]])))