package be.openclinic.statistics;

/**
 * User: Frank Verbeke
 * Date: 6-aug-2007
 * Time: 21:49:59
 */
public class ServicePeriodItemStats {
    private String itemType;
    private int count;

    public ServicePeriodItemStats() {
    }

    public String getItemType() {
        return itemType;
    }

    public void setItemType(String itemType) {
        this.itemType = itemType;
    }

    public int getCount() {
        return count;
    }

    public void setCount(int count) {
        this.count = count;
    }

    public ServicePeriodItemStats(String itemType, int count) {
        this.itemType = itemType;
        this.count=count;
    }
}
