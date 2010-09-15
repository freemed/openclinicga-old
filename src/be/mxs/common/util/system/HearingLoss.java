package be.mxs.common.util.system;

public class HearingLoss {
    public double loss1250;
    public double loss250;
    public double loss500;
    public double loss1000;
    public double loss2000;
    public double loss3000;
    public double loss4000;
    public double loss6000;
    public double loss8000;

    public HearingLoss() {
    }

    public HearingLoss(double loss1250, double loss250,double loss500,double loss1000,double loss2000,double loss3000,double loss4000,double loss6000,double loss8000){
        this.loss1250=loss1250;
        this.loss250=loss250;
        this.loss500=loss500;
        this.loss1000=loss1000;
        this.loss2000=loss2000;
        this.loss3000=loss3000;
        this.loss4000=loss4000;
        this.loss6000=loss6000;
        this.loss8000=loss8000;
    }

    public double getLoss1250() {
        return loss1250;
    }

    public void setLoss1250(double loss1250) {
        this.loss1250 = loss1250;
    }

    public double getLoss250() {
        return loss250;
    }

    public void setLoss250(double loss250) {
        this.loss250 = loss250;
    }

    public double getLoss500() {
        return loss500;
    }

    public void setLoss500(double loss500) {
        this.loss500 = loss500;
    }

    public double getLoss1000() {
        return loss1000;
    }

    public void setLoss1000(double loss1000) {
        this.loss1000 = loss1000;
    }

    public double getLoss2000() {
        return loss2000;
    }

    public void setLoss2000(double loss2000) {
        this.loss2000 = loss2000;
    }

    public double getLoss3000() {
        return loss3000;
    }

    public void setLoss3000(double loss3000) {
        this.loss3000 = loss3000;
    }

    public double getLoss4000() {
        return loss4000;
    }

    public void setLoss4000(double loss4000) {
        this.loss4000 = loss4000;
    }

    public double getLoss6000() {
        return loss6000;
    }

    public void setLoss6000(double loss6000) {
        this.loss6000 = loss6000;
    }

    public double getLoss8000() {
        return loss8000;
    }

    public void setLoss8000(double loss8000) {
        this.loss8000 = loss8000;
    }

}
