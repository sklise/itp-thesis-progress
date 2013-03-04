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
  'main.js',
  'expandingareas.js',
  'image_upload.js'
])
.uglify()
.save('app.min.js');

process.chdir('../css');

buildify().concat([
  'grid.css',
  'old.css',
  'thesis.css',
  'chosen.css',
  'print.css',
  'progress-form.css'
])
.cssmin()
.save('app.min.css');