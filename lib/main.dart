import "dart:io";
import "package:path/path.dart";
import "package:path_provider/path_provider.dart";
import "package:flutter/material.dart";
import "package:scoped_model/scoped_model.dart";
import "LoginDialog.dart";
import "Model.dart" show FlutterChatModel, model;
import "Home.dart";
import "Lobby.dart";
import "Room.dart";
import "UserList.dart";
import "CreateRoom.dart";


var credentials;
var exists;


void main() {
  WidgetsFlutterBinding.ensureInitialized();

  startMeUp() async {
    Directory docsDir = await getApplicationDocumentsDirectory();
    model.docsDir = docsDir;

    var credentialsFile = File(join(model.docsDir.path, "credentials"));
    exists = await credentialsFile.exists();

    if (exists) {
      credentials = await credentialsFile.readAsString();
      print("## main(): credentials = $credentials");
    }

    runApp(FlutterChat());
  }

  startMeUp();
}

class FlutterChat extends StatelessWidget {
  const FlutterChat({Key key}) : super(key: key);

  @override
  Widget build(final BuildContext context) {
    return MaterialApp(home: Scaffold(body: FlutterChatMain()));
  }
}

class FlutterChatMain extends StatelessWidget {
  const FlutterChatMain({Key key}) : super(key: key);

  @override
  Widget build(final BuildContext inContext) {
    model.rootBuildContext = inContext;

    WidgetsBinding.instance.addPostFrameCallback((_) => executeAfterBuild());

    return ScopedModel<FlutterChatModel>(model: model, child: ScopedModelDescendant<FlutterChatModel>(
      builder: (BuildContext inContext, Widget inChild, FlutterChatModel inModel) {
        return MaterialApp(initialRoute: "/",
          routes: {
            "/Lobby" : (screenContext) => Lobby(),
            "/Room" : (screenContext) => Room(),
            "/UserList" : (screenContext) => UserList(),
            "/CreateRoom" : (screenContext) => CreateRoom()
          },
          home: Home()
        );
      }
    ));
  }

  Future<void> executeAfterBuild() async {

    if (exists) {

      print("## main(): Credential file exists, calling server with stored credentials");

      List credParts = credentials.split("============");
      LoginDialog().validateWithStoredCredentials(credParts[0], credParts[1]);
      
    } else {

      print("## main(): Credential file does NOT exist, prompting for credentials");

      await showDialog(context : model.rootBuildContext, barrierDismissible : false,
          builder : (BuildContext inDialogContext) {
            return LoginDialog();
          }
      );

    }

  }

}

