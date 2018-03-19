  $( function() {

    //var object = { "soldier":{"y":2},"SUV":{"y":2},"UAV":{"y":1} };
    
	 //------------------------------
    function refresh_img() 
	 {
      //var obj_y_m = object["soldier"]["y"];
     
		var obj_selected = $( "#obj_select" ).val();
		console.log(obj_selected);
	
      var obj_y_m = Objective[obj_selected]["y"];
		
		//var img_src = "/lens_scale/img/" + obj_selected + "_silhouette.png"; 
		var img_src = "./img/" + obj_selected + ".svg"; 
		$( "#preview0" ).attr('src', img_src);
		
		//var dist_z = $( "#slider" ).slider( "value" );
	   var dist_z = get_dist_z();
	
      var fov_lst = calc_fov(dist_z);
      var fov_x_m = fov_lst[0];
      var fov_y_m = fov_lst[1];
				
		var win_y_px = resize_win();
	   var obj_y_px = (obj_y_m / fov_y_m) * win_y_px;
		
		if (typeof fov_lst[2] !== 'undefined') 
		{
		   var sen_x_px = fov_lst[2];
			var ppmh = Math.round(sen_x_px/fov_x_m); 
         
			$("#ppm_row").show()
         $("#ppmh").html(  ppmh );
		
			console.log("hppm=",ppmh);
	   }
		else
		{
			$("#ppm_row").hide()
		}		
		
					
	   // Update Labelling  
      $( "#slider_val" ).text( dist_z + "m" );
      $( "#dist_z_txt" ).text( dist_z + "m" );
		
		var haov = 2 * rad2deg( Math.atan( (fov_x_m/2)/dist_z ));
		var vaov = 2 * rad2deg( Math.atan( (fov_y_m/2)/dist_z ));
		
      $("#aov_wxh").html(  haov.toFixed(1) + "&deg; x " + vaov.toFixed(1) + "&deg;" );
      $("#fov_wxh").html(  fov_x_m.toFixed(1) + "m x " + fov_y_m.toFixed(1) + "m" );
		
      $( "#preview0" ).css("height",obj_y_px);
		
		var offset_bottom = Math.round( (win_y_px - obj_y_px)/2 );
		//console.log(offset_bottom);
		
		$( "#preview0" ).css("bottom",offset_bottom);
    };

	 //------------------------------
    function calc_fov(dist_z)
    {
        var device = $("#ccd_select").val();
        var ccd_y = Ccd[device]["y"];
        var ccd_x = Ccd[device]["x"];
        var lens_mm = $("#lens_mm").val();

		  // Proportion  
        var fov_y_m = ( ccd_y/lens_mm ) * dist_z;
        var fov_x_m = ( ccd_x/lens_mm ) * dist_z;
  
        var ccd_y_px = Ccd[device]["y_px"];
        var ccd_x_px = Ccd[device]["x_px"];
  
		  return [fov_x_m,fov_y_m,ccd_x_px,ccd_y_px];
    }

	 //------------------------------
    function resize_win()
    {
		  // Need to calculate the height based on sensor geometry... 
	     var win_x_px = $("#fov_col").width();
      		  
        var ccd_select = $("#ccd_select").val();
        var ratio = Ccd[ccd_select]["ratio"];
        var win_y_px = Math.round(win_x_px / ratio);

		  // Size the fov 
        $("#fov_div").css( {"width":win_x_px.toString()+"px","height":win_y_px.toString()+"px"} );
        //$("#fov_div").width(win_x_px);
        //$("#fov_div").height(win_y_px);

		  // Update html tags 
		  $("#sensor_wxh").html(  Ccd[ccd_select]['x'] + "mm x " + Ccd[ccd_select]['y'] + "mm" );
		  $("#sensor").html(  ccd_select );
		  $("#lens_mm_txt").html(  $("#lens_mm").val() + "mm" );
		  $("#ratio").html(  ratio.toFixed(3) );
		  
		  console.log("x,y=",win_x_px,win_y_px,win_x_px/win_y_px,ratio);
		  return(win_y_px);
	 }

	function get_URL_parameter(param_wanted)
   {
     var URL_str = window.location.search.substring(1);
     var URL_components = URL_str.split('&');
     for (var i = 0; i < URL_components.length; i++)
     {
        var URL_varname = URL_components[i].split('=');
        if (URL_varname[0] == param_wanted) { return URL_varname[1]; }
	  }
	}	  

   // -- Translation functions for slider --------------------------------
	function get_dist_z()
	{
		var slide_pos = $( "#slider" ).slider( "value" );
		dist_z = Math.round (Math.pow(slide_pos/1000,4) ); 
		//console.log("slide,dist=",slide_pos,dist_z)
		//dist_z = slide_pos; 
	   return dist_z;
	}

	function set_dist_z(dist_z)
	{
		slide_pos = Math.round( Math.pow(dist_z,.25)*1000 );
		//slide_pos = dist_z;
		$( "#slider" ).slider( "value",slide_pos );
		return slide_pos; 
	}

	// Init slider	
   $( "#slider" ).slider({
      orientation: "horizontal",
      min: 1000,
      max: 15*1000,
      //max: 50000,
      slide: refresh_img,
      change: refresh_img
   });
	
	// Get url dist_z or set default value 
   var url_dist_z = get_URL_parameter('dist_z');	
   if (typeof url_dist_z === 'undefined' ) { url_dist_z = 10 } 
	set_dist_z(url_dist_z)
	
	// -- Utility functions --------------------------------------
	function rad2deg(rad) {  return rad * (180 / Math.PI); }
	
	// -- Events -------------------------------------------------------
   $( "#ccd_select" ).change(function() { resize_win(); refresh_img(); });

 	$( "#obj_select" ).change(function() { refresh_img(); });

   $( "#lens_mm" ).change(function() { refresh_img(); });
   $( "#lens_mm" ).blur(function() { refresh_img();});
	$('#lens_mm').keypress(function (e) 
	{
		var key = e.which;
		if(key == 13)  // the enter key code
		{
			refresh_img();
			return false;  
		}
   });  
	 
	// Submit button 
	$( "#create_url" ).click( function()
	{ 
		var dist_z = get_dist_z();
		$("#dist_z").val( dist_z );
		
		$("#lens_calc").submit(); 
	});
   //// -----

   resize_win();
	refresh_img();

	$(window).resize(function() 
	{
		//	var viewportWidth = $(window).width();
		//	var viewportHeight = $(window).height();
		//	console.log("viewport=",viewportWidth,viewportHeight);
		resize_win();
   	refresh_img();
  });
		
  } );