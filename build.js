var buildify = require('buildify');
var exec = require('child_process').exec;

process.chdir('public/javascripts');

buildify().concat([
  'libraries/jquery.js',
  'libraries/underscore.js',
  'libraries/backbone.js',
  'libraries/moment.js',
  'libraries/string.min.js',
  'libraries/handlebars.js',
  'libraries/chosen.jquery.js',
  'libraries/marked.js',
  'handlebars-helpers.js',
  'main.js',
  'expandingareas.js',
  'image_upload.js'
])
.uglify()
.save('application.min.js');

process.chdir('../css');

buildify().concat([
  'glyphicons.css',
  'grid.css',
  'chosen.css',
  'thesis.css',
  'sections.css',
  'progress-form.css'
])
.cssmin()
.save('application.min.css');

exec('heroku releases --app itpthesisprogress', function (err, resp) {
  if (err) return;
  var rev = resp.split(/\n/)[1].split(' ')[0] || 'v1';
  exec("heroku config:add REV="+rev + " --app itpthesisprogress", function(e,r) {console.log(e,r)});
});