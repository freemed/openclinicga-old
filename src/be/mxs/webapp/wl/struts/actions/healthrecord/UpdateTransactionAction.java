package be.mxs.webapp.wl.struts.actions.healthrecord;

import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.vo.ValueObjectHelper;
import be.mxs.common.model.vo.ValueObjectHelperException;
import be.mxs.common.model.vo.healthrecord.IConstants;
import be.mxs.common.model.vo.healthrecord.ItemContextVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactory;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactoryGeneral;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;
import be.mxs.common.util.system.Mail;
import be.mxs.common.util.system.Pointer;
import be.mxs.common.util.system.ScreenHelper;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;
import be.mxs.webapp.wl.servlet.http.RequestParameterParser;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.openclinic.adt.Encounter;
import be.openclinic.common.ObjectReference;
import be.openclinic.finance.Debet;
import be.openclinic.finance.Prestation;
import be.openclinic.medical.Diagnosis;
import net.admin.User;
import net.admin.AdminPerson;
import net.admin.UserParameter;
import net.admin.system.AccessLog;
import org.apache.struts.action.ActionForm;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionMapping;

import javax.servlet.ServletException;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.io.IOException;
import java.io.PrintWriter;
import java.io.StringWriter;
import java.sql.Connection;
import java.sql.SQLException;
import java.util.*;

public class UpdateTransactionAction extends org.apache.struts.action.Action {

    //--- INNER CLASS ------------------------------------------------------------------------------
    private class DummyTransactionFactory extends TransactionFactory {
        public TransactionVO createTransactionVO(UserVO userVO) {
            return null;
        }
    }

    //--- PERFORM ----------------------------------------------------------------------------------
    public ActionForward perform(ActionMapping mapping,
                               ActionForm form,
                               HttpServletRequest request,
                               HttpServletResponse response)
        throws IOException, ServletException {

        ActionForward actionForward = mapping.findForward("failure");
        SessionContainerWO sessionContainerWO;

        try {
            sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
            if (sessionContainerWO.getHealthRecordVO()!=null){
                sessionContainerWO.getHealthRecordVO().setUpdated(true);
            }

            //*** send e-mail **********************************************************************
            try{
                String sMailTo = ScreenHelper.checkString(request.getParameter("MailTo"));
                String sMailMessage = ScreenHelper.checkString(request.getParameter("MailMessage"));

                if (sMailMessage.length()>0 && sMailTo.length()>0){
                    if (sMailTo.indexOf("@")==-1){
                        // only id : search email address
                        User user = new User();
                        user.initialize(Integer.parseInt(sMailTo));
                        sMailTo = "";
                    }

                    if (sMailTo.length()>0){
                        String sMailFrom = ScreenHelper.checkString(request.getParameter("MailFrom"));
                        if (sMailFrom.length()==0){
                            sMailFrom = MedwanQuery.getInstance().getConfigString("DefaultFromMailAddress");
                        }

                        String sMailSubject = ScreenHelper.checkString(request.getParameter("MailSubject"));
                        if (sMailSubject.length()==0){
                            sMailSubject = "OpenClinic";
                        }

                        // send messages
                        String sMailServer = MedwanQuery.getInstance().getConfigString("PatientEdit.MailServer");
                        Mail.sendMail(sMailServer,sMailFrom,sMailTo,sMailSubject,sMailMessage);
                    }
                }
            }
            catch (Exception e){
                Debug.println(e.getMessage());
            }

            Vector items = new Vector();
            
            boolean bIsNewTrans = sessionContainerWO.getCurrentTransactionVO().getTransactionId().intValue()<0;              // save accesslog

            if (sessionContainerWO.getCurrentTransactionVO().getTransactionType().equals(be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION)
                 || sessionContainerWO.getCurrentTransactionVO().getTransactionType().equals(be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_OPTHALMOLOGY_EX_WITH_STEREOSCOPY)
                 || sessionContainerWO.getCurrentTransactionVO().getTransactionType().equals(be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_OPHTALMOLOGY)){
                Iterator it = sessionContainerWO.getCurrentTransactionVO().getItems().iterator();
                ItemVO oldItem, newItem;

                while (it.hasNext()){
                    oldItem = (ItemVO)it.next();
                    if (oldItem.getValue() != null){
                        if (oldItem.getValue().trim().length()>0){
                            newItem = new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), oldItem.getType(),"",new Date(),oldItem.getItemContext());
                            newItem.setValue(oldItem.getValue());
                            newItem.setItemId(oldItem.getItemId());
                            newItem.setDate(oldItem.getDate());
                            newItem.setItemContext(oldItem.getItemContext());
                            newItem.setType(oldItem.getType());
                            items.add(newItem);
                        }
                    }
                }
            }

            // copy the CurrentTransactionVO
            TransactionVO oldTransaction = new TransactionVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()),sessionContainerWO.getCurrentTransactionVO().getTransactionType(),new Date(),new Date(),IConstants.TRANSACTION_STATUS_CLOSED, sessionContainerWO.getCurrentTransactionVO().getUser(),items,sessionContainerWO.getCurrentTransactionVO().getServerId(),sessionContainerWO.getCurrentTransactionVO().getVersion(),sessionContainerWO.getCurrentTransactionVO().getVersionserverId(),sessionContainerWO.getCurrentTransactionVO().getTimestamp());


            Hashtable dirtyRequestParameters = RequestParameterParser.getInstance().parseRequestParameters(request, "currentTransactionVO");
            Hashtable requestParameters = new Hashtable();
            Enumeration dirtypars = dirtyRequestParameters.keys();
            while(dirtypars.hasMoreElements()){
            	String key = (String)dirtypars.nextElement();
            	if(key.indexOf("_currentTransactionVO")<0){
            		requestParameters.put(key,dirtyRequestParameters.get(key));
            	}
            }

            String actionForwardKey;

            Collection valueObjectContainers = ValueObjectHelper.getInstance().updateModel(sessionContainerWO, requestParameters);
            Collection newTransactions = ValueObjectHelper.getInstance().getValueObjectsInPath(valueObjectContainers, "currentTransactionVO");

            Iterator iterator = newTransactions.iterator();
            DummyTransactionFactory df;
            TransactionVO newTransactionVO, baseTransactionVO, returnedTransactionVO;
            String factoryClass, subClass, key, value, sOldContext, code;
            Iterator i,ICPCItems;
            TransactionVO baseTransactionVO2;
            Vector newItems;
            ItemVO item, oldItem;
            Enumeration enumeration;
            ItemContextVO itemContextVO;
            Hashtable ICD10Codes, ICPCCodes, DSM4Codes;

            while (iterator.hasNext()) {
                df = new DummyTransactionFactory();
                newTransactionVO = (TransactionVO) iterator.next();
                factoryClass = null;
                subClass = null;

                if (sessionContainerWO.getCurrentTransactionVO().getTransactionType().equals(be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION)){
                    factoryClass = "be.mxs.common.model.vo.healthrecord.util.TransactionFactoryClinicalExamination";
                    subClass = request.getParameter("subClass");
                }

                if (sessionContainerWO.getCurrentTransactionVO().getTransactionType().equals(be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION)){
                    sessionContainerWO.setPersonalVaccinationsInfoVO(null);
                }

                if (sessionContainerWO.getCurrentTransactionVO().getTransactionType().equals(be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_OPHTALMOLOGY)){
                    factoryClass = "be.mxs.common.model.vo.healthrecord.util.TransactionFactoryOphtalmologyExaminationWithStereoscopy";
                    subClass = request.getParameter("subClass");
                }

                if (sessionContainerWO.getCurrentTransactionVO().getTransactionType().equals(be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR2)){
                    subClass = request.getParameter("subClass");
                }

                if (factoryClass != null){
                    try{
                        //baseTransactionVO2=null;
                        if (factoryClass.equalsIgnoreCase("be.mxs.common.model.vo.healthrecord.util.TransactionFactoryClinicalExamination")){
                            baseTransactionVO = TransactionFactory.createTransactionFactory(factoryClass).createTransactionVO(subClass);
                            baseTransactionVO2 = new TransactionFactoryGeneral().createTransactionVO(sessionContainerWO.getUserVO(),sessionContainerWO.getCurrentTransactionVO().getTransactionType(),false);
                        }
                        else {
                            baseTransactionVO = TransactionFactory.createTransactionFactory(factoryClass).createTransactionVO(subClass);
                            baseTransactionVO2 = TransactionFactory.createTransactionFactory(factoryClass).createTransactionVO((String)null);
                        }

                        i = baseTransactionVO.getItems().iterator();
                        while (i.hasNext()){
                            ((ItemVO)i.next()).setValue(null);
                        }

                        i = baseTransactionVO2.getItems().iterator();
                        while (i.hasNext()){
                            ((ItemVO)i.next()).setValue(null);
                        }

                        baseTransactionVO.setCreationDate(sessionContainerWO.getCurrentTransactionVO().getCreationDate());
                        baseTransactionVO.setStatus(sessionContainerWO.getCurrentTransactionVO().getStatus());
                        baseTransactionVO.setTransactionId(sessionContainerWO.getCurrentTransactionVO().getTransactionId());
                        baseTransactionVO.setServerId(sessionContainerWO.getCurrentTransactionVO().getServerId());
                        baseTransactionVO.setTransactionType(sessionContainerWO.getCurrentTransactionVO().getTransactionType());
                        baseTransactionVO.setUpdateTime(sessionContainerWO.getCurrentTransactionVO().getUpdateTime());
                        baseTransactionVO.setUser(sessionContainerWO.getCurrentTransactionVO().getUser());

                        baseTransactionVO2.setCreationDate(sessionContainerWO.getCurrentTransactionVO().getCreationDate());
                        baseTransactionVO2.setStatus(sessionContainerWO.getCurrentTransactionVO().getStatus());
                        baseTransactionVO2.setTransactionId(sessionContainerWO.getCurrentTransactionVO().getTransactionId());
                        baseTransactionVO2.setServerId(sessionContainerWO.getCurrentTransactionVO().getServerId());
                        baseTransactionVO2.setTransactionType(sessionContainerWO.getCurrentTransactionVO().getTransactionType());
                        baseTransactionVO2.setUpdateTime(sessionContainerWO.getCurrentTransactionVO().getUpdateTime());
                        baseTransactionVO2.setUser(sessionContainerWO.getCurrentTransactionVO().getUser());

                        df.populateTransaction(baseTransactionVO,newTransactionVO);
                        df.populateTransaction(oldTransaction,baseTransactionVO);
                        df.populateTransactionPreserve(oldTransaction,baseTransactionVO2);

                        newTransactionVO = oldTransaction;
                    }
                    catch (Exception e){
                        e.printStackTrace();
                    }
                }

                if (request.getParameter("be.mxs.healthrecord.updateTransaction.preserve")==null){
                    df.populateTransaction(oldTransaction,newTransactionVO);
                }
                else {
                    df.populateTransactionPreserve(oldTransaction,newTransactionVO);
                }

                if (request.getParameter("be.mxs.healthrecord.updateTransaction.actionForwardKey").indexOf("be.mxs.healthrecord.transaction_id=currentTransaction")<=0){
                	df.cleanTransaction(oldTransaction);
                    // Alle oude ICPCCodes en ICD10Codes en DSM4Codes wissen
                    newItems = new Vector();
                    ICPCItems = oldTransaction.getItems().iterator();

                    while (ICPCItems.hasNext()){
                        item = (ItemVO)ICPCItems.next();
                        if (item.getType().indexOf("ICPCCode")==-1 && item.getType().indexOf("ICD10Code")==-1 && item.getType().indexOf("DSM4Code")==-1){
                            newItems.add(item);
                        }
                    }
                    oldTransaction.setItems(newItems);

                    // ICPCCodes toevoegen
                    ICPCCodes = RequestParameterParser.getInstance().parseRequestParameters(request, "ICPCCode");
                    enumeration=ICPCCodes.keys();
                    itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                    while (enumeration.hasMoreElements()){
                        code=(String)enumeration.nextElement();
                        if (code.indexOf("ICPCCode")==0 || code.indexOf("GravityICPCCode")==0 || code.indexOf("CertaintyICPCCode")==0 || code.indexOf("POAICPCCode")==0 || code.indexOf("NCICPCCode")==0 || code.indexOf("ServiceICPCCode")==0 || code.indexOf("FlagsICPCCode")==0){
                            oldTransaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), code,(String)ICPCCodes.get(code),new Date(),itemContextVO));
                        }
                    }
                    // DSM4Codes toevoegen
                    DSM4Codes = RequestParameterParser.getInstance().parseRequestParameters(request, "DSM4Code");
                    enumeration=DSM4Codes.keys();
                    itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");
                    while (enumeration.hasMoreElements()){
                        code=(String)enumeration.nextElement();
                        if (code.indexOf("DSM4Code")==0 || code.indexOf("GravityDSM4Code")==0 || code.indexOf("CertaintyDSM4Code")==0 || code.indexOf("POADSM4Code")==0 || code.indexOf("NCDSM4Code")==0 || code.indexOf("ServiceDSM4Code")==0 || code.indexOf("FlagsDSM4Code")==0){
                            oldTransaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), code,(String)DSM4Codes.get(code),new Date(),itemContextVO));
                        }
                    }
                    // ICD10Codes toevoegen
                    ICD10Codes = RequestParameterParser.getInstance().parseRequestParameters(request, "ICD10Code");
                    enumeration=ICD10Codes.keys();
                    while (enumeration.hasMoreElements()){
                        code=(String)enumeration.nextElement();
                        if (code.indexOf("ICD10Code")==0 || code.indexOf("GravityICD10Code")==0 || code.indexOf("CertaintyICD10Code")==0 || code.indexOf("POAICD10Code")==0 || code.indexOf("NCICD10Code")==0 || code.indexOf("ServiceICD10Code")==0 || code.indexOf("FlagsICD10Code")==0){
                            oldTransaction.getItems().add(new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), code,(String)ICD10Codes.get(code),new Date(),itemContextVO));
                        }
                    }
                    TransactionVO previousTransaction=null;
                    if (oldTransaction.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DELIVERY")){
                    	previousTransaction = MedwanQuery.getInstance().loadTransaction(oldTransaction.getServerId(), oldTransaction.getTransactionId().intValue());
                    }

                    String privatetransaction = ScreenHelper.checkString(request.getParameter("privatetransaction"));
                    ItemVO privateItem=oldTransaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PRIVATETRANSACTION");
                    if(privateItem==null){
                        privateItem = new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier())
                        , "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PRIVATETRANSACTION"
                        ,sessionContainerWO.getPersonVO().personId.intValue()+""
                        ,new Date()
                        ,new ItemContextVO(new Integer(IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", ""));
                    	oldTransaction.getItems().add(privateItem);
                    }
                    privateItem.setValue(privatetransaction);

                    //Sla de transactie op
                    returnedTransactionVO = MedwanQuery.getInstance().updateTransaction(sessionContainerWO.getPersonVO().personId.intValue(),oldTransaction);
                    if(returnedTransactionVO.getVersion()>1){
                    	Pointer.storePointer("TU."+returnedTransactionVO.getServerId()+"."+returnedTransactionVO.getTransactionId()+"."+returnedTransactionVO.getVersion(),sessionContainerWO.getUserVO().userId+"");
                    }
                    if (MedwanQuery.getInstance().getConfigInt("automatedDebet",0)==1){
                        ItemVO ctxt=returnedTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT");
                        try{
                        	Prestation.registerPrestationsAsDebetTransactions("TRAN."+returnedTransactionVO.getTransactionType()+"."+(ctxt!=null?ctxt.getValue():""),null,returnedTransactionVO.getUpdateTime(),null,new ObjectReference("Person",returnedTransactionVO.getUser().getPersonVO().getPersonId()+""),new ObjectReference("Transaction",returnedTransactionVO.getObjectUid()),returnedTransactionVO.getUser().getUserId()+"",sessionContainerWO.getPersonVO().getPersonId()+"");
                        }
                        catch(Exception a){}
                    }
                    if (MedwanQuery.getInstance().getConfigInt("exportEnabled")==1){
                        request.getSession().setAttribute("exportActivityCheck","");
                        if (request.getSession().getAttribute("nightShift")!=null && ((String)request.getSession().getAttribute("nightShift")).length()>0){
                            MedwanQuery.getInstance().exportTransaction(sessionContainerWO.getPersonVO().personId.intValue(),returnedTransactionVO,sessionContainerWO.getUserVO().getUserId().toString(),true,(String)request.getSession().getAttribute("activeMedicalCenter"),(String)request.getSession().getAttribute("activeMD"),(String)request.getSession().getAttribute("activePara"));
                        }
                        else {
                            MedwanQuery.getInstance().exportTransaction(sessionContainerWO.getPersonVO().personId.intValue(),returnedTransactionVO,sessionContainerWO.getUserVO().getUserId().toString(),false,(String)request.getSession().getAttribute("activeMedicalCenter"),(String)request.getSession().getAttribute("activeMD"),(String)request.getSession().getAttribute("activePara"));
                        }
                    }
// bij geboorte, kind aanmaken + transactie registreren
                    if (returnedTransactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_DELIVERY")){
                        ItemVO previousLastName=null;
                        if(previousTransaction!=null){
                        	previousLastName=previousTransaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_LASTNAME");
                        }
                    	if (previousLastName==null || ScreenHelper.checkString(previousLastName.getValue()).length()==0){
                            ItemVO itemChildLastname = returnedTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_LASTNAME");
                            if ((itemChildLastname!=null)&&(ScreenHelper.checkString(itemChildLastname.getValue()).length()>0)){
                                ItemVO itemChildFirstname = returnedTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_FIRSTNAME");
                                ItemVO itemChildDOB = returnedTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_CHILD_DOB");
                                ItemVO itemChildGender = returnedTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_DELIVERY_GENDER");

                                AdminPerson personChild = new AdminPerson();

                                if ((itemChildGender!=null)&&(ScreenHelper.checkString(itemChildGender.getValue()).length()>0)){
                                    if (itemChildGender.getValue().equalsIgnoreCase("male")){
                                        personChild.gender = "M";
                                    }
                                    else if (itemChildGender.getValue().equalsIgnoreCase("female")){
                                        personChild.gender = "F";
                                    }
                                }

                                personChild.lastname = itemChildLastname.getValue();
                                personChild.firstname = ScreenHelper.checkString(itemChildFirstname.getValue());
                                personChild.dateOfBirth = ScreenHelper.checkString(itemChildDOB.getValue());
                                personChild.sourceid = MedwanQuery.getInstance().getConfigString("PatientEditSourceID");
                                personChild.updateuserid = returnedTransactionVO.getUser().getUserId().intValue()+"";
                            	Connection ad_conn = MedwanQuery.getInstance().getAdminConnection();
                                personChild.saveToDB(ad_conn);
                                try {
									ad_conn.close();
								} catch (SQLException e) {
									e.printStackTrace();
								}

                                if (ScreenHelper.checkString(personChild.personid).length()>0){
                                    Vector vChildItems = new Vector();

                                    ItemVO itemChildPersonId = new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier())
                                            , "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PERSONID"
                                            ,sessionContainerWO.getPersonVO().personId.intValue()+""
                                            ,new Date()
                                            ,itemChildFirstname.getItemContext());
                                    vChildItems.add(itemChildPersonId);

                                    ItemVO itemChildTransactionId = new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier())
                                            , "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_TRANSACTIONID"
                                            ,returnedTransactionVO.getTransactionId().intValue()+""
                                            ,new Date()
                                            ,itemChildFirstname.getItemContext());
                                    vChildItems.add(itemChildTransactionId);

                                    ItemVO itemChildServerId = new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier())
                                            , "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_SERVERID"
                                            ,returnedTransactionVO.getServerId()+""
                                            ,new Date()
                                            ,itemChildFirstname.getItemContext());
                                    vChildItems.add(itemChildServerId);

                                    TransactionVO transactionDelivery = new TransactionVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier())
                                            ,"be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_PEDIATRY_DELIVERY"
                                            ,new Date()
                                            ,new Date()
                                            ,IConstants.TRANSACTION_STATUS_CLOSED, sessionContainerWO.getCurrentTransactionVO().getUser()
                                            ,vChildItems
                                            ,sessionContainerWO.getCurrentTransactionVO().getServerId()
                                            ,sessionContainerWO.getCurrentTransactionVO().getVersion()
                                            ,sessionContainerWO.getCurrentTransactionVO().getVersionserverId()
                                            ,sessionContainerWO.getCurrentTransactionVO().getTimestamp());

                                    MedwanQuery.getInstance().updateTransaction(Integer.parseInt(personChild.personid),transactionDelivery);

                                }
                            }
                        }
                    }
                    else if(returnedTransactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR2")){
                    	item = returnedTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_MIR2_TYPE");
                    	if(item!=null && ScreenHelper.checkString(item.getValue()).length()>0){
                            if(MedwanQuery.getInstance().getConfigInt("enableAutomaticImagingInvoicing",0)==1){
                            	Debet.createAutomaticDebetByAlias("MIRPREST."+returnedTransactionVO.getTransactionId(), sessionContainerWO.getPersonVO().personId+"", "mir_type."+item.getValue(), sessionContainerWO.getUserVO().userId+"",24*3600*1000);
                            }
                    	}
                    }
                    else if(returnedTransactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_OPERATION_PROTOCOL")){
                    	item = returnedTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT1");
                    	if(item!=null && ScreenHelper.checkString(item.getValue()).length()>0){
                            if(MedwanQuery.getInstance().getConfigInt("enableAutomaticSurgeryInvoicing",0)==1){
                            	Debet.createAutomaticDebetByAlias("SURGERYPREST."+returnedTransactionVO.getTransactionId(), sessionContainerWO.getPersonVO().personId+"", "surgicalacts."+item.getValue(), sessionContainerWO.getUserVO().userId+"",24*3600*1000);
                            }
                    	}
                    	item = returnedTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT2");
                    	if(item!=null && ScreenHelper.checkString(item.getValue()).length()>0){
                            if(MedwanQuery.getInstance().getConfigInt("enableAutomaticSurgeryInvoicing",0)==1){
                            	Debet.createAutomaticDebetByAlias("SURGERYPREST."+returnedTransactionVO.getTransactionId(), sessionContainerWO.getPersonVO().personId+"", "surgicalacts."+item.getValue(), sessionContainerWO.getUserVO().userId+"",24*3600*1000);
                            }
                    	}
                    	item = returnedTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_OPERATION_PROTOCOL_SURGICAL_ACT3");
                    	if(item!=null && ScreenHelper.checkString(item.getValue()).length()>0){
                            if(MedwanQuery.getInstance().getConfigInt("enableAutomaticSurgeryInvoicing",0)==1){
                            	Debet.createAutomaticDebetByAlias("SURGERYPREST."+returnedTransactionVO.getTransactionId(), sessionContainerWO.getPersonVO().personId+"", "surgicalacts."+item.getValue(), sessionContainerWO.getUserVO().userId+"",24*3600*1000);
                            }
                    	}
                    }
                    else if(returnedTransactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST")){
                    	//Bewaar SMS en e-mail in user profiel
                    	item = returnedTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_SMS");
                    	if(item!=null && ScreenHelper.checkString(item.getValue()).length()>0){
                    		UserParameter.saveUserParameter("lastLabSMS", item.getValue(), returnedTransactionVO.getUser().userId);
                    	}
                    	item = returnedTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_LAB_EMAIL");
                    	if(item!=null && ScreenHelper.checkString(item.getValue()).length()>0){
                    		UserParameter.saveUserParameter("lastLabEmail", item.getValue(), returnedTransactionVO.getUser().userId);
                    	}
                    }

                    //Delete diagnoses from OC_DIAGNOSES and ADD all+new again
                    Diagnosis.deleteDiagnosesByReferenceUID(returnedTransactionVO.getServerId()+"."+returnedTransactionVO.getTransactionId(),"Transaction");
                    ItemVO encounterItem=returnedTransactionVO.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_ENCOUNTERUID");
                    if(encounterItem!=null){
                    	Encounter encounter = Encounter.get(encounterItem.getValue());
                    	if(encounter!=null){
                    		saveDiagnosesToTable(RequestParameterParser.getInstance().parseRequestParameters(request, "ICPCCode"),RequestParameterParser.getInstance().parseRequestParameters(request, "ICD10Code"),RequestParameterParser.getInstance().parseRequestParameters(request, "DSM4Code"),returnedTransactionVO.getServerId()+"."+returnedTransactionVO.getTransactionId(),sessionContainerWO,encounter);
                    	}
                    }

                    sessionContainerWO.setCurrentTransactionVO(returnedTransactionVO);
                    requestParameters = RequestParameterParser.getInstance().parseRequestParameters(request, "inactiveDiagnosis");
                    enumeration = requestParameters.keys();

                    while (enumeration.hasMoreElements()) {
                        key = (String) enumeration.nextElement();
                        value = (String)requestParameters.get(key);
                        if (value.equalsIgnoreCase("medwan.common.true")){
                            key = key.replaceAll("inactiveDiagnosis.","");
                            MedwanQuery.getInstance().inactivateDiagnosis(sessionContainerWO.getPersonVO().personId.intValue(),key,sessionContainerWO.getCurrentTransactionVO().getUpdateTime());
                        }
                    }

                    //Bewaar de actieve diagnoses
                    MedwanQuery.getInstance().activateDiagnosis(sessionContainerWO.getPersonVO().personId.intValue(),sessionContainerWO.getCurrentTransactionVO().getTransactionId().intValue(),sessionContainerWO.getCurrentTransactionVO().getServerId(),sessionContainerWO.getCurrentTransactionVO().getUpdateTime());
                }
                else {
                    sessionContainerWO.setCurrentTransactionVO(oldTransaction);
                }

                oldItem = oldTransaction.getItem("be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_CONTEXT_CONTEXT");
                if (oldItem!=null){
                    sOldContext = ScreenHelper.checkString(oldItem.getValue());
                    sessionContainerWO.getFlags().setContext(sOldContext);
                }
            }

            // action forward
            actionForwardKey = request.getParameter("be.mxs.healthrecord.updateTransaction.actionForwardKey");
            if (actionForwardKey==null){
                actionForwardKey = "";
            }

            // add ts if not present
            if (actionForwardKey.indexOf("ts=")<0){
                actionForwardKey+= (request.getParameter("be.mxs.healthrecord.updateTransaction.actionForwardKey").indexOf("?")>-1?"&":"?")+"ts=" + new java.util.Date().hashCode();
            }

            //update exitmessage if it exists
            String exitmessage = request.getParameter("exitmessage");
            if(exitmessage!=null){
                actionForwardKey+="&exitmessage="+request.getParameter("exitmessage")+"."+sessionContainerWO.getCurrentTransactionVO().getServerId()+"."+sessionContainerWO.getCurrentTransactionVO().getTransactionId();
            }

            if (actionForwardKey != null) {
                if (actionForwardKey.indexOf("ForwardUpdateTransactionId")>-1){
                    returnedTransactionVO = sessionContainerWO.getCurrentTransactionVO();
                    actionForwardKey+= "&be.mxs.healthrecord.createTransaction.transactionType="+returnedTransactionVO.getTransactionType()+"&be.mxs.healthrecord.transaction_id="+returnedTransactionVO.getTransactionId()+"&be.mxs.healthrecord.server_id="+returnedTransactionVO.getServerId();
                }
                actionForward = new ActionForward(actionForwardKey, true);
            }
            sessionContainerWO.getHealthRecordVO().setUpdated(true);
            
            // INSERT ACCESS LOG
            if(bIsNewTrans){
            	AccessLog.insert(sessionContainerWO.getCurrentTransactionVO().getUser().getUserId()+"","T."+sessionContainerWO.getCurrentTransactionVO().getServerId()+"."+sessionContainerWO.getCurrentTransactionVO().getTransactionId().intValue());
            }
        }
        catch (SessionContainerFactoryException e) {
            try {
                e.printStackTrace();

                StringWriter writer = new StringWriter();
                e.printStackTrace(new PrintWriter(writer));

                sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
                sessionContainerWO.resetErrorMessage();
                sessionContainerWO.addErrorMessage("Exception in " + this.getClass().getName() + "\nCause: \n" + e.getCause().getMessage() + "\nMessage: \n" + e.getMessage());
                sessionContainerWO.addErrorMessage(""+writer.getBuffer());

            }
            catch (SessionContainerFactoryException e1) {
                e1.printStackTrace();
            }

            actionForward = mapping.findForward( "failure" );
        }
        catch (ValueObjectHelperException e) {
            try {
                e.printStackTrace();

                StringWriter writer = new StringWriter();
                e.printStackTrace(new PrintWriter(writer));

                sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
                sessionContainerWO.resetErrorMessage();
                sessionContainerWO.addErrorMessage(""+writer.getBuffer());

            }
            catch (SessionContainerFactoryException e1) {
                e1.printStackTrace();
            }

            actionForward = mapping.findForward("failure");
        }

        return actionForward;
    }

    public static void saveDiagnosesToTable(Hashtable ICPCCodes,Hashtable ICD10Codes,Hashtable DSM4Codes,String sTransactionUID,SessionContainerWO sessionContainerWO,Encounter encounter){

        Enumeration enumeration;
        String code;
        enumeration=ICPCCodes.keys();
        while (enumeration.hasMoreElements()){
            code=(String)enumeration.nextElement();
            if (code.indexOf("ICPCCode")==0){
                if(ScreenHelper.checkString((String)ICPCCodes.get("Gravity"+code)).length() > 0 && ScreenHelper.checkString((String)ICPCCodes.get("Certainty"+code)).length() > 0){
                    Diagnosis.saveTransactionDiagnosisWithServiceAndFlags(code,
                                                      ScreenHelper.checkString((String)ICPCCodes.get(code)),
                                                      ScreenHelper.checkString((String)ICPCCodes.get("Gravity"+code)),
                                                      ScreenHelper.checkString((String)ICPCCodes.get("Certainty"+code)),
                                                      sessionContainerWO.getPersonVO().personId.toString(),
                                                      "ICPCCode",
                                                      "icpc",
                                                      ScreenHelper.getSQLTime(),
                                                      sTransactionUID,
                                                      sessionContainerWO.getUserVO().getUserId().intValue(),
                                                      encounter,
                                                      ScreenHelper.checkString((String)ICPCCodes.get("POA"+code)),
                                                      ScreenHelper.checkString((String)ICPCCodes.get("NC"+code)),
                                                      ScreenHelper.checkString((String)ICPCCodes.get("Service"+code)),
                                                      ScreenHelper.checkString((String)ICPCCodes.get("Flags"+code))
                    );
                }
            }
        }
        enumeration=DSM4Codes.keys();
        while (enumeration.hasMoreElements()){
            code=(String)enumeration.nextElement();
            if (code.indexOf("DSM4Code")==0){
                if(ScreenHelper.checkString((String)DSM4Codes.get("Gravity"+code)).length() > 0 && ScreenHelper.checkString((String)DSM4Codes.get("Certainty"+code)).length() > 0){
                    Diagnosis.saveTransactionDiagnosisWithServiceAndFlags(code,
                                                      ScreenHelper.checkString((String)DSM4Codes.get(code)),
                                                      ScreenHelper.checkString((String)DSM4Codes.get("Gravity"+code)),
                                                      ScreenHelper.checkString((String)DSM4Codes.get("Certainty"+code)),
                                                      sessionContainerWO.getPersonVO().personId.toString(),
                                                      "DSM4Code",
                                                      "dsm4",
                                                      ScreenHelper.getSQLTime(),
                                                      sTransactionUID,
                                                      sessionContainerWO.getUserVO().getUserId().intValue(),
                                                      encounter,
                                                      ScreenHelper.checkString((String)DSM4Codes.get("POA"+code)),
                                                      ScreenHelper.checkString((String)DSM4Codes.get("NC"+code)),
                                                      ScreenHelper.checkString((String)DSM4Codes.get("Service"+code)),
                                                      ScreenHelper.checkString((String)DSM4Codes.get("Flags"+code))
                    );
                }
            }
        }
        // ICD10Codes toevoegen
        enumeration=ICD10Codes.keys();

        while (enumeration.hasMoreElements()){
            code=(String)enumeration.nextElement();
            if (code.indexOf("ICD10Code")==0){
                if(ScreenHelper.checkString((String)ICD10Codes.get("Gravity"+code)).length() > 0 && ScreenHelper.checkString((String)ICD10Codes.get("Certainty"+code)).length() > 0){
                    Diagnosis.saveTransactionDiagnosisWithServiceAndFlags(code,
                                                      ScreenHelper.checkString((String)ICD10Codes.get(code)),
                                                      ScreenHelper.checkString((String)ICD10Codes.get("Gravity"+code)),
                                                      ScreenHelper.checkString((String)ICD10Codes.get("Certainty"+code)),
                                                      sessionContainerWO.getPersonVO().personId.toString(),
                                                      "ICD10Code",
                                                      "icd10",
                                                      ScreenHelper.getSQLTime(),
                                                      sTransactionUID,
                                                      sessionContainerWO.getUserVO().getUserId().intValue(),
                                                      encounter,
                                                      ScreenHelper.checkString((String)ICD10Codes.get("POA"+code)),
                                                      ScreenHelper.checkString((String)ICD10Codes.get("NC"+code)),
                                                      ScreenHelper.checkString((String)ICD10Codes.get("Service"+code)),
                                                      ScreenHelper.checkString((String)ICD10Codes.get("Flags"+code))

                    );
                }
            }
        }
    }
}