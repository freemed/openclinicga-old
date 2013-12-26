<%@include file="/includes/helper.jsp"%>

<%
	String sColorFields=checkString(request.getParameter("colorfields"));
	String sValueField=checkString(request.getParameter("valuefield"));
	String sDefaultColor=checkString(request.getParameter("defaultcolor"));
%>

<head>
	<%=sJSCOLORPICKER %>
</head>

<script type="text/javascript">        
  $(document).ready(
    function()
    {
      $('#inline').jPicker(
    		  {window: { position: {y: 'bottom'}}, color: {active: new $.jPicker.Color({ hex: '<%=sDefaultColor.length()>0?sDefaultColor:"ffee00"%>' })}, images: {clientPath: '<%=sCONTEXTPATH+"/_common/_script/images/"%>'}},
    		  function(color, context) {chooseColor(color.val('hex'));}, function(color, context) {}, function(color, context) {window.close();}
    	);
    });      
</script>
<div id="inline"></div>

<script>
	function chooseColor(hexcolor){
		fields = '<%=sColorFields%>'.split(";");
		for(n=0;n<fields.length;n++){
			if(window.opener.document.getElementById(fields[n])){
				window.opener.document.getElementById(fields[n]).style.backgroundColor=hexcolor;
			}
		}
		if(window.opener.document.getElementById('<%=sValueField%>')){
			window.opener.document.getElementById('<%=sValueField%>').value=hexcolor;
		}
		window.close();
	}
</script>