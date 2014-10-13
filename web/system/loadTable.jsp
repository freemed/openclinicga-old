<%@page import="be.mxs.common.util.io.MessageReader,
                be.mxs.common.util.io.MessageReaderMedidoc,
                java.util.*,be.openclinic.finance.*,be.openclinic.pharmacy.*,
                javazoom.upload.MultipartFormDataRequest,
                javazoom.upload.UploadFile,org.dom4j.*,org.dom4j.io.*,be.openclinic.medical.*,
                java.io.*,be.mxs.common.util.system.*,be.mxs.common.util.db.*"%>
<%@page errorPage="/includes/error.jsp"%>
<%@include file="/includes/validateUser.jsp"%>
<%!
	void storeAgeGender(String type,int id,double minAge, double maxAge, String gender, double minVal, double maxVal, String comment ){
		try{
			Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
			PreparedStatement ps = conn.prepareStatement("insert into AgeGenderControl(rowid,type,id,minAge,maxAge,gender,frequency,tolerance,updatetime,comment) values(?,?,?,?,?,?,?,?,?,?)");
			ps.setInt(1,MedwanQuery.getInstance().getOpenclinicCounter("AgeGenderControlID"));
			ps.setString(2,type);
			ps.setInt(3,id);
			ps.setDouble(4,minAge);
			ps.setDouble(5, maxAge);
			ps.setString(6, gender);
			ps.setDouble(7,	minVal);
			ps.setDouble(8, maxVal);
			ps.setTimestamp(9,new java.sql.Timestamp(new java.util.Date().getTime()));
			ps.setString(10,comment);
			ps.execute();
			ps.close();
			conn.close();
		}
		catch(Exception e){
			e.printStackTrace();
		}
	}
%>
<jsp:useBean id="upBean" scope="page" class="javazoom.upload.UploadBean" >
    <jsp:setProperty name="upBean" property="folderstore" value="<%=MedwanQuery.getInstance().getConfigString("tempDirectory","/tmp") %>" />
    <jsp:setProperty name="upBean" property="parser" value="<%= MultipartFormDataRequest.DEFAULTPARSER	 %>"/>
  	<jsp:setProperty name="upBean" property="filesizelimit" value="8589934592"/>
  	<jsp:setProperty name="upBean" property="overwrite" value="true"/>
  	<jsp:setProperty name="upBean" property="dump" value="true"/>
    <jsp:setProperty name="upBean" property="parsertmpdir" value="<%=MedwanQuery.getInstance().getConfigString("tempDirectory","/tmp") %>"/>
</jsp:useBean>
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

					        UpdateSystem systemUpdate = new UpdateSystem();
					        systemUpdate.updateCounters();
						}
						int serverid=MedwanQuery.getInstance().getConfigInt("serverId"),objectid;
						String code,name,price,category,prestationclass,mfppct,mfpadmissionpct,tariffcode,tariffprice;
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
								tariffcode="";
								tariffprice="";
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
												if(line.length>7){
													tariffcode=line[7];
													if(line.length>8){
														tariffprice=line[8];
													}
												}
											}
										}
									}
								}
								Prestation prestation = new Prestation();
								if(code!=null && code.length()>0 && !code.equalsIgnoreCase("#")){
									prestation = Prestation.getByCode(code);
									if(prestation==null){
										prestation=new Prestation();
									}
								}
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
								if(tariffcode.length()>0){
									prestation.setCategoryPrice(tariffcode, tariffprice);
								}
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

					        UpdateSystem systemUpdate = new UpdateSystem();
					        systemUpdate.updateCounters();
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
					else if(mrequest.getParameter("filetype").equalsIgnoreCase("labxml")){
						if(mrequest.getParameter("erase")!=null){
							ObjectCacheFactory.getInstance().resetObjectCache();
							Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
							PreparedStatement ps = conn.prepareStatement("delete from Labanalysis");
							ps.execute();
							ps.close();
							ps = conn.prepareStatement("delete from oc_labels where oc_label_type in ('labanalysis','labprofiles','labprofile','labanalysis.short','labanalysis.group','labanalysis.refcomment')");
							ps.execute();
							ps.close();
							ps = conn.prepareStatement("delete from labprofiles");
							ps.execute();
							ps.close();
							ps = conn.prepareStatement("delete from labprofilesanalysis");
							ps.execute();
							ps.close();
							ps = conn.prepareStatement("delete from agegendercontrol where type='LabAnalysis'");
							ps.execute();
							ps.close();
							conn.close();

					        UpdateSystem systemUpdate = new UpdateSystem();
					        systemUpdate.updateCounters();
						}	
						String type,id,language,label;
						//Read file as a prestations csv file
		                File f = new File(upBean.getFolderstore()+"/"+sFileName);
						BufferedReader br = new BufferedReader(new FileReader(f));
						SAXReader reader=new SAXReader(false);
						org.dom4j.Document document=reader.read(br);
						Element root = document.getRootElement();
						Iterator i = root.elementIterator("labanalysis");
						lines=0;
						while(i.hasNext()){
							lines++;
							Element element = (Element)i.next();
							LabAnalysis analysis = new LabAnalysis();
							analysis.setLabcode(element.elementText("code"));
							analysis.setLabtype(element.elementText("type"));
							analysis.setMonster(element.elementText("sample"));
							analysis.setLabgroup(element.elementText("group"));
							analysis.setUnit(element.elementText("unit"));
							analysis.setEditor(element.elementText("editor"));
							analysis.setEditorparameters(element.elementText("modifiers"));
							analysis.setMedidoccode(element.elementText("loinc"));
							analysis.setUpdatetime(new Timestamp(new java.util.Date().getTime()));
							analysis.setUpdateuserid(Integer.parseInt(activeUser.userid));
							analysis.setLabId(MedwanQuery.getInstance().getOpenclinicCounter("LabAnalysisID"));
							analysis.insert();
							Iterator labels = element.elementIterator("label");
							while(labels.hasNext()){
								Element lbl = (Element)labels.next();
								MedwanQuery.getInstance().storeLabel("labanalysis", analysis.getLabId()+"", lbl.attributeValue("language"), lbl.getText(), Integer.parseInt(activeUser.userid));
								MedwanQuery.getInstance().storeLabel("labanalysis.short", analysis.getLabId()+"", lbl.attributeValue("language"), checkString(element.elementText("short")), Integer.parseInt(activeUser.userid));
								MedwanQuery.getInstance().storeLabel("labanalysis.refcomment", analysis.getLabId()+"", lbl.attributeValue("language"), checkString(lbl.elementText("refcomment")), Integer.parseInt(activeUser.userid));
							}
							//Now check the reference values
							Element refs = element.element("refs");
							if(refs != null){
								Iterator r = refs.elementIterator("ref");
								while(r.hasNext()){
									Element ref = (Element)r.next();
									storeAgeGender("LabAnalysis",analysis.getLabId(),Double.parseDouble(ref.attributeValue("minage")),Double.parseDouble(ref.attributeValue("maxage")),ref.attributeValue("gender"),Double.parseDouble(ref.elementText("minval")),Double.parseDouble(ref.elementText("maxval")),checkString(ref.elementText("comment")));
								}
							}
						}
						i = root.elementIterator("labprofile");
						while(i.hasNext()){
							lines++;
							Element element = (Element)i.next();
							LabProfile profile = new LabProfile();
							profile.setProfilecode(element.elementText("code").toUpperCase());
							profile.setProfileID(MedwanQuery.getInstance().getOpenclinicCounter("LabProfileID"));
							profile.setUpdatetime(new Timestamp(new java.util.Date().getTime()));
							profile.setUpdateuserid(Integer.parseInt(activeUser.userid));
							profile.insert();
							Iterator as = element.elementIterator("labanalysis");
							while(as.hasNext()){
								Element analysisElement = (Element)as.next();
								LabAnalysis analysis = LabAnalysis.getLabAnalysisByLabcode(analysisElement.getText());
								if(analysis!=null){
									LabProfileAnalysis an = new LabProfileAnalysis();
									an.setLabID(analysis.getLabId());
									an.setProfileID(profile.getProfileID());
									an.setUpdatetime(new Timestamp(new java.util.Date().getTime()));
									an.setUpdateuserid(Integer.parseInt(activeUser.userid));
									an.insert();
								}
							}
							Iterator labels = element.elementIterator("label");
							while(labels.hasNext()){
								Element lbl = (Element)labels.next();
								MedwanQuery.getInstance().storeLabel("labprofiles", profile.getProfileID()+"", lbl.attributeValue("language"), lbl.getText(), Integer.parseInt(activeUser.userid));
							}
							
						}
						i = root.elementIterator("labanalysisgroup");
						while(i.hasNext()){
							lines++;
							Element element = (Element)i.next();
							Iterator labels = element.elementIterator("label");
							while(labels.hasNext()){
								Element lbl = (Element)labels.next();
								MedwanQuery.getInstance().storeLabel("labanalysis.group", element.elementText("code")+"", lbl.attributeValue("language"), lbl.getText(), Integer.parseInt(activeUser.userid));
							}
						}
						br.close();
						reloadSingleton(session);
		                f.delete();
						out.println("<h3>"+lines+" " +getTran("web","records.loaded",sWebLanguage)+"</h3>");
					}					
					else if(mrequest.getParameter("filetype").equalsIgnoreCase("drugsxml")){
						if(mrequest.getParameter("erase")!=null){
							ObjectCacheFactory.getInstance().resetObjectCache();
							Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
							PreparedStatement ps = conn.prepareStatement("delete from oc_products");
							ps.execute();
							ps.close();
							conn.close();

					        UpdateSystem systemUpdate = new UpdateSystem();
					        systemUpdate.updateCounters();
						}						
						String type,id,language,label;
						//Read file as a prestations csv file
		                File f = new File(upBean.getFolderstore()+"/"+sFileName);
						BufferedReader br = new BufferedReader(new FileReader(f));
						SAXReader reader=new SAXReader(false);
						org.dom4j.Document document=reader.read(br);
						Element root = document.getRootElement();
						Iterator i = root.elementIterator("drug");
						lines=0;
						while(i.hasNext()){
							lines++;
							Element element = (Element)i.next();
							Product product = new Product();
							product.setUid("-1");
							product.setCreateDateTime(new Timestamp(new java.util.Date().getTime()));
							product.setName(element.elementText("name"));
							product.setPackageUnits(1);
							product.setProductGroup(element.elementText("group"));
							product.setProductSubGroup(element.elementText("category"));
							product.setSupplierUid("TEC.PHA");
							product.setUnit(element.elementText("form"));
							product.setUpdateDateTime(new Timestamp(new java.util.Date().getTime()));
							product.setUpdateUser(activeUser.userid);
							product.store();
						}
						i = root.elementIterator("drugcategory");
						if(i.hasNext() && mrequest.getParameter("erase")!=null){
							Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
							PreparedStatement ps = conn.prepareStatement("delete from DrugCategories");
							ps.execute();
							ps = conn.prepareStatement("delete from oc_labels where oc_label_type ='drug.category'");
							ps.execute();
							ps.close();
							conn.close();

					        UpdateSystem systemUpdate = new UpdateSystem();
					        systemUpdate.updateCounters();
						}
						while(i.hasNext()){
							lines++;
							Element element = (Element)i.next();
							DrugCategory category = new DrugCategory();
							category.code=element.elementText("code");
							category.parentcode=element.elementText("parentcode");
							category.updatetime=new java.util.Date();
							category.updateuserid=activeUser.userid;
							category.saveToDB();
							Iterator labels = element.elementIterator("label");
							while(labels.hasNext()){
								Element lbl = (Element)labels.next();
								MedwanQuery.getInstance().storeLabel("drug.category", element.elementText("code")+"", lbl.attributeValue("language"),lbl.getText(),Integer.parseInt(activeUser.userid));
							}
						}
						i = root.elementIterator("drugform");
						if(i.hasNext() && mrequest.getParameter("erase")!=null){
							Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
							PreparedStatement ps = conn.prepareStatement("delete from oc_labels where oc_label_type ='product.unit'");
							ps.execute();
							ps.close();
							conn.close();

					        UpdateSystem systemUpdate = new UpdateSystem();
					        systemUpdate.updateCounters();
						}
						while(i.hasNext()){
							lines++;
							Element element = (Element)i.next();
							Iterator labels = element.elementIterator("label");
							while(labels.hasNext()){
								Element lbl = (Element)labels.next();
								MedwanQuery.getInstance().storeLabel("product.unit", element.elementText("code")+"", lbl.attributeValue("language"), lbl.getText(), Integer.parseInt(activeUser.userid));
							}
						}
						i = root.elementIterator("druggroup");
						if(i.hasNext() && mrequest.getParameter("erase")!=null){
							Connection conn = MedwanQuery.getInstance().getOpenclinicConnection();
							PreparedStatement ps = conn.prepareStatement("delete from oc_labels where oc_label_type ='product.productgroup'");
							ps.execute();
							ps.close();
							conn.close();

					        UpdateSystem systemUpdate = new UpdateSystem();
					        systemUpdate.updateCounters();
						}
						while(i.hasNext()){
							lines++;
							Element element = (Element)i.next();
							Iterator labels = element.elementIterator("label");
							while(labels.hasNext()){
								Element lbl = (Element)labels.next();
								MedwanQuery.getInstance().storeLabel("product.productgroup", element.elementText("code")+"", lbl.attributeValue("language"), lbl.getText(), Integer.parseInt(activeUser.userid));
							}
						}
						br.close();
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
	else {
	}
%>
<form name="readMessageForm" method="post" enctype="multipart/form-data">
	<table>
		<tr>
			<td class='admin'>
				<%=getTran("web","filetype",sWebLanguage)%>
				<select name="filetype" id="filetype" class="text" onchange="showstructure();">
					<option value="prestationscsv"><%=getTran("web","prestations.csv",sWebLanguage)%></option>
					<option value="servicescsv"><%=getTran("web","services.csv",sWebLanguage)%></option>
					<option value="labelscsv"><%=getTran("web","labels.csv",sWebLanguage)%></option>
					<option value="labxml"><%=getTran("web","lab.xml",sWebLanguage)%></option>
					<option value="drugsxml"><%=getTran("web","drugs.xml",sWebLanguage)%></option>
				</select>
			</td>
			<td class='admin2'><input class="text" type="checkbox" name="erase" value="1"/> <%=getTran("web","delete.table.before.load",sWebLanguage)%></td>
			<td class='admin2'><input class="text" type="file" name="filename"/> <input class="button" type="submit" name="ButtonReadfile" value="<%=getTranNoLink("web","load",sWebLanguage)%>"/></td>
		</tr>
		<tr>
			<td colspan="2"><div id="structure"/></td>
		</tr>
    </table>
</form>

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
		else {
			document.getElementById("structure").innerHTML="";
		}
	}
	
	showstructure();
</script>