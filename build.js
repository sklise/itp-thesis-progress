var buildify = require('buildify');

process.chdir('public/javascripts');

buildify().concat([
  'libraries/jquery.js',
  'libraries/underscore.js',
  'libraries/backbone.js',
  'libraries/moment.js',
  'libraries/string.min.js',
  'libraries/handlebars.js',
  'libraries/chosen.jquery.js',
  'handlebars-helpers.js',
  'main.js',
  'expandingareas.js',
  'image_upload.js'
])
.uglify()
.save('application325.min.js');

process.chdir('../css');

buildify().concat([
  'glyphicons.css',
  'grid.css',
  'chosen.css',
  'thesis.css',
  'progress-form.css'
])
.cssmin()
.save('application.min.css');