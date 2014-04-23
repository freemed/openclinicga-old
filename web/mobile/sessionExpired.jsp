<html>
<head>
  <link href="/openclinic/mobile/_css/web.css" rel="stylesheet" type="text/css">
  <link rel="shortcut icon" href="/openclinic/_img/openclinic.ico"/>
  <link rel="icon" type="image/x-icon" href="/openclinic/_img/openclinic.ico"/>
  <script src="/openclinic/mobile/_script/scripts.js"></script>
    
  <script>
    if(window.history.forward(1)!=null){
      window.history.forward(1); 
    }

	function goToLogin(){
	  window.location.href = "/openclinic/mobile";
	}
  </script>
</head>
	
<body class="login" onkeydown="escBackSpace();if(enterEvent(event,13)){goToLogin();}">    
	<div id="login">
		<img src="../_img/openclinic_mobile.jpg">
		<br>Your session expired.<br>Please relogin
		<a href="/openclinic/mobile" onMouseOver="window.status='';return true;">here</a>.<br><br>
	</div>
</div>
</body>
</html>