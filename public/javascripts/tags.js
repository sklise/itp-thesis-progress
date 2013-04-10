var Tag = Backbone.Model.extend({
  urlRoot: '/api/tags'
});

var Tags = Backbone.Collection.extend({
  model: Tag,
  url: '/api/tags'
});

var Templates = {
  "tag" : "{{name}} <div class='tag-edit edit glyphicons'><i></i></div> <div class='tag-delete glyphicons remove_2'><i></i></div>",
  "editTag" : "<input type='text' class='name' value='{{name}}'/>"
}

$(function () {
  TagsView = Backbone.View.extend({
    tagName: "ul",
    el: '#tags',

    initialize: function () {
      this.collection.fetch();
      this.collection.bind('reset', this.render, this);
      this.collection.bind('add', this.render, this);
      this.collection.bind('remove', this.render, this);
    },

    render: function () {
      this.$el.empty();
      this.collection.forEach(function (tag) {
        var tagView = new TagView({model: tag});
        this.$el.append(tagView.render().el);
      }, this)
    }
  });

  TagView = Backbone.View.extend({
    tagName: "li",

    events: {
      'click .tag-edit': 'edit',
      'click .tag-delete': 'delete',
      'keypress input' : 'save'
    },

    initialize: function () {
      this.model.bind('sync', this.render, this);
    },

    render: function () {
      var t = Handlebars.compile(Templates['tag'])
      this.$el.html(t(this.model.toJSON()));
      return this;
    },

    edit: function () {
      this.$el.html(Handlebars.compile(Templates['editTag'])(this.model.toJSON()));
      this.$el.find('input').focus();
      return this;
    },

    save: function () {
      if (event.keyCode === 13) {
        this.model.set('name', this.$el.find('input').val());
        this.model.save();
      }
    },

    delete: function () {
      this.model.destroy();
    }
  });
  var NewTagView = Backbone.View.extend({});

  tv = new TagsView({collection: new Tags});
});