$(function(){
    window.addEventListener("message", function(event){   
        if(event.data.options){
          var options = event.data.options;
          new Noty(options).show();
        }else{
          var maxNotifications = event.data.maxNotifications;
          Noty.setMaxVisible(maxNotifications.max, maxNotifications.queue);
        };
    });
	
	/*var options = new Object();
		options.type = "success";
		options.layout = "centerLeft";
		options.theme = "gta";
		options.text = "Empty Notification";
		options.timeout = 500000;
		options.progressBar = true;
		options.modal = false;
		options.id = false;
		options.force = false;
		options.queue = "global";
		options.killer = false;
		options.container = false;
		options.buttons = false;
		
		new Noty(options).show();
		
		console.log('show fucking')*/
});