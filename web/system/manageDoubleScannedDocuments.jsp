<%@page import="java.util.*,
                java.io.File,
                be.openclinic.archiving.ArchiveDocument,
                be.openclinic.archiving.ScanDirectoryMonitor"%>
<%@include file="/includes/validateUser.jsp"%>
<%@page errorPage="/includes/error.jsp"%>
<%=sJSSORTTABLE%>

<%!
    //--- SORT FILES BY DATE ---------------------------------------------------------------------- 
    public void sortFilesByDate(File files[], final boolean sortAsc){
	    Comparator<File> comparator = new Comparator<File>(){  
            public int compare(File o1, File o2){  
                if(sortAsc){  
                    return Long.valueOf(o1.lastModified()).compareTo(o2.lastModified());  
                }
                else{  
                    return -1 * Long.valueOf(o1.lastModified()).compareTo(o2.lastModified());  
                }  
             }  
         };  
         
         Arrays.sort(files,comparator);    
     }  

%>

<%
    String sAction = checkString(request.getParameter("Action"));
    final int MAX_FILES_TO_LIST = 200;

    /// DEBUG /////////////////////////////////////////////////////////////////////////////////////
    if(Debug.enabled){
        Debug.println("\n*************** system/manageDoubleScannedDocuments.jsp ***************");
        Debug.println("sAction           : "+sAction);
        Debug.println("MAX_FILES_TO_LIST : "+MAX_FILES_TO_LIST+"\n");
    }
    ///////////////////////////////////////////////////////////////////////////////////////////////
    
    String sMsg = "";
    
    ScanDirectoryMonitor scanDirMon = new ScanDirectoryMonitor(); // only instantiation, no activation of Thread
    
    final String SCANDIR_BASE = ScanDirectoryMonitor.SCANDIR_BASE,
   		         SCANDIR_URL  = ScanDirectoryMonitor.SCANDIR_URL,
    	         SCANDIR_FROM = ScanDirectoryMonitor.SCANDIR_FROM,
   		         SCANDIR_TO   = ScanDirectoryMonitor.SCANDIR_TO,
	    		 SCANDIR_ERR  = ScanDirectoryMonitor.SCANDIR_ERR,
	             SCANDIR_DEL  = ScanDirectoryMonitor.SCANDIR_DEL;
    
    final String EXCLUDED_EXTENSIONS = ScanDirectoryMonitor.EXCLUDED_EXTENSIONS;
    
    
    //--- FORCED READ -----------------------------------------------------------------------------
    // files from SCANDIR_ERR accepted forcively as OK files
    if(sAction.equals("forcedRead")){  
    	Enumeration checkedBoxes = request.getParameterNames();
    	
    	File file, toFile;
    	int fileCount = 0;
    	sMsg = ""; // reset
    	
    	while(checkedBoxes.hasMoreElements()){
    		String cbName = (String)checkedBoxes.nextElement();
    		
    		if(cbName.startsWith("cb_")){  
    			String sFilename = checkString(request.getParameter(cbName));
    			
	            try{
	            	file = new File(SCANDIR_BASE+"/"+SCANDIR_ERR+"/"+sFilename);
	            	
	            	sFilename = sFilename.replaceAll("DOUBLE_","SCAN_");
	            	sFilename = sFilename.replaceAll("ORPHAN_","SCAN_");
	            	sFilename = sFilename.replaceAll("INVEXT_","SCAN_");
	            	sFilename = sFilename.replaceAll("INVPREFIX_","SCAN_");
	            	sFilename = sFilename.replaceAll("INVUDI_","SCAN_");
	            	
	            	toFile = new File(SCANDIR_BASE+"/"+SCANDIR_TO+"/"+sFilename);
		        	
	            	ScanDirectoryMonitor.moveFile(file,toFile);	            			        	
	            	ScanDirectoryMonitor.storeFileInDB(toFile,true,++fileCount); // forced
	            }
	            catch(Exception e){
		        	sMsg = "<font color='red'>"+e.getMessage()+" (<b>DO NOT REFRESH PAGE</b>)</font>";
	                Debug.printStackTrace(e);
	            }	
	    	}
    	}
    	
    	sMsg+= "<br>"+fileCount+" "+getTran("web.manage","filesRead",sWebLanguage);
    }
    //--- DELETE ----------------------------------------------------------------------------------
    else if(sAction.equals("delete")){
    	Enumeration checkedBoxes = request.getParameterNames();
    	
    	File file, toFile;
    	int fileCount = 0;
    	
    	while(checkedBoxes.hasMoreElements()){
    		String cbName = (String)checkedBoxes.nextElement();
    		
    		if(cbName.startsWith("cb_")){
    			String sFilename = checkString(request.getParameter(cbName));
    			
		        try{
		        	file = new File(SCANDIR_BASE+"/"+SCANDIR_ERR+"/"+sFilename);
		        	
		        	sFilename = sFilename.replaceAll("DOUBLE_","DEL_");
		        	sFilename = sFilename.replaceAll("ERR_","DEL_");
		        	toFile = new File(SCANDIR_BASE+"/"+SCANDIR_DEL+"/"+sFilename);
		        	
		        	ScanDirectoryMonitor.moveFile(file,toFile);
		        	fileCount++;
		        }
		        catch(Exception e){
		        	sMsg = "<font color='red'>"+e.getMessage()+" (<b>DO NOT REFRESH PAGE</b>)</font>";
		            Debug.printStackTrace(e);
		        }
    		}
    	}
    	
    	sMsg = fileCount+" "+getTran("web.manage","filesDeleted",sWebLanguage);
    }
%>

<form name="transactionForm" id="transactionForm" method="post">
    <input type="hidden" name="Action">
    
    <%=writeTableHeader("web.manage","manageDoubleScannedDocuments",sWebLanguage," doBack();")%>
    <br>
    
    <%
        if(sMsg.length() > 0){
            %><%=sMsg%><br><%
        }
    
        //************************ LIST DOUBLE FILES *************************
	    File fromDir = null, toDir = null, errDir = null, delDir = null;	     	
	    File[] files = null; 
	    int checkboxCount = 0;
        
	    try{        		    		    	
	    	boolean configOK = true;
	    	
	    	//*** 1 - CHECK SCANDIR_BASE ****************************
	    	if(SCANDIR_BASE.length() > 0){
	    	    File baseDir = new File(SCANDIR_BASE);
	    	    if(!baseDir.exists()){
	    	    	baseDir.mkdir();
	    	    	
		    		Debug.println("INFO : 'scanDirectoryMonitor_basePath' ("+SCANDIR_BASE+") created");
		    		%><font color="orange">INFO : <b>'scanDirectoryMonitor_basePath'</b> (<%=SCANDIR_BASE%>) created</font><br><%
	    	    }
	    	}
	    	else{
	    		Debug.println("WARNING : 'scanDirectoryMonitor_basePath' is not configured");
	    		%><font color="red">WARNING : <b>'scanDirectoryMonitor_basePath'</b> is not configured</font><br><%
	    		configOK = false;
	    	}
	    	
	    	//*** 2 - CHECK DEPENDING DIRS **************************
	    	if(configOK){
		    	//*** SCANDIR_FROM ***
		    	if(SCANDIR_FROM.length() > 0){
		    	    fromDir = new File(SCANDIR_BASE+"/"+SCANDIR_FROM);
		    	    if(!fromDir.exists()){
		    	    	fromDir.mkdir();
		    	    	
			    		Debug.println("INFO : 'scanDirectoryMonitor_dirFrom' ("+SCANDIR_FROM+") created (in '"+SCANDIR_BASE+"')");
			    		%><font color="orange">INFO : <b>'scanDirectoryMonitor_dirFrom'</b> (<%=SCANDIR_FROM%>) created (in '<%=SCANDIR_BASE%>')</font><br><%
		    	    }
		    	}
		    	else{
		    		Debug.println("WARNING : 'scanDirectoryMonitor_dirFrom' is not configured");
		    		%><font color="red">WARNING : <b>'scanDirectoryMonitor_dirFrom'</b> is not configured</font><br><%
		    		configOK = false;
		    	}
	
		    	//*** SCANDIR_TO ***
		    	if(SCANDIR_TO.length() > 0){
		    	    toDir = new File(SCANDIR_BASE+"/"+SCANDIR_TO);
		    	    if(!toDir.exists()){
		    	    	toDir.mkdir();
		    	    	
			    		Debug.println("INFO : 'scanDirectoryMonitor_dirTo' ("+SCANDIR_TO+") created (in '"+SCANDIR_BASE+"')");
			    		%><font color="orange">INFO : <b>'scanDirectoryMonitor_dirTo'</b> (<%=SCANDIR_TO%>) created (in '<%=SCANDIR_BASE%>')</font><br><%
		    	    }
		    	}
		    	else{
		    		Debug.println("WARNING : 'scanDirectoryMonitor_dirTo' is not configured");
		    		%><font color="red">WARNING : <b>'scanDirectoryMonitor_dirTo'</b> is not configured</font><br><%
		    		configOK = false;
		    	}
		    	
		    	//*** SCANDIR_ERR ***
		    	if(SCANDIR_ERR.length() > 0){
		    	    errDir = new File(SCANDIR_BASE+"/"+SCANDIR_ERR);
		    	    if(!errDir.exists()){
		    	    	errDir.mkdir();
		    	    	
			    		Debug.println("INFO : 'scanDirectoryMonitor_dirError' ("+SCANDIR_ERR+") created (in '"+SCANDIR_BASE+"')");
			    		%><font color="orange">INFO : <b>'scanDirectoryMonitor_dirError'</b> (<%=SCANDIR_ERR%>) created (in '<%=SCANDIR_BASE%>')</font><br><%
		    	    }
		    	}
		    	else{
		    		Debug.println("WARNING : 'scanDirectoryMonitor_dirError' is not configured");
		    		%><font color="red">WARNING : <b>'scanDirectoryMonitor_dirError'</b> is not configured</font><br><%
		    		configOK = false;
		    	}
		    	
		    	//*** SCANDIR_DEL ***
		    	if(SCANDIR_DEL.length() > 0){
		    	    delDir = new File(SCANDIR_BASE+"/"+SCANDIR_DEL);
		    	    if(!delDir.exists()){
		    	    	delDir.mkdir();
		    	    	
			    		Debug.println("INFO : 'scanDirectoryMonitor_dirDeleted' ("+SCANDIR_DEL+") created (in '"+SCANDIR_BASE+"')");
			    		%><font color="orange">INFO : <b>'scanDirectoryMonitor_dirDeleted'</b> (<%=SCANDIR_DEL%>) created (in '<%=SCANDIR_BASE%>')</font><br><%
		    	    }
		    	}
		    	else{
		    		Debug.println("WARNING : 'scanDirectoryMonitor_dirDeleted' is not configured");
		    		%><font color="red">WARNING : <b>'scanDirectoryMonitor_dirDeleted'</b> is not configured</font><br><%
		    		configOK = false;
		    	}
	    	}
	    	
	    	if(SCANDIR_URL.length()==0){
	    		Debug.println("WARNING : 'scanDirectoryMonitor_url' is not configured");
	    		%><font color="red">WARNING : <b>'scanDirectoryMonitor_url'</b> is not configured</font><br><%
	    		configOK = false;
	    	}
	    	
	    	if(configOK){	    		     	
		     	files = errDir.listFiles(); 
		     	Debug.println("Files in 'scanDirectoryMonitor_dirError' : "+files.length);

		     	sortFilesByDate(files,true);
		     	
                if(files.length > 0){
	                %>
			     	    <table class="sortable" id="searchresults" width="100%" class="list" cellspacing="0" cellpadding="1">
			     	        <%-- HEADER --%>
			     	        <tr class="admin">
			     	            <td width="20">&nbsp;</td>
			     	            <td width="120"><%=getTran("web","udi",sWebLanguage)%></td>
			     	            <td width="280"><%=getTran("web","existingFile",sWebLanguage)%></td>
			     	            <td width="180"><%=getTran("web","incomingFile",sWebLanguage)%></td>
			     	            <td width="100"><SORTTYPE:DATE><%=getTran("web","date",sWebLanguage)%></SORTTYPE:DATE></td>
			     	            <td width="*"><NOSORT><%=getTran("web","solution",sWebLanguage)%></NOSORT></td>
			     	        </tr> 
  
				     		<%				     		
						     	File dblFile, linkedFile = null;		
					     		String sUDI, sLinkedFile = "", sLinkedFileDate = "", sDoubleFileDate = "", sClass = "";
						     	for(int i=0; i<files.length && i<MAX_FILES_TO_LIST; i++){
						     		// reset
						     		sLinkedFile = "<i>none</i>";
						     		sLinkedFileDate = "";
						     		linkedFile = null;
						     		
						     		dblFile = (File)files[i];
						     		sDoubleFileDate = ScreenHelper.fullDateFormat.format(dblFile.lastModified());						     		
						     		sUDI = dblFile.getName().substring(dblFile.getName().indexOf("_")+1,dblFile.getName().lastIndexOf(".")); // remove prefix and extension
						     	   	
						     		ArchiveDocument archDoc = ArchiveDocument.get(sUDI);
						     	   	if(archDoc!=null){
							     		sLinkedFile = archDoc.storageName;
							     		if(sLinkedFile.length() > 0){
							     			linkedFile = new File(SCANDIR_BASE+"/"+SCANDIR_TO+"/"+sLinkedFile);
							     			if(linkedFile.exists()){
							     				sLinkedFileDate = ScreenHelper.fullDateFormat.format(linkedFile.lastModified());
							     			}
							     		}
							     		else{
							     			sLinkedFile = "<i>none</i>";
							     		}
						     	   	}
						     	   	
						     		// alternate row-style
						     		if(sClass.length()==0) sClass = "1";
						     		else                   sClass = "";
						     		
						     		%>
						     	        <tr class="list<%=sClass%>">
						     	            <%
						     	                // no checkbox when reading forcively is not advisable
					     	                    if(dblFile.getName().startsWith("INVEXT_") || dblFile.getName().startsWith("ORPHAN_") || 
					     	                       dblFile.getName().startsWith("INVPREFIX_") || dblFile.getName().startsWith("INVUDI_")){
					     	                    	%><td></td><%
						     	                }
					     	                    else{
					     	                    	// "DOUBLE_"
					     	                    	%><td><input type="checkbox" name="cb_<%=i%>" id="cb_<%=i%>" class="hand" value="<%=dblFile.getName()%>"></td><%
					     	                    	checkboxCount++;
					     	                    }
						     	            %>						     	            
						     	            <td>&nbsp;<label for="cb_<%=i%>" class="hand"><%=sUDI%></label></td>
						     	            <%
						     	                if(linkedFile!=null && linkedFile.exists()){
    						     	                %><td>&nbsp;<a href="javascript:void(1);" onClick="openDoc('<%=SCANDIR_TO%>','<%=sLinkedFile%>');"><%=sLinkedFile%></a><%=(sLinkedFileDate.length()>0?" ("+sLinkedFileDate+")":"")%></td><%
    						     	            }
						     	                else{
						     	                	%><td>&nbsp;<font color="red"><%=sLinkedFile%></font></td><%
						     	                }
    						     	        %>
						     	            <td>&nbsp;<a href="javascript:void(1);" onClick="openDoc('<%=SCANDIR_ERR%>','<%=dblFile.getName()%>');"><%=dblFile.getName()%></a></td>
						     	            <td>&nbsp;<%=sDoubleFileDate%></td>
						     	            <td><font color="green"><%
						     	                    if(dblFile.getName().startsWith("INVEXT_")){
						     	                    	%><%=getTran("web.manage","solution_invalidExtension",sWebLanguage).replaceAll("#invalidExtensions#",EXCLUDED_EXTENSIONS)%><%
						     	                    }
						     	                    else if(dblFile.getName().startsWith("ORPHAN_")){
						     	                    	%><%=getTran("web.manage","solution_orphanFile",sWebLanguage)%><%
							     	                } 
						     	                    else if(dblFile.getName().startsWith("INVPREFIX_")){
						     	                    	%><%=getTran("web.manage","solution_invalidPrefix",sWebLanguage)%><%
							     	                } 
						     	                    else if(dblFile.getName().startsWith("DOUBLE_")){
						     	                    	%><%=getTran("web.manage","solution_doubleFile",sWebLanguage)%><%
							     	                }
						     	                    else if(dblFile.getName().startsWith("INVUDI_")){
					     	                    		%><%=getTran("web.manage","solution_invalidUDI",sWebLanguage)%><%
					     	                    	}
						     	                %></font>
						     	            </td>
						     	        </tr>
						     		<%	        	    
						     	}						     	
					     	%>
			     	    </table>
			     	    
			     	    <%-- BUTTONS --%>
			     	    <%=ScreenHelper.alignButtonsStart()%>			     	    
							<%
							    if(checkboxCount > 0){
							        %>
										<input class="button" type="button" name="readButton" value="<%=getTranNoLink("web","forcedRead",sWebLanguage)%>" onclick='doForcedRead();'>&nbsp;
										<input class="button" type="button" name="deleteButton" value="<%=getTranNoLink("web","delete",sWebLanguage)%>" onclick='doDelete();'>&nbsp;&nbsp;
                     	     	        <input class="button" type="button" name="resetButton" value="<%=getTranNoLink("web","reset",sWebLanguage)%>" onclick='doReset();'>&nbsp;
									<%
								}
							%>	     	        
			     	        <input class="button" type="button" name="backButton" value="<%=getTranNoLink("web","back",sWebLanguage)%>" onclick='doBack();'>
			     	    <%=ScreenHelper.alignButtonsStop()%>
			     	<%
		        }
		     	else{
		     		%><%=getTran("web","noFilesFound",sWebLanguage)%><%
		     	}
	    	}
	    }
	    catch(Exception e){
	        e.printStackTrace();
	    }        
    %>   
</form>

<%-- link to config --%>
<img src='<c:url value="/_img/themes/default/pijl.gif"/>'>
<a  href="<c:url value='/main.do'/>?Page=system/manageConfig.jsp&ts=<%=getTs()%>" onMouseOver="window.status='';return true;"><%=getTran("web.manage","ManageConfiguration",sWebLanguage)%></a>&nbsp;
  
<%
    if(files!=null && files.length > 20){
        %>
			<%-- link to top of page --%>
			<p align="right">
			    <a href="#topp" class="topbutton">&nbsp;</a>&nbsp;
			</p>
	    <%
    }
%>

<script>
  <%-- DO FORCED READ --%>
  function doForcedRead(){
	var fileCount = countSelectedFiles();
	if(fileCount > 0){
	  if(yesnoDialogDirectText(replaceAll("<%=getTranNoLink("web","areYouSureToForceReadXFiles",sWebLanguage)%>","#fileCount#",fileCount))){
        transactionForm.Action.value = "forcedRead";
        transactionForm.submit();
      }
	}
	else{
      alertDialog("web","selectAtLeastOneFile");
	}
  }
  
  <%-- DO DELETE --%>
  function doDelete(){
	var fileCount = countSelectedFiles();
	if(fileCount > 0){
      if(yesnoDialogDirectText(replaceAll("<%=getTranNoLink("web","areYouSureToDeleteXFiles",sWebLanguage)%>","#fileCount#",fileCount))){
        transactionForm.Action.value = "delete";
        transactionForm.submit();
      }
	}
	else{
      alertDialog("web","selectAtLeastOneFile");
	}
  }
  
  <%-- AT LEAST ONE FILE SELECTED --%>
  function atLeastOneFileSelected(){
    var inputs = document.getElementsByTagName("input");

    for(var i=0; i<inputs.length; i++){
      if(inputs[i].type=="checkbox"){
        if(inputs[i].checked){
          return true;
        }
      }
    }
    
    return false;
  }
  
  <%-- COUNT SELECTED FILES --%>
  function countSelectedFiles(){
	var fileCount = 0;
    var inputs = document.getElementsByTagName("input");

    for(var i=0; i<inputs.length; i++){
      if(inputs[i].type=="checkbox"){
        if(inputs[i].checked){
          fileCount++;
        }
      }
    }
    
    return fileCount;
  }
  
  <%-- DO RESET --%>
  function doReset(){
    transactionForm.reset();
  }
  
  <%-- OPEN DOC --%>
  function openDoc(scanDir,fileName){
    var url = "<%=SCANDIR_URL%>/"+scanDir+"/"+fileName;
    var w = 900;
    var h = 600;
    var left = (screen.width/2)-(w/2);
    var topp = (screen.height/2)-(h/2);
    window.open(url,"DoubleScannedDocument<%=new java.util.Date().getTime()%>","toolbar=no,status=no,scrollbars=yes,resizable=yes,menubar=no,width="+w+",height="+h+",top="+topp+",left="+left);
  }

  <%-- DO BACK --%>
  function doBack(){
    window.location.href = "<%=sCONTEXTPATH%>/main.jsp?Page=system/menu.jsp";
  }
</script>