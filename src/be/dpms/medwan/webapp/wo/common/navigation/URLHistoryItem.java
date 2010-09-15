package be.dpms.medwan.webapp.wo.common.navigation;

import be.dpms.medwan.common.model.IConstants;

/**
 * Created by IntelliJ IDEA.
 * User: Michaël
 * Date: 02-avr.-2003
 * Time: 16:11:47
 * To change this template use Options | File Templates.
 */
public class URLHistoryItem {
    private String id;
    private String displayName;
    private String path;
    private String removeQueryString;
    private String addQueryString;

    public URLHistoryItem(String id, String displayName, String path) {
        this.id = id;
        this.displayName = displayName;
        this.path = path;
        this.removeQueryString = getRemoveFromHistoryQueryString();
        this.addQueryString = getAddToHistoryQueryString();
    }

    public String getRemoveQueryString() {
        return removeQueryString;
    }

    public String getAddQueryString() {
        return addQueryString;
    }

    public String getId() {
        return id;
    }

    public String getDisplayName() {
        return displayName;
    }

    public String getPath() {
        return path;
    }


    public String getRemoveFromHistoryQueryString(){
        String s;

        if (getPath().indexOf("?") == -1) {
            s = getPath() + "?" + IConstants.HISTORY_ACTION + "=" + IConstants.REMOVE + "&" + IConstants.ITEM_ID + "=" + getId();
        } else {
            s = getPath() + "&" + IConstants.HISTORY_ACTION + "=" + IConstants.REMOVE + "&" + IConstants.ITEM_ID + "=" + getId();
        }

        return s;
    }

    public String getAddToHistoryQueryString(){
        String s;

        if (getPath().indexOf("?") == -1) {
            s = getPath() + "?" + IConstants.HISTORY_ACTION + "=" + IConstants.ADD + "&" + IConstants.HISTORY_ITEM_DISPLAY_NAME + "=" + getDisplayName();
        } else {
            s = getPath() + "&" + IConstants.HISTORY_ACTION + "=" + IConstants.ADD + "&" + IConstants.HISTORY_ITEM_DISPLAY_NAME + "=" + getDisplayName();
        }

        return s;
    }

    public boolean equals(Object o){
        ////Debug.println("URLHistoryItem.equals - SOURCE Object = "+o);
        if (o instanceof URLHistoryItem) {
            URLHistoryItem i = (URLHistoryItem)o;
            ////Debug.println("URLHistoryItem.equals - SOURCE URLHistoryItem.DisplayName = "+ i.getDisplayName());
            ////Debug.println("URLHistoryItem.equals - THIS URLHistoryItem.DisplayName = "+ this.getDisplayName());
            return (i.getDisplayName().equals(this.getDisplayName()));
        }

        return false;
    }
}
