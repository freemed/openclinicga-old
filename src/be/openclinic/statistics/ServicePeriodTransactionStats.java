package be.openclinic.statistics;

/**
 * User: Frank Verbeke
 * Date: 6-aug-2007
 * Time: 21:47:58
 */
public class ServicePeriodTransactionStats {
    private String transactionType;
    private int count;

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public int getCount() {
        return count;
    }

    public ServicePeriodTransactionStats() {
    }

    public ServicePeriodTransactionStats(String transactionType, int count) {
        this.transactionType = transactionType;
        this.count = count;
    }

    public void setCount(int count) {
        this.count = count;
    }
}
