<%@ page import="java.awt.image.*,java.awt.geom.*,java.awt.*,javax.imageio.*,java.util.*,be.openclinic.pharmacy.*,java.io.*,be.mxs.common.util.system.*,be.mxs.common.util.pdf.general.*,org.dom4j.*" %>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	void drawpoint(Graphics2D g,int x,int y, Color color){
		int width = 20;
		int height = 20;
		g.setPaint(color);
		Ellipse2D.Double circle = new Ellipse2D.Double(x-width/2, y-height/2, width, height);
		g.fill(circle);
	}
	
%>

<%

//Visual field points coordinates
int [][] left = {
		{241,33},
		{124,105},
		{126,217},
		{132,253},
		{11,96},
		{19,126},
		{36,149},
		{65,170},
		{99,170},
		{383,170},
		{174,65},
		{306,65},
		{271,92},
		{213,92},
		{324,96},
		{159,96},
		{260,123},
		{224,123},
		{300,123},
		{183,123},
		{316,148},
		{163,148},
		{299,173},
		{183,173},
		{323,173},
		{160,173},
		{329,206},
		{152,206},
		{282,206},
		{199,206},
		{257,206},
		{226,206},
		{302,231},
		{178,231},
		{263,231},
		{219,231},
		{264,253},
		{219,253},
		{304,267},
		{179,267},
		{242,81}
};
int [][] right = {
		{548,33},
		{660,105},
		{662,217},
		{659,253},
		{780,96},
		{767,126},
		{749,149},
		{725,170},
		{690,170},
		{403,170},
		{481,65},
		{614,65},
		{519,92},
		{578,92},
		{467,96},
		{631,96},
		{531,123},
		{564,123},
		{490,123},
		{606,123},
		{471,148},
		{625,148},
		{490,173},
		{606,173},
		{464,173},
		{630,173},
		{459,206},
		{637,206},
		{507,206},
		{590,206},
		{533,206},
		{564,206},
		{486,231},
		{609,231},
		{526,231},
		{569,231},
		{526,253},
		{568,253},
		{485,267},
		{611,267},
		{548,81}
};

BufferedImage img = ImageIO.read(new File("e:/temp/visualfield.jpg"));
Graphics2D g = img.createGraphics();
for (int n=0;n<41;n++){
	drawpoint(g,left[n][0],left[n][1],Color.green);
	drawpoint(g,right[n][0],right[n][1],Color.green);
}
g.dispose();
ImageIO.write(img, "JPEG", new File(MedwanQuery.getInstance().getConfigString("DocumentsFolder")+"/"+activeUser.userid+".jpg"));
%>
<img src='<%=MedwanQuery.getInstance().getConfigString("DocumentsURL")+"/"+activeUser.userid%>.jpg'/>
