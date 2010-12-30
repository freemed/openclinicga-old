package be.openclinic.datacenter;

import java.util.Date;

public class DatacenterMessage {
	int objectId;
	String messageId;
	Date createDateTime;
	Date ackDateTime;
	Date importDateTime;
	Date importAckDateTime;
	String data;
	Date sentDateTime;
	int serverId;
	int error;

	public int getError() {
		return error;
	}

	public void setError(int error) {
		this.error = error;
	}

	public int getServerId() {
		return serverId;
	}

	public void setServerId(int serverId) {
		this.serverId = serverId;
	}

	public Date getSentDateTime() {
		return sentDateTime;
	}
	public void setSentDateTime(Date sentDateTime) {
		this.sentDateTime = sentDateTime;
	}

	public Date getImportAckDateTime() {
		return importAckDateTime;
	}
	public void setImportAckDateTime(Date importAckDateTime) {
		this.importAckDateTime = importAckDateTime;
	}
	public int getObjectId() {
		return objectId;
	}
	public void setObjectId(int objectId) {
		this.objectId = objectId;
	}
	public String getMessageId() {
		return messageId;
	}
	public void setMessageId(String messageId) {
		this.messageId = messageId;
	}
	public Date getCreateDateTime() {
		return createDateTime;
	}
	public void setCreateDateTime(Date createDateTime) {
		this.createDateTime = createDateTime;
	}
	public Date getAckDateTime() {
		return ackDateTime;
	}
	public void setAckDateTime(Date ackDateTime) {
		this.ackDateTime = ackDateTime;
	}
	public Date getImportDateTime() {
		return importDateTime;
	}
	public void setImportDateTime(Date importDateTime) {
		this.importDateTime = importDateTime;
	}
	public String getData() {
		return data;
	}
	public void setData(String data) {
		this.data = data;
	}
}
