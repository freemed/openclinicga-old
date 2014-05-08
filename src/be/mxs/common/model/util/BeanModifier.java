package be.mxs.common.model.util;

import java.lang.reflect.Method;
import java.lang.reflect.InvocationTargetException;
import java.lang.reflect.Constructor;
import java.text.ParseException;
import java.text.SimpleDateFormat;

import be.mxs.common.util.system.ScreenHelper;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 04-juil.-2003
 * Time: 16:30:28
 * To change this template use Options | File Templates.
 */
public class BeanModifier {

    public static BeanModifier getInstance() {
        return new BeanModifier();
    }

    public void setPropertyValue(Object o, String property, String value) throws BeanModifierException {

        try {

            Object _o = o;
            String innerPropertyName, innerGetterName;
            Method _method;

            while (property.indexOf(".") > 0) {

                innerPropertyName = property.substring(0, property.indexOf("."));
                innerGetterName = "get" + innerPropertyName.substring(0,1).toUpperCase() + innerPropertyName.substring(1);

                _method = o.getClass().getMethod(innerGetterName, null);

                _o = _method.invoke(_o, null);

                property = property.substring(property.indexOf(".") +1);
            }

            String setterName = "set" + property.substring(0,1).toUpperCase() + property.substring(1);

            Method[] methods = _o.getClass().getMethods();
            Method setter = null;

            for (int i=0; i < methods.length ; i++) {
                if (methods[i].getName().equals(setterName)) setter = methods[i];
            }

            Class[] parameterTypes = setter.getParameterTypes();

            if (parameterTypes.length >= 1) {

                if (parameterTypes[0].isPrimitive()) {

                    if (parameterTypes[0] == Boolean.TYPE) parameterTypes[0] = Boolean.class;
                    else if (parameterTypes[0] == Byte.TYPE) parameterTypes[0] = Byte.class;
                    else if (parameterTypes[0] == Short.TYPE) parameterTypes[0] = Short.class;
                    else if (parameterTypes[0] == Integer.TYPE) parameterTypes[0] = Integer.class;
                    else if (parameterTypes[0] == Long.TYPE) parameterTypes[0] = Long.class;
                    else if (parameterTypes[0] == Float.TYPE) parameterTypes[0] = Float.class;
                    else if (parameterTypes[0] == Double.TYPE) parameterTypes[0] = Double.class;
                }

                Class[] constructorParameterTypes = {String.class};
                Constructor constructor = parameterTypes[0].getConstructor(constructorParameterTypes);

                Object parameterObject;

                if ( ( parameterTypes[0].isAssignableFrom( java.util.Date.class ) ) || ( parameterTypes[0].isAssignableFrom( java.sql.Date.class ) ) ) {

                    SimpleDateFormat simpleDateFormat = ScreenHelper.stdDateFormat;
                    java.util.Date dateValue = simpleDateFormat.parse(value);

                    parameterObject = new java.util.Date(dateValue.getTime());

                } else {

                    Object[] parameterValue = {value};
                    parameterObject = constructor.newInstance(parameterValue);
                }

                Object[] parameterArgs = {parameterObject};

                setter.invoke(_o, parameterArgs);
            }

        } catch (NoSuchMethodException e) {
            throw new BeanModifierException(e.getClass()+ " - " + e.getMessage());
        } catch (SecurityException e) {
            throw new BeanModifierException(e.getClass()+ " - " + e.getMessage());
        } catch (IllegalAccessException e) {
            throw new BeanModifierException(e.getClass()+ " - " + e.getMessage());
        } catch (IllegalArgumentException e) {
            throw new BeanModifierException(e.getClass()+ " - " + e.getMessage());
        } catch (InvocationTargetException e) {
            throw new BeanModifierException(e.getClass()+ " - " + e.getMessage());
        } catch (InstantiationException e) {
            throw new BeanModifierException(e.getClass()+ " - " + e.getMessage());
        } catch (ParseException e) {
            throw new BeanModifierException(e.getClass()+ " - " + e.getMessage());
        }
    }

    public class BeanModifierException extends Exception {

        public BeanModifierException(String s) {
            super(s);
        }
    }
}
