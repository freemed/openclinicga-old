package be.mxs.common.model.vo.healthrecord.util;
import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.ItemContextVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.healthrecord.IConstants;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.util.db.MedwanQuery;
import be.dpms.medwan.common.model.vo.authentication.UserVO;
import java.util.Date;
import java.util.Vector;
import java.util.Collection;
import java.util.Iterator;

public class TransactionFactoryClinicalExamination extends TransactionFactory {

    private String subClass = null;

    public TransactionVO createTransactionVO(String subClass){
        this.subClass = subClass;
        return createTransactionVO((UserVO)null);
    }

    public TransactionVO createTransactionVO(UserVO userVO) {

        String subClass = this.subClass;
        this.subClass = null;

        ItemContextVO itemContextVO = new ItemContextVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier()), "", "");

        Collection itemsVO = new Vector();

        itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                IConstants.ITEM_TYPE_EXTENDED_CLINICAL_EXAMINATION,"medwan.common.false",new Date(),itemContextVO));
        itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                IConstants.ITEM_TYPE_TRANSACTION_RESULT,"",new Date(),itemContextVO));
        // -- GENERAL  -----------------------------------------------------------------------------------------------------
        if(subClass == null){
            // -- GENERAL.RAS ----------------------------------------------------------------------------------------
            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_GENERAL_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("GENERAL")>=0)){
             // -- GENERAL.ANAMNESE ---------------------------------------------------------------------------------------------

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_CARDIAL_COMPLAINTS,"",new Date(),itemContextVO));
            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_ORL_COMPLAINTS,"",new Date(),itemContextVO));
            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_ABDOMINAL_COMPLAINTS,"",new Date(),itemContextVO));
            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_ORTHO_COMPLAINTS,"",new Date(),itemContextVO));
            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_NEURO_COMPLAINTS,"",new Date(),itemContextVO));

            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_CE_"));
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_"));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_LIFE_STYLE__CONTEXT_GENERAL_ANAMNESE,"",new Date(),itemContextVO));

            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_MEDICIATIONS__CONTEXT_GENERAL_ANAMNESE"));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_DRUGS_USAGE__CONTEXT_GENERAL_ANAMNESE,"",new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_COFFEE_USAGE__CONTEXT_GENERAL_ANAMNESE,"",new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_ALCOHOL_USAGE__CONTEXT_GENERAL_ANAMNESE,"",new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_TOBACCO_USAGE__CONTEXT_GENERAL_ANAMNESE,"",new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_SOCIAL_AND_FAMILIAL_STATUS__CONTEXT_GENERAL_ANAMNESE,"",new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_SPORTS__CONTEXT_GENERAL_ANAMNESE,"",new Date(),itemContextVO));

            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_GENERAL_ANAMNESE_REMARK__CONTEXT_GENERAL_ANAMNESE"));
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_GENERAL_ANAMNESE_COMPLAINTS__CONTEXT_GENERAL_ANAMNESE"));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                                IConstants.ITEM_TYPE_GENERAL_ANAMNESE_WORKCONDITIONS__CONTEXT_GENERAL_ANAMNESE,"",new Date(),itemContextVO));

            // -- GENERAL.CLINICAL_EXAMNIATION ---------------------------------------------------------------------

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_CONSCIENCE__CONTEXT_GENERAL_CLINICAL_EXAMNIATION,"",new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_TATOUAGE__CONTEXT_GENERAL_CLINICAL_EXAMNIATION,"",new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_PIERCING__CONTEXT_GENERAL_CLINICAL_EXAMNIATION,"",new Date(),itemContextVO));

            // -- GENERAL.DIAGNOSE ---------------------------------------------------------------------------------------------

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_ACCEPTABLE_TATOO__CONTEXT_GENERAL_DIAGNOSE,"",new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_OBESITY__CONTEXT_GENERAL_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_COOPER_TEST_INSUFFICIENT_RESULT__CONTEXT_GENERAL_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_SHUTTLE_RUN_INSUFFICIENT_RESULT__CONTEXT_GENERAL_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_BALANCE_TEST_INSUFFICIENT_RESULT__CONTEXT_GENERAL_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_POTENTIALITY_TEST_UNDONE__CONTEXT_GENERAL_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_USUAL_CANABIS_CONSOMMATION__CONTEXT_GENERAL_DIAGNOSE,null,new Date(),itemContextVO));
        }

        if(subClass == null){
            // -- DERMATOLOGIE.RAS ----------------------------------------------------------------------------------------
            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_DERMATOLOGIE_RAS,"medwan.common.true",new Date(),itemContextVO));
        }
        if((subClass == null)||(subClass.indexOf("DERMATOLOGY")>=0)){
            // -- DERMATOLOGIE.ANAMNESE ----------------------------------------------------------------------------------------
            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_ICTERE__CONTEXT_DERMATOLOGIE_ANAMNESE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_PRURIT__CONTEXT_DERMATOLOGIE_ANAMNESE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_OTHER__CONTEXT_DERMATOLOGIE_ANAMNESE,null,new Date(),itemContextVO));

            // -- DERMATOLOGIE.CLINICAL_EXAMNIATION ----------------------------------------------------------------------------
            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_ROUGEUR__CONTEXT_DERMATOLOGIE_ANAMNESE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_PALEUR__CONTEXT_DERMATOLOGIE_CLINICAL_EXAMNIATION,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_ICTERE__CONTEXT_DERMATOLOGIE_CLINICAL_EXAMNIATION,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_CICATRICE__CONTEXT_DERMATOLOGIE_CLINICAL_EXAMNIATION,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_NAEVUS_SUSPECTE__CONTEXT_DERMATOLOGIE_CLINICAL_EXAMNIATION,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_PAPULES__CONTEXT_DERMATOLOGIE_CLINICAL_EXAMNIATION,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_MACULES__CONTEXT_DERMATOLOGIE_CLINICAL_EXAMNIATION,null,new Date(),itemContextVO));

            // -- DERMATOLOGIE.DIAGNOSE ----------------------------------------------------------------------------------------

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_LIPOME__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_URTICAIRE__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_DERMATITE__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_DERMATITE_DE_CONTACT__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_GALE__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_PUCES__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_VERRURES__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_CANDIDA__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_ACNEE__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_PSORIASIS__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_PITYRIASIS_VERSICOLOR__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_ZONA__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_AFFECTION_ONGLES__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_TUMEUR_BENIN__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_TUMEUR_MALIN__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_MYCOSES__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_OTHER__CONTEXT_DERMATOLOGIE_DIAGNOSE,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_DERMATOLOGY_DIAGNOSIS_TUMOR_MALIGNANT,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_DERMATOLOGY_DIAGNOSIS_TUMOR_BENIGN,null,new Date(),itemContextVO));

            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_OTHER__CONTEXT_DERMATOLOGIE_SEBUMCYSTE,null,new Date(),itemContextVO));
        }

        if(subClass == null){
            // -- ORL.RAS ----------------------------------------------------------------------------------------
            itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                    IConstants.ITEM_TYPE_ORL_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("ORL")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_ORL_"));
            removeItem(itemsVO,IConstants.ITEM_TYPE_ORL_COMPLAINTS);
        }

        if(subClass == null){
            // -- VISUS.RAS ----------------------------------------------------------------------------------------
             itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                     IConstants.ITEM_TYPE_VISUS_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("VISUS")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_VISUS_"));
        }

        if(subClass == null){
            // -- CARDIAL.RAS ----------------------------------------------------------------------------------------
             itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                     IConstants.ITEM_TYPE_CARDIAL_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("CARDIAL")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_CARDIAL_"));
            removeItem(itemsVO,IConstants.ITEM_TYPE_CARDIAL_COMPLAINTS);
            removeItem(itemsVO,IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_FREQUENCY);
            removeItem(itemsVO,IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_HEARTH_RYTMH);
            removeItem(itemsVO,IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_RIGHT);
            removeItem(itemsVO,IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_SYSTOLIC_PRESSURE_LEFT);
            removeItem(itemsVO,IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_RIGHT);
            removeItem(itemsVO,IConstants.ITEM_TYPE_CARDIAL_CLINICAL_EXAMINATION_DIASTOLIC_PRESSURE_LEFT);
        }

        if(subClass == null){
            // -- VASCULAR.RAS ----------------------------------------------------------------------------------------
             itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                     IConstants.ITEM_TYPE_VASCULAR_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("VASCULAR")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_VASCULAR_"));
        }

        if(subClass == null){
            // -- RESPITORY.RAS ----------------------------------------------------------------------------------------
             itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                     IConstants.ITEM_TYPE_RESPIRATORY_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("RESPIRATORY")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_RESPIRATORY_"));
        }

        if(subClass == null){
            // -- GASTRO.RAS ----------------------------------------------------------------------------------------
             itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                     IConstants.ITEM_TYPE_GASTRO_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("GASTRO")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_GASTRO_"));
        }

        if(subClass == null){
            // -- HEMATO.RAS ----------------------------------------------------------------------------------------
             itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                     IConstants.ITEM_TYPE_HEMATO_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("HEMATO")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_HEMATO_"));
        }

        if(subClass == null){
            // -- ENDOCRINO.RAS ----------------------------------------------------------------------------------------
             itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                     IConstants.ITEM_TYPE_ENDOCRINO_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("ENDOCRINO")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_ENDOCRINO_"));
        }

        if(subClass == null){
            // -- URO.RAS ----------------------------------------------------------------------------------------
             itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                     IConstants.ITEM_TYPE_URO_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("URO")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_URO_"));
        }

        if(subClass == null){
            // -- GENITAL.RAS ----------------------------------------------------------------------------------------
             itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                     IConstants.ITEM_TYPE_GENITAL_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("GENITAL")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_GENITAL_"));
        }

        if(subClass == null){
            // -- NEURO.RAS ----------------------------------------------------------------------------------------
             itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                     IConstants.ITEM_TYPE_NEURO_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("NEURO")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_NEURO_"));
            removeItem(itemsVO,IConstants.ITEM_TYPE_NEURO_COMPLAINTS);
        }

        if(subClass == null){
            // -- PSYCHO.RAS ----------------------------------------------------------------------------------------
             itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                     IConstants.ITEM_TYPE_PSYCHO_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("PSYCHO")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_PSYCHO_"));
        }

        if(subClass == null){
            // -- ORTHO.RAS ----------------------------------------------------------------------------------------
             itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                     IConstants.ITEM_TYPE_ORTHO_RAS,"medwan.common.true",new Date(),itemContextVO));
        }

        if((subClass == null)||(subClass.indexOf("ALLERGY")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_ALLERGY_"));
        }

        if((subClass == null)||(subClass.indexOf("ORTHO")>=0)){
            itemsVO.addAll(MedwanQuery.getInstance().loadTransactionItems(IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,itemContextVO,IConstants.IConstants_PREFIX+"ITEM_TYPE_ORTHO_"));
            removeItem(itemsVO,IConstants.ITEM_TYPE_ORTHO_COMPLAINTS);
        }
          // -- TRANSACTION --------------------------------------------------------------------------------------

        itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                IConstants.ITEM_TYPE_RECRUITMENT_CONVOCATION_ID,this.getActiveContext().getConvocationId(),new Date(),itemContextVO));

        itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                IConstants.ITEM_TYPE_CONTEXT_DEPARTMENT,this.getActiveContext().getDepartment(),new Date(),itemContextVO));

        itemsVO.add( new ItemVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                IConstants.ITEM_TYPE_CONTEXT_CONTEXT,this.getActiveContext().getContext(),new Date(),itemContextVO));

        return new TransactionVO(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ),
                                IConstants.TRANSACTION_TYPE_GENERAL_CLINICAL_EXAMINATION,
                                new Date(),
                                new Date(),
                                IConstants.TRANSACTION_STATUS_CLOSED,
                                userVO,
                                itemsVO);
    }

    private void removeItem(Collection cItems, String sItemType){
        ItemVO itemVO;
        Iterator iterator = cItems.iterator();
         while (iterator.hasNext()) {
            itemVO = (ItemVO) iterator.next();
            if (itemVO.getType().equals(sItemType)){
                cItems.remove(itemVO);
                break;
            }
        }
    }
}

