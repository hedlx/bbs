(ns front.components.dropzone
  (:require
            [reagent.core :as r]
            [front.util.js :refer [file->map]]))

; (defn- check-file-type [accepted? file]
;   (if (and (fn? accepted?)
;            (accepted? (. file -type)))
;     (just [:accepted file])
;     (just [:rejected file])))

; (defn- file-accepted? [[status file]]
;   (if (= status :accepted)
;     (just file)
;     (nothing)))

      ; (>>= (partial check-file-type (:accepted? props)))
      ; (>>= (fn [[status _]]
      ;        (swap! state #(-> % (assoc :status status)))))))

; (defn- on-drag-over [_ event]
;   (prevent-default! event)
;   (stop-propagation! event)
;   (try
;     (set! (.. event -dataTransfer -dropEffect) "copy")
;     (catch js/Error e
;       nil)))

; (defn- on-drag-leave [state event]
;   (prevent-default! event)
;   (swap! state #(-> % (assoc :status :usual))))

; (defn- get-onload-data [type event]
;   (if-let [data (.. event -target -result)]
;     (just [type data])
;     (nothing)))

; (defn- check-onload-data [result [type data]]
;   (let [res (-> @result (assoc type data))]
;     (if (and (some? (:url res))
;              (some? (:binary res)))
;       (just res)
;       (do (reset! result res)
;           (nothing)))))

; (defn- reader-onload [type result on-file-loaded event]
;   (-> (get-onload-data type event)
;       (>>= (partial check-onload-data result))
;       (>>= (fn [data]
;              (on-file-loaded data)))))

; (defn- load-droppped-file [on-file-will-load on-file-loaded file]
;   (let [reader-url (js/FileReader.)
;         reader-binary (js/FileReader.)
;         result (atom {})]
;     (on-file-will-load)
;     (set!
;      (. reader-url -onload)
;      (partial reader-onload :url result on-file-loaded))
;     (set!
;      (. reader-binary -onload)
;      (partial reader-onload :binary result on-file-loaded))
;     (. reader-url (readAsDataURL file))
;     (. reader-binary (readAsBinaryString file))))

; (defn- on-drop [state props event]
;   (stop-propagation! event)
;   (prevent-default! event)
;   ;; get file from event
;   (-> (get-file-from-event event)
;       (>>= (partial check-file-type (:accepted? props)))
;       (>>= file-accepted?)
;       (>>= (partial
;             load-droppped-file
;             (:on-file-will-load props)
;             (:on-file-loaded props))))
;   (swap! state #(-> % (assoc :status :usual))))


; (defn dropzone [props children]
;   (let [file-input (atom nil)
;         state (r/atom {:status :usual})
;         -on-click (partial on-click file-input)
;         -on-drag-start (partial on-drag-start state)
;         -on-drag-enter (partial on-drag-enter state)
;         -on-drag-over (partial on-drag-over state)
;         -on-drag-leave (partial on-drag-leave state)
;         -on-drop (partial on-drop state)]
;     (fn [props children]
;       [:div (-> props
;                 (dissoc :accepted?)
;                 (dissoc :accepted-class)
;                 (dissoc :rejected-class)
;                 (dissoc :on-file-will-load)
;                 (dissoc :on-file-loaded)
;                 (merge
;                  {:on-click -on-click
;                   :on-drag-start -on-drag-start
;                   :on-drag-enter (partial -on-drag-enter props)
;                   :on-drag-over -on-drag-over
;                   :on-drag-leave -on-drag-leave
;                   :on-drop (partial -on-drop props)}))
;        children
;        [:input {:style {:display "none"}
;                 :accept true
;                 :type "file"
;                 :multiple false
;                 :on-change (partial -on-drop props)
;                 :ref #(reset! file-input %)}]])))

(defn- open-file-dialog [file-input-el]
  (set! (. file-input-el -value) nil)
  (. file-input-el (click)))

(defn- stop-propagation! [e]
  (.stopPropagation e))

(defn- prevent-default! [e]
  (.preventDefault e))

(defn- ignore! [e]
  (stop-propagation! e)
  (prevent-default! e))

(defn- on-click [file-input-atom event]
  (stop-propagation! event)
  (open-file-dialog @file-input-atom))

(defn file-list->vec [file-list]
  (map file->map (vec (mapv #(.item file-list %) (range (.-length file-list))))))

(defn- extract-files [dt]
    (-> dt (.-files) (file-list->vec)))

(defn- get-file-from-event [event]
  (cond
    (some? (. event -dataTransfer)) (extract-files (. event -dataTransfer))
    (some? (. event -target)) (extract-files (. event -target))
    :else '()))

(defn- handle-drop [cb event]
  (let [f (if (nil? cb) (fn [xs]) cb)]
    (prevent-default! event)
    (stop-propagation! event)
    (-> event
        (get-file-from-event)
        (f))))

(defn c [{:keys [on-drop]}]
  (let [file-input (r/atom nil)
        is-over (r/atom false)]
    [:div {:class "dropzone"
           :on-drag-enter #(reset! is-over true)
           :on-drag-leave #(reset! is-over false)
           :on-drag-over prevent-default!
           :on-drop (partial handle-drop on-drop)}
     "SOSI"
     [:input {:style {:display "none"}
              :accept true
              :type "file"
              :multiple true
              :ref #(reset! file-input %)}]]))