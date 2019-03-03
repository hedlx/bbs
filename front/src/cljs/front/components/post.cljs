(ns front.components.post)


(defn c []
  (fn [{:keys [post]}]
    (let [{:keys [id name text] :or {name "Anonymous"}} post]
      [:div {:class "flex flex-column ba b--dashed"}
        [:div {:class "flex ph3"}
          [:div {:class "b pr2"} name]
          [:div {:class "pr2"} id]]
        [:div text]])))