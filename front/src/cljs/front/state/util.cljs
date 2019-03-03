(ns front.state.util
  (:require [clojure.string :as str]))


(defn gen-url [& path]
  (str/join "/" path))