// ignore_for_file: dangling_library_doc_comments
/*
Padding(
  padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 275),
    child: TextFormField(
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: textInputDecoation.copyWith(
        hintText: "Full Name",
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      enableSuggestions: false,
      validator: (val) {
        if (val!.isEmpty) {
          return "Please enter a name";
        } else {
          return null;
        }
      },
      onChanged: (val) => setState(
        () => _name = val,
      ),
    ),
  ),
),
*/

/**
 * ! Line Separator
 */

/* 
Padding(
  padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 275),
    child: TextFormField(
      style: const TextStyle(
        color: Colors.white,
      ),
      decoration: textInputDecoation.copyWith(
        hintText: "Email",
      ),
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      enableSuggestions: false,
      validator: (val) {
        if (val!.isEmpty) {
          return "Please enter an Email";
        } else if (!val.contains('@')) {
          return "Please enter a valid Email";
        } else {
          return null;
        }
      },
      onChanged: (val) => setState(() => _email = val),
    ),
  ),
),
*/

/**
 * ! Line Separator
 */

/*
Padding(
  padding: const EdgeInsets.fromLTRB(35, 10, 35, 10),
  child: ConstrainedBox(
    constraints: const BoxConstraints(maxWidth: 275),
    child: TextFormField(
      style: const TextStyle(color: Colors.white),
      decoration: textInputDecoation.copyWith(
        hintText: "Password",
        suffixIcon: IconButton(
          icon: _obsecureText
              ? const Icon(
                  Icons.visibility_rounded,
                )
              : const Icon(
                  Icons.visibility_off_rounded,
                ),
          onPressed: () => setState(() => _obsecureText = !_obsecureText),
          color: Colors.white,
        ),
      ),
      obscureText: _obsecureText,
      autocorrect: false,
      enableSuggestions: false,
      validator: (val) {
        return val!.length < 6
            ? "The password must be at least 6 characters long"
            : null;
      },
      onChanged: (val) => setState(() => _password = val),
    ),
  ),
),
*/

/**
 * ! Line Separator
 */

/* 
final _formKey = GlobalKey<FormState>();
String _name = "", _email = "", _password = "", _error = "";
bool _obsecureText = true; 
*/


/**
 * ! Line Separator
 * TODO: type_wrapper.dart file
 */

/* 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sign_in_button/sign_in_button.dart';

import '../../services/auth.dart';
import '../../shared/constants.dart';
import '../auth/authenticate.dart';

class TypeWrapper extends StatefulWidget {
  final AuthService authService;
  const TypeWrapper({super.key, required this.authService});

  @override
  State<TypeWrapper> createState() => _TypeWrapperState();
}

class _TypeWrapperState extends State<TypeWrapper> {
  String? dropdownValue;


  @override
  Widget build(BuildContext context) {
    return Card(
      child: Column(
        children: [
          AppBar(
            title: const Text(
              "Attendify",
              style: TextStyle(
                fontSize: 50,
                color: Colors.white,
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.blue[200],
            elevation: 20,
            shadowColor: Colors.black,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(25),
            ),
            toolbarHeight: 150,
          ),
          Expanded(
            flex: dropdownValue != null ? 0 : 1,
            child: Center(
              child: Container(
                color: Colors.transparent,
                child: DropdownButton<String>(
                  padding: const EdgeInsets.all(8.0),
                  elevation: 16,
                  dropdownColor: Colors.blue[100],
                  borderRadius: BorderRadius.circular(20),
                  value: dropdownValue,
                  hint: Text(
                    "Choose your user type",
                    textAlign: TextAlign.center,
                    style: GoogleFonts.poppins(
                        fontSize: 25,
                        fontWeight: FontWeight.w600,
                        color: Colors.blue[900]),
                  ),
                  style: const TextStyle(
                    color: Colors.black,
                    backgroundColor: Colors.transparent,
                  ),
                  underline: Container(
                    height: 2,
                    color: Colors.blue[900],
                  ),
                  onChanged: (String? newValue) {
                    setState(() {
                      dropdownValue = newValue;
                    });
                  },
                  items: <String>['teacher', 'student', 'HNS User']
                      .map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        capitalizeFirst(value),
                        textAlign: TextAlign.center,
                        style: GoogleFonts.poppins(
                          fontSize: 22.5,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          dropdownValue != null
              ? Container(
                  child: dropdownValue == "HNS User"
                      ? Expanded(
                          child: Center(
                            child: Transform.scale(
                              scale: 1.35,
                              child: ConstrainedBox(
                                constraints:
                                    const BoxConstraints(maxHeight: 50),
                                child: SignInButton(
                                  Buttons.google,
                                  padding: const EdgeInsets.all(8.0),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  text: "Sign in with HNS-RE2SD",
                                  onPressed: () {
                                    print("clicked");
                                    _signIn();
                                  },
                                ),
                              ),
                            ),
                          ),
                        )
                      : dropdownValue == "teacher"
                          ? Expanded(
                              flex: 1,
                              child: Authenticate(
                                //userType: "teacher",
                                authService: widget.authService,
                              ),
                            )
                          : Expanded(
                              flex: 1,
                              child: Authenticate(
                                //userType: "student",
                                authService: widget.authService,
                              ),
                            ),
                )
              : const SizedBox(height: 25)
        ],
      ),
    );
  }
}
 */

/**
 * ! Line Separator
 * TODO: a code for cached images
 */

/* 
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

class UserProfileWidget extends StatelessWidget {
  final String profilePictureUrl;

  UserProfileWidget({required this.profilePictureUrl});

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: profilePictureUrl,
      placeholder: (context, url) => CircularProgressIndicator(),
      errorWidget: (context, url, error) => Icon(Icons.error),
      fit: BoxFit.cover, // or other BoxFit options
    );
  }
}
 */

/**
 * ! Line Separator
 * TODO: a code for old generation of routes in main.dart
 */

/*

{
          '/studentView': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var student = args['student'] as Student;
            var databaseService = args['databaseService'] as DatabaseService;
            var authService = args['authService'] as AuthService;
            return StudentView(
              student: student,
              databaseService: databaseService,
              authService: authService,
            );
          },
          '/teacherView': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var teacher = args['teacher'] as Teacher;
            var databaseService = args['databaseService'] as DatabaseService;
            var authService = args['authService'] as AuthService;
            return TeacherView(
              teacher: teacher,
              databaseService: databaseService,
              authService: authService,
            );
          },
          '/moduleViewFromTeacher': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var module = args['module'] as Module;
            var databaseService = args['databaseService'] as DatabaseService;
            return ModuleViewFromTeacher(
              module: module,
              databaseService: databaseService,
            );
          },
          '/moduleViewFromStudent': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var module = args['module'] as Module;
            var student = args['student'] as Student;
            var databaseService = args['databaseService'] as DatabaseService;
            return ModuleViewFromStudent(
              module: module,
              student: student,
              databaseService: databaseService,
            );
          },
          '/selectModule': (context) {
            var args = ModalRoute.of(context)!.settings.arguments
                as Map<String, dynamic>;
            var modules = args['modules'] as List<Module>;
            var teacher = args['teacher'] as Teacher;
            var databaseService = args['databaseService'] as DatabaseService;
            var authService = args['authService'] as AuthService;
            return SelectModule(
              modules: modules,
              teacher: teacher,
              databaseService: databaseService,
              authService: authService,
            );
          },
        },

*/

/**
 * ! Line Separator
 * * This is a good widget for drawer
 * TODO: don't ignore this widget one
 */

/*

child: Padding(
      padding: EdgeInsetsDirectional.fromSTEB(0, 12, 0, 12),
      child: Column(
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(0, 0, 16, 0),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                  child: Text(
                    'Account Options',
                    textAlign: TextAlign.start,
                    style: FlutterFlowTheme.of(context).labelMedium.override(
                          fontFamily: 'Plus Jakarta Sans',
                          color: Color(0xFF57636C),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                  child: Icon(
                    Icons.close_rounded,
                    color: Color(0xFF57636C),
                    size: 32,
                  ),
                ),
              ],
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12, 8, 12, 8),
            child: Row(
              mainAxisSize: MainAxisSize.max,
              children: [
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 0, 12, 0),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: Color(0x4C4B39EF),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Color(0xFF4B39EF),
                        width: 2,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsetsDirectional.fromSTEB(2, 2, 2, 2),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(10),
                        child: Image.network(
                          'https://images.unsplash.com/photo-1633332755192-727a05c4013d?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxzZWFyY2h8M3x8dXNlcnN8ZW58MHx8MHx8&auto=format&fit=crop&w=900&q=60',
                          width: 36,
                          height: 36,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                  ),
                ),
                Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                  child: Column(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Randy Peterson',
                        style:
                            FlutterFlowTheme.of(context).bodyMedium.override(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Color(0xFF14181B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                      ),
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(0, 4, 0, 0),
                        child: Text(
                          'randy.p@domainname.com',
                          style:
                              FlutterFlowTheme.of(context).bodySmall.override(
                                    fontFamily: 'Plus Jakarta Sans',
                                    color: Color(0xFF4B39EF),
                                    fontSize: 12,
                                    fontWeight: FontWeight.w500,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Divider(
            thickness: 1,
            color: Color(0xFFE0E3E7),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 4),
            child: MouseRegion(
              opaque: false,
              cursor: MouseCursor.defer ?? MouseCursor.defer,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _model.mouseRegionHovered1!
                      ? Color(0xFFF1F4F8)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                        child: Icon(
                          Icons.account_circle_outlined,
                          color: Color(0xFF14181B),
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                            'My Account',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Color(0xFF14181B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onEnter: ((event) async {
                setState(() => _model.mouseRegionHovered1 = true);
              }),
              onExit: ((event) async {
                setState(() => _model.mouseRegionHovered1 = false);
              }),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 4),
            child: MouseRegion(
              opaque: false,
              cursor: SystemMouseCursors.basic ?? MouseCursor.defer,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _model.mouseRegionHovered2!
                      ? Color(0xFFF1F4F8)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                        child: Icon(
                          Icons.settings_outlined,
                          color: Color(0xFF14181B),
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                            'Settings',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Color(0xFF14181B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onEnter: ((event) async {
                setState(() => _model.mouseRegionHovered2 = true);
              }),
              onExit: ((event) async {
                setState(() => _model.mouseRegionHovered2 = false);
              }),
            ),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 4),
            child: MouseRegion(
              opaque: false,
              cursor: SystemMouseCursors.click ?? MouseCursor.defer,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _model.mouseRegionHovered3!
                      ? Color(0xFFF1F4F8)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                        child: Icon(
                          Icons.attach_money_rounded,
                          color: Color(0xFF14181B),
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                            'Billing Details',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Color(0xFF14181B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onEnter: ((event) async {
                setState(() => _model.mouseRegionHovered3 = true);
              }),
              onExit: ((event) async {
                setState(() => _model.mouseRegionHovered3 = false);
              }),
            ),
          ),
          Align(
            alignment: AlignmentDirectional(0.00, 0.00),
            child: Padding(
              padding: EdgeInsetsDirectional.fromSTEB(16, 4, 16, 4),
              child: Container(
                width: double.infinity,
                height: 50,
                decoration: BoxDecoration(
                  color: Color(0xFFF1F4F8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(4, 4, 4, 4),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            setDarkModeSetting(context, ThemeMode.light);
                          },
                          child: Container(
                            width: 115,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.light
                                  ? Colors.white
                                  : Color(0xFFF1F4F8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).brightness ==
                                        Brightness.light
                                    ? Color(0xFFE0E3E7)
                                    : Color(0xFFF1F4F8),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.wb_sunny_rounded,
                                  color: Theme.of(context).brightness ==
                                          Brightness.light
                                      ? Color(0xFF14181B)
                                      : Color(0xFF57636C),
                                  size: 16,
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      4, 0, 0, 0),
                                  child: Text(
                                    'Light Mode',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.light
                                                  ? Color(0xFF14181B)
                                                  : Color(0xFF57636C),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: InkWell(
                          splashColor: Colors.transparent,
                          focusColor: Colors.transparent,
                          hoverColor: Colors.transparent,
                          highlightColor: Colors.transparent,
                          onTap: () async {
                            setDarkModeSetting(context, ThemeMode.dark);
                          },
                          child: Container(
                            width: 115,
                            height: 100,
                            decoration: BoxDecoration(
                              color: Theme.of(context).brightness ==
                                      Brightness.dark
                                  ? Colors.white
                                  : Color(0xFFF1F4F8),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(
                                color: Theme.of(context).brightness ==
                                        Brightness.dark
                                    ? Color(0xFFE0E3E7)
                                    : Color(0xFFF1F4F8),
                                width: 1,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.nightlight_round,
                                  color: Theme.of(context).brightness ==
                                          Brightness.dark
                                      ? Color(0xFF14181B)
                                      : Color(0xFF57636C),
                                  size: 16,
                                ),
                                Padding(
                                  padding: EdgeInsetsDirectional.fromSTEB(
                                      4, 0, 0, 0),
                                  child: Text(
                                    'Dark Mode',
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                          fontFamily: 'Plus Jakarta Sans',
                                          color:
                                              Theme.of(context).brightness ==
                                                      Brightness.dark
                                                  ? Color(0xFF14181B)
                                                  : Color(0xFF57636C),
                                          fontSize: 14,
                                          fontWeight: FontWeight.w500,
                                        ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ).animateOnActionTrigger(
                          animationsMap['containerOnActionTriggerAnimation']!,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Divider(
            thickness: 1,
            color: Color(0xFFE0E3E7),
          ),
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(12, 0, 12, 0),
            child: MouseRegion(
              opaque: false,
              cursor: SystemMouseCursors.click ?? MouseCursor.defer,
              child: AnimatedContainer(
                duration: Duration(milliseconds: 150),
                curve: Curves.easeInOut,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: _model.mouseRegionHovered4!
                      ? Color(0xFFF1F4F8)
                      : Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding: EdgeInsetsDirectional.fromSTEB(0, 8, 0, 8),
                  child: Row(
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Padding(
                        padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                        child: Icon(
                          Icons.login_rounded,
                          color: Color(0xFF14181B),
                          size: 20,
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding:
                              EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
                          child: Text(
                            'Log out',
                            style: FlutterFlowTheme.of(context)
                                .bodyMedium
                                .override(
                                  fontFamily: 'Plus Jakarta Sans',
                                  color: Color(0xFF14181B),
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              onEnter: ((event) async {
                setState(() => _model.mouseRegionHovered4 = true);
              }),
              onExit: ((event) async {
                setState(() => _model.mouseRegionHovered4 = false);
              }),
            ),
          ),
        ],
      ),
    ),

*/

/**
 * ! Line Separator
 */

/**
  void queryListener() {
    search(searchController.text);
  }

  void search(String query) {
    if (query.isEmpty) {
      setState(() {
        modules = allModules;
      });
    } else {
      setState(() {
        modules = allModules
            .where(
              (element) => element.name.toLowerCase().contains(
                    query.toLowerCase(),
                  ),
            )
            .toList();
      });
    }
  }

*/