var config = {
  feedUrl: "http://feeds.delicious.com/v2/json/avityuk"
}

function loadAllLinks() {
  loadLinks($("#all-links"), 30);
}

function loadSidebarLinks() {
  loadLinks($("#links-list"), 5);
}

function loadLinks(element, maxLinks) {
  $.ajax({
    url: config.feedUrl,
    dataType: "jsonp",
    data: {
      count: maxLinks
    },
    success: function(data) {
      var links = $("<ul class='links-list'></ul>");
      $(data).each(function(i, v) {
        links.append("<li><a href='" + v.u + "'>" + v.d + "</a></li>");
      });
      element.prepend(links);
    }
  });
}