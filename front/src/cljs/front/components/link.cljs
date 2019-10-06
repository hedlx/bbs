(ns front.components.link)


(defn c [{:keys [href label]}]
  [:a {:class "link"
       :href href}
   label])
