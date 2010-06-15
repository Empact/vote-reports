// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
//
;(function($) {
  $.fn.fadeOutSoon = function(when, length) {
    if (typeof when == "undefined") when = 5000;
    if (typeof length == "undefined") length = 1000;
    var self = $(this);
    setTimeout(function() {
      self.fadeOut(length)
    }, when);
    return self;
  };

  $(document).ready(function(){
    $('.flash.success, .flash.notice, .flash.message').fadeOutSoon(3000);
    $('.flash.error, .flash.warning').fadeOutSoon(5000, 5000);

    $('.selectable').live('update_selected', function(event) {
      $(event.target).closest('.selectable').toggleClass('selected');
      return true;
    });

    $('[data-dialog]').live('mouseover', function() {
      var target = $('#' + $(this).attr('data-dialog'));
      target.dialog({
        autoOpen: false,
        title: target.attr('data-dialog-title'),
        width: target.attr('data-dialog-width') || 740});
    });
    $('[data-dialog]').live('click', function(event) {
      $('#' + $(event.target).attr('data-dialog')).dialog('open');
      return false;
    });

    $('[data-toggle]').live('click', function(event) {
      $.each($(event.target).attr('data-toggle').split(', '), function() {
        $('#' + this).toggle();
      })
      return false;
    });

    $('[data-tab-select]').live('click', function(event) {
      $current_tabs.tabs('select', $(event.target).attr('data-tab-select'));
      return false;
    });

    $('[data-hover]').live('mouseover', function() {
      var hoverable = $(this);
      if (!hoverable.data('hover-init')) {
        hoverable.data('hover-init', true);
        var target = $('#' + hoverable.attr('data-hover'));
        hoverable.hoverIntent({
          timeout: 500,
          over: function() { target.fadeIn(); },
          out: function() { target.fadeOut(); }
        });
        hoverable.mouseover();
      }
    });

    $('.hoverable, .dropdown').live('mouseover', function() {
      var self = $(this);
      if (!self.data('init')) {
        self.data('init', true);
        self.hoverIntent({
          timeout: 500,
          over: function() { $(this).addClass("hovering"); },
          out: function() { $(this).removeClass("hovering"); }
        });
        self.mouseover();
      }
    });

    $('.fieldtag').fieldtag();
    $('label.fieldtag').hide();

    $("#nav_search").autocomplete({
      source: "/search",
      minLength: 2,
      select: function(event, ui) {
        window.location = ui.item.path;
      }
    });

    $('.fancyboxy').live('mouseover', function() {
      var self = $(this);
      if (!self.data('init')) {
        self.data('init', true);
        self.fancybox({
          hideOnContentClick: false
        });
        self.mouseover();
      }
    });
  });

  $current_tabs = $(".ui-tabs").tabs();

  $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;
  $.ajaxSetup({
    beforeSend: function(xhr) {
      xhr.setRequestHeader("Accept", "text/javascript");
    }
  });
})(jQuery);
