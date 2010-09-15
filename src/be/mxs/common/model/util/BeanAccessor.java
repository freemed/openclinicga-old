package be.mxs.common.model.util;

import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 04-juil.-2003
 * Time: 16:30:28
 * To change this template use Options | File Templates.
 */
public class BeanAccessor {

    public static BeanAccessor getInstance() {
        return new BeanAccessor();
    }

    public Object getPropertyValue(Object o, String property) throws BeanAccessorException {

        try {

            String innerPropertyName, innerGetterName;
            Method _method;

            while (property.indexOf(".") > 0) {

                innerPropertyName = property.substring(0, property.indexOf("."));
                innerGetterName = "get" + innerPropertyName.substring(0,1).toUpperCase() + innerPropertyName.substring(1);

                _method = o.getClass().getMethod(innerGetterName, null);
                o = _method.invoke(o, null);

                property = property.substring(property.indexOf(".") +1);
            }

            String getterName = "get" + property.substring(0,1).toUpperCase() + property.substring(1);

            Method getter = o.getClass().getMethod(getterName, null);

            return getter.invoke(o, null);

        } catch (NoSuchMethodException e) {
            throw new BeanAccessorException(e.getMessage());
        } catch (SecurityException e) {
            throw new BeanAccessorException(e.getMessage());
        } catch (IllegalAccessException e) {
            throw new BeanAccessorException(e.getMessage());
        } catch (IllegalArgumentException e) {
            throw new BeanAccessorException(e.getMessage());
        } catch (InvocationTargetException e) {
            throw new BeanAccessorException(e.getMessage());
        }
    }

    public class BeanAccessorException extends java.lang.Exception {

        public BeanAccessorException(String s) {
            super(s);
        }
    }
}
