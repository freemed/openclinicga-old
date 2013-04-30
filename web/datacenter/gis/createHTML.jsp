<%@page import="be.mxs.common.util.db.MedwanQuery,
                be.mxs.common.util.system.Debug,
                be.mxs.common.util.system.ScreenHelper,
                java.text.DecimalFormat,
                java.util.*,
                java.io.*,
                java.sql.*"%>
<%@include file="/includes/validateUser.jsp"%>
                
<%!
    //--- ALTER HTML FILE -------------------------------------------------------------------------
    private void alterHtmlFile(String sSourcePath, String sTargetPath, String jsonFileId, String sLocalhostSubstitute){
        boolean fileWritten = false;               
        FileReader htmlReader = null;
        FileWriter htmlWriter = null;
		BufferedReader bufReader = null;

		try{
			// reader of static html file
        	htmlReader = new FileReader(new File(sSourcePath));
        	bufReader = new BufferedReader(htmlReader);
        	
        	// writer of specific html file
        	String sExt      = sTargetPath.substring(sTargetPath.lastIndexOf(".")+1),
                   sBaseName = sTargetPath.substring(0,sTargetPath.lastIndexOf("."));
        	String sNewFilePath = sBaseName+"_"+jsonFileId+"."+sExt;
        	htmlWriter = new FileWriter(new File(sNewFilePath));
			
	        String sLine;
	        while((sLine = bufReader.readLine())!=null){
				sLine = ScreenHelper.checkString(sLine);

				// look for placeHolders to replace
				if(sLine.indexOf("#jsonFileId#") > 0){
					sLine = sLine.replaceAll("#jsonFileId#",jsonFileId);
				}
				
				if(sLine.indexOf("#localhostSubstitute#") > 0){
					sLine = sLine.replaceAll("#localhostSubstitute#",sLocalhostSubstitute);
				}

				if(sLine.indexOf("#contextPathSubstitute#") > 0){
					sLine = sLine.replaceAll("#contextPathSubstitute#",sCONTEXTPATH.replaceAll("/", ""));
				}

				htmlWriter.write(sLine);
				htmlWriter.write("\r\n");
	        }
        }
        catch(Exception e){
            Debug.printProjectErr(e,e.getStackTrace());
        }
        finally{
            // close file, even after error
            if(bufReader!=null){
                try{
                	bufReader.close();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
            
            if(htmlReader!=null){
                try{
                	htmlReader.close();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
            
            if(htmlWriter!=null){
                try{
                	htmlWriter.flush();
                	htmlWriter.close();
                }
                catch(Exception e){
                    e.printStackTrace();
                }
            }
        }
    }
%>                
                
<%	
	// form-data	
	String jsonFileId = ScreenHelper.checkString(request.getParameter("jsonFileId")),
		   sHtmlPage  = ScreenHelper.checkString(request.getParameter("htmlPage"));
		
	/// DEBUG /////////////////////////////////////////////////////////////////
	if(Debug.enabled){
		Debug.println("*********** datacenter/gis/createHTML.jsp ***********");
		Debug.println("jsonFileId : "+jsonFileId);
		Debug.println("sHtmlPage  : "+sHtmlPage+"\n");
	}
	///////////////////////////////////////////////////////////////////////////

    // 1 - read static html page (html-content)    
    // 2 - replace #jsonFileId# with parameter 'jsonFileId' in html-content    
    // 3 - write html-content to new file with 'jsonFileId' in name
    	
	//String sContextPath = MedwanQuery.getInstance().getConfigString("contextpath");
		
    String sSourcePath = sAPPFULLDIR+"/datacenter/gis/googleMaps/static/"+sHtmlPage,
           sTargetPath = sAPPFULLDIR+"/datacenter/gis/googleMaps/"+sHtmlPage;
	
    java.net.InetAddress localHost = java.net.InetAddress.getLocalHost();
    String sIP = localHost.getHostAddress();
	
    alterHtmlFile(sSourcePath,sTargetPath,jsonFileId,MedwanQuery.getInstance().getConfigString("datacenterHostname","www.globalhealthbarometer.net"));
%>