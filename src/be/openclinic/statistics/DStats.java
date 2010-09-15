package be.openclinic.statistics;

import be.mxs.common.util.db.MedwanQuery;
import be.mxs.common.util.system.ScreenHelper;

import java.util.*;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.sql.ResultSet;
import java.text.SimpleDateFormat;

public class DStats implements Comparable{
    String codeType;
    String code;
    Date start;
    Date end;
    String service;
    SortedSet outcomeStats = new TreeSet();
    int totalContacts;
    int totalDuration;
    String sortOrder="duration";
    String type=""; //admission or visit

    public String getType() {
        return type;
    }

    public void setType(String type) {
        this.type = type;
    }

    public int compareTo(Object o) {
        int comp;
        if (o.getClass().isInstance(this)){
            if(sortOrder.equalsIgnoreCase("duration")){
                if(this.getDiagnosisTotalDuration().equals(((DStats)o).getDiagnosisTotalDuration())){
                    comp = ScreenHelper.padRight(this.getCode(),"0",6).compareTo(ScreenHelper.padRight(((DStats)o).getCode(),"0",6));
                }
                else {
                    comp = this.getDiagnosisTotalDuration().compareTo(((DStats)o).getDiagnosisTotalDuration());
                }
            }
            else if(sortOrder.equalsIgnoreCase("count")){
                if(this.getDiagnosisCount().equals(((DStats)o).getDiagnosisCount())){
                    comp = ScreenHelper.padRight(this.getCode(),"0",6).compareTo(ScreenHelper.padRight(((DStats)o).getCode(),"0",6));
                }
                else {
                    comp = this.getDiagnosisCount().compareTo(((DStats)o).getDiagnosisCount());
                }
            }
            else {
                if(this.getDiagnosisDead().equals(((DStats)o).getDiagnosisDead())){
                    comp = ScreenHelper.padRight(this.getCode(),"0",6).compareTo(ScreenHelper.padRight(((DStats)o).getCode(),"0",6));
                }
                else {
                    comp = this.getDiagnosisDead().compareTo(((DStats)o).getDiagnosisDead());
                }
            }
        }
        else {
            throw new ClassCastException();
        }
        return comp;
    }

    public static class OutcomeStat implements Comparable{
        String outcome;
        int diagnosisCases;
        double coMorbidityScore;
        double meanDuration;
        double standardDeviationDuration;
        int minDuration;
        int maxDuration;

        public int compareTo(Object o) {
            int comp;
            if (o.getClass().isInstance(this)){
                comp = this.outcome.compareTo(((OutcomeStat)o).outcome);
            }
            else {
                throw new ClassCastException();
            }
            return comp;
        }

        public String getOutcome() {
            return outcome;
        }

        public void setOutcome(String outcome) {
            this.outcome = outcome;
        }

        public int getDiagnosisCases() {
            return diagnosisCases;
        }

        public void setDiagnosisCases(int diagnosisCases) {
            this.diagnosisCases = diagnosisCases;
        }

        public double getCoMorbidityScore() {
            return coMorbidityScore;
        }

        public void setCoMorbidityScore(double coMorbidityScore) {
            this.coMorbidityScore = coMorbidityScore;
        }

        public double getMeanDuration() {
            return meanDuration;
        }

        public void setMeanDuration(double meanDuration) {
            this.meanDuration = meanDuration;
        }

        public double getStandardDeviationDuration() {
            return standardDeviationDuration;
        }

        public void setStandardDeviationDuration(double standardDeviationDuration) {
            this.standardDeviationDuration = standardDeviationDuration;
        }

        public int getMinDuration() {
            return minDuration;
        }

        public void setMinDuration(int minDuration) {
            this.minDuration = minDuration;
        }

        public int getMaxDuration() {
            return maxDuration;
        }

        public void setMaxDuration(int maxDuration) {
            this.maxDuration = maxDuration;
        }
    }

    public Integer getDiagnosisDead(){
        int dead =0;
        Iterator iterator = outcomeStats.iterator();
        while(iterator.hasNext()){
            OutcomeStat outcomeStat = (OutcomeStat)iterator.next();
            if(outcomeStat.outcome.equalsIgnoreCase("dead")){
                dead=outcomeStat.getDiagnosisCases();
                break;
            }
        }
        return new Integer(dead);
    }

    public Integer getDiagnosisTotalDuration(){
        int duration =0;
        Iterator iterator = outcomeStats.iterator();
        while(iterator.hasNext()){
            OutcomeStat outcomeStat = (OutcomeStat)iterator.next();
            duration+=outcomeStat.getMeanDuration()*outcomeStat.getDiagnosisCases();
        }
        return new Integer(duration);
    }

    public int getDiagnosisAllCases(){
        int allcases =0;
        Iterator iterator = outcomeStats.iterator();
        while(iterator.hasNext()){
            OutcomeStat outcomeStat = (OutcomeStat)iterator.next();
            allcases+=outcomeStat.getDiagnosisCases();
        }
        return allcases;
    }

    public Integer getDiagnosisCount(){
        int allcases =0;
        Iterator iterator = outcomeStats.iterator();
        while(iterator.hasNext()){
            OutcomeStat outcomeStat = (OutcomeStat)iterator.next();
            allcases+=outcomeStat.getDiagnosisCases();
        }
        return new Integer(allcases);
    }

    public DStats(String codeType, String code) {
        this.codeType = codeType;
        this.code = code;
    }


    public DStats(String codeType, String code, Date start, Date end,String service,String sortorder,String type) {
        this.codeType = codeType;
        this.code = code;
        this.start = start;
        this.end = end;
        this.service=service;
        this.sortOrder=sortorder;
        this.type=type;
        calculate();
    }

    public SortedSet getOutcomeStats() {
        return outcomeStats;
    }

    public void setOutcomeStats(SortedSet outcomeStats) {
        this.outcomeStats = outcomeStats;
    }

    public int getTotalContacts() {
        return totalContacts;
    }

    public void setTotalContacts(int totalContacts) {
        this.totalContacts = totalContacts;
    }

    public int getTotalDuration() {
        return totalDuration;
    }

    public void setTotalDuration(int totalDuration) {
        this.totalDuration = totalDuration;
    }

    public String getCodeType() {
        return codeType;
    }

    public void setCodeCype(String codeType) {
        this.codeType = codeType;
    }

    public String getCode() {
        return code;
    }

    public void setCode(String code) {
        this.code = code;
    }

    public Date getStart() {
        return start;
    }

    public void setStart(Date start) {
        this.start = start;
    }

    public Date getEnd() {
        return end;
    }

    public void setEnd(Date end) {
        this.end = end;
    }

    public static Vector getDiagnosisList(String codetype,String code,Date start,Date end,String service,int detail,String type){
        return null;
    }

    public int calculateTotalDead(Date start,Date end){
        return 0;
    }

    public DStats() {
    }

    public void calculate(Date start,Date end){};

    public void calculateHeader(Date start,Date end){};

    public static SortedSet calculateSubStats(String codeType, String code, Date start, Date end,String service,String sortorder,int detail,String type){
        return null;
    }

    public static Vector getAssociatedPathologies(String diagnosisCode, String diagnosisType,Date dBegin, Date dEnd,String outcome,String service,int detail,String type){
        return null;
    }

    public static double[] getMedianDuration(String diagnosisCode, String diagnosisType,Date dBegin, Date dEnd,String outcome,String service,String type){
        return null;
    }

    public void calculate(){
        calculate(start,end);
    }
}