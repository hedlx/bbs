(ns front.state.specs
  (:require [clojure.spec.alpha :as s]))

(def initialized? (atom  false))

(defn reg-create-msg-specs [limits]
  (when (not @initialized?)
    (reset! initialized? true)
    (s/def ::name (s/and string? #(<= (count %) (:msg-name-len limits))))
    (s/def ::secret string?)
    (s/def ::password string?)
    (s/def ::text (s/and string? #(<= (count %) (:msg-text-len limits))))
    (s/def ::subject (s/and string? #(<= (count %) (:msg-subject-len limits))))
    (s/def ::media #(<= (count %) (:media-max-count limits)))
    (s/def ::new-thread
      (s/and (s/keys :req-un [::name ::secret ::password ::text ::subject ::media])
             (fn [{:keys [subject text media]}]
               (and (> (count subject) 0)
                    (or (> (count text) 0)
                        (> (count media) 0))
                    (every? #(not (:loading? %)) (vals media))))))
    (s/def ::new-answer
      (s/and (s/keys :req-un [::name ::secret ::password ::text ::media])
             (fn [{:keys [text media]}]
               (and (or (> (count text) 0)
                        (> (count media) 0))
                    (every? #(not (:loading? %)) (vals media))))))))