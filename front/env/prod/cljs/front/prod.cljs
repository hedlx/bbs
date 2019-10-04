(ns front.prod
  (:require [front.core :as core]
            [clojure.string :as str]))


(defn get-base-url []
  (let [[prot _ addr] (str/split (-> js/window .-location .-href) "/")]
    (str prot "//" addr)))

;;ignore println statements in prod
(set! *print-fn* (fn [& _]))

(core/init! (get-base-url))
