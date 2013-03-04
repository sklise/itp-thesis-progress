var buildify = require('buildify');

process.chdir('public/javascripts');

buildify().concat([
  'jquery.js',
  'underscore.js',
  'backbone.js',
  'moment.js',
  'string.min.js',
  'handlebars.js',
  'chosen.jquery.js',
  'htmlparser.js',
  'marked.js',
  'main.js',
  'expandingareas.js',
  'image_upload.js'
])
.uglify()
.save('app.min.js');

process.chdir('../css');

buildify().concat([
  'glyphicons.css',
  'grid.css',
  'old.css',
  'chosen.css',
  'thesis.css',
  'progress-form.css',
  'print.css'
])
.cssmin()
.save('app.min.css');