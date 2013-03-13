var Announcement = Backbone.Model.extend({
  urlRoot: '/announcements'
});

var Section = Backbone.Model.extend();

var Sections = Backbone.Collection.extend({
  model: Section,

  setSections: function (ids) {
    this.forEach(function (section) {
      if (_.contains(ids, section.get('id'))) {
        section.set('selected', true);
      }
    })
  },

  selectedSections: function () {
    return this.filter(function (section) {
      return section.get('selected') === true;
    });
  },

  selectedSectionIds: function () {
    return _.map(this.selectedSections(), function (section) {
      return section.get('id');
    });
  }
});

jQuery(function () {
  var AnnouncementView = Backbone.View.extend({
    el: '#announcement-form',
    templateSource: $('#announcement-form-template').html(),

    events: {
      'click .markdown-mark': 'toggleMarkdownGuide',
      'blur .announcement-title': 'updateTitle',
      'blur textarea' : 'updateContent',
      'click .make-draft' : 'updateDraft',
      'click .make-publish' : 'updatePublish',
      'click .make-email' : 'updateEmail'
    },

    initialize: function () {
      this.render().el;
      this.model.bind('change:title', this.updateTitle, this);
      this.model.bind('change:content', this.updateContent, this);
      this.model.sections.bind('change', this.setSections, this);
      this.bind('pending', this.pending, this);

      this.model.sections.setSections($('#announcement-form').data().sectionids);
    },

    pending: function () {
      this.$el.find('.the-form').addClass('pending');
    },

    render: function () {
      var tmpl = Handlebars.compile(this.templateSource);
      this.$el.html(tmpl(this.model.toJSON()));

      this.sectionSelect = new SectionsView({collection: this.model.sections});

      bindExpandingAreas();
      return this;
    },

    setSections: function () {
      var selectedSections = this.model.sections.selectedSectionIds();
      this.model.set('section_ids', selectedSections);

      if (selectedSections.length === this.model.sections.length) {
        this.model.set('everyone', true);
      } else {
        this.model.set('everyone', false);
      }
    },

    toggleMarkdownGuide: function () {
      $('#markdown-wrapper').toggle();
    },

    updateContent: function () {
      this.model.set('content', this.$el.find('textarea').val());
    },

    updateDraft: function () {
      this.model.set('draft', true);
      this.push();
    },

    updateEmail: function () {
      this.model.set({
        'draft': false,
        'send_email': true
      });
      this.push();
    },

    updatePublish: function () {
      this.model.set('draft', false);
      this.push();
    },

    updateTitle: function () {
      this.model.set('title', this.$el.find('.announcement-title').val());
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
          view.$el.find('.publish-status').addClass('info').prepend('<p class="error"><strong>There was an error saving your announcement just now, please try again.</strong></p>');
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