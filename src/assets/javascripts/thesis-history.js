var Thesis = Backbone.Model.extend({});

var Theses = Backbone.Collection.extend({
  model: Thesis,

  initialize: function () {
    this.setCurrent(_.last(this.ordered()));
  },

  setCurrent: function (thesis) {
    this.current = thesis;
    this.trigger('change:current');
  },

  getCurrent: function () {
    return this.current;
  },

  ordered: function () {
    return this.sortBy(function (thesis) {
      return thesis.get('created_at');
    })
  }
});

var TimelineView = Backbone.View.extend({
  el: '#thesis-history-container',

  template: function () {
    return Handlebars.compile($('#thesis-container-template').html());
  },

  initialize: function () {
    var timeline = this;
    this.collection.add(this.$el.data().theses);
    this.collection.setCurrent(_.last(this.collection.ordered()));
    this.render().el;
    this.collection.bind('change:current', this.render, this);
  },

  render: function () {
    this.$el.empty();
    this.$el.html(this.template()());
    var view = this;
    this.collection.ordered().forEach(function (thesis) {
      var v = new ThesisNodeView({model: thesis});
      if (view.collection.getCurrent() === thesis) {
        v.makeCurrent();
      }
      view.$el.find('#thesis-timeline').append(v.render().el);
    });

    this.thesisView = new ThesisHistoryView({model: this.collection.getCurrent() });
    return this;
  }
});

var ThesisNodeView = Backbone.View.extend({
  tagName: 'li',

  template: function () {
    return Handlebars.compile($('#thesis-node-template').html())
  },

  events: {
    'click' : 'setCurrent'
  },

  initialize: function () {
    this.render().el;
  },

  render: function () {
    this.$el.html(this.template()(this.model.toJSON()));
    return this;
  },

  setCurrent: function () {
    this.model.collection.setCurrent(this.model);
  },

  makeCurrent: function () {
    this.$el.addClass('current');
  }
});

var ThesisHistoryView = Backbone.View.extend({
  el: '#thesis-history-content',

  template: function () {
    return Handlebars.compile($('#thesis-history-template').html())
  },

  initialize: function () {
    console.log(this.model.attributes);
    this.render().el;
  },

  render: function () {
    this.$el.empty();
    this.$el.html(this.template()(this.model.toJSON()));
    return this;
  }
});


$(function () {
  timeline = new TimelineView({collection: new Theses()});
});
