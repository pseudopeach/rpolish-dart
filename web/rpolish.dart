import 'dart:html';

void main() {
  querySelector("#goButton")
    ..text = "Click me!"
    ..onClick.listen(polepole);
}

void polepole(MouseEvent event) {

  InputElement ele = querySelector("#text_input");
  Expression ex = new Expression.fromString(ele.value);

  querySelector("#output").text = ex.postfixForm;
}

class Expression{
  String humanForm;
  String postfixForm;
  bool assumeWhitespace = true;
  List<Token> tokenized;
  
  static List<String> processWhitespace(String str){
    //settings about whitespace can apply here
    RegExp exp = new RegExp(r"\s+");
    return str.split(exp);
  }
  
  Expression.fromString(String str){
    tokenized = [];
    List<Operator> opStack = [];
    List<String> input = processWhitespace(str);
    int lastGroupArgCount;
    
    this.humanForm = input.join(" ");
    
    void opPop(){
      //error handling can go in here...
      Operator op = opStack.removeLast();
      if(op.argCount == null){
        if(lastGroupArgCount == null) throw "Illegal use of function";
        op.argCount = lastGroupArgCount;
        lastGroupArgCount = null;
      }
      tokenized.add(op);
    }
  
    while(input.length > 0){
      Token tok = new Token.autoCreate(input.removeAt(0));
      if(tok is Operator){
        Operator op = tok;
        if(op.isArgSeparator){
          while(!opStack.last.opensGroup) opPop();
          opStack.last.argCount++;
        }else if(op.closesGroup){
          //special case: grouping operator
          //pop till we find the corresponding opener
          while(!opStack.last.opensGroup ) opPop();
          lastGroupArgCount = opStack.removeLast().argCount;  //leave the paren, keep the argCount and the cannoli
        }else{
          //clear ops with greater priority from the [opStack]
          while(!opStack.isEmpty && opStack.last.priority > tok.priority) opPop();
          //add the operator to the [opStack]
          opStack.add(op);
          
        }
      }else //just pass any non operators (ids) thru 
        tokenized.add(tok);
    }
    while(!opStack.isEmpty) opPop();
    postfixForm = tokenized.join(" ");
  }
  
}

class Token{
  String label;
  String toString() => label;
  Token(this.label);
 
  factory Token.autoCreate(String str){
    Operator op = new Operator.autoCreate(str);
    if(op != null) return op;
    return new Token(str);
  }
}

class Operator extends Token{
  
  int priority;
  int argCount;
  bool get opensGroup => label == "(";
  bool get closesGroup => label == ")";
  bool get isArgSeparator => label == ",";
  
  Operator(String str) : super(str);
  
  factory Operator.autoCreate(String input){
    Map opInfo = opCatalog[input];
    if(opInfo == null) return null;
    Operator out = new Operator(input);
    out.priority = opInfo["priority"];
    out.argCount = opInfo["argCount"];
    return out;
  }
  
  static final Map<String, Map> opCatalog = {
    ")":{ "priority": 0},
    "(":{ "priority": 0, "argCount":1},
    ",":{ "priority": 0},
    "OR":{ "priority":1, "argCount":2},
    "XOR":{ "priority": 2, "argCount":2},
    "AND":{"priority":3, "argCount":2},
     
    "<":{ "priority": 4, "argCount":2},
    "<=":{ "priority": 4, "argCount":2},
    "=":{ "priority": 4, "argCount":2},
    ">":{ "priority": 4, "argCount":2},
    ">=":{ "priority": 4, "argCount":2},
    "<>":{ "priority": 4, "argCount":2},
    "+":{ "priority": 5, "argCount":2},
    "-":{ "priority": 5, "argCount":2},
    "*":{ "priority": 8, "argCount":2},
    "/":{ "priority": 8, "argCount":2},
    
    "NOT":{ "priority": 10, "argCount":1},
    
    "SNAKE":{"priority":-1} //no specified argCount, must use parentheses                                                        
  };
}


/*
 * ken's way
 * 
   ")":{ "priority": -1, "argCount":2},
   "(":{ "priority": -1, "argCount":2},
   "OR":{ "priority":1, "argCount":2},
   "XOR":{ "priority": 2, "argCount":2},
   "AND":{"priority":3, "argCount":2},
   
   "<":{ "priority": 4, "argCount":2},
    "<=":{ "priority": 4, "argCount":2},
    "=":{ "priority": 4, "argCount":2},
    ">":{ "priority": 4, "argCount":2},
    ">=":{ "priority": 4, "argCount":2},
    "<>":{ "priority": 4, "argCount":2},
    "+":{ "priority": 5, "argCount":2},
    "-":{ "priority": 5, "argCount":2},
    "*":{ "priority": 8, "argCount":2},
    "/":{ "priority": 8, "argCount":2},
    
    "NOT":{ "priority": 10, "argCount":1},
    
    "SNAKE":{"priority":11}
    
    
    
    
    */
