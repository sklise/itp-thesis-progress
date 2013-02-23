var Post = Backbone.Model.extend({});
var Category = Backbone.Model.extend();

var Categories = Backbone.Collection.extend({
  model: Category
});

jQuery(function () {
  var PostView = Backbone.View.extend({
    initialize: function(){
      this.render();
    },

    render: function(){
      console.log(this.model.toJSON());
      var template = Handlebars.compile( $("#post-form-template").html() );
      this.el.html( template(this.model.toJSON()) );
    }
  });

  this.app = window.app != null ? window.app : {}
  this.app.PostView = PostView;
});