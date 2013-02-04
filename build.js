var buildify = require('buildify');

process.chdir('public/javascripts');

buildify().concat([
  'jquery.js',
  'jquery-ui.js',
  'underscore.js',
  'moment.js',
  'string.min.js',
  'handlebars.js',
  'chosen.jquery.js',
  'main.js',
  'image_upload.js'
]).save('app.js')
.uglify()
.save('app.min.js');

process.chdir('../css');

buildify().concat([
  'jquery-ui.css',
  'grid.css',
  'old.css',
  'thesis.css',
  'chosen.css',
  'print.css'
]).save('app.css')
.cssmin()
.save('app.min.css');