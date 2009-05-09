var resize = function() {
  var frame = $("iframe");
  frame.height($(window).height() - frame.offset().top);
};

$(window).load(resize);
$(window).resize(resize);