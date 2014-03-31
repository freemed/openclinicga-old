<%@page import="java.util.*"%>
<%@include file="/includes/validateUser.jsp"%>

<%=sJSTREEMENU%>
<%=sCSSTREEMENU%>

<%
    /// DEBUG /////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n***************** hr/treeMenu.jsp *****************");
        Debug.println("no parameters\n");
    }
    ///////////////////////////////////////////////////////////////////////////    
%>       
 
<div id="button1Div">
  <img src="<%=sCONTEXTPATH%>/_img/hdis2/empty.gif" id="button1Icon">&nbsp;
  <img src="<%=sCONTEXTPATH%>/_img/hdis2/empty.gif" id="button2Icon">
</div> 

<script>
  var iconFull = new Image();
  iconFull.src = "<%=sCONTEXTPATH%>/_img/hdis2/full.gif";
  
  var iconEmpty = new Image();
  iconEmpty.src = "<%=sCONTEXTPATH%>/_img/hdis2/empty.gif";
  
  <%-- TOGGLE BUTTON ICON --%>
  function toggleButtonIcon(buttonId,hasValue){	
	var buttonIcon = document.getElementById(buttonId);
  
    if(hasValue){
      buttonIcon.src = iconFull.src;
    }
    else{ 
      buttonIcon.src = iconEmpty.src;
    }
  }
</script>
<br>

<a href="javascript:toggleButtonIcon('button1Icon',true);">full</a>&nbsp;
<a href="javascript:toggleButtonIcon('button2Icon',true);">full</a>
<br>

<a href="javascript:toggleButtonIcon('button1Icon',false);">empty</a>&nbsp;
<a href="javascript:toggleButtonIcon('button2Icon',false);">empty</a>
<br>
<br>
 
<script>
  <%-- CLOSE ALL ROOTS --%>
  function closeAllRoots(){
    var rootsAr = tree.getSubItems(0).split(",");
    for(var i=0; i<rootsAr.length; i++){
      tree.closeAllItems(rootsAr[i]);
    }
  }
</script>

<table>
    <tr>
        <td style="vertical-align:top;"> 
            <div id="treeboxbox_tree" style="width:270px; height:200px;background-color:#f5f5f5;border :1px solid Silver;; overflow:auto;"></div>
        </td>
        <td rowspan="2" style="padding-left:25" style="vertical-align:top;">        
	        <a href="javascript:void(0);" onClick="tree.openAllItems(0);">Expand all</a><br><br>
	        <a href="javascript:void(0);" onClick="tree.closeAllItems(0);">Collapse all</a><br><br>
	        <a href="javascript:void(0);" onClick="tree.closeItem(tree.getSelectedItemId());">Close  selected item</a><br><br>
	        <a href="javascript:void(0);" onClick="tree.openItem(tree.getSelectedItemId());">Open selected item</a><br><br>            
	        <a href="javascript:void(0);" onClick="tree.closeAllItems(tree.getSelectedItemId());">Collapse selected branch</a><br><br>
	        <a href="javascript:void(0);" onClick="tree.openAllItems(tree.getSelectedItemId());">Expand selected branch</a><br><br>
        </td>
    </tr>
    
    <tr>
        <td>&nbsp;</td>
    </tr>    
</table>

<script>
  tree = new dhtmlXTreeObject("treeboxbox_tree","100%","100%",0);
  tree.setSkin("csh_winstyle"); // check : C:\projects\openclinicnew\web\_img\treemenu
  tree.setImagePath("<%=sCONTEXTPATH%>/_img/treemenu/csh_winstyle/");
  tree.setXMLAutoLoading("<%=sCONTEXTPATH%>/hr/getTreeMenuXML.jsp");
  tree.loadXML("<%=sCONTEXTPATH%>/hr/getTreeMenuXML.jsp?Id=0");
</script>