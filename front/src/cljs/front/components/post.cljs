(ns front.components.post
  (:require [front.router :refer [routes]]
            [clojure.string :as str]))


(defn- root-class [op?]
  (str/join " "
            ["flex"
             "flex-column"
             (if op? "w-100" "min-w5")
             "pa3"
             "br2"
             "bg-dark-pink"
             "ba"
             "b--pink"]))

(defn c []
  (fn [{:keys [id name text show-link? op?]}]
      [:div {:class (root-class op?)}
        [:div {:class "flex pb2"}
          [:div {:class "b pr2"} (if (nil? name) "Anonymous" name)]
          [:div {:class "pr2"}
           (if show-link?
             [:a {:href ((:thread @routes) {:id id})} id]
             id)]]
        [:div text]]))