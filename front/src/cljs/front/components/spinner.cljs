(ns front.components.spinner
  (:require [reagent.core :as r]))


(defn c []
  (let [show? (r/atom false)]
    (fn [{:keys [delay] :or {delay 0}}]
      (r/create-class
       {:display-name "spinner"

        :component-did-mount
        (fn []
          (js/setTimeout #(reset! show? true) delay))

        :reagent-render
        (fn []
          (if @show?
            [:div {:class "spinner"}]
            nil))}))))
