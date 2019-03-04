(defproject front "0.1.0-SNAPSHOT"
  :description "FIXME: write description"
  :url "http://example.com/FIXME"
  :license {:name "Eclipse Public License"
            :url "http://www.eclipse.org/legal/epl-v10.html"}

  :dependencies [[org.clojure/clojure "1.10.0"]
                 [reagent "0.8.1"]
                 [clj-commons/secretary "1.2.4"]
                 [re-frame "0.10.6"]
                 [day8.re-frame/http-fx "0.1.6"]
                 [org.clojure/clojurescript "1.10.520"
                  :scope "provided"]
                 [binaryage/devtools "0.9.10"]]

  :plugins [[lein-environ "1.1.0"]
            [lein-cljsbuild "1.1.7"]
            [lein-figwheel "0.5.18"]
            [lein-asset-minifier "0.2.7"
             :exclusions [org.clojure/clojure]]]

  :min-lein-version "2.5.0"

  :minify-assets
  {:assets
   {"resources/public/css/site.min.css" "resources/public/css/site.css"}}

  :cljsbuild
  {:builds {
    :min
    {:source-paths ["src/cljs" "src/cljc" "env/prod/cljs"]
     :compiler
     {:main          "front.prod"
      :output-to     "resources/public/js/app.js"
      :optimizations :advanced
      :pretty-print  false}}

    :app
    {:source-paths ["src/cljs" "src/cljc" "env/dev/cljs"]
     :figwheel {:on-jsload "front.core/mount-root"
                :open-urls ["http://localhost:3449/"]}
     :compiler
     {:main "front.dev"
      :asset-path "/js/out"
      :output-to "resources/public/js/app.js"
      :output-dir "resources/public/js/out"
      :source-map true
      :optimizations :none
      :pretty-print  true}}}}

  :figwheel
  {:css-dirs ["resources/public/css"]}

  :clean-targets ^{:protect false} ["resources/public/js"])
