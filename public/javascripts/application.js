// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults
// 
;(function($) {
  $.fn.fadeOutSoon = function(when, length) {
    if (typeof when == "undefined") when = 5000;
    if (typeof length == "undefined") length = 1000;
    var $this = $(this);
    setTimeout(function() {
      $this.fadeOut(length)
    }, when);
    return $this;
  };
  
  $(document).ready(function(){

    $('.flash').fadeOutSoon(1000);

    $('[data-dialog]').each(function() {
        $($(this).attr('data-dialog')).dialog({
          autoOpen: false,
          title: $(this).attr('data-dialog-title'),
          width: 800});
    });
    $('[data-dialog]').click(function(event) {
        $($(event.target).attr('data-dialog')).dialog('open');
        return false;
    });

    $('[data-toggle]').click(function(event) {
      $($(event.target).attr('data-toggle')).toggle();
      return false;
    })

    $('[data-replace] a, a[data-replace]').live('click', function(event) {
      var target = $(event.target);
      $(target.closest('[data-replace]').attr('data-replace')).load(target.attr('href'));

      return false;
    })

    $('form[data-replace]').submit(function(event){
      var target = $(event.target);
      $(target.attr('data-replace')).load(target.attr('action') + '?' + target.serialize());

      return false;
    });

  });
  $.ajaxSettings.accepts.html = $.ajaxSettings.accepts.script;
})(jQuery);


