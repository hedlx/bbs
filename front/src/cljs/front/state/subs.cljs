(ns front.state.subs
  (:require [re-frame.core :refer [subscribe reg-sub]]))


(reg-sub :threads-root #(:threads %))
(reg-sub
  :threads
  (fn [_ _] (subscribe [:threads-root]))
  (fn [root _] (:list root)))
(reg-sub
  :sorted-threads
  (fn [_ _] (subscribe [:threads]))
  (fn [threads _] (sort-by #(-> % :last last :ts) > threads)))
(reg-sub
  :threads-loading?
  (fn [_ _] (subscribe [:threads-root]))
  (fn [root _] (:loading? root)))
(reg-sub
  :threads-error
  (fn [_ _] (subscribe [:threads-root]))
  (fn [root _] (:error root)))

(reg-sub :thread-root #(:thread %))
(reg-sub
  :thread-posts
  (fn [_ _] (subscribe [:thread-root]))
  (fn [root _] (:posts root)))
(reg-sub
  :thread-loading?
  (fn [_ _] (subscribe [:thread-root]))
  (fn [root _] (:loading? root)))
(reg-sub
  :thread-error
  (fn [_ _] (subscribe [:thread-root]))
  (fn [root _] (:error root)))

(reg-sub :router #(:router %))
(reg-sub
  :current-page
  (fn [_ _] (subscribe [:router]))
  (fn [root _] (:current-page root)))
(reg-sub
  :route-params
  (fn [_ _] (subscribe [:router]))
  (fn [root _] (:params root)))
(reg-sub
  :threads-page?
  (fn [_ _] (subscribe [:current-page]))
  (fn [page _] (= page :threads)))