gulp = require 'gulp'
coffee = require 'gulp-coffee'
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

	gulp.src "#{src}/pure-min.css"
		.pipe gulp.dest("#{dest}/")

	gulp.src "#{src}/*.coffee"
		.pipe coffee(bare:true)
		.pipe gulp.dest("#{dest}/")

gulp.task "clean",(cb)->
	del "#{dest}/",cb

gulp.task "build",['clean'],build
