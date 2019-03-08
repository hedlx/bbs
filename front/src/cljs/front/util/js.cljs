(ns front.util.js)


(defn ts->iso [ts]
  (.toISOString (new js/Date ts)))