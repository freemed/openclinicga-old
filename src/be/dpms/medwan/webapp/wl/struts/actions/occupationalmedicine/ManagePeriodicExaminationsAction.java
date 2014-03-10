package be.dpms.medwan.webapp.wl.struts.actions.occupationalmedicine;

import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionForm;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import java.io.IOException;
import java.util.*;
import java.text.SimpleDateFormat;
import java.text.ParseException;

import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.dpms.medwan.webapp.wo.occupationalmedicine.RiskProfileRiskCodeWO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.*;
import be.dpms.medwan.common.model.vo.administration.PersonVO;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.date.MedwanCalendar;
import be.mxs.common.util.system.Miscelaneous;
import be.mxs.common.model.vo.healthrecord.*;
import net.admin.AdminPerson;

public class ManagePeriodicExaminationsAction extends org.apache.struts.action.Action {

    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {

        ActionForward actionForward = mapping.findForward( "success" );

        try {
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
            sessionContainerWO.setCurrentTransactionVO(null);

            AdminPerson adminPerson=(AdminPerson)(request.getSession().getAttribute("activePatient"));
            String personid=request.getParameter("PersonID");
            //Debug.println("personid="+personid);

            if (personid!=null){
                if (personid.equals("") ||personid.equals("null")){
                    if (adminPerson!=null){
                        personid=adminPerson.personid;
                    }
                    else
                    {
                        if (sessionContainerWO.getPersonVO()!=null){
                            personid=sessionContainerWO.getPersonVO().getPersonId().toString();
                        }
                        else {
                            personid="-1";
                        }
                    }
                }
            }
            else{
                if (sessionContainerWO.getPersonVO()!=null){
                    personid=sessionContainerWO.getPersonVO().getPersonId().toString();
                }
                else {
                    personid="-1";
                }
            }
            
            PersonVO personVO = sessionContainerWO.verifyPerson(personid);
            HealthRecordVO healthRecordVO = sessionContainerWO.verifyHealthRecord("be.mxs.healthrecord.transactionVO.date");

            //Some actions are only usefull if there is a HealthRecord
            if (healthRecordVO != null){
                sessionContainerWO.setRiskProfileVerifiedExaminations(null);
                sessionContainerWO.setRiskProfileVO(null);

                PersonalVaccinationsInfoVO personalVaccinationsInfoVO = sessionContainerWO.getPersonalVaccinationsInfoVO();
                if (sessionContainerWO.getPersonalVaccinationsInfoVO()==null && sessionContainerWO.getPersonVO()!=null){
                    personalVaccinationsInfoVO = MedwanQuery.getInstance().getPersonalVaccinationsInfo( sessionContainerWO.getPersonVO(),sessionContainerWO.getUserVO());
                    sessionContainerWO.setPersonalVaccinationsInfoVO( personalVaccinationsInfoVO );
                }
                else if (sessionContainerWO.getPersonVO()!=null && !sessionContainerWO.getPersonalVaccinationsInfoVO().getPersonVO().getPersonId().equals(sessionContainerWO.getPersonVO().getPersonId())){
                    personalVaccinationsInfoVO = MedwanQuery.getInstance().getPersonalVaccinationsInfo( sessionContainerWO.getPersonVO(),sessionContainerWO.getUserVO() );
                    sessionContainerWO.setPersonalVaccinationsInfoVO( personalVaccinationsInfoVO );
                }

                FlagsVO flagsVO = new FlagsVO();

                //BEGIN SET CONTEXT DATA
                String _param_activeDepartment = request.getParameter("be.medwan.context.department");
                String _param_activeContext = request.getParameter("be.medwan.context.context");
                if (_param_activeContext==null){
                    _param_activeContext=sessionContainerWO.getFlags().getContext();
                }
                if (_param_activeDepartment==null){
                    _param_activeDepartment=sessionContainerWO.getFlags().getDepartment();
                }
                if (_param_activeContext.equals("")){
                    _param_activeContext="context.context.periodic-examinations";
                }
                if (_param_activeDepartment.equals("")){
                    _param_activeDepartment="context.department.occup";
                }
                flagsVO.setDepartment(_param_activeDepartment);
                flagsVO.setContext(_param_activeContext);
                //END SET CONTEXT DATA

                float age = MedwanQuery.getInstance().getAgeDecimal(sessionContainerWO.getPersonVO().getPersonId().intValue());
                flagsVO.setAge(age);
                sessionContainerWO.setFlags(flagsVO);

                RiskProfileVO riskProfileVO = sessionContainerWO.getRiskProfileVO();
                if ( riskProfileVO == null) {
                    riskProfileVO = MedwanQuery.getInstance().getRiskProfileVO(new Long(personVO.getPersonId().longValue()),sessionContainerWO);
                    Iterator iRiskCodes = riskProfileVO.getRiskCodes().iterator();
                    Vector riskCodesVO = new Vector();
                    while (iRiskCodes.hasNext()){
                        riskCodesVO.add(new RiskProfileRiskCodeWO((RiskProfileRiskCodeVO)iRiskCodes.next(),sessionContainerWO.getUserVO().getPersonVO().getLanguage()));
                    }
                    sessionContainerWO.setRiskCodesVO(riskCodesVO);

                    sessionContainerWO.setRiskProfileVO( riskProfileVO );
                }
                Iterator ir = sessionContainerWO.getRiskProfileVO().getRiskCodes().iterator();
                boolean bDriversLicenseDue = false;
                RiskProfileRiskCodeVO riskProfileRiskCodeVO;
                while (ir.hasNext()){
                    riskProfileRiskCodeVO = (RiskProfileRiskCodeVO)ir.next();
                    if (riskProfileRiskCodeVO.getCode().equalsIgnoreCase(MedwanQuery.getInstance().getConfigString("codeChauffeurCat2"))){
                        bDriversLicenseDue=true;
                        break;
                    }
                }
                if (!bDriversLicenseDue){
                    if (flagsVO.getLastDrivingCertificate()!=null)
                        flagsVO.getLastDrivingCertificate().setNewExaminationDue("medwan.common.unknown");
                }
                
                //Check if vaccinations are to be given
                flagsVO.setOveralVaccinationStatus(new VaccinationInfoVO().getGreenCode());
                Iterator vaccinations = personalVaccinationsInfoVO.getVaccinationsInfoVO().iterator();
                VaccinationInfoVO vaccinationInfoVO;
                Iterator iteratorRiskExaminations;
                RiskProfileExaminationVO riskProfileExaminationVO;
                while (vaccinations.hasNext()){
                    vaccinationInfoVO = (VaccinationInfoVO)vaccinations.next();
                    if (vaccinationInfoVO.getColor().equals(vaccinationInfoVO.getRedCode())){
                        iteratorRiskExaminations = sessionContainerWO.getRiskProfileVO().getRiskProfileExaminations().iterator();
                        while(iteratorRiskExaminations.hasNext()){
                            riskProfileExaminationVO = (RiskProfileExaminationVO)iteratorRiskExaminations.next();
                            //Debug.println("Analyzed examination: "+riskProfileExaminationVO.getTransactionType()+"/"+riskProfileExaminationVO.getMessageKey());
                            if (riskProfileExaminationVO.getTransactionType().indexOf("TRANSACTION_TYPE_VACCINATION")>0 && riskProfileExaminationVO.getTransactionType().indexOf(vaccinationInfoVO.getType())>0 && !riskProfileExaminationVO.getStatus().equals(new Integer(be.dpms.medwan.common.model.IConstants.RISK_PROFILE_ITEM__STATUS_DELETED))){
                                flagsVO.setOveralVaccinationStatus(vaccinationInfoVO.getRedCode());
                                break;
                            }
                        }
                    }
                }

                Miscelaneous.setLastItems(sessionContainerWO);

                if (sessionContainerWO.getRiskProfileVerifiedExaminations()==null){
                    Collection allExaminations = MedwanQuery.getInstance().getAllExaminations(sessionContainerWO.getUserVO().personVO.language);

                    Collection otherExaminations = new Vector();
                    Collection verifiedExaminations = new Vector();

                    Iterator iteratorAllExaminations = allExaminations.iterator();
                    boolean bFound;
                    ExaminationVO examinationVO;
                    Iterator iterator;
                    VerifiedExaminationVO verifiedExaminationVO;
                    String transactionType;
                    Date newDueDate;
                    long defaultInterval, fullDefaultInterval, personalInterval, fullPersonalInterval, dueInterval;
                    while (iteratorAllExaminations.hasNext()) {

                        bFound = false;
                        examinationVO = (ExaminationVO) iteratorAllExaminations.next();
                        iterator = riskProfileVO.getRiskProfileExaminations().iterator();
                        while (iterator.hasNext()) {

                            riskProfileExaminationVO = (RiskProfileExaminationVO) iterator.next();
                            if ((examinationVO.getId().equals( riskProfileExaminationVO.getId())) && (!riskProfileExaminationVO.getTransactionType().startsWith("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_VACCINATION")) && (!riskProfileExaminationVO.getStatus().equals(new Integer(-1)))) {
                                bFound = true;
                                transactionType= examinationVO.getTransactionType();
                                if (sessionContainerWO.getHealthRecordVO().hashCode() != 0){
                                    verifiedExaminationVO = new VerifiedExaminationVO(examinationVO.id.intValue(),(sessionContainerWO.getHealthRecordVO().getHealthRecordId()).toString(),examinationVO.getLabel(),transactionType,sessionContainerWO);
                                }
                                else {
                                    verifiedExaminationVO = new VerifiedExaminationVO(examinationVO.id.intValue(),"-1",examinationVO.getLabel(),transactionType,sessionContainerWO);
                                }
                                defaultInterval = new Double((riskProfileExaminationVO.defaultFrequency-riskProfileExaminationVO.defaultTolerance)*30.42*24*60).longValue();
                                fullDefaultInterval = new Double((riskProfileExaminationVO.defaultFrequency)*30.42*24*60).longValue();
                                defaultInterval = defaultInterval*60000;
                                personalInterval = new Double((riskProfileExaminationVO.personalFrequency-riskProfileExaminationVO.personalTolerance)*30.42*24*60).longValue();
                                fullPersonalInterval = new Double((riskProfileExaminationVO.personalFrequency)*30.42*24*60).longValue();
                                personalInterval = personalInterval * 60000;
                                newDueDate = new Date();
                                dueInterval =0;
                                //personalInterval defines calculation
                                if (personalInterval > 0){
                                    newDueDate = MedwanCalendar.getNewDate(new Date(),-personalInterval);
                                    dueInterval=fullPersonalInterval;
                                }
                                else if (defaultInterval > 0){
                                    //defaultInterval defines calculation
                                    newDueDate = MedwanCalendar.getNewDate(new Date(),-defaultInterval);
                                    dueInterval=fullDefaultInterval;
                                }
                                if (verifiedExaminationVO.getLastExaminationDate()!=null){
                                    if (verifiedExaminationVO.getTransactionType().equalsIgnoreCase(IConstants.TRANSACTION_TYPE_DRIVING_LICENCE_DECLARATION)){
                                        if (flagsVO.getLastDrivingCertificate().getNewExaminationDue().equalsIgnoreCase("medwan.common.true") && verifiedExaminationVO.getLastExaminationDate().before(new SimpleDateFormat("dd/MM/yyyy").parse(new SimpleDateFormat("dd/MM/yyyy").format(new java.util.Date())))){
                                            verifiedExaminationVO.setNewExaminationDue("medwan.common.true");
                                        }
                                        else {
                                            verifiedExaminationVO.setNewExaminationDue("medwan.common.false");
                                        }
                                    }
                                    else {
                                        verifiedExaminationVO.setNewExaminationDueDate(new Date(verifiedExaminationVO.getLastExaminationDate().getTime()+dueInterval*60000));
                                        if(verifiedExaminationVO.getLastExaminationDate().after(newDueDate)){
                                            verifiedExaminationVO.setNewExaminationDue("medwan.common.false");
                                        }
                                        else {
                                            verifiedExaminationVO.setNewExaminationDue("medwan.common.true");
                                        }
                                    }
                                }
                                else {
                                    verifiedExaminationVO.setNewExaminationDueDate(new Date(newDueDate.getTime()+dueInterval*60000));
                                    verifiedExaminationVO.setNewExaminationDue("medwan.common.true");
                                }
                                verifiedExaminations.add(verifiedExaminationVO);
                                break;                                
                            }
                        }

                        if (bFound == false) {
                            otherExaminations.add( examinationVO );
                        }
                    }

                    sessionContainerWO.setRiskProfileOtherExaminations( otherExaminations );
                    sessionContainerWO.setRiskProfileVerifiedExaminations( verifiedExaminations );
                }
            }

        } catch (SessionContainerFactoryException e) {
            e.printStackTrace();
            actionForward = mapping.findForward( "failure" );
        } 
        catch (ParseException e) {
            e.printStackTrace();
        }

        return actionForward;
    }
    
}
