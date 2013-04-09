<%@page import="be.mxs.common.util.io.MessageReader,
                be.mxs.common.util.io.MessageReaderMedidoc,
                java.util.*,be.openclinic.finance.*,
                javazoom.upload.MultipartFormDataRequest,
                javazoom.upload.UploadFile,
                java.io.*,be.mxs.common.util.system.*,be.mxs.common.util.db.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<jsp:useBean id="upBean" scope="page" class="javazoom.upload.UploadBean" >
    <jsp:setProperty name="upBean" property="folderstore" value="tmp" />
    <jsp:setProperty name="upBean" property="parser" value="<%= MultipartFormDataRequest.CFUPARSER %>"/>
    <jsp:setProperty name="upBean" property="parsertmpdir" value="tmp"/>
</jsp:useBean>
<form name="readMessageForm" method="POST" enctype="multipart/form-data">
	<table>
		<tr>
			<td class='admin'>
				<%=getTran("web","filetype",sWebLanguage) %>
				<select name="filetype" id="filetype" class="text" onchange="showstructure();">
					<option value="prestationscsv"><%=getTran("web","prestations.csv",sWebLanguage) %></option>
					<option value="servicescsv"><%=getTran("web","services.csv",sWebLanguage) %></option>
					<option value="labelscsv"><%=getTran("web","labels.csv",sWebLanguage) %></option>
				</select>
			</td>
			<td class='admin2'><input class="text" type="checkbox" name="erase" value="1"/> <%=getTran("web","delete.table.before.load",sWebLanguage)%></td>
			<td class='admin2'><input class="text" type="file" name="filename"/> <input class="button" type="submit" name="ButtonReadfile" value="<%=getTran("web","load",sWebLanguage)%>"/></td>
		</tr>
		<tr>
			<td colspan="2"><div id="structure"/></td>
		</tr>
    </table>
</form>
<%
	int lines=0;
	String sFileName = "";
	MultipartFormDataRequest mrequest;
	if (MultipartFormDataRequest.isMultipartFormData(request)) {
	    // Uses MultipartFormDataRequest to parse the HTTP request.
		mrequest = new MultipartFormDataRequest(request);
		if (mrequest.getParameter("ButtonReadfile")!=null){
	        try{
	            Hashtable files = mrequest.getFiles();
	            if (files != null && !files.isEmpty()){
	                UploadFile file = (UploadFile) files.get("filename");
	                sFileName= new SimpleDateFormat("yyyyMMddHHmmssSSS").format(new java.util.Date())+".ext";
	                file.setFileName(sFileName);
	                upBean.store(mrequest, "filename");
					if(mrequest.getParameter("filetype").equalsIgnoreCase("prestationscsv")){
						if(mrequest.getParameter("erase")!=null){
							ObjectCacheFactory.getInstance().resetObjectCache();
							Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
							PreparedStatement ps = conn.prepareStatement("delete from OC_PRESTATIONS");
							ps.execute();
							ps.close();
							conn.close();
							UpdateSystem.updateCounters();
						}
						int serverid=MedwanQuery.getInstance().getConfigInt("serverId"),objectid;
						String code,name,price,category,prestationclass,mfppct,mfpadmissionpct;
						//Read file as a prestations csv file
		                File f = new File(upBean.getFolderstore()+"/"+sFileName);
						BufferedReader reader = new BufferedReader(new FileReader(f));
						lines=0;
						while(reader.ready()){
							String[] line = reader.readLine().split(";");
							if(line.length<3){
								break;
							}
							else{
								prestationclass="";
								category="";
								mfppct="0";
								mfpadmissionpct="0";
								lines++;
								code=line[0].trim();
								name=line[1].trim();
								price=line[2].trim();
								if(line.length>3){
									category=line[3].trim();
									if(line.length>4){
										prestationclass=line[4].trim();
										if(line.length>5){
											mfppct=line[5];
											if(line.length>6){
												mfpadmissionpct=line[6];
											}
										}
									}
								}
								Prestation prestation = new Prestation();
								prestation.setCode(code);
								prestation.setDescription(name);
								prestation.setReferenceObject(new ObjectReference(category,""));
								prestation.setCategories("");
								prestation.setInvoicegroup(category);
								prestation.setPrestationClass(prestationclass);
								prestation.setPrice(Double.parseDouble(price));
								prestation.setType(category);
								prestation.setUpdateDateTime(new java.util.Date());
								prestation.setUpdateUser(activeUser.userid);
								prestation.setVersion(1);
								prestation.setMfpAdmissionPercentage(Integer.parseInt(mfpadmissionpct));
								prestation.setMfpPercentage(Integer.parseInt(mfppct));
								prestation.store();
								if(code.equalsIgnoreCase("#")){
									prestation.setCode(category+"."+prestation.getUid().split("\\.")[1]);
									prestation.store();
								}
								MedwanQuery.getInstance().storeLabel("prestation.type", category, "fr", category, Integer.parseInt(activeUser.userid));
								MedwanQuery.getInstance().storeLabel("prestation.type", category, "en", category, Integer.parseInt(activeUser.userid));
							}
						}
						reader.close();
						reloadSingleton(session);
		                f.delete();
						out.println("<h3>"+lines+" " +getTran("web","records.loaded",sWebLanguage)+"</h3>");
					}
					else if(mrequest.getParameter("filetype").equalsIgnoreCase("servicescsv")){
						if(mrequest.getParameter("erase")!=null){
							ObjectCacheFactory.getInstance().resetObjectCache();
							Connection conn = MedwanQuery.getInstance().getAdminConnection();
							PreparedStatement ps = conn.prepareStatement("delete from Services");
							ps.execute();
							ps.close();
							conn.close();
							UpdateSystem.updateCounters();
						}
						String code,name,language,beds,visits,parentcode;
						//Read file as a prestations csv file
		                File f = new File(upBean.getFolderstore()+"/"+sFileName);
						BufferedReader reader = new BufferedReader(new FileReader(f));
						lines=0;
						while(reader.ready()){
							String[] line = reader.readLine().split(";");
							if(line.length<3){
								break;
							}
							else{
								parentcode="";
								beds="0";
								visits="0";
								lines++;
								code=line[0].trim();
								name=line[1].trim();
								language=line[2].trim();
								if(line.length>3){
									beds=line[3].trim();
									if(line.length>4){
										visits=line[4].trim();
										if(line.length>5){
											parentcode=line[5];
										}
									}
								}
								Service service = new Service();
								service.code=code;
								service.language=language;
								service.totalbeds=Integer.parseInt(beds);
								service.acceptsVisits=visits;
								service.parentcode=parentcode;
								service.updatetime= new java.sql.Date(new java.util.Date().getTime());
								service.updateuserid=activeUser.userid;
								service.store();
								MedwanQuery.getInstance().storeLabel("service", code, "fr", name, Integer.parseInt(activeUser.userid));
								MedwanQuery.getInstance().storeLabel("service", code, "en", name, Integer.parseInt(activeUser.userid));
							}
						}
						reader.close();
						reloadSingleton(session);
		                f.delete();
						out.println("<h3>"+lines+" " +getTran("web","records.loaded",sWebLanguage)+"</h3>");
					}
					else if(mrequest.getParameter("filetype").equalsIgnoreCase("labelscsv")){
						String type,id,language,label;
						//Read file as a prestations csv file
		                File f = new File(upBean.getFolderstore()+"/"+sFileName);
						BufferedReader reader = new BufferedReader(new FileReader(f));
						lines=0;
						while(reader.ready()){
							String[] line = reader.readLine().split(";");
							if(line.length<4){
								break;
							}
							else{
								type=line[0].trim();
								id=line[1].trim();
								language=line[2].trim();
								label=line[3].trim();
								MedwanQuery.getInstance().updateLabel(type,id,language,label);
								lines++;
							}
						}
						reader.close();
						reloadSingleton(session);
		                f.delete();
						out.println("<h3>"+lines+" " +getTran("web","records.loaded",sWebLanguage)+"</h3>");
					}
	            }
	        }
	        catch(Exception e){
	            e.printStackTrace();
	        }
		}
	}
%>
<script>
	function showstructure(){
		if(document.getElementById("filetype").value=="prestationscsv"){
			document.getElementById("structure").innerHTML="Required structure (* are mandatory):<br/><b>Code* (#=auto); Name* ; Price* ; Category ; Class; AMO % ; AMO Admission %</b>";
		}
		else if(document.getElementById("filetype").value=="servicescsv"){
			document.getElementById("structure").innerHTML="Required structure (* are mandatory):<br/><b>Code* ; Name* ; Language* ; Beds ; Visits ; ParentCode</b>";
		}
		else if(document.getElementById("filetype").value=="labelscsv"){
			document.getElementById("structure").innerHTML="Required structure (* are mandatory):<br/><b>Type* ; ID* ; Language* ; Label*</b>";
		}
	}
	
	showstructure();
</script>