var config = {
  feedUrl: "http://feeds.delicious.com/v2/json/avityuk",
  linksCount: 30
}

function loadLinks() {
  $.ajax({
    url: config.feedUrl,
    dataType: "jsonp",
    data: {
      count: config.linksCount
    },
    success: function(data) {
      $(data).each(function(i, v) {
        $("#my_links").append("<li><a href='" + v.u + "'>" + v.d + "</a></li>");
      });
    }
  });
}