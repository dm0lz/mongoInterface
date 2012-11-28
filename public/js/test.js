$( function () {
	$("section.navbar-inner").bind('click', function () {
		if ($(this).hasClass('down')) {
	    $(this).removeClass('down');
	    $(this).addClass('up');
	  } else {
	    $(this).removeClass('up');
	    $(this).toggleClass('down');
	  }
	});
});