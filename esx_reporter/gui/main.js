var snd = new Audio("alert.mp3");

function alert(volume){
    snd.volume = volume;
	snd.loop = false;
    snd.play();
    setTimeout(function(){
        snd.pause();
        snd.currentTime = 0;
        //document.body.style.display = "none";
		hideAlert();
    }, 22000);
}

function hideAlert() {
    $('.eas').show().removeClass('zoomInDown').addClass('zoomOut');
	setTimeout(function(){
		$('body').hide();
		$('.eas').hide();
	}, 3500); 
} 

function showAlert(message, volume) {
	$('.eas_alerter').html('<marquee behavior="scroll" direction="left" scrollamount="10"><p>'+message+'</p></marquee>');
            //document.body.style.display = event.data.enable ? "block" : "none";
	$('body').show();
	$('.eas').show().removeClass('zoomOut').addClass('zoomInDown');
	alert(volume)
}

$(function() {
	
	window.addEventListener('message', function(event) {
		if (event.data.type == "alert") {
			if ($('body').is(":hidden")) {
				showAlert(event.data.message, event.data.volume)
			}
            
		}
	});
	
	window.addEventListener('hide', function(event) {
		hideAlert();
	});
});