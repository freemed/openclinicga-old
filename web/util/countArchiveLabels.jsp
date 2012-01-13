<%@page import="be.mxs.common.util.system.*,be.openclinic.datacenter.*,java.awt.*,javax.swing.*,javax.imageio.*,java.awt.image.*,java.io.*"%>
<table border="1">
<%
	
String[] alfabet = {"a","b","c","d","e","f","g","h","i","j","k","l","m",
        "n","o","p","q","r","s","t","u","v","w","x","y","z"};
int[] l = new int[26];

String startrecord="A";
int numberOfRecords=10000;

if(request.getParameter("startrecord")!=null && request.getParameter("numberOfRecords")!=null){
	startrecord=request.getParameter("startrecord").toLowerCase();
	int start=ScreenHelper.convertFromAlfabeticalCode(startrecord);
	numberOfRecords=Integer.parseInt(request.getParameter("numberOfRecords"));
	int end=start+numberOfRecords-1;
	int total=0;
	for (int n=start;n<=end;n++){
		String letters="";
		int number = n*1;
		while(number>0){
			number--;
			letters=alfabet[(number % alfabet.length)]+letters;
			l[(number % alfabet.length)]++;
			number=number-(number % alfabet.length);
			number=number/alfabet.length;
		}
	}
	for(int n=0;n<alfabet.length;n++){
		total+=l[n];
		out.println("<tr><td>"+alfabet[n].toUpperCase()+"</td><td>"+l[n]+"</td></tr>");
	}
	out.println("<tr><td>Total</td><td>"+total+"</td></tr>");
		
}

%>
</table>
<hr/>
<form name='calculateForm'>
	Startrecord: <input type='text' name='startrecord' value='<%=startrecord.toUpperCase()+""%>'/> (<%=ScreenHelper.convertFromAlfabeticalCode(startrecord.toLowerCase()) %>)<br/>
	Number of records: <input type='text' name='numberOfRecords' value='<%=numberOfRecords+""%>'/><br/>
	<input type='submit' name='submit' value='Calculate'/>
</form>