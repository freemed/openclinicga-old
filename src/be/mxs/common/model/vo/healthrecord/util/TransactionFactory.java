package be.mxs.common.model.vo.healthrecord.util;

import be.mxs.common.model.vo.healthrecord.TransactionVO;
import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.vo.IdentifierFactory;
import be.mxs.common.util.db.MedwanQuery;
import be.dpms.medwan.common.model.vo.authentication.UserVO;
import be.dpms.medwan.common.model.vo.system.ActiveContextVO;

import java.util.*;
import java.net.URL;

import org.dom4j.io.SAXReader;
import org.dom4j.Document;
import org.dom4j.Element;

public abstract class TransactionFactory {

    private static Hashtable _hashtable = new Hashtable();
    public ActiveContextVO activeContext = new ActiveContextVO("","","");

    static String templateSource = "";

    public ActiveContextVO getActiveContext(){
        return activeContext;
    }

    public void setContext(String department,String context,String convocationId){
        this.getActiveContext().setDepartment(department);
        this.getActiveContext().setContext(context);
        this.getActiveContext().setConvocationId(convocationId);
    }

    public static TransactionFactory createTransactionFactory(String className) throws TransactionFactoryException {
        templateSource = MedwanQuery.getInstance().getConfigString("templateSource");

        try {
            TransactionFactory transactionFactory = (TransactionFactory)_hashtable.get(className);
            if (transactionFactory == null) {
                transactionFactory = (TransactionFactory) Class.forName(className).newInstance();
                _hashtable.put( className, transactionFactory );
            }

            return transactionFactory;
        }
        catch (Exception e) {
            e.printStackTrace();
            throw new TransactionFactoryException(e.getMessage());
        }
    }

    //--- CREATE TRANSACTION VO --------------------------------------------------------------------
    public abstract TransactionVO createTransactionVO(UserVO userVO);

    public TransactionVO createTransactionVO(String subClass){
        return null;
    }

    public TransactionVO createTransactionVO(TransactionVO transactionVO) {
        TransactionVO newTransactionVO = createTransactionVO( transactionVO.getUser() );
        populateTransaction( newTransactionVO, transactionVO );
        return newTransactionVO;
    }

    public TransactionVO updateTransactionVOfromXML(TransactionVO transactionVO,String xml) throws org.dom4j.DocumentException,java.net.MalformedURLException {
        if (xml == null || xml.equals("null") ){
            return transactionVO;
        }

        Hashtable hTransactionItems = new Hashtable();
        Iterator iTransactionItems = transactionVO.getItems().iterator();

        // We will iterate through all the items of the Target transaction
        // Every Item is put into the hTransactionItems Hashtable
        ItemVO itemVO;
        while (iTransactionItems.hasNext()) {
            itemVO = (ItemVO) iTransactionItems.next();
            hTransactionItems.put( itemVO.getType() , itemVO);
        }

        SAXReader reader = new SAXReader(false);
        String sDoc = templateSource+xml;
        Document document = reader.read(new URL(sDoc));

        if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_LAB_REQUEST")){
            Element root = document.getRootElement();
            Element element, modifier, item;
            ItemVO itemToUpdate;
            Iterator iItems;

            for ( Iterator iElements = root.elementIterator("Element"); iElements.hasNext(); ) {
                element = (Element) iElements.next();
                itemToUpdate = (ItemVO) hTransactionItems.get(element.valueOf("@Label"));
                if (itemToUpdate == null) {
                    // Debug.println("The Item found in the XML data is not part of the Transaction");
                }
                else {
                    // Find all Modifier Elements
                    for (Iterator iModifiers = element.elementIterator("Modifier"); iModifiers.hasNext();) {
                        modifier = (Element) iModifiers.next();
                        if (modifier.valueOf("@Type").equals("DefaultValue")){
                            for (iItems = modifier.elementIterator("Item"); iItems.hasNext();) {
                                item = (Element) iItems.next();
                                if (item.valueOf("@ID").equals("Value")){
                                    itemToUpdate.setValue(item.getText());
                                }
                            }
                        }
                    }
                }
            }
        }

        if (transactionVO.getTransactionType().equals("be.mxs.common.model.vo.healthrecord.IConstants.TRANSACTION_TYPE_MIR")){
            Element root = document.getRootElement();
            Element element, modifier, item;
            Iterator iModifiers, iItems;
            ItemVO itemToUpdate;

            for ( Iterator iElements = root.elementIterator("Element"); iElements.hasNext(); ) {
                element = (Element) iElements.next();
                itemToUpdate = (ItemVO) hTransactionItems.get(element.valueOf("@Label"));
                if (itemToUpdate == null) {
                    // Debug.println("The Item found in the XML data is not part of the Transaction");
                }
                else {
                    // Find all Modifier Elements
                    for (iModifiers = element.elementIterator("Modifier"); iModifiers.hasNext();) {
                        modifier = (Element) iModifiers.next();
                        if (modifier.valueOf("@Type").equals("DefaultValue")){
                            for (iItems = modifier.elementIterator("Item"); iItems.hasNext();) {
                                item = (Element) iItems.next();
                                if (item.valueOf("@ID").equals("Value")){
                                    itemToUpdate.setValue(item.getText());
                                }
                            }
                        }
                    }
                }
            }
        }

        return transactionVO;
    }

    public void cleanTransaction(TransactionVO transactionVO){
        Vector items = (Vector)transactionVO.getItems();
        transactionVO.setItems(new Vector());

        for (int i=0;i<items.size();i++){
            if ((((ItemVO)items.get(i)).getValue()!=null)&&(((ItemVO)items.get(i)).getValue().trim().length()>0)){
                transactionVO.getItems().add(items.get(i));
            }
        }
    }

    public void populateTransaction(TransactionVO targetTransactionVO, TransactionVO sourceTransactionVO) {
        if ( (sourceTransactionVO == null) || (targetTransactionVO == null) ) return;

        Hashtable items_target = new Hashtable();
        Iterator iterator_target = targetTransactionVO.getItems().iterator();

        // We will iterate through all the items of the Target transaction
        ItemVO itemVO;

        while (iterator_target.hasNext()) {
            itemVO = (ItemVO)iterator_target.next();
            items_target.put(itemVO.getType().toLowerCase(), itemVO);
        }

        Iterator iterator_source = sourceTransactionVO.getItems().iterator();

        targetTransactionVO.setCreationDate(sourceTransactionVO.getCreationDate());
        targetTransactionVO.setStatus(sourceTransactionVO.getStatus());
        targetTransactionVO.setTransactionId(sourceTransactionVO.getTransactionId());
        targetTransactionVO.setTransactionType(sourceTransactionVO.getTransactionType());
        targetTransactionVO.setUpdateTime(sourceTransactionVO.getUpdateTime());
        targetTransactionVO.setUser(sourceTransactionVO.getUser());
        targetTransactionVO.setServerId(sourceTransactionVO.getServerId());
        targetTransactionVO.setVersion(sourceTransactionVO.getVersion());
        targetTransactionVO.setVersionServerId(sourceTransactionVO.getVersionserverId());

        ItemVO itemVO_source, itemVO_target;

        while (iterator_source.hasNext()) {
            itemVO_source = (ItemVO)iterator_source.next();
            itemVO_target = (ItemVO)items_target.get( itemVO_source.getType().toLowerCase() );
            if ( itemVO_target == null  ) {
                targetTransactionVO.getItems().add( itemVO_source );
            }
            else {
                if (itemVO_source.getValue()==null){
                    itemVO_target.setItemId(new Integer( IdentifierFactory.getInstance().getTemporaryNewIdentifier() ));
                }
                else {
                    itemVO_target.setItemId( itemVO_source.getItemId() );
                }

                itemVO_target.setType( itemVO_source.getType() );
                itemVO_target.setDate( itemVO_source.getDate() );
                itemVO_target.setValue( itemVO_source.getValue() );
                itemVO_target.setItemContext( itemVO_source.getItemContext() );
            }
        }
    }

    public void populateTransactionPreserve(TransactionVO targetTransactionVO, TransactionVO sourceTransactionVO) {
        if ( (sourceTransactionVO == null) || (targetTransactionVO == null) ) return;

        Hashtable items_target = new Hashtable();
        Iterator iterator_target = targetTransactionVO.getItems().iterator();

        // We will iterate through all the items of the Target transaction
        ItemVO itemVO;
        while (iterator_target.hasNext()) {
            itemVO = (ItemVO) iterator_target.next();
            items_target.put( itemVO.getType().toLowerCase() , itemVO);
        }

        Iterator iterator_source = sourceTransactionVO.getItems().iterator();

        targetTransactionVO.setCreationDate(sourceTransactionVO.getCreationDate());
        targetTransactionVO.setStatus(sourceTransactionVO.getStatus());
        targetTransactionVO.setTransactionId(sourceTransactionVO.getTransactionId());
        targetTransactionVO.setTransactionType(sourceTransactionVO.getTransactionType());
        targetTransactionVO.setUpdateTime(sourceTransactionVO.getUpdateTime());
        targetTransactionVO.setUser(sourceTransactionVO.getUser());
        targetTransactionVO.setServerId(sourceTransactionVO.getServerId());
        targetTransactionVO.setVersion(sourceTransactionVO.getVersion());
        targetTransactionVO.setVersionServerId(sourceTransactionVO.getVersionserverId());

        ItemVO itemVO_source, itemVO_target;
        while (iterator_source.hasNext()) {
            itemVO_source = (ItemVO) iterator_source.next();
            itemVO_target = (ItemVO) items_target.get( itemVO_source.getType().toLowerCase() );

            if ( itemVO_target == null  ) {
                targetTransactionVO.getItems().add( itemVO_source );
            }
            else {
                if (itemVO_source.getValue()!=null){
                    itemVO_target.setItemId( itemVO_source.getItemId() );
                    itemVO_target.setType( itemVO_source.getType() );
                    itemVO_target.setDate( itemVO_source.getDate() );
                    itemVO_target.setValue( itemVO_source.getValue() );
                    itemVO_target.setItemContext( itemVO_source.getItemContext() );
                }
            }
        }
    }
}
