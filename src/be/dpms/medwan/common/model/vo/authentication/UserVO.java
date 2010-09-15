package be.dpms.medwan.common.model.vo.authentication;

import be.dpms.medwan.common.model.vo.administration.PersonVO;
import be.mxs.common.model.vo.IIdentifiable;

import java.io.Serializable;
import java.util.Date;

public class UserVO implements Serializable, IIdentifiable {
    public static final Integer INVALID_USER_VO = new Integer(-1);
    public Integer userId;
    public final String password;
    public final Date dateBegin;
    public final Date dateEnd;

    public PersonVO personVO = null;
    public String accessRights = null;

    public UserVO(Integer userId, String password, Date dateBegin, Date dateEnd, PersonVO person) {
        this.userId = userId;
        this.password = password;
        this.dateBegin = dateBegin;
        this.dateEnd = dateEnd;
        this.personVO = person;
    }

    public Integer getUserId() {
        return userId;
    }

    public String getPassword() {
        return password;
    }

    public Date getDateBegin() {
        return dateBegin;
    }

    public Date getDateEnd() {
        return dateEnd;
    }

    public PersonVO getPersonVO() {
        return personVO;
    }

    public String getAccessRights() {
        return accessRights;
    }

    public void setAccessRights(String accessRights) {
        this.accessRights = accessRights;
    }

    public boolean equals(Object o) {
        if (this == o) return true;
        if (!(o instanceof UserVO)) return false;

        final UserVO userVO = (UserVO) o;

        return userId.equals(userVO.userId);

    }

    public int hashCode() {
        return userId.hashCode();
    }
}
