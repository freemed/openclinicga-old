package be.dpms.medwan.webapp.wo.common.navigation;

import java.util.*;

public class URLHistory {

    private List urlHistoryItems = null;
    private String homepageDisplayName = null;
    private String homepageQueryString = null;

    public URLHistory(){
        urlHistoryItems = new LinkedList();
    }

    public URLHistory(String homeDisplayName, String homeQueryString){

        homepageDisplayName = homeDisplayName;
        homepageQueryString = homeQueryString;

        urlHistoryItems = new LinkedList();

        // Generate new Id and build the the History Item
        String id = String.valueOf(urlHistoryItems.size());
        URLHistoryItem urlHistoryItem = new URLHistoryItem(id, homeDisplayName,  homeQueryString);

        // Add the History Item to the list
        ((LinkedList)urlHistoryItems).addLast(urlHistoryItem);

        ////Debug.println("\n\n********************** URLHistory create with homeDisplayName = "+ homeDisplayName + " - homeQueryString = " + homeQueryString);
    }

    public List getUrlHistoryItems(){
        return urlHistoryItems;
    }

    public String getHomepageDisplayName() {
        return homepageDisplayName;
    }

    public String getHomepageQueryString() {
        return homepageQueryString;
    }

    public synchronized URLHistoryItem addUrlItem(String displayName, String path) {
        // Generate new Id and build the the History Item
        String id = String.valueOf(urlHistoryItems.size());
        URLHistoryItem urlHistoryItem = new URLHistoryItem(id, displayName,  path);

        // Add the History Item to the list
        addUrlItem(urlHistoryItem);

        return urlHistoryItem;
    }

    private void addUrlItem(URLHistoryItem urlItem) {
        ////Debug.println("URLHistory : START addUrlItem()");
        if (!urlHistoryItems.contains(urlItem)){
            ((LinkedList)urlHistoryItems).addLast(urlItem);
            ////Debug.println("URLHistory : addLast(urlItem)");
        }
        ////Debug.println("URLHistory : END addUrlItem()");
    }

    public void removeUrlItem(String itemId) {

        ////Debug.println("URLHistory : START removeUrlItem()");

        for(int i = Integer.parseInt(itemId)+1; i < urlHistoryItems.size();) {
            ////Debug.println("urlHistoryItems.size() = " + urlHistoryItems.size());
            ////Debug.println("urlHistoryItems.remove("+i+")");
            urlHistoryItems.remove(i);
        }
    }
}
