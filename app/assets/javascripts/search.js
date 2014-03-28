$('#searchform').onsubmit = function() { return false }
$('#search').keydown(function() {
  var searchVal = $(this).val()
  if (searchVal.length > 2) {
    $('a').not('a[href*="'+searchVal+'"]').parent().parent().css('display', 'none')
    $('a[href*="'+searchVal+'"]').parent().parent().css('display', 'block')
  }
  else {
    $('a').parent().parent().css('display', 'block')
  }
})