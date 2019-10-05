(ns front.components.link
  (:require
    [front.styles.colors :as colors]
    [cljss.core :refer-macros [defstyles]]))


(defstyles root-class []
  {:color colors/purple-1
   :&:hover {:color colors/purple}})

(defn c [{:keys [href label]}]
  [:a {:class (root-class)
       :href href}
   label])
