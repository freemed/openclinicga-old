package be.mxs.common.model.util;

import be.mxs.common.model.vo.IdentifierFactory;
import java.util.Collection;

public class BeanFinder {

    public static BeanFinder getInstance() {
        return new BeanFinder();
    }

    public Object findBean(Object model, String propertyName, String propertyValue) throws BeanFinderException {

        Object bean = null;
        String objectPath;
        String _propertyName = propertyName;
        String objectFieldPath;
        Object objectValue;

        while (_propertyName.indexOf( IdentifierFactory.getInstance().getIdentifierStartTag() ) > 0) {

            objectPath = _propertyName.substring(0, _propertyName.indexOf( IdentifierFactory.getInstance().getIdentifierStartTag() ) - 1 );
            objectFieldPath = _propertyName.substring( _propertyName.indexOf( IdentifierFactory.getInstance().getIdentifierEndTag() ) + 2 );

            try {
                objectValue = BeanAccessor.getInstance().getPropertyValue(model, objectPath);
            }
            catch (BeanAccessor.BeanAccessorException e) {
                throw new BeanFinderException("Inner exception : " + e.getClass().getName() + " - " + e.getMessage());
            }

            if (objectValue instanceof Collection) {

            } else {

            }

            _propertyName = objectFieldPath;
        }
        return bean;
    }

    public class BeanFinderException extends Exception {

        public BeanFinderException(String s) {
            super(s);
        }
    }
}
