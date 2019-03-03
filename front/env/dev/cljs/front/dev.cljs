(ns ^:figwheel-no-load front.dev
  (:require
    [front.core :as core]
    [devtools.core :as devtools]))

(devtools/install!)
(enable-console-print!)
(core/init! "http://hedlx.org:8000")