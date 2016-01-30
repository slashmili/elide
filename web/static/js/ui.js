export var ui = {
  run: function(){
    var short_url_copy = new Clipboard('.short-url-copy');
    $('[data-toggle="tooltip"]').tooltip();
    var url_count = 1;
    $('.elink-more-url').click(function (e) {
        url_count += 1;
        var url_input = $('.elink-url-base').html()
            .replace('urls_url_1', 'urls_url_' + url_count)
            .replace('urls-item-1', 'urls-item-' + url_count)
            .replace('urls[url_1]', 'urls[url_' + url_count + ']');
        $('.elink-extra-urls').html(
            $('.elink-extra-urls').html() + url_input
        );
        $(`#urls-item-${url_count} .elink-url-del`).click(function (e, item) {
            $(this).parent().remove()
            e.preventDefault();
        });
        e.preventDefault()
    });
  }
}

// @TODO: find an alternarive way for this
ui.run()
