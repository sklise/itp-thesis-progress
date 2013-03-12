//
// MODELS
//
var Post = Backbone.Model.extend({
  urlRoot: '/posts'
});

var Category = Backbone.Model.extend();
var Assignment = Backbone.Model.extend();

//
// COLLECTIONS
//
var Assignments = Backbone.Collection.extend({
  model: Assignment,

  selectedAssignment : function () {
    return this.find(function (assignment) {
      return assignment.get('selected') === true;
    })
  },

  setAssignment: function (assignmentId) {
    this.forEach(function (assignment) {
      if (assignment.get('id') === parseInt(assignmentId)) {
        assignment.set('selected', true);
      } else {
        assignment.unset('selected');
      }
    });
  }
});

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
      this.model.assignments.bind('change', this.setAssignment, this);
      this.model.categories.bind('change', this.setCategory, this);
      this.model.categories.setCategory(this.model.get('category_id'))
      this.model.assignments.setAssignment(this.model.get('assignment_id'))
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

      this.assignmentsSelect = new AssignmentsView({collection: this.model.assignments});
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

    setAssignment: function () {
      var selectedAssignment = this.model.assignments.selectedAssignment();

      if (typeof selectedAssignment === 'undefined') {
        this.model.set('assignment_id', null)
      } else {
        this.model.set('assignment_id', selectedAssignment.get('id'));
      }
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
      var p = this.model;
      p.set({
        'draft': true,
        'title': S(p.get('title')).escapeHTML().s,
        'content': p.get('content')
      });
      this.publishIt();
    },

    updatePublish: function () {
      var p = this.model;

      p.set({
        'draft': false,
        'title': S(p.get('title')).escapeHTML().s,
        'content': p.get('content')
      });
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

  var AssignmentsView = Backbone.View.extend({
    initialize: function () {
      this.render().el;
      this.collection.bind('change', this.render, this);
    },

    events: {
      'change .assignments-select' : 'chooseAssignment'
    },

    el: '.assignments-choice',

    templateSource: $('#assignments-choice-template').html(),

    chooseAssignment: function () {
      this.collection.setAssignment(this.$el.find('.assignments-select').first().val());
    },

    render: function () {
      var template = Handlebars.compile(this.templateSource);
      var c = this.collection.toJSON();
      var templateModel = {};

      var selectedAssignment = this.collection.selectedAssignment()

      if (typeof selectedAssignment !== 'undefined' ) {
        templateModel = selectedAssignment.toJSON();
      }
      this.$el.html(template( templateModel ));
      this.collection.forEach(function (assignment) {
        var assignmentTemplate = Handlebars.compile('<option {{#if selected}}selected{{/if}} value="{{ id }}">{{ title }}</option>')(assignment.toJSON());
        this.$el.find('.assignments-select').append(assignmentTemplate);
      }, this);
      $('.assignments-select').chosen();
      return this;
    }
  });

  var postFormData = $('#post-form').data();

  window.post = new Post(postFormData.post);
  post.assignments =  new Assignments(postFormData.assignments);
  post.categories = new Categories(postFormData.categories);

  window.postView = new PostView({model: post});
});