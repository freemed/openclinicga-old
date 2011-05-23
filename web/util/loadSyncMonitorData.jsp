<%
	long n = (new java.util.Date().getTime()) % 9;
	if(n==0){
		out.println("0;Done");
	}
	else {
		out.println("1;Running");
	}
%>