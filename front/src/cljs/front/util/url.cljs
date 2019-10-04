(ns front.util.url
  (:require [clojure.string :as str]))


(defn gen-url [& path]
  (str/join "/" path))