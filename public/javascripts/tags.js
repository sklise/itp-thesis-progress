var Tag = Backbone.Model.extend({
  urlRoot: '/api/tags'
});

var Tags = Backbone.Collection.extend({
  model: Tag,
  url: '/api/tags'
});

var Templates = {
  "tag" : "{{name}} <div class='tag-edit edit glyphicons'><i></i></div> <div class='tag-delete glyphicons remove_2'><i></i></div>",
  "editTag" : "<input type='text' class='name' value='{{name}}'/>",
  "newTag" : "<input type='text' class='name' placeholder='Name for new tag'/>"
}

$(function () {
  TagsView = Backbone.View.extend({
    el: '#tags',

    initialize: function () {
      this.collection.fetch();
      this.collection.bind('reset', this.render, this);
      this.collection.bind('add', this.render, this);
      this.collection.bind('sync', this.render, this);
      this.collection.bind('change', this.render, this);
      this.collection.bind('remove', this.render, this);
    },

    render: function () {
      this.$el.empty();
      var ntv = new NewTagView({collection: this.collection})
      this.$el.append(ntv.render().el);

      var sorted = this.collection.sortBy(function (tag) {
        return tag.get('name').toLowerCase();
      });

      sorted.forEach(function (tag) {
        var tagView = new TagView({model: tag});
        this.$el.append(tagView.render().el);
      }, this);
    }
  });

  NewTagView = Backbone.View.extend({
    tagName: "li",

    events: {
      'keypress input' : 'save'
    },

    initialize: function () {
      console.log("new tag view");
      this.render().el;
    },

    render: function () {
      var template = Handlebars.compile(Templates['newTag']);
      this.$el.html(template());
      return this;
    },

    save: function () {
      if (event.keyCode === 13) {
        var tagname = this.$el.find('input').val();

        if (tagname.length > 0) {
          var tag = this.collection.create({name: this.$el.find('input').val()});
        }
      }
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

  tv = new TagsView({collection: new Tags});
});