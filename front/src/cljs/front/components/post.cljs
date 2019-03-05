(ns front.components.post
  (:require [clojure.string :as str]))


(defn c []
  (fn [{:keys [post]}]
    (let [{:keys [id op]} post
          {:keys [name text] :or {:name "Anonymous"}} op]
      [:div {:class "flex flex-column pa3 br2 bg-dark-pink ba b--pink"}
        [:div {:class "flex pb2"}
          [:div {:class "b pr2"} name]
          [:div {:class "pr2"} id]]
        [:div text]])))