(ns front.util.js
  (:require [goog.events :as gevents]
            [clojure.string :as str])
  (:import [goog.async Throttle]))


(defn ts->iso [ts]
  (let [date-obj (new js/Date ts)
        offset (* (. date-obj getTimezoneOffset) 60000)
        res (. (new js/Date (- ts offset)) toISOString)
        [date raw-time] (-> res (str/split "T"))
        time (-> raw-time (str/split ".") first)]
    (str/join " " [date time])))

(defn add-global-event-listener [type cb]
  (let [key (gevents/listen js/document
                            type
                            cb)]
    (fn [] (gevents/unlistenByKey key))))

(defn- disposable->function [disposable listener interval]
  (let [disposable-instance (disposable. listener interval)]
    (fn [& args]
      (.apply (.-fire disposable-instance) disposable-instance (to-array args)))))

(defn throttle [listener interval]
  (disposable->function Throttle listener interval))
