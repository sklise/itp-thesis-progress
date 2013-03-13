var Announcement = Backbone.Model.extend({
  urlRooot: '/announcements'
});

var Section = Backbone.Model.extend();

var Sections = Backbone.Collection.extend({
  model: Section
});

jQuery(function () {
  var AnnouncementView = Backbone.View.extend({
    el: '#announcement-form',
    templateSource: $('#announcement-form-template').html(),

    events: {
      'click .markdown-mark': 'toggleMarkdownGuide',
      'blur .announcement-title': 'updateTitle',
      'blur textarea' : 'updateContent'
    },

    initialize: function () {
      this.render().el;
      this.model.bind('change:title', this.render, this);
      this.model.bind('change:content', this.render, this);
    },

    render: function () {
      var tmpl = Handlebars.compile(this.templateSource);
      this.$el.html(tmpl(this.model.toJSON()));

      this.sectionSelect = new SectionsView({collection: this.model.sections});

      bindExpandingAreas();
      return this;
    },

    toggleMarkdownGuide: function () {
      $('#markdown-wrapper').toggle();
    },

    updateTitle: function () {
      this.model.set('title', this.$el.find('.announcement-title').val());
    },

    updateContent: function () {
      this.model.set('content', this.$el.find('textarea').val());
    },

    updateDraft: function () {
      this.set('draft', true);
      this.push();
    },

    updatePublish: function () {
      this.set('draft', false);
      this.push();
    },

    updateEmail: function () {
      this.set({
        'draft': false,
        'send_email': true
      });
      this.push();
    },

    push: function () {
      this.pending = true;
      this.trigger("pending");

      var view = this;

      this.model.save(this.model.attributes, {
        success: function () {
          if (window.location.pathname === "/announcements/new") {
            window.location.pathname = "/announcements/" + view.model.get('year') + "/" + view.model.get('id') + "/edit"
          } else {
            view.render().el;
          }
        },
        error: function () {
          view.render().el;
          view.$el.find('.publish-status').prepend('<p class="error"><strong>There was an error saving your announcement just now, please try again.</strong></p>');
        }
      });
    }
  });

  var SectionView = Backbone.View.extend({
    className: 'toggle-button',
    initialize: function () {
      this.render().el;
    },

    events: {
      'click': 'setunset'
    },

    render: function () {
      var tmpl = Handlebars.compile($('#section-template').html());
      this.$el.html(tmpl(this.model.toJSON()));
      if (this.model.get('selected') === true) {
        this.$el.addClass('selected')
      }
      return this;
    },

    setunset: function () {
      var selectState = this.model.get('selected');

      if (selectState === true) {
        this.model.set('selected', false);
      } else {
        this.model.set('selected', true);
      }

    }
  });

  var SectionsView = Backbone.View.extend({
    initialize: function () {
      this.render().el;
      this.collection.bind('change', this.render, this);
    },

    el: '.sections-place',

    render: function () {
      this.$el.empty();
      this.collection.forEach(function (section) {
        var sectionView = new SectionView({model: section});
        this.$el.append(sectionView.render().el)
      }, this);
      return this;
    }
  });

  var announcementData = $('#announcement-form').data();

  window.announcement = new Announcement(announcementData.announcement);
  announcement.sections = new Sections(announcementData.sections);

  window.announcementView = new AnnouncementView({model: announcement});
});