$(function() {
  if (window.location.href.match(/\/status\/?$/)) {
    statusPath = window.location.href;
  }
  else if (window.location.href.match(/\/$/)) {
    statusPath = window.location.href + "status";
  }
  else {
    statusPath = window.location.href + "/status";
  }

  setInterval("$.getScript(statusPath)", 2000);
});
