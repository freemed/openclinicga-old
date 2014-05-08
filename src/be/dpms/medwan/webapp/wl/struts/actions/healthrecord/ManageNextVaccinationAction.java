package be.dpms.medwan.webapp.wl.struts.actions.healthrecord;

import org.apache.struts.action.*;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import javax.servlet.ServletException;
import java.io.IOException;
import java.util.*;
import java.text.SimpleDateFormat;
import be.dpms.medwan.webapp.wo.common.system.SessionContainerWO;
import be.dpms.medwan.common.model.vo.occupationalmedicine.ExaminationVO;
import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.dpms.medwan.services.exceptions.InternalServiceException;
import be.mxs.webapp.wl.session.SessionContainerFactory;
import be.mxs.webapp.wl.exceptions.SessionContainerFactoryException;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactory;
import be.mxs.common.model.vo.healthrecord.*;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.util.collections.BeanPropertyAccessor;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

public class ManageNextVaccinationAction extends org.apache.struts.action.Action {

    private class DummyTransactionFactory extends TransactionFactory{
        public TransactionVO createTransactionVO(UserVO userVO) {
            return null;
        }
    }
    
    public ActionForward perform(ActionMapping mapping,
                                       ActionForm form,
                                       HttpServletRequest request,
                                       HttpServletResponse response)
        throws IOException, ServletException {

        ActionForward actionForward = mapping.findForward( "success" );

        try {
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );

            String _param_vaccinationMessageKey = request.getParameter("vaccination");
            String _param_vaccinationname = request.getParameter("vaccination_name");

            VaccinationInfoVO vaccinationInfoVO = null;

            PersonalVaccinationsInfoVO personalVaccinationsInfoVO = sessionContainerWO.getPersonalVaccinationsInfoVO();

            if (personalVaccinationsInfoVO == null && sessionContainerWO.getUserVO()!=null) {
                personalVaccinationsInfoVO = MedwanQuery.getInstance().getPersonalVaccinationsInfo( sessionContainerWO.getPersonVO(),sessionContainerWO.getUserVO() );
            }

            Iterator iVaccinationsInfoVO = personalVaccinationsInfoVO.getVaccinationsInfoVO().iterator();
            VaccinationInfoVO _vaccinationInfoVO;
            String vaccinationType, vaccinationName;
            while (iVaccinationsInfoVO.hasNext()) {

                _vaccinationInfoVO = (VaccinationInfoVO) iVaccinationsInfoVO.next();

                vaccinationType = null;
                vaccinationName = null;

                try {
                    vaccinationType = (String) BeanPropertyAccessor.getInstance().getValue(  _vaccinationInfoVO,
                                                                                             "transactionVO.items",
                                                                                             "value",
                                                                                             "type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE");
                    vaccinationName = (String) BeanPropertyAccessor.getInstance().getValue(  _vaccinationInfoVO,
                                                                                             "transactionVO.items",
                                                                                             "value",
                                                                                             "type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_NAME");
                } catch (Exception e) { e.printStackTrace();}

                if ((vaccinationType != null) && (vaccinationType.equals(_param_vaccinationMessageKey) && (_param_vaccinationname==null || _param_vaccinationname.equals(vaccinationName))) ) {

                    vaccinationInfoVO = _vaccinationInfoVO;
                    break;
                }
            }

            if (vaccinationInfoVO == null) {
                Iterator iOtherVaccinations = personalVaccinationsInfoVO.getOtherVaccinations().iterator();
                ExaminationVO examinationVO;
                Collection itemsVO;
                ItemContextVO itemContextVO;
                TransactionVO transactionVO;

                while (iOtherVaccinations.hasNext()) {
                    examinationVO = (ExaminationVO) iOtherVaccinations.next();

                    if (examinationVO.getMessageKey().equals(_param_vaccinationMessageKey)) {
                        itemsVO = new Vector();
                        itemContextVO = null;

                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                             IConstants.ITEM_TYPE_VACCINATION_TYPE,
                                                             _param_vaccinationMessageKey,
                                                             new Date(),
                                                             itemContextVO));

                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                 IConstants.ITEM_TYPE_VACCINATION_STATUS,
                                                                 IConstants.ITEM_TYPE_VACCINATION_STATUS_NONE,
                                                                 new Date(),
                                                                 itemContextVO));

                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                 IConstants.ITEM_TYPE_VACCINATION_DATE,
                                                                 ScreenHelper.stdDateFormat.format(new java.util.Date()),
                                                                 new Date(),
                                                                 itemContextVO));

                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                IConstants.ITEM_TYPE_VACCINATION_NAME,
                                                                "",
                                                                new Date(),
                                                                itemContextVO));

                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                 IConstants.ITEM_TYPE_COMMENT,
                                                                 "",
                                                                 new Date(),
                                                                 itemContextVO));

                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                 IConstants.ITEM_TYPE_RESULTRECEIVED,
                                                                 "",
                                                                 new Date(),
                                                                 itemContextVO));
                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PREGNANT",
                                "",
                                new Date(),
                                itemContextVO));


                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                        IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION_ACTION,
                                                                        "",
                                                                        new Date(),
                                                                        itemContextVO));

                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                        IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION_PRODUCT,
                                                                        "",
                                                                        new Date(),
                                                                        itemContextVO));

                        transactionVO = new TransactionVO(    new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                        IConstants.TRANSACTION_TYPE_VACCINATION,
                                                                        new Date(),
                                                                        new Date(),
                                                                        IConstants.TRANSACTION_STATUS_CLOSED,
                                                                        sessionContainerWO.getUserVO(),
                                                                        itemsVO);

                        vaccinationInfoVO = MedwanQuery.getInstance().getVaccinationInfoVO(transactionVO, examinationVO);

                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                        IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE,
                                                                        ScreenHelper.stdDateFormat.format(vaccinationInfoVO.getNextDate()),
                                                                        new Date(),
                                                                        itemContextVO));

                        vaccinationInfoVO = MedwanQuery.getInstance().getVaccinationInfoVO(transactionVO, examinationVO);
                    }

                }
            } else {
                //Debug.println("We recupereren een bestaande VaccinationInfoVO");
                //Debug.println("NextMinInterval="+vaccinationInfoVO.getNextMinInterval());

                Collection itemsVO = new Vector();
                ItemVO previousItemVO, newItemVO;
                Iterator iterator = vaccinationInfoVO.getTransactionVO().getItems().iterator();
                TransactionVO transactionVO;
                while (iterator.hasNext()) {
                    previousItemVO = (ItemVO) iterator.next();

                    if ( previousItemVO.getType().equals( IConstants.ITEM_TYPE_VACCINATION_DATE ) ) {
                        previousItemVO.setValue(ScreenHelper.stdDateFormat.format(new Date()));
                    }
                    else if ( previousItemVO.getType().equals( IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE ) ) {
                        previousItemVO.setValue(ScreenHelper.stdDateFormat.format(new Date(new Date().getTime()+vaccinationInfoVO.getNextMinInterval()*24*60*60*1000)));
                    }

                    newItemVO = new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                    previousItemVO.getType(),
                                                    previousItemVO.getValue(),
                                                    previousItemVO.getDate(),
                                                    null);
                    //Debug.println("Adding Item "+newItemVO.getType()+" with value "+newItemVO.getValue());
                    itemsVO.add(newItemVO);
                }

                transactionVO = new TransactionVO(    new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                    IConstants.TRANSACTION_TYPE_VACCINATION,
                                                                    new Date(),
                                                                    new Date(),
                                                                    IConstants.TRANSACTION_STATUS_CLOSED,
                                                                    sessionContainerWO.getUserVO(),
                                                                    itemsVO);

                ItemContextVO itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");

                //Create a baseTransaction
                Collection items = new Vector();
                items.add( new ItemVO(     new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                        IConstants.ITEM_TYPE_VACCINATION_TYPE,
                                                        "",
                                                        new Date(),
                                                        itemContextVO));

                items.add( new ItemVO(     new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                        IConstants.ITEM_TYPE_VACCINATION_STATUS,
                                                        IConstants.ITEM_TYPE_VACCINATION_STATUS_NONE,
                                                        new Date(),
                                                        itemContextVO));

                items.add( new ItemVO(     new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                        IConstants.ITEM_TYPE_VACCINATION_DATE,
                                                        "",
                                                        new Date(),
                                                        itemContextVO));
                items.add( new ItemVO(     new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                        IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE,
                                                        "",
                                                        new Date(),
                                                        itemContextVO));

                items.add( new ItemVO(     new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                        IConstants.ITEM_TYPE_VACCINATION_NAME,
                                                        "",
                                                        new Date(),
                                                        itemContextVO));

                items.add( new ItemVO(     new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                        IConstants.ITEM_TYPE_COMMENT,
                                                        "",
                                                        new Date(),
                                                        itemContextVO));

                items.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                        IConstants.ITEM_TYPE_RESULTRECEIVED,
                                                        "",
                                                        new Date(),
                                                        itemContextVO));
                items.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                        "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PREGNANT",
                        "",
                        new Date(),
                        itemContextVO));


                items.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                        IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION,
                                                        "",
                                                        new Date(),
                                                        itemContextVO));

                TransactionVO baseTransactionVO = new TransactionVO(    vaccinationInfoVO.getTransactionVO().getTransactionId(),
                                                                    IConstants.TRANSACTION_TYPE_VACCINATION,
                                                                    new Date(),
                                                                    new Date(),
                                                                    IConstants.TRANSACTION_STATUS_CLOSED,
                                                                    sessionContainerWO.getUserVO(),
                                                                    items);

                DummyTransactionFactory df = new DummyTransactionFactory();
                df.populateTransaction(baseTransactionVO,transactionVO);
                vaccinationInfoVO.setTransactionVO(baseTransactionVO);
            }

            if (vaccinationInfoVO == null) {
                actionForward = mapping.findForward( "failure" );
            }
            else {
                sessionContainerWO.setPersonalVaccinationsInfoVO(null);
                sessionContainerWO.setCurrentVaccinationInfoVO(vaccinationInfoVO);
                sessionContainerWO.setCurrentTransactionVO(vaccinationInfoVO.getTransactionVO());
            }
        } 
        catch (Exception e) {
            actionForward = mapping.findForward( "failure" );
        }

        return actionForward;
    }
}
