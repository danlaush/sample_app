// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

Event.observe(window, 'load', function() {
	$('remaining_chars').innerHTML = "140 characters remaining";
	
	Event.observe('micropost_content', 'keyup', function(){
		var count = $('micropost_content').value.length
		$('remaining_chars').innerHTML = (140 - count) + " characters remaining";
		
		if (count > 140) {
			$('remaining_chars').setStyle({ color: 'red' });
		} else if (count > 120) {
			$('remaining_chars').setStyle({ color: 'orange' });
		} else {
			$('remaining_chars').setStyle({ color: 'black' });
		}
	});
});