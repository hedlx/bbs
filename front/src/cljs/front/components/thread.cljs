(ns front.components.thread
  (:require [front.components.post :as post]))


(defn c []
  (fn [{:keys [thread]}]
      [post/c {:post thread}]))
