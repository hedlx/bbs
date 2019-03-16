(ns front.components.outside-click-listener
  (:require [front.util.js :refer [add-global-event-listener]]
            [reagent.core :as r]
            [goog.events.EventType]))


(def unlisten-mouse-down (r/atom #()))
(def unlisten-mouse-up (r/atom #()))
(def ref (r/atom nil))

(defn- make-outside-action-handler [parent handler]
  (fn [e]
    (when (not (or (nil? @ref)
                   (nil? @parent)))
      (let [target (. e -target)
            outside? (not (or (. @ref contains target)
                              (. @parent contains target)))]
        (when outside? (handler))))))

(defn- make-on-mouse-up [on-click parent]
  (let [handler (make-outside-action-handler parent on-click)]
    (fn [e]
      (do
        (@unlisten-mouse-up)
        (reset! unlisten-mouse-up #())
        (handler e)))))

(defn- make-on-mouse-down [on-click parent]
  (let [action #(reset!
                  unlisten-mouse-up
                  (add-global-event-listener
                    goog.events.EventType.MOUSEUP
                    (make-on-mouse-up on-click parent)))]
    (make-outside-action-handler parent action)))

(defn c [{:keys [on-click parent-ref]}]
  (r/create-class
    {:display-name "outside-click-listener"

     :component-did-mount
     (fn []
       (reset!
         unlisten-mouse-down
         (add-global-event-listener
           goog.events.EventType.MOUSEDOWN
           (make-on-mouse-down on-click parent-ref))))

     :component-will-unmount
     (fn []
       (do
         (@unlisten-mouse-down)
         (@unlisten-mouse-up)))

     :reagent-render
     (fn [_ child]
       (do
         [:div {:ref #(reset! ref %)}
          child]))}))