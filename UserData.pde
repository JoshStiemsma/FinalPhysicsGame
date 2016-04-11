public class UserData{
  
  
  String type;
  
  Object obj;
  UserData(){}
  UserData(String _type, Object _obj){
    this.type=_type;
    this.obj = _obj;
  }
  
  
  public String getType() {
        return type;
    }
  public Object getObject(){
     return obj; 
  }
  
}