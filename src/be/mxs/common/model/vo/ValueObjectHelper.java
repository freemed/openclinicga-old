package be.mxs.common.model.vo;

import be.mxs.common.model.vo.healthrecord.ItemVO;
import be.mxs.common.model.util.BeanAccessor;
import be.mxs.common.model.util.BeanModifier;
import be.mxs.common.model.util.OptionBean;

import java.util.*;
import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;

public class ValueObjectHelper {

    // Static instance of the factory
    private static ValueObjectHelper thisFactory = null;


    //--- PRIVATE CONTRUCTOR ----------------------------------------------------------------------
    private ValueObjectHelper(){

    }

    //--- GET INSTANCE ----------------------------------------------------------------------------
    public static ValueObjectHelper getInstance(){
        if (thisFactory == null) {
            thisFactory = new ValueObjectHelper();
        }

        return thisFactory;
    }

    //--- UPDATE MODEL ----------------------------------------------------------------------------
    public Collection updateModel(Object model, Hashtable parametersHashtable) throws ValueObjectHelperException {
        Collection updatedValueObjects = new Vector();

        Enumeration eParameters = parametersHashtable.keys();
        String optionKey, optionValue;
        Hashtable modelObjectsHashtable = new Hashtable();
        Hashtable newObjectPropertyValuesHashtable = new Hashtable();
        String parameterName, property, objectPath, objectFieldPath, objectIdentifierTag, objectKey, parameterValue;
        ValueObjectContainer valueObjectContainer;
        Object objectValue, o, bean;
        Hashtable propertyHashtable;
        Iterator i;

        while (eParameters.hasMoreElements()) {
            try {
                parameterName = (String) eParameters.nextElement();
                property = parameterName;

                objectPath = property.substring(0, property.indexOf( IdentifierFactory.getInstance().getIdentifierStartTag() ) - 1 );
                objectFieldPath = property.substring( property.indexOf( IdentifierFactory.getInstance().getIdentifierEndTag() ) + 2 );
                objectIdentifierTag = property.substring( property.indexOf( IdentifierFactory.getInstance().getIdentifierStartTag()) ,
                                                          property.indexOf( IdentifierFactory.getInstance().getIdentifierEndTag()) + 1);

                objectKey = objectPath + objectIdentifierTag;
                valueObjectContainer = (ValueObjectContainer) modelObjectsHashtable.get(objectKey);
                objectValue = null;

                if (valueObjectContainer != null) objectValue = valueObjectContainer.getValueObject();

                if (objectValue == null) {
                    objectValue = BeanAccessor.getInstance().getPropertyValue(model, objectPath);
                    if (objectValue == null) throw new ValueObjectHelperException("No such object in model : " + objectPath);

                    if (objectValue instanceof Collection) {
                        i = ((Collection) objectValue).iterator();

                        while (i.hasNext()) {
                            o = i.next();
                            bean = o;

                            if (o instanceof OptionBean) {
                                bean = ( (OptionBean) o).getBean();
                            }

                            if ( bean instanceof IIdentifiable ) {
                                if (IdentifierFactory.getInstance().getIdentifier((IIdentifiable) bean,null, null).equals(objectIdentifierTag)) {
                                    objectValue = o;
                                    break;
                                }
                            }
                        }
                    }

                    if (objectValue != null) {
                        modelObjectsHashtable.put( objectKey, new ValueObjectContainer(objectPath, objectValue) );
                    }
                }

                if ( ( objectValue != null) && (objectValue instanceof OptionBean) ) {
                    optionKey = objectPath + "." + objectIdentifierTag + ".checked";
                    optionValue = (String) parametersHashtable.get(optionKey);

                    if (optionValue == null) continue;

                    if ( (optionValue != null) && (!optionValue.equals("on")) ) {
                        continue;
                    }
                }

                propertyHashtable = (Hashtable) newObjectPropertyValuesHashtable.get(objectKey);
                if (propertyHashtable == null) propertyHashtable = new Hashtable();

                parameterValue = (String)parametersHashtable.get(parameterName);
                propertyHashtable.put(objectFieldPath, parameterValue);

                newObjectPropertyValuesHashtable.put(objectKey, propertyHashtable);
            }
            catch (java.lang.ClassCastException e) {
                throw new ValueObjectHelperException(e.getClass() + " - " + e.getMessage());
            }
            catch (BeanAccessor.BeanAccessorException e) {
                throw new ValueObjectHelperException(e.getClass() + " - " + e.getMessage());
            }
        } //while

        Hashtable objectCollections = new Hashtable();
        Object modelObject, fieldValue;
        Enumeration enumeration = newObjectPropertyValuesHashtable.keys();
        ItemVO itemVO;
        Collection objectsCollection, updatedCollection, currentCollection, newCollection;
        Enumeration updatedCollectionsPath, properties;
        String collectionPath;
        Hashtable newPropertyValuesHashtable;
        Iterator iterator;

        while (enumeration.hasMoreElements()) {
            objectKey = (String) enumeration.nextElement();
            valueObjectContainer = (ValueObjectContainer) modelObjectsHashtable.get(objectKey);
            modelObject = valueObjectContainer.getValueObject();

            try {
                if (modelObject instanceof ItemVO) {
                    itemVO = (ItemVO) modelObject;
                }

                if (BeanAccessor.getInstance().getPropertyValue(model, valueObjectContainer.getValueObjectPath()) instanceof Collection) {
                    objectsCollection = (Collection) objectCollections.get(valueObjectContainer.getValueObjectPath());

                    if (objectsCollection == null) {
                        objectsCollection = new Vector();
                        objectCollections.put(valueObjectContainer.getValueObjectPath(), objectsCollection);
                    }

                    objectsCollection.add(modelObject);
                }
            }
            catch (BeanAccessor.BeanAccessorException e) {
                throw new ValueObjectHelperException(e.getClass() + " - " + e.getMessage());
            }

            newPropertyValuesHashtable = (Hashtable) newObjectPropertyValuesHashtable.get(objectKey);

            if ( (! (modelObject instanceof OptionBean) ) || ( (modelObject instanceof OptionBean) && ( (newPropertyValuesHashtable.get("checked") != null) && (newPropertyValuesHashtable.get("checked")).equals("on") ) ) ) {
                properties = newPropertyValuesHashtable.keys();

                while (properties.hasMoreElements()) {
                    try {
                        objectFieldPath = (String) properties.nextElement();
                        parameterValue = (String) newPropertyValuesHashtable.get(objectFieldPath);
                        fieldValue = BeanAccessor.getInstance().getPropertyValue(modelObject, objectFieldPath);

                        if ( (modelObject instanceof OptionBean) && (objectFieldPath.equals("checked")) ) {

                            if (parameterValue.equals("on") && ( (fieldValue != null) || (! parameterValue.equals(fieldValue.toString())) ) ) {

                                BeanModifier.getInstance().setPropertyValue(modelObject, "selected", "true");
                            }
                        }
                        else {
                            if ((fieldValue == null) || (! parameterValue.equals(fieldValue.toString())) ) {
                                BeanModifier.getInstance().setPropertyValue(modelObject, objectFieldPath, parameterValue);
                            }
                        }
                    }
                    catch (BeanAccessor.BeanAccessorException e) {
                        throw new ValueObjectHelperException(e.getClass() + " - " + e.getMessage());
                    }
                    catch (BeanModifier.BeanModifierException e) {
                        throw new ValueObjectHelperException(e.getClass() + " - " + e.getMessage());
                    }
                }

                updatedValueObjects.add(valueObjectContainer);
            }

            updatedCollectionsPath = objectCollections.keys();

            while (updatedCollectionsPath.hasMoreElements()) {
                try {
                    collectionPath = (String) updatedCollectionsPath.nextElement();

                    updatedCollection = (Collection) objectCollections.get(collectionPath);
                    currentCollection = (Collection) BeanAccessor.getInstance().getPropertyValue(model, collectionPath);

                    iterator = updatedCollection.iterator();
                    while (iterator.hasNext()) {
                        o = iterator.next();
                        if (o instanceof ItemVO) {
                            itemVO = (ItemVO) o;
                        }
                    }

                    iterator = currentCollection.iterator();
                    while (iterator.hasNext()) {
                        o = iterator.next();

                        if (o instanceof ItemVO) {
                            itemVO = (ItemVO) o;
                        }
                    }

                    currentCollection.clear();
                    currentCollection.addAll(updatedCollection);

                    newCollection = (Collection) BeanAccessor.getInstance().getPropertyValue(model, collectionPath);
                    iterator = newCollection.iterator();
                    while (iterator.hasNext()) {
                        o = iterator.next();

                        if (o instanceof ItemVO) {
                            itemVO = (ItemVO) o;
                        }
                    }

                } catch (BeanAccessor.BeanAccessorException e) {
                    throw new ValueObjectHelperException(e.getClass() + " - " + e.getMessage());
                }
            }
        } //while

        return updatedValueObjects;
    }

    //--- GET VALUE OBJECTS IN PATH ---------------------------------------------------------------
    public Collection getValueObjectsInPath(Collection valueOjectContainers, String path) {
        Collection valueObjects = new Vector();
        ValueObjectContainer valueObjectContainer;
        Iterator iterator = valueOjectContainers.iterator();

        while (iterator.hasNext()) {
            valueObjectContainer = (ValueObjectContainer) iterator.next();

            if (valueObjectContainer.getValueObjectPath().equals(path)) {
                valueObjects.add(valueObjectContainer.getValueObject());
            }
        }

        return valueObjects;
    }

    //--- POPULATE VALUES -------------------------------------------------------------------------
    public void populateValues(IValueObject valueObject, Object businessObject) throws ValueObjectHelperException {
        try {
            if(valueObject == null) return;
            if(businessObject == null) return;

            // Populate the setters and getters hashtables for the valueObject
            Hashtable voGettersHashtable    = new Hashtable();
            Hashtable voSettersHashtable    = new Hashtable();

            initVOMethodsHashtables(valueObject, voGettersHashtable, voSettersHashtable);

            // Populate the setters and getters hashtables for the bussinessObject
            Hashtable boGettersHashtable    = new Hashtable();
            Hashtable boSettersHashtable    = new Hashtable();

            initBOMethodsHashtables(businessObject, boGettersHashtable, boSettersHashtable);

            // Populate the the valueObject
            String voSetterSuffix, boGetterSuffix;
            Method voSetterMethod, boGetterMethod, voGetterMethod;
            Object boValue,innerBusinessObject;
            Class innerWebOjectClass;
            IValueObject  innerWebObject;

            for (Enumeration e = voSettersHashtable.keys() ; e.hasMoreElements() ; ) {

                voSetterSuffix = (String)e.nextElement();
                voSetterMethod = (Method)voSettersHashtable.get(voSetterSuffix);
                boGetterSuffix = voSetterSuffix;
                boGetterMethod = (Method)boGettersHashtable.get(boGetterSuffix);

                if ( IValueObject.class.isAssignableFrom(voSetterMethod.getParameterTypes()[0]) ) { // the DestinationObject getter method returns another ValueObject
                    boValue = boGetterMethod.invoke(businessObject, null);

                    innerBusinessObject = boValue;
                    voGetterMethod = (Method)voGettersHashtable.get(voSetterSuffix);
                    innerWebOjectClass = voGetterMethod.getReturnType();
                    innerWebObject = (IValueObject)Class.forName(innerWebOjectClass.getName()).newInstance();
                    Object[] voValues = {innerWebObject};

                    populateValues(innerWebObject, innerBusinessObject);

                    voSetterMethod.invoke(valueObject, voValues);

                } else {

                    boValue          = boGetterMethod.invoke(businessObject, null);
                    Object[] boValues       = {boValue};

                    voSetterMethod.invoke(valueObject, boValues);
                }
            }
        } catch (IllegalArgumentException e) {

            throw new ValueObjectHelperException("ValueObjectHelper("+valueObject.getClass().getName() +", "+businessObject.getClass().getName() +") throws an inner exception : \n"+e.getMessage());

        } catch (IllegalAccessException e) {

            throw new ValueObjectHelperException(e.getMessage());

        } catch (InvocationTargetException e) {

            throw new ValueObjectHelperException(e.getMessage());

        } catch (ClassNotFoundException e) {

            throw new ValueObjectHelperException(e.getMessage());

        } catch (InstantiationException e) {
            e.printStackTrace();
        }
    }

    //--- INIT VO METHODS HASHTABLES --------------------------------------------------------------
    private void initVOMethodsHashtables(IValueObject valueObject, Hashtable voGettersHashtable, Hashtable voSettersHashtable){

        if (voGettersHashtable == null) voGettersHashtable = new Hashtable();
        if (voSettersHashtable == null) voSettersHashtable = new Hashtable();

        Method[] voMethods = valueObject.getClass().getMethods();
        Method voMethod;
        String voGetterSuffix, voSetterSuffix;

        for (int i=0; i < voMethods.length ; i++){

            voMethod = voMethods[i];

            if (voMethod.getName().startsWith("get")) {

                voGetterSuffix = voMethod.getName().substring(voMethod.getName().indexOf("get")+3, voMethod.getName().length());

                voGettersHashtable.put(voGetterSuffix, voMethod);
            }
            else if ( ( voMethod.getName().startsWith("set") ) && ( voMethod.getParameterTypes().length == 1 ) ) {

                voSetterSuffix = voMethod.getName().substring(voMethod.getName().indexOf("set")+3, voMethod.getName().length());

                voSettersHashtable.put(voSetterSuffix, voMethod);

            }
        }
    }

    private void initBOMethodsHashtables(Object businessObject, Hashtable boGettersHashtable, Hashtable boSettersHashtable){

        if (boGettersHashtable == null) boGettersHashtable = new Hashtable();
        if (boSettersHashtable == null) boSettersHashtable = new Hashtable();

        Method[] boMethods = businessObject.getClass().getMethods();
        Method boMethod;
        String boGetterSuffix, boSetterSuffix;

        for (int i=0; i < boMethods.length ; i++){

            boMethod = boMethods[i];

            if (boMethod.getName().startsWith("get")) {

                boGetterSuffix = boMethod.getName().substring(boMethod.getName().indexOf("get")+3, boMethod.getName().length());

                boGettersHashtable.put(boGetterSuffix, boMethod);
            }
            else if ( ( boMethod.getName().startsWith("set") ) && ( boMethod.getParameterTypes().length == 1 ) ) {

                boSetterSuffix = boMethod.getName().substring(boMethod.getName().indexOf("set")+3, boMethod.getName().length());

                boSettersHashtable.put(boSetterSuffix, boMethod);
            }
        }
    }
}