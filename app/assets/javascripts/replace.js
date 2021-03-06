//= require jquery.pjax

;(function($) {
  function current_url() {
    return window.location.protocol + '//' + window.location.host + window.location.pathname;
  }

  function params_to_path(target_id, url) {
    return target_id + '/' + url.substring(url.indexOf('?') + 1);
  }

  function replaceWith(target_ids, url, mode) {
    function success_callback() {
        target.unblock();
        if (typeof(init_map) != 'undefined' && $.isFunction(init_map)) {
          init_map();
        }
    }

    var target_id = $(target_ids.split(' ')).select(function() {
      return $('#' + this + ':visible').length != 0;
    });

    var target = $('#' + target_id + ':visible');
    if (target.length == 0) {
      return true;
    }
    target.block({message: '<p class="loading">Loading...</p>'});
    if (mode == 'pjax') {
      $.pjax({
        url: url,
        container: '#' + target_id,
        timeout: null
      });
      target.bind('pjax:end', success_callback);
    } else {
      target.load(url, success_callback);
    }
    return false;
  }

  $(function(){
    $('.act-fill').each(function() {
      var self = $(this);
      replaceWith(self.attr('id'), self.attr('rel'));
    });

    $('.act-refresh').each(function() {
      var self = $(this);
      function refresh() {
        self.load(current_url(), function() {
          self.show('highlight', {}, 2000);
        });
      }

      setInterval(refresh, 10000);
    });

    $(':input.act-replace').live('click', function(event) {
      var target = $(event.target);
      replaceWith(
        target.attr('rel'),
        current_url() + '?' + target.closest('form').serialize(),
        'pjax');
      return true;
    });

    $('.act-replace > a, .act-replace > .pagination a, a.act-replace').live('click', function(event) {
      var target = $(event.target);
      target.trigger('update_selected');
      return replaceWith(target.closest('.act-replace').attr('rel'), target.attr('href'), 'pjax');
    })

    $('form.act-replace :submit').live('click', function(event){
      var source = $(event.target);
      var form = source.closest('form');
      var target = form.attr('action') + '?' + form.serialize();
      if (source.attr('name')) {
        var args = {}
        args[source.attr('name')] = source.attr('value')
        target += '&' + $.param(args);
      }
      return replaceWith(form.attr('rel'), target, 'pjax');
    });

    $('form.act-replace').live('submit', function(event){
      var source = $(event.target);
      return replaceWith(source.attr('rel'), source.attr('action') + '?' + source.serialize(), 'pjax');
    });

    $('form#guide_causes :submit').live('click', function(event) {
      var source = $(event.target);
      var form = source.closest('form');

      if (!source.hasClass('selected')) {
        var sibling = source.closest('ul').find('li:has(button.selected)')
        var params = {};
        if (sibling.length > 0) {
          var sibling_button = sibling.find('button.selected');
          sibling_button.removeClass('selected');
          params['remove'] = sibling_button.attr('value');
        }
        if (source.is('[name=support]')) {
          params['support'] = source.attr('value');
        } else if (source.is('[name=oppose]')) {
          params['oppose'] = source.attr('value');
        }

        source.addClass('selected');
        replaceWith(form.attr('rel'), form.attr('action') + '?' + form.serialize() + '&' + $.param(params));
      }

      var next = form.find('li.question:not(:has(button.selected))');
      if (next.length > 0) {
        form.find('li.question').hide();
        form.find('li.question#' + next.attr('id')).show();
      }

      return false;
    });
  });
})(jQuery);
