package be.dpms.medwan.webapp.wl.struts.actions.healthrecord;

import org.apache.struts.action.ActionMapping;
import org.apache.struts.action.ActionForward;
import org.apache.struts.action.ActionForm;

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
import be.mxs.common.model.vo.healthrecord.*;
import be.mxs.common.model.vo.healthrecord.util.TransactionFactory;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.model.util.collections.BeanPropertyAccessor;
import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.Debug;

public class ManageVaccinationAction extends org.apache.struts.action.Action {

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

        // By default our action should be successfull...
        ActionForward actionForward = mapping.findForward( "success" );
        VaccinationInfoVO vaccinationInfoVO = null;
        PersonalVaccinationsInfoVO personalVaccinationsInfoVO = null;
        SimpleDateFormat stdDateFormat = new SimpleDateFormat("dd/MM/yyyy");

        try {
            SessionContainerWO sessionContainerWO = (SessionContainerWO)SessionContainerFactory.getInstance().getSessionContainerWO( request , SessionContainerWO.class.getName() );
            String _param_vaccinationMessageKey = null;

            String _param_transactionId = request.getParameter("be.mxs.healthrecord.transaction_id");
            String _param_serverId = request.getParameter("be.mxs.healthrecord.server_id");

            if ((_param_transactionId != null) && (!_param_transactionId.equals("null"))){

                TransactionVO existingTransactionVO;
                try {
                    //Debug.println("looking for Transaction (vaccination) with transactionId="+_param_transactionId+" and serverId="+_param_serverId);
                    existingTransactionVO = MedwanQuery.getInstance().loadTransaction(Integer.parseInt(_param_serverId),Integer.parseInt(_param_transactionId));

                    Iterator iItems = existingTransactionVO.getItems().iterator();
                    ItemVO item;
                    while (iItems.hasNext()){
                        item = (ItemVO)iItems.next();
                        if (item.getType().equals(be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE)){
                            _param_vaccinationMessageKey = item.getValue();
                            break;
                        }
                    }
                    vaccinationInfoVO = new VaccinationInfoVO();

                    personalVaccinationsInfoVO = sessionContainerWO.getPersonalVaccinationsInfoVO();

                    if (personalVaccinationsInfoVO == null && sessionContainerWO.getPersonVO()!=null) {
                        personalVaccinationsInfoVO = MedwanQuery.getInstance().getPersonalVaccinationsInfo( sessionContainerWO.getPersonVO(),sessionContainerWO.getUserVO() );
                    }

                    Iterator iVaccinationsInfoVO = personalVaccinationsInfoVO.getVaccinationsInfoVO().iterator();
                    VaccinationInfoVO _vaccinationInfoVO;
                    String vaccinationType;

                    while (iVaccinationsInfoVO.hasNext()) {
                        _vaccinationInfoVO = (VaccinationInfoVO) iVaccinationsInfoVO.next();
                        vaccinationType = null;

                        try {
                            vaccinationType = (String) BeanPropertyAccessor.getInstance().getValue(  _vaccinationInfoVO,
                                                                                                     "transactionVO.items",
                                                                                                     "value",
                                                                                                     "type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE");
                        } catch (Exception e) { e.printStackTrace();}


                        if ((vaccinationType != null) && (vaccinationType.equals(_param_vaccinationMessageKey)) ) {
                            vaccinationInfoVO = _vaccinationInfoVO;
                            break;
                        }
                    }

                    vaccinationInfoVO.setTransactionVO(existingTransactionVO);
                } catch (Exception e) {
                    //
                }

            }
            else {
                _param_vaccinationMessageKey = request.getParameter("vaccination");

                personalVaccinationsInfoVO = sessionContainerWO.getPersonalVaccinationsInfoVO();

                if (personalVaccinationsInfoVO == null && sessionContainerWO.getPersonVO()!=null) {

                    personalVaccinationsInfoVO = MedwanQuery.getInstance().getPersonalVaccinationsInfo( sessionContainerWO.getPersonVO(),sessionContainerWO.getUserVO() );
                }

                Iterator iVaccinationsInfoVO = personalVaccinationsInfoVO.getVaccinationsInfoVO().iterator();
                VaccinationInfoVO _vaccinationInfoVO;
                String vaccinationType;

                while (iVaccinationsInfoVO.hasNext()) {

                    _vaccinationInfoVO = (VaccinationInfoVO) iVaccinationsInfoVO.next();

                    vaccinationType = null;

                    try {
                        vaccinationType = (String) BeanPropertyAccessor.getInstance().getValue(  _vaccinationInfoVO,
                                                                                                 "transactionVO.items",
                                                                                                 "value",
                                                                                                 "type=be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_VACCINATION_TYPE");
                    } catch (Exception e) { e.printStackTrace();}


                    if ((vaccinationType != null) && !vaccinationType.equals("be.mxs.healthrecord.vaccination.Other") && (vaccinationType.equals(_param_vaccinationMessageKey)) ) {

                        vaccinationInfoVO = _vaccinationInfoVO;
                        break;
                    }
                }
            }

            if (vaccinationInfoVO == null) {

                if (Debug.enabled) Debug.println("VaccinationInfo is null");
                Iterator iOtherVaccinations = personalVaccinationsInfoVO.getOtherVaccinations().iterator();

                ExaminationVO examinationVO;
                Collection itemsVO;
                ItemContextVO itemContextVO;
                TransactionVO transactionVO;

                while (iOtherVaccinations.hasNext()) {
                    examinationVO = (ExaminationVO) iOtherVaccinations.next();
                    if (Debug.enabled) Debug.println("Validating vaccination "+examinationVO.getMessageKey()+" against "+_param_vaccinationMessageKey);

                    if (examinationVO.getMessageKey().equalsIgnoreCase(_param_vaccinationMessageKey)) {
                        if (Debug.enabled) Debug.println("Found "+examinationVO.getMessageKey());

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

                        itemsVO.add( new ItemVO(     new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                    IConstants.ITEM_TYPE_VACCINATION_NAME,
                                                                    "",
                                                                    new Date(),
                                                                    itemContextVO));

                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                     IConstants.ITEM_TYPE_COMMENT,
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
                                                                          IConstants.ITEM_TYPE_VACCINATION_DATE,
                                                                          stdDateFormat.format(new Date()),
                                                                          new Date(),
                                                                          itemContextVO));

                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PREGNANT",
                                "",
                                new Date(),
                                itemContextVO));

                        itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                IConstants.ITEM_TYPE_RESULTRECEIVED,
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

                        boolean bNextDateExists=false;
                        Iterator i = itemsVO.iterator();
                        ItemVO item;
                        while (i.hasNext()){
                            item = (ItemVO)i.next();
                            if(item.getType().equalsIgnoreCase(IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE)){
                                item.setValue(stdDateFormat.format(new Date(new Date().getTime()+vaccinationInfoVO.getNextMinInterval()*24*60*60*1000)));
                                bNextDateExists=true;
                                break;
                            }
                        }
                        if (!bNextDateExists){
                            itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                        IConstants.ITEM_TYPE_VACCINATION_NEXT_DATE,
                                                                        stdDateFormat.format(new Date(new Date().getTime()+vaccinationInfoVO.getNextMinInterval()*24*60*60*1000)),
                                                                        new Date(),
                                                                        itemContextVO));
                        }
                        transactionVO.setItems(itemsVO);
                        vaccinationInfoVO.setTransactionVO(transactionVO);
                        break;
                    }
                }
            }
            else {
                if (Debug.enabled) Debug.println("VaccinationInfo is not null");
                Collection itemsVO = new Vector();

                Iterator iterator = vaccinationInfoVO.getTransactionVO().getItems().iterator();
                ItemVO previousItemVO, newItemVO;
                while (iterator.hasNext()) {

                    previousItemVO = (ItemVO) iterator.next();

                    newItemVO = new ItemVO(  previousItemVO.getItemId(),
                                                    previousItemVO.getType(),
                                                    previousItemVO.getValue(),
                                                    previousItemVO.getDate(),
                                                    null);
                    itemsVO.add(newItemVO);
                }

                TransactionVO transactionVO = new TransactionVO(    vaccinationInfoVO.getTransactionVO().getTransactionId(),
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

                items.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                        "be.mxs.common.model.vo.healthrecord.IConstants.ITEM_TYPE_PREGNANT",
                        "",
                        new Date(),
                        itemContextVO));

                items.add( new ItemVO(     new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                        IConstants.ITEM_TYPE_COMMENT,
                                                        "",
                                                        new Date(),
                                                        itemContextVO));

                itemsVO.add( new ItemVO(  new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                                IConstants.ITEM_TYPE_OTHER_REQUESTS_PRESTATION,
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
        catch (SessionContainerFactoryException e) {
            e.printStackTrace();
            actionForward = mapping.findForward( "failure" );
        }
        catch (InternalServiceException e) {
            e.printStackTrace();
            actionForward = mapping.findForward( "failure" );
        }

        return actionForward;
    }
}
