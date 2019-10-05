import {task, src, dest, series, watch} from 'gulp';
import sass, {logError} from 'gulp-sass';
import concatCss from 'gulp-concat-css';
import del from 'del';

const SASS_PATH = 'src/cljs/**/*.sass'
const CSS_BUILD_PATH = 'build/css';
const CSS_PATH = `${CSS_BUILD_PATH}/**/*.css`;
const CSS_BUNDLE_PATH = 'resources/public/css';
const CSS_BUNDLE_NAME = 'main.css';

task('sass->css', () => src(SASS_PATH)
    .pipe(sass().on('error', logError))
    .pipe(dest(CSS_BUILD_PATH)));

task('concat-css', () => src(CSS_PATH)
    .pipe(concatCss(CSS_BUNDLE_NAME))
    .pipe(dest(CSS_BUNDLE_PATH)));

task('clean-build', () => del([
    `${CSS_BUILD_PATH}/*`
]));

task('clean-bundle', () => del([
    `${CSS_BUNDLE_PATH}/${CSS_BUNDLE_NAME}`
]));

task('clean', series(['clean-build', 'clean-bundle']));
task('sass', series(['clean', 'sass->css', 'concat-css', 'clean-build']));
task('sass:watch', () => watch(SASS_PATH, series(['clean-bundle', 'sass->css', 'concat-css'])));