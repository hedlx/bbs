(ns front.state.subs
  (:require [re-frame.core :refer [subscribe reg-sub]]))


(reg-sub :threads #(:threads %))
(reg-sub :threads-loading? #(:threads-loading %))

(reg-sub :thread-posts #(:thread-posts %))

(reg-sub :current-page #(:current-page %))
(reg-sub :route-params #(:route-params %))