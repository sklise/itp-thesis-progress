//
// MODELS
//
var Post = Backbone.Model.extend({
  urlRoot: '/posts'
});

var Category = Backbone.Model.extend();

//
// COLLECTIONS
//
var Categories = Backbone.Collection.extend({
  model: Category,

  selectedCategory : function () {
    return this.find(function (category) {
      return category.get('selected') === true;
    });
  },

  setCategory: function (categoryId) {
    this.forEach(function (category) {
      if (category.get('id') === categoryId) {
        category.set('selected', true);
      } else {
        category.unset('selected');
      }
    });
  },

  unsetCategory: function () {
    this.forEach(function (category) {
      category.unset('selected');
    });
  }
});

//
// VIEWS
//
jQuery(function () {
  var PostView = Backbone.View.extend({
    initialize: function(){
      this.render().el;
      this.model.bind('change:privacy', this.render, this);
      this.bind('pending', this.pending, this);
      this.model.categories.bind('change', this.setCategory, this);
      this.model.categories.setCategory(this.model.get('category_id'))
    },

    el: '#post-form',

    events: {
      'click .privacy' : 'changePrivacy',
      'blur .post-title' : 'updateTitle',
      'blur textarea' : 'updateContent',
      'click .make-draft' : 'updateDraft',
      'click .make-publish' : 'updatePublish',
      'click .markdown-mark' : 'toggleMarkdownGuide'
    },

    templateSource: $('#post-form-template').html(),

    render: function(){
      var template = Handlebars.compile( this.templateSource );
      this.$el.html( template(this.model.toJSON()) );

      this.categorySelect = new CategoriesView({collection: this.model.categories});

      bindExpandingAreas();
      return this;
    },

    updateTitle: function () {
      this.model.set('title', this.$el.find('.post-title').val());
    },

    updateContent: function () {
      this.model.set('content', this.$el.find('textarea').val())
    },

    changePrivacy: function (e) {
      console.log('hey!')
      this.model.set('is_public', $(e.target).data().privacy);
      this.model.trigger('change:privacy');
    },

    toggleMarkdownGuide: function () {
      $('#markdown-wrapper').toggle();
    },

    setCategory: function (e) {
      var selectedCategory = this.model.categories.selectedCategory();

      var id;

      if (typeof selectedCategory === 'undefined') {
        id = null;
      } else {
        id = selectedCategory.get('id')
      }

      this.model.set('category_id', id);
    },

    updateDraft: function () {
      this.model.set('draft', true);
      this.publishIt();
    },

    updatePublish: function () {
      this.model.set('draft', false);
      this.publishIt();
    },

    publishIt: function () {
      this.pending = true;
      this.trigger("pending");

      var view = this;

      this.model.save(this.model.attributes, {
        success: function () {
          if (window.location.pathname === "/posts/new") {
            window.location.pathname = "/posts/"+view.model.get('id')+"/edit"
          } else {
            view.render().el;
          }
        },
        error: function () {
          view.render().el;
          view.$el.find('.publish-status').prepend('<p class="error"><strong>There was an error saving your post just now, please try again.</strong></p>');
        }
      });
    },

    pending: function () {
      this.$el.find('.the-form').addClass('pending');
    }
  });

  var CategoriesView = Backbone.View.extend({
    initialize: function () {
      this.render().el;
      this.collection.bind('change', this.render, this);
    },

    el: '.categories-choice',

    events: {
      'click a': 'unsetCategory'
    },

    unsetCategory: function () {
      this.collection.unsetCategory();
      return false;
    },

    templateSource: Handlebars.compile($('#categories-choice-template').html()),

    render: function () {
      this.$el.html(this.templateSource({category_id: this.collection.selectedCategory()}));
      this.collection.forEach(function (category) {
        var categoryV = new CategoryView({model: category});
        this.$el.find('.categories-place').append(categoryV.render().el);
      }, this);
      return this;
    }
  });

  var CategoryView = Backbone.View.extend({
    className: 'toggle-button',
    initialize: function () {
      this.render().el;
    },

    events: {
      'click': 'setCategory'
    },

    setCategory: function () {
      this.model.collection.setCategory(this.model.id);
    },

    render: function () {
      var categoryTemplate = Handlebars.compile($('#category-template').html());
      this.$el.html(categoryTemplate(this.model.toJSON()));
      if (this.model.get('selected') === true) {
        this.$el.addClass('selected')
      }
      return this;
    }
  })

  var postFormData = $('#post-form').data();

  window.post = new Post(postFormData.post);
  post.categories = new Categories(postFormData.categories);

  window.postView = new PostView({model: post});
});