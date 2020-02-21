package visp_common;

public interface ChooseObjectResponse extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "visp_common/ChooseObjectResponse";
  static final java.lang.String _DEFINITION = "geometry_msgs/Point object_center\nbool success";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  geometry_msgs.Point getObjectCenter();
  void setObjectCenter(geometry_msgs.Point value);
  boolean getSuccess();
  void setSuccess(boolean value);
}
