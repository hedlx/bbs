(ns front.state.subs
  (:require [re-frame.core :refer [subscribe reg-sub]]))


(reg-sub :threads-root #(:threads %))
(reg-sub
  :threads
  (fn [_ _] (subscribe [:threads-root]))
  (fn [root _] (:list root)))
(reg-sub
  :threads-loading?
  (fn [_ _] (subscribe [:threads-root]))
  (fn [root _] (:loading? root)))

(reg-sub :router #(:router %))
(reg-sub
  :current-page
  (fn [_ _] (subscribe [:router]))
  (fn [root _] (:current-page root)))
(reg-sub
  :route-params
  (fn [_ _] (subscribe [:router]))
  (fn [root _] (:params [router])))