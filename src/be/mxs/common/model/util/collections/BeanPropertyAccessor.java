package be.mxs.common.model.util.collections;

import be.mxs.common.model.util.BeanAccessor;

import java.lang.reflect.Method;
import java.util.*;

public class BeanPropertyAccessor {

    // ------------------------------------------------------------- Properties

    public static BeanPropertyAccessor getInstance() {
        return new BeanPropertyAccessor();
    }

    private Object model = null;
    private String path;
    private String property;
    private String compare;
    private Hashtable comparator = null;

    private Object getModel() {
        return model;
    }

    private void setModel(Object model) {
        this.model = model;
    }

    private String getPath() {
        return path;
    }

    private void setPath(String path) {
        this.path = path;
    }

    private String getProperty() {
        return property;
    }

    private void setProperty(String property) {
        this.property = property;
    }

    private String getCompare() {
        return compare;
    }

    private void setCompare(String compare) {
        this.compare = compare;
    }

    private Hashtable getComparator() {

        if (comparator != null) return comparator;

        comparator = new Hashtable();

        String _compare = getCompare();
        String comparatorField = null;

        if (_compare.indexOf("=") > 0) comparatorField = _compare.substring(0, _compare.indexOf("="));

        String comparatorValue;

        while (comparatorField != null) {

            if (_compare.indexOf(";") > 0) {
                comparatorValue = _compare.substring(_compare.indexOf("=") + 1, _compare.indexOf(";"));
                _compare = _compare.substring( _compare.indexOf(";") + 1 );
            }
            else {
                comparatorValue = _compare.substring(_compare.indexOf("=") + 1, _compare.length());
                _compare = _compare.substring( _compare.indexOf("=") + 1 );
            }

            comparator.put(comparatorField, comparatorValue);

            if (_compare.indexOf("=") > 0) comparatorField = _compare.substring(0, _compare.indexOf("="));
            else comparatorField = null;
        }

        return comparator;
    }

    private boolean isComparable(Object o) {

        try {
            Enumeration fieldNames = getComparator().keys();
            String fieldName, fieldValue, getterName, objectFieldValue;
            Method method;

            while (fieldNames.hasMoreElements()) {

                fieldName = (String) fieldNames.nextElement();
                fieldValue = (String) getComparator().get(fieldName);
                getterName = "get" + fieldName.substring(0,1).toUpperCase() + fieldName.substring(1);
                method = o.getClass().getMethod(getterName, null);
                objectFieldValue = (String) method.invoke(o, null);

                if (!objectFieldValue.equals(fieldValue)) return false;
            }

        } catch (Exception e) {
            ////Debug.println(e.getMessage());
            return false;
        }

        ////Debug.println("-------------------------------- isComparable is TRUE !");
        return true;
    }


    // --------------------------------------------------------- Public Methods

    /**
     * Process the start tag.
     *
     */
    public Object getValue(Object model, String path, String property, String compareString) {

        setModel(model);
        setPath(path);
        setProperty(property);
        setCompare(compareString);

        comparator = null;
        Object objectValue = null;
        Object o = getModel();

        if (o != null) {

            String getterName = "get" + getProperty().substring(0,1).toUpperCase() + getProperty().substring(1);

            if (getPath() != null) {

                try {

                    o = BeanAccessor.getInstance().getPropertyValue(o, getPath());

                } catch (BeanAccessor.BeanAccessorException e) {

                    objectValue = null;
                }
            }

            if (o instanceof Collection) {

                Iterator iterator = ( (Collection) o).iterator();
                boolean found = false;
                Object _o;
                Method _method;

                while (iterator.hasNext() && (!found)) {

                    _o = iterator.next();

                    if (!isComparable(_o)) continue;
                    else found = true;

                    try {

                        _method = _o.getClass().getMethod(getterName, null);
                        objectValue = _method.invoke(_o, null);

                    } catch (Exception e) {
                        objectValue = null;
                    }

                }
            } else {

                if (isComparable(o)) {

                    try {

                        Method _method = o.getClass().getMethod(getterName, null);
                        objectValue = _method.invoke(o, null);

                    } catch (Exception e) {
                        objectValue = null;
                    }
                }
            }
        }
        return objectValue;
    }
}
