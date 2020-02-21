package visp_common;

public interface ChooseObjectRequest extends org.ros.internal.message.Message {
  static final java.lang.String _TYPE = "visp_common/ChooseObjectRequest";
  static final java.lang.String _DEFINITION = "string object\n";
  static final boolean _IS_SERVICE = true;
  static final boolean _IS_ACTION = false;
  java.lang.String getObject();
  void setObject(java.lang.String value);
}
