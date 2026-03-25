import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../index.dart';
import '../shared/loading.dart';

class UserAccountDrawerHeader extends StatelessWidget {
  final String username;
  final String email;
  final String profileURL;
  final bool hasLogout;
  final void Function()? onLogout;
  const UserAccountDrawerHeader({
    super.key,
    required this.username,
    required this.email,
    required this.profileURL,
    this.hasLogout = false,
    this.onLogout,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        UserAccountsDrawerHeader(
          currentAccountPicture: CircleAvatar(
            backgroundColor: Colors.blue[100],
            child: ClipOval(
              child: CachedNetworkImage(
                imageUrl: profileURL,
                placeholder: (context, url) => const Loading(),
                errorWidget: (context, url, error) =>
                    AppImages.defaultProfilePicture,
                fit: BoxFit.contain,
              ),
            ),
          ),
          accountName: Text(
            username,
            style: GoogleFonts.roboto(
              fontSize: 20,
              fontWeight: FontWeight.w500,
              color: Colors.white,
            ),
          ),
          margin: const EdgeInsets.all(8.0),
          accountEmail: Text(
            email,
            style: GoogleFonts.roboto(
              fontSize: 18,
              fontWeight: FontWeight.w400,
              fontStyle: FontStyle.italic,
              color: Colors.white,
            ),
          ),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Colors.blue[700]!,
                Colors.blue[100]!,
              ],
              tileMode: TileMode.decal,
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(15),
            boxShadow: const [
              BoxShadow(
                color: Colors.black,
                blurRadius: 0.5,
                blurStyle: BlurStyle.normal,
                offset: Offset(0, 3),
              )
            ],
          ),
          arrowColor: Colors.black,
        ),
        if (hasLogout)
          Positioned(
            top: 16.0,
            right: 16.0,
            child: IconButton(
              icon: Icon(
                Icons.logout,
                color: Colors.blue[900]!,
              ),
              onPressed: onLogout,
            ),
          ),
      ],
    );
  }
}
/* 
userAccountDrawerHeader({
  required String username,
  required String email,
  required String profileURL,
  bool hasLogout = false,
  void Function()? onLogout,
}) {
  return Stack(
    children: [
      UserAccountsDrawerHeader(
        currentAccountPicture: CircleAvatar(
          backgroundColor: Colors.blue[100],
          child: ClipOval(
            child: CachedNetworkImage(
              imageUrl: profileURL,
              placeholder: (context, url) => const Loading(),
              errorWidget: (context, url, error) =>
                  AppImages.defaultProfilePicture,
              fit: BoxFit.contain,
            ),
          ),
        ),
        accountName: Text(
          username,
          style: GoogleFonts.roboto(
            fontSize: 20,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        margin: const EdgeInsets.all(8.0),
        accountEmail: Text(
          email,
          style: GoogleFonts.roboto(
            fontSize: 18,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.italic,
            color: Colors.white,
          ),
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.blue[700]!,
              Colors.blue[100]!,
            ],
            tileMode: TileMode.decal,
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: const [
            BoxShadow(
              color: Colors.black,
              blurRadius: 0.5,
              blurStyle: BlurStyle.normal,
              offset: Offset(0, 3),
            )
          ],
        ),
        arrowColor: Colors.black,
      ),
      if (hasLogout)
        Positioned(
          top: 16.0,
          right: 16.0,
          child: IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.blue[900]!,
            ),
            onPressed: onLogout,
          ),
        ),
    ],
  );
}
 */