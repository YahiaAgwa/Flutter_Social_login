import 'package:flutter/material.dart';
import 'package:flutter_facebook_login/flutter_facebook_login.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_twitter_login/flutter_twitter_login.dart';

final FirebaseAuth _authInstance = FirebaseAuth.instance;
final GoogleSignIn _googleSignIn = new GoogleSignIn();
final FacebookLogin _facebookSignIn = new FacebookLogin();
final TwitterLogin _twitterLogin = new TwitterLogin(
  consumerKey: 'YcZlI3fbQB3kDgUPh6NokVeec',
  consumerSecret: 'N2tqmOu2TPDT2AgU4YiNNGJOKsUoaQK1f1EdAeDebF9FuAnU7z',
);

void main() => runApp(new MyApp());
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Flutter Demo',
      home: new MyHomePage(title: 'FireBase Login'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({Key key, this.title}) : super(key: key);
  final String title;
  @override
  _MyHomePageState createState() => new _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  List<String> _status = ['Not Authenticated','Signed in Anonymously','Signed out','Sign in failed','Already Signed In','Signed in by Google','Signed in by Facebook'];
  int _currentStatus;

  @override
  void initState(){
    _currentStatus = 0;
  }
  void _signInTwitter() async{

    final TwitterLoginResult result = await _twitterLogin.authorize();
    if (result.status == TwitterLoginStatus.loggedIn) {
      int newStatus;
      final FirebaseUser user = await _authInstance.signInWithTwitter(authToken:result.session.token ,authTokenSecret: result.session.secret);
      if(user!=null && !user.isAnonymous)
        newStatus=5;
      else
        newStatus = 3;
      setState(() {
        _currentStatus=newStatus;
      });
    }
  }
  void _signInGoogle() async{
    int newStatus;
    GoogleSignInAccount _googleUser = await _googleSignIn.signIn();
    GoogleSignInAuthentication _googleAuth = await _googleUser.authentication;
    final FirebaseUser user = await _authInstance.signInWithGoogle(
      idToken:_googleAuth.idToken,
      accessToken:_googleAuth.accessToken
    );
    if(user!=null && !user.isAnonymous)
      newStatus=5;
    else
      newStatus = 3;
    setState(() {
      _currentStatus=newStatus;
    });
  }
  void _signInFacebook() async{
    _facebookSignIn.loginBehavior = FacebookLoginBehavior.nativeOnly;
    final FacebookLoginResult result = await _facebookSignIn.logInWithReadPermissions(['email','public_profile']);
    if(result.status==FacebookLoginStatus.loggedIn){
        int newStatus;
        final FirebaseUser user = await _authInstance.signInWithFacebook(accessToken: result.accessToken.token);
        debugPrint(user.toString());
        if(user!=null && !user.isAnonymous)
          newStatus=6;
        else
          newStatus = 3;
        setState(() {
          _currentStatus=newStatus;
        });
    }


  }
  void _signInAnon() async{
    int newStatus;
    if(_currentStatus==1 || _currentStatus==4)
      newStatus=4;
    else{
      FirebaseUser user = await _authInstance.signInAnonymously();
      if(user != null && user.isAnonymous) newStatus = 1;
      else newStatus = 3;
    }
    setState(() { _currentStatus = newStatus;});
  }
  void _signOut() async{
    if(_googleSignIn.isSignedIn==true)await _googleSignIn.signOut();
    if(_facebookSignIn.isLoggedIn == true)await _facebookSignIn.logOut();
    await _twitterLogin.logOut();
    await _authInstance.signOut();
    setState(() {
          _currentStatus = 2;
        });
  }
  @override
  Widget build(BuildContext context) {
    return new Scaffold(
      appBar: new AppBar(
        title: new Text(widget.title),
      ),
      body: new Center(
        child: new Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
             Text('${_status[_currentStatus]}'),
            RaisedButton(onPressed: _signOut,child: Text("Sign out"),),
            RaisedButton(onPressed: _signInAnon,child: Text("Sign in anonymously"),),
            FlatButton(onPressed: _signInGoogle,child: Image.asset("images/google.png",height:100.0,),),
            FlatButton(onPressed: _signInTwitter,child: Image.asset("images/twitter.png",height:100.0,),),
            FlatButton(onPressed: _signInFacebook,child: Image.asset("images/facebook.png",height: 100.0,),),

          ],
        ),
      )
    );
  }
}
