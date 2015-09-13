gulp = require 'gulp'
coffee = require 'gulp-coffee'
watch =require 'gulp-watch'
batch = require 'gulp-batch'
del = require 'del'
replace = require 'gulp-replace'
pkg = require './package.json'

src='./src'
dest='./build'

ver=pkg.version

build=()->
  gulp.src "#{src}/manifest.json"
    .pipe replace(/\{version\}/g,ver)
    .pipe gulp.dest("#{dest}/")

  gulp.src "#{src}/*.html"
    .pipe gulp.dest("#{dest}/")

  gulp.src "#{src}/images/*"
    .pipe gulp.dest("#{dest}/images/")

  gulp.src "#{src}/css/*"
    .pipe gulp.dest("#{dest}/css")

  gulp.src "#{src}/fonts/*"
    .pipe gulp.dest("#{dest}/fonts")

  gulp.src "#{src}/scripts/*"
    .pipe gulp.dest("#{dest}/scripts/")

  gulp.src "#{src}/*.coffee"
    .pipe coffee(bare:true)
    .pipe gulp.dest("#{dest}/")

gulp.task "clean",(cb)->
  del "#{dest}/",cb

gulp.task "build",['clean'],build

gulp.task 'watch', ()->
  gulp.watch "#{src}/*.js", ["build"]
  gulp.watch "#{src}/*.html", ["build"]