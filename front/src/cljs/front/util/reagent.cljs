(ns front.util.reagent)


(defn fragment [seq]
  (js/React.addons.createFragment
    #js {:_ seq}))